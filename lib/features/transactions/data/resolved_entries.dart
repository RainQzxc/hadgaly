import 'package:drift/drift.dart';

import '../../onboarding/data/app_database.dart';

class EntryState {
  const EntryState(this.entry, this.revision, this.deleted);
  final CashEntry entry;
  final int revision;
  final bool deleted;
}

/// Shared by account replay and history; originals/versions never double count.
Future<List<EntryState>> resolveEntries(AppDatabase db) async {
  final originals = await db.select(db.cashEntries).get();
  final versions = await (db.select(
    db.entryRevisions,
  )..orderBy([(r) => OrderingTerm.asc(r.revision)])).get();
  final latest = {for (final version in versions) version.entryId: version};
  return [
    for (final original in originals)
      if (latest[original.id] case final version?)
        EntryState(
          original.copyWith(
            accountId: version.accountId,
            categoryId: version.categoryId,
            kind: version.kind,
            amount: version.amount,
            effectiveAt: version.effectiveAt,
            entryDate: version.entryDate,
            note: version.note,
          ),
          version.revision,
          version.deleted,
        )
      else
        EntryState(original, 0, false),
  ];
}
