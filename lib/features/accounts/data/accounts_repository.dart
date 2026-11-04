import 'package:drift/drift.dart';

import '../../../core/domain/money.dart';
import '../../onboarding/data/app_database.dart';
import '../domain/ledger.dart';
import '../../transactions/data/resolved_entries.dart';

class AdjustmentView {
  const AdjustmentView(this.record, this.point, this.edits);
  final BalanceAdjustment record;
  final LedgerPoint point;
  final List<AdjustmentEdit> edits;
  int get originalDifference =>
      record.originalTarget - record.observedBalanceBefore;
}

class AccountView {
  const AccountView(this.account, this.ledger, this.adjustments);
  final Account account;
  final LedgerResult ledger;
  final List<AdjustmentView> adjustments;
  int get balance => ledger.balance;
}

class AccountsSnapshot {
  const AccountsSnapshot(
    this.accounts,
    this.defaultId, {
    this.entries = const [],
    this.categories = const [],
  });
  final List<AccountView> accounts;
  final int? defaultId;
  final List<CashEntry> entries;
  final List<Category> categories;
  AccountView get defaultAccount =>
      accounts.firstWhere((a) => a.account.id == defaultId);
  AccountView byId(int id) => accounts.firstWhere((a) => a.account.id == id);
}

class AccountsRepository {
  AccountsRepository(this.db, {int Function()? clock})
    : now = clock ?? (() => DateTime.now().toUtc().microsecondsSinceEpoch);
  final AppDatabase db;
  final int Function() now;

  Future<AccountsSnapshot> snapshot() => db.transaction(() async {
    final profile = await db.select(db.profiles).getSingle();
    final accounts = await (db.select(
      db.accounts,
    )..orderBy([(a) => OrderingTerm.asc(a.id)])).get();
    final adjustments = await db.select(db.balanceAdjustments).get();
    final cash = (await resolveEntries(db))
        .where((s) => !s.deleted)
        .map((s) => s.entry)
        .toList();
    final edits = await (db.select(
      db.adjustmentEdits,
    )..orderBy([(e) => OrderingTerm.asc(e.id)])).get();
    return AccountsSnapshot(
      List.unmodifiable(
        accounts.map((a) {
          final records = adjustments
              .where((r) => r.accountId == a.id)
              .toList();
          final ledger = replayLedger(a.openingBalance, [
            ...records.map(_event),
            ...cash.where((r) => r.accountId == a.id).map(_cashEvent),
          ]);
          final bySequence = {for (final r in records) r.id: r};
          final history = ledger.points.reversed
              .where((p) => p.event.kind == EventKind.adjustment)
              .map((point) {
                final record = bySequence[point.event.sequence]!;
                return AdjustmentView(
                  record,
                  point,
                  List.unmodifiable(
                    edits.where((e) => e.adjustmentId == record.id),
                  ),
                );
              })
              .toList();
          return AccountView(a, ledger, List.unmodifiable(history));
        }),
      ),
      profile.defaultAccountId,
      entries: List.unmodifiable(cash),
      categories: List.unmodifiable(await db.select(db.categories).get()),
    );
  });

  Stream<AccountsSnapshot> watch() => db
      .customSelect(
        'SELECT 1',
        readsFrom: {
          db.accounts,
          db.profiles,
          db.balanceAdjustments,
          db.adjustmentEdits,
          db.cashEntries,
          db.entryRevisions,
          db.categories,
        },
      )
      .watch()
      .asyncMap((_) => snapshot());

  LedgerEvent _event(BalanceAdjustment r) => LedgerEvent(
    sequence: r.id,
    effectiveAt: r.effectiveAt,
    kind: EventKind.adjustment,
    amount: r.target,
    originalDifference: r.originalTarget - r.observedBalanceBefore,
  );

  LedgerEvent _cashEvent(CashEntry r) => LedgerEvent(
    sequence: r.id,
    effectiveAt: r.effectiveAt,
    kind: r.kind == 'income' ? EventKind.income : EventKind.expense,
    amount: r.amount,
  );

  Future<LedgerResult> ledgerFor(int accountId) async {
    final account = await _account(accountId);
    final anchors = await (db.select(
      db.balanceAdjustments,
    )..where((a) => a.accountId.equals(accountId))).get();
    final entries = (await resolveEntries(db))
        .where((s) => !s.deleted && s.entry.accountId == accountId)
        .map((s) => s.entry);
    return replayLedger(account.openingBalance, [
      ...anchors.map(_event),
      ...entries.map(_cashEvent),
    ]);
  }

  Future<Account> _account(int id) async {
    final account = await (db.select(
      db.accounts,
    )..where((a) => a.id.equals(id))).getSingleOrNull();
    if (account == null) throw const FormatException('Данс олдсонгүй.');
    return account;
  }

  void _key(String key) {
    if (key.trim().isEmpty || key.length > 128) {
      throw ArgumentError('Invalid request key');
    }
  }

  Future<int> createAccount(
    String name,
    String balance,
    String requestKey,
  ) async {
    final validName = validateName(name, label: 'Дансны нэр');
    final amount = parseMnt(balance);
    _key(requestKey);
    return db.transaction(() async {
      final existing = await (db.select(
        db.accounts,
      )..where((a) => a.creationKey.equals(requestKey))).getSingleOrNull();
      if (existing != null) {
        if (existing.name != validName || existing.openingBalance != amount) {
          throw StateError('Request key reused');
        }
        return existing.id;
      }
      return db
          .into(db.accounts)
          .insert(
            AccountsCompanion.insert(
              name: validName,
              openingBalance: amount,
              creationKey: Value(requestKey),
            ),
          );
    });
  }

  Future<void> renameAccount(int id, String name) async {
    final validName = validateName(name, label: 'Дансны нэр');
    await db.transaction(() async {
      await _account(id);
      await (db.update(db.accounts)..where((a) => a.id.equals(id))).write(
        AccountsCompanion(name: Value(validName)),
      );
    });
  }

  Future<void> selectDefault(int id) => db.transaction(() async {
    await _account(id);
    final changed = await (db.update(db.profiles)..where((p) => p.id.equals(1)))
        .write(ProfilesCompanion(defaultAccountId: Value(id)));
    if (changed != 1) throw StateError('Missing local profile');
  });

  Future<int> adjustBalance(
    int accountId,
    String target,
    String requestKey,
  ) async {
    final amount = parseMnt(target);
    _key(requestKey);
    return db.transaction(() async {
      final existing = await (db.select(
        db.balanceAdjustments,
      )..where((a) => a.requestKey.equals(requestKey))).getSingleOrNull();
      if (existing != null) {
        if (existing.accountId != accountId ||
            existing.originalTarget != amount) {
          throw StateError('Request key reused');
        }
        return existing.id;
      }
      final ledger = await ledgerFor(accountId);
      final before = ledger.balance;
      final createdAt = now();
      var effectiveAt = createdAt;
      for (final point in ledger.points) {
        if (point.event.effectiveAt > effectiveAt) {
          effectiveAt = point.event.effectiveAt;
        }
      }
      final sequence = await db.allocateSequence('adjustment');
      return db
          .into(db.balanceAdjustments)
          .insert(
            BalanceAdjustmentsCompanion.insert(
              id: Value(sequence),
              accountId: accountId,
              target: amount,
              effectiveAt: effectiveAt,
              createdAt: createdAt,
              originalTarget: amount,
              observedBalanceBefore: before,
              requestKey: requestKey,
            ),
          );
    });
  }

  Future<void> editAdjustment(
    int id,
    String target,
    int expectedRevision,
    String requestKey,
  ) async {
    final amount = parseMnt(target);
    _key(requestKey);
    await db.transaction(() async {
      final retry = await (db.select(
        db.adjustmentEdits,
      )..where((e) => e.requestKey.equals(requestKey))).getSingleOrNull();
      if (retry != null) {
        if (retry.adjustmentId != id ||
            retry.newTarget != amount ||
            retry.previousRevision != expectedRevision) {
          throw StateError('Request key reused');
        }
        return;
      }
      final record = await (db.select(
        db.balanceAdjustments,
      )..where((a) => a.id.equals(id))).getSingle();
      if (record.revision != expectedRevision) {
        throw const FormatException(
          'Дүн өөрчлөгдсөн байна. Дахин нээгээд шалгаарай.',
        );
      }
      if (record.target == amount) return;
      await db
          .into(db.adjustmentEdits)
          .insert(
            AdjustmentEditsCompanion.insert(
              adjustmentId: id,
              oldTarget: record.target,
              newTarget: amount,
              editedAt: now(),
              previousRevision: record.revision,
              requestKey: requestKey,
            ),
          );
      await (db.update(
        db.balanceAdjustments,
      )..where((a) => a.id.equals(id))).write(
        BalanceAdjustmentsCompanion(
          target: Value(amount),
          revision: Value(record.revision + 1),
        ),
      );
      // Validate replay inside the same transaction. Later anchors stay authoritative.
      await ledgerFor(record.accountId);
    });
  }
}
