import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadgaly/features/accounts/data/accounts_repository.dart';
import 'package:hadgaly/features/accounts/domain/ledger.dart';
import 'package:hadgaly/features/onboarding/data/app_database.dart';
import 'package:hadgaly/features/transactions/data/transactions_repository.dart';

/// Only a copy of the preserved synthetic fixture is ever opened for migration.
Future<void> verifyStage2Migration(Uint8List bytes) async {
  final directory = await Directory.systemTemp.createTemp(
    'hadgaly-v2-fixture-',
  );
  final file = File('${directory.path}/copy.sqlite');
  await file.writeAsBytes(bytes, flush: true);
  const tables = [
    'accounts',
    'profiles',
    'balance_adjustments',
    'adjustment_edits',
  ];
  final before = <String, List<Map<String, Object?>>>{};
  var db = AppDatabase(
    NativeDatabase(
      file,
      setup: (raw) {
        expect(raw.select('PRAGMA user_version').single['user_version'], 2);
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
    final accounts = AccountsRepository(db);
    final s = await accounts.snapshot();
    expect(s.accounts.map((a) => a.balance), [800, -500]);
    expect(s.defaultId, 2);
    final profile = await db.loadProfile();
    expect(profile.nickname, 'Туршилт v2');
    expect(profile.completed, isTrue);
    expect(profile.step, 4);
    for (final table in tables) {
      expect(
        (await db.customSelect('SELECT * FROM $table ORDER BY id').get())
            .map((r) => r.data)
            .toList(),
        before[table],
        reason: table,
      );
    }
    expect(
      (await db.customSelect('PRAGMA user_version').getSingle()).read<int>(
        'user_version',
      ),
      4,
    );
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
    expect(await db.select(db.cashEntries).get(), isEmpty);
    expect(await db.select(db.categories).get(), hasLength(10));
    final a = s.byId(1).adjustments.singleWhere((a) => a.record.id == 1);
    expect(a.originalDifference, -100);
    expect(a.point.difference, -50);
    expect(a.edits.single.oldTarget, 900);
    expect(a.edits.single.newTarget, 950);
    expect(s.byId(1).adjustments.first.point.difference, -150);
    expect((await db.select(db.ledgerSequences).get()).map((s) => s.id), [
      1,
      2,
    ]);
    await db.close();
    db = AppDatabase(NativeDatabase(file));
    expect(
      (await AccountsRepository(db).snapshot()).accounts.map((a) => a.balance),
      [800, -500],
    );
    final now = DateTime(2026, 11, 3, 12);
    final category = (await db.select(db.categories).get()).firstWhere(
      (c) => c.kind == 'income',
    );
    final id = await TransactionsRepository(db, clock: () => now).post(
      kind: EventKind.income,
      amount: '100',
      accountId: 1,
      categoryId: category.id,
      date: now,
      requestKey: 'after-migration',
    );
    expect(id, 3);
    final anchor = await AccountsRepository(
      db,
      clock: () => now.toUtc().microsecondsSinceEpoch,
    ).adjustBalance(1, '850', 'after-migration-anchor');
    expect(anchor, 4);
    expect((await AccountsRepository(db).snapshot()).byId(1).balance, 850);
    // Old immutable observations and audits still match after new postings.
    expect(
      (await db
              .customSelect(
                'SELECT * FROM balance_adjustments WHERE id<=2 ORDER BY id',
              )
              .get())
          .map((r) => r.data)
          .toList(),
      before['balance_adjustments'],
    );
    expect(
      (await db
              .customSelect('SELECT * FROM adjustment_edits ORDER BY id')
              .get())
          .map((r) => r.data)
          .toList(),
      before['adjustment_edits'],
    );
  } finally {
    await db.close();
    await directory.delete(recursive: true);
  }
}
