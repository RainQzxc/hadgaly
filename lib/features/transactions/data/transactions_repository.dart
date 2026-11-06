import 'package:drift/drift.dart';

import '../../../core/domain/money.dart';
import '../../accounts/data/accounts_repository.dart';
import '../../accounts/domain/ledger.dart';
import '../../onboarding/data/app_database.dart';
import '../domain/entry_rules.dart';
import 'resolved_entries.dart';

class TransactionsRepository {
  TransactionsRepository(this.db, {DateTime Function()? clock})
    : now = clock ?? DateTime.now;
  final AppDatabase db;
  final DateTime Function() now;

  Future<EntryState> load(int id) => db.transaction(() async {
    final found = (await resolveEntries(db)).where((s) => s.entry.id == id);
    if (found.isEmpty) throw const FormatException('Гүйлгээ олдсонгүй.');
    return found.single;
  });

  Future<void> edit({
    required int id,
    required int expectedRevision,
    required EventKind kind,
    required String amount,
    required int accountId,
    required int categoryId,
    required DateTime date,
    String note = '',
    required String requestKey,
  }) async {
    final type = entryKind(kind),
        value = parseEntryAmount(amount),
        memo = validateNote(note);
    final selected = dateKey(calendarDay(date));
    _key(requestKey);
    await db.transaction(() async {
      final retry = await (db.select(
        db.entryRevisions,
      )..where((r) => r.requestKey.equals(requestKey))).getSingleOrNull();
      if (retry != null) {
        if (retry.entryId != id ||
            retry.revision != expectedRevision + 1 ||
            retry.deleted ||
            retry.kind != type ||
            retry.amount != value ||
            retry.accountId != accountId ||
            retry.categoryId != categoryId ||
            retry.entryDate != selected ||
            retry.note != memo) {
          throw StateError('Request key reused');
        }
        return;
      }
      final current = await load(id), old = current.entry;
      _editable(current, expectedRevision);
      final changed = now();
      if (selected != old.entryDate) validateEntryDate(date, changed);
      final category = await (db.select(
        db.categories,
      )..where((c) => c.id.equals(categoryId))).getSingleOrNull();
      if (category == null ||
          category.kind != type ||
          (category.archived &&
              (categoryId != old.categoryId || type != old.kind))) {
        throw const FormatException('Идэвхтэй ангилал сонгоорой.');
      }
      final accounts = AccountsRepository(db);
      final destination = await accounts.ledgerFor(accountId);
      final other = destination.points
          .where((p) => p.event.sequence != id)
          .toList();
      final effective = editedEntryEffectiveAt(
        previousDate: old.entryDate,
        previousTime: old.effectiveAt,
        date: date,
        now: changed,
        sequence: id,
        latestOtherTime: other.isEmpty ? 0 : other.last.event.effectiveAt,
        latestOtherSequence: other.isEmpty ? 0 : other.last.event.sequence,
      );
      await db
          .into(db.entryRevisions)
          .insert(
            EntryRevisionsCompanion.insert(
              entryId: id,
              revision: expectedRevision + 1,
              accountId: accountId,
              categoryId: categoryId,
              kind: type,
              amount: value,
              effectiveAt: effective,
              entryDate: selected,
              note: memo,
              changedAt: changed.toUtc().microsecondsSinceEpoch,
              requestKey: requestKey,
            ),
          );
      await accounts.ledgerFor(old.accountId);
      if (accountId != old.accountId) await accounts.ledgerFor(accountId);
    });
  }

  void _editable(EntryState state, int revision) {
    if (state.deleted) throw const FormatException('Энэ гүйлгээ устсан байна.');
    if (state.revision != revision) {
      throw const FormatException(
        'Гүйлгээ өөрчлөгдсөн байна. Дахин нээгээрэй.',
      );
    }
  }

  Future<void> delete({
    required int id,
    required int expectedRevision,
    required String requestKey,
  }) async {
    _key(requestKey);
    await db.transaction(() async {
      final retry = await (db.select(
        db.entryRevisions,
      )..where((r) => r.requestKey.equals(requestKey))).getSingleOrNull();
      if (retry != null) {
        if (retry.entryId != id ||
            retry.revision != expectedRevision + 1 ||
            !retry.deleted) {
          throw StateError('Request key reused');
        }
        return;
      }
      final current = await load(id), entry = current.entry;
      _editable(current, expectedRevision);
      await db
          .into(db.entryRevisions)
          .insert(
            EntryRevisionsCompanion.insert(
              entryId: id,
              revision: expectedRevision + 1,
              accountId: entry.accountId,
              categoryId: entry.categoryId,
              kind: entry.kind,
              amount: entry.amount,
              effectiveAt: entry.effectiveAt,
              entryDate: entry.entryDate,
              note: entry.note,
              deleted: const Value(true),
              changedAt: now().toUtc().microsecondsSinceEpoch,
              requestKey: requestKey,
            ),
          );
      await AccountsRepository(db).ledgerFor(entry.accountId);
    });
  }

  void _key(String key) {
    if (key.trim().isEmpty || key.length > 128) {
      throw ArgumentError('Invalid request key');
    }
  }

  Stream<List<Category>> watchCategories() => (db.select(
    db.categories,
  )..orderBy([(c) => OrderingTerm.asc(c.id)])).watch();
  Stream<List<CashEntry>> watchEntries() => db
      .customSelect('SELECT 1', readsFrom: {db.cashEntries, db.entryRevisions})
      .watch()
      .asyncMap(
        (_) => db.transaction(
          () async =>
              (await resolveEntries(db))
                  .where((s) => !s.deleted)
                  .map((s) => s.entry)
                  .toList(),
        ),
      );

  Future<int> saveCategory({
    int? id,
    required EventKind kind,
    required String name,
    required String icon,
    required String requestKey,
  }) async {
    final type = entryKind(kind),
        valid = validateName(name, label: 'Ангиллын нэр');
    if (!categoryIcons.contains(icon)) {
      throw const FormatException('Дүрсээ сонгоорой.');
    }
    _key(requestKey);
    return db.transaction(() async {
      if (id == null) {
        final existing = await (db.select(
          db.categories,
        )..where((c) => c.creationKey.equals(requestKey))).getSingleOrNull();
        if (existing != null) {
          if (existing.name != valid ||
              existing.kind != type ||
              existing.icon != icon) {
            throw StateError('Request key reused');
          }
          return existing.id;
        }
      } else {
        final existing = await (db.select(
          db.categories,
        )..where((c) => c.id.equals(id))).getSingle();
        if (existing.kind != type) {
          throw const FormatException('Ангиллын төрлийг өөрчлөхгүй.');
        }
      }
      final duplicate =
          await (db.select(db.categories)..where(
                (c) =>
                    c.kind.equals(type) &
                    c.normalizedName.equals(valid.toLowerCase()) &
                    c.archived.equals(false),
              ))
              .getSingleOrNull();
      if (duplicate != null && duplicate.id != id) {
        throw const FormatException('Ийм нэртэй ангилал байна.');
      }
      if (id == null) {
        return db
            .into(db.categories)
            .insert(
              CategoriesCompanion.insert(
                kind: type,
                name: valid,
                normalizedName: valid.toLowerCase(),
                icon: icon,
                creationKey: requestKey,
              ),
            );
      }
      await (db.update(db.categories)..where((c) => c.id.equals(id))).write(
        CategoriesCompanion(
          name: Value(valid),
          normalizedName: Value(valid.toLowerCase()),
          icon: Value(icon),
        ),
      );
      return id;
    });
  }

  Future<void> archiveCategory(int id) => db.transaction(() async {
    final c = await (db.select(
      db.categories,
    )..where((c) => c.id.equals(id))).getSingle();
    if (!c.archived) {
      await (db.update(db.categories)..where((c) => c.id.equals(id))).write(
        const CategoriesCompanion(archived: Value(true)),
      );
    }
  });

  Future<int> post({
    required EventKind kind,
    required String amount,
    required int accountId,
    required int categoryId,
    required DateTime date,
    String note = '',
    required String requestKey,
  }) async {
    final type = entryKind(kind),
        value = parseEntryAmount(amount),
        memo = validateNote(note);
    // Validate future dates only after a matching retry has had a chance to return;
    // a clock change must not turn a committed operation into a second posting.
    final selected = dateKey(calendarDay(date));
    _key(requestKey);
    return db.transaction(() async {
      final retry = await (db.select(
        db.cashEntries,
      )..where((e) => e.requestKey.equals(requestKey))).getSingleOrNull();
      if (retry != null) {
        if (retry.kind != type ||
            retry.amount != value ||
            retry.accountId != accountId ||
            retry.categoryId != categoryId ||
            retry.note != memo ||
            retry.entryDate != selected) {
          throw StateError('Request key reused');
        }
        return retry.id;
      }
      final created = now();
      validateEntryDate(date, created);
      final category = await (db.select(
        db.categories,
      )..where((c) => c.id.equals(categoryId))).getSingleOrNull();
      if (category == null || category.archived || category.kind != type) {
        throw const FormatException('Идэвхтэй ангилал сонгоорой.');
      }
      final accounts = AccountsRepository(db);
      final ledger = await accounts.ledgerFor(accountId);
      final latest = ledger.points.isEmpty
          ? 0
          : ledger.points.last.event.effectiveAt;
      final sequence = await db.allocateSequence(type);
      await db
          .into(db.cashEntries)
          .insert(
            CashEntriesCompanion.insert(
              id: Value(sequence),
              accountId: accountId,
              categoryId: categoryId,
              kind: type,
              amount: value,
              effectiveAt: entryEffectiveAt(date, created, latest),
              createdAt: created.toUtc().microsecondsSinceEpoch,
              entryDate: selected,
              note: Value(memo),
              requestKey: requestKey,
            ),
          );
      await accounts.ledgerFor(
        accountId,
      ); // Reject any intermediate/current overflow atomically.
      return sequence;
    });
  }
}
