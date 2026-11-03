import 'package:drift/drift.dart';

import '../../../core/domain/money.dart';
import '../../accounts/data/accounts_repository.dart';
import '../../accounts/domain/ledger.dart';
import '../../onboarding/data/app_database.dart';
import '../domain/entry_rules.dart';

class TransactionsRepository {
  TransactionsRepository(this.db, {DateTime Function()? clock})
    : now = clock ?? DateTime.now;
  final AppDatabase db;
  final DateTime Function() now;

  void _key(String key) {
    if (key.trim().isEmpty || key.length > 128) {
      throw ArgumentError('Invalid request key');
    }
  }

  Stream<List<Category>> watchCategories() => (db.select(
    db.categories,
  )..orderBy([(c) => OrderingTerm.asc(c.id)])).watch();
  Stream<List<CashEntry>> watchEntries() => (db.select(
    db.cashEntries,
  )..orderBy([(e) => OrderingTerm.asc(e.id)])).watch();

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
