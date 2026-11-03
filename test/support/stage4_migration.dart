import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadgaly/features/accounts/data/accounts_repository.dart';
import 'package:hadgaly/features/accounts/domain/ledger.dart';
import 'package:hadgaly/features/onboarding/data/app_database.dart';
import 'package:hadgaly/features/transactions/data/transactions_repository.dart';

Future<void> verifyStage3Migration(Uint8List bytes) async {
  final dir = await Directory.systemTemp.createTemp('hadgaly-v3-fixture-');
  final file = File('${dir.path}/copy.sqlite');
  await file.writeAsBytes(bytes, flush: true);
  const tables = [
    'accounts',
    'profiles',
    'categories',
    'ledger_sequences',
    'cash_entries',
    'balance_adjustments',
    'adjustment_edits',
  ];
  final before = <String, List<Map<String, Object?>>>{};
  var db = AppDatabase(
    NativeDatabase(
      file,
      setup: (raw) {
        expect(raw.select('PRAGMA user_version').single['user_version'], 3);
        for (final table in tables) {
          before[table] = raw
              .select('SELECT * FROM $table ORDER BY id')
              .map((r) => Map<String, Object?>.from(r))
              .toList();
        }
      },
    ),
  );
  try {
    var s = await AccountsRepository(db).snapshot();
    expect(s.accounts.map((a) => a.balance), [750, -505]);
    expect(s.defaultId, 2);
    expect((await db.loadProfile()).completed, isTrue);
    expect((await db.loadProfile()).nickname, 'Туршилт v2');
    expect(s.entries, hasLength(3));
    expect(await db.select(db.entryRevisions).get(), isEmpty);
    expect(
      (await db.customSelect('PRAGMA user_version').getSingle()).read<int>(
        'user_version',
      ),
      4,
    );
    for (final table in tables) {
      expect(
        (await db.customSelect('SELECT * FROM $table ORDER BY id').get())
            .map((r) => r.data)
            .toList(),
        before[table],
        reason: table,
      );
    }
    final old = s.entries.singleWhere((e) => e.kind == 'income');
    final repo = TransactionsRepository(
      db,
      clock: () => DateTime(2026, 11, 3, 12),
    );
    await repo.edit(
      id: old.id,
      expectedRevision: 0,
      kind: EventKind.income,
      amount: '100',
      accountId: old.accountId,
      categoryId: old.categoryId,
      date: DateTime.parse(old.entryDate),
      note: old.note,
      requestKey: 'migration-edit',
    );
    s = await AccountsRepository(db).snapshot();
    expect(s.byId(1).balance, 750);
    expect(s.byId(1).adjustments.last.originalDifference, -100);
    expect((await repo.load(old.id)).revision, 1);
    await repo.delete(
      id: old.id,
      expectedRevision: 1,
      requestKey: 'migration-delete',
    );
    await db.close();
    db = AppDatabase(NativeDatabase(file));
    s = await AccountsRepository(db).snapshot();
    expect(s.accounts.map((a) => a.balance), [750, -505]);
    expect(s.entries, hasLength(2));
    expect(await db.select(db.entryRevisions).get(), hasLength(2));
    expect((await TransactionsRepository(db).load(old.id)).deleted, isTrue);
    for (final table in tables) {
      expect(
        (await db.customSelect('SELECT * FROM $table ORDER BY id').get())
            .map((r) => r.data)
            .toList(),
        before[table],
        reason: 'immutable originals after edit/delete: $table',
      );
    }
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
  } finally {
    await db.close();
    await dir.delete(recursive: true);
  }
}
