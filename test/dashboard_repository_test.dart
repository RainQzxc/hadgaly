import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadgaly/features/accounts/data/accounts_repository.dart';
import 'package:hadgaly/features/accounts/domain/ledger.dart';
import 'package:hadgaly/features/home/data/dashboard_report.dart';
import 'package:hadgaly/features/onboarding/data/app_database.dart';
import 'package:hadgaly/features/transactions/data/transactions_repository.dart';

import 'support/stage5_data.dart';

void main() {
  test('Resolved dashboard tracks date/type/account edits, tombstones and archived taxonomy around anchors', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime(2027, 1, 4, 12), prior = DateTime(2026, 12, 31);
    final ids = await seedStage5(db, now);
    final accounts = AccountsRepository(db);
    final repo = TransactionsRepository(db, clock: () => now);
    var s = await accounts.snapshot(),
        r = dashboardReport(await accounts.snapshot(), now);
    final original = (await db.select(db.balanceAdjustments).get()).single
        .toJson();
    expect(r.balance, BigInt.from(375));
    expect(r.net, BigInt.from(125));
    expect(r.categories.map((c) => (c.amount, c.tenths)), [
      (BigInt.from(50), 667),
      (BigInt.from(25), 333),
    ]);
    expect(s.categories.singleWhere((c) => c.id == ids.food).archived, isTrue);
    await repo.edit(
      id: ids.expense,
      expectedRevision: 0,
      kind: EventKind.expense,
      amount: '80',
      accountId: ids.card,
      categoryId: ids.food,
      date: prior,
      requestKey: 's5-move',
    );
    s = await accounts.snapshot();
    r = dashboardReport(s, now);
    expect(s.byId(1).balance, 900);
    expect(s.byId(ids.card).balance, -605);
    expect(r.current.expense, BigInt.from(25));
    expect(r.previous.expense, BigInt.from(180));
    expect(r.balance, BigInt.from(295));
    await repo.edit(
      id: ids.expense,
      expectedRevision: 1,
      kind: EventKind.income,
      amount: '80',
      accountId: ids.card,
      categoryId: ids.income,
      date: prior,
      requestKey: 's5-type',
    );
    r = dashboardReport(await accounts.snapshot(), now);
    expect(r.previous.income, BigInt.from(180));
    expect(r.previous.expense, BigInt.from(100));
    expect(r.balance, BigInt.from(455));
    await repo.delete(
      id: ids.currentIncome,
      expectedRevision: 0,
      requestKey: 's5-delete',
    );
    s = await accounts.snapshot();
    r = dashboardReport(s, now);
    expect(r.current.income, BigInt.zero);
    expect(r.net, BigInt.from(-25));
    expect(r.balance, BigInt.from(455));
    expect(r.categories.single.id, ids.cart);
    expect(
      (await db.select(db.balanceAdjustments).get()).single.toJson(),
      original,
    );
    expect(s.byId(1).adjustments.single.originalDifference, -250);
    expect(s.byId(1).adjustments.single.point.difference, -100);
    expect(await db.select(db.entryRevisions).get(), hasLength(3));
    expect(
      await db
          .customSelect('PRAGMA user_version')
          .getSingle()
          .then((r) => r.read<int>('user_version')),
      4,
    );
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
  });
  test('Category rename/archive and default selection refresh the coherent read stream', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime(2027, 1, 4);
    final ids = await seedStage5(db, now);
    final repo = TransactionsRepository(db);
    final accounts = AccountsRepository(db);
    final iterator = StreamIterator(accounts.watch());
    addTearDown(iterator.cancel);
    expect(await iterator.moveNext(), isTrue);
    await repo.saveCategory(
      id: ids.cart,
      kind: EventKind.expense,
      name: 'Өдөр тутмын хүнс',
      icon: 'cart',
      requestKey: 'rename',
    );
    expect(await iterator.moveNext(), isTrue);
    final s = iterator.current;
    expect(
      s.categories.singleWhere((c) => c.id == ids.cart).name,
      'Өдөр тутмын хүнс',
    );
    expect(s.defaultId, ids.card);
    expect(dashboardReport(s, now).current.expense, BigInt.from(75));
    await repo.archiveCategory(ids.cart);
    expect(await iterator.moveNext(), isTrue);
    expect(
      iterator.current.categories.singleWhere((c) => c.id == ids.cart).archived,
      isTrue,
    );
    await accounts.selectDefault(1);
    expect(await iterator.moveNext(), isTrue);
    expect(iterator.current.defaultId, 1);
    expect(dashboardReport(iterator.current, now).balance, BigInt.from(375));
  });
  test('SQLite close/reopen preserves report, original rows and schema without migration', () async {
    final dir = await Directory.systemTemp.createTemp('hadgaly-s5-');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/synthetic.sqlite');
    var db = AppDatabase(NativeDatabase(file));
    final now = DateTime(2027, 1, 4);
    await seedStage5(db, now);
    final before = dashboardReport(
      await AccountsRepository(db).snapshot(),
      now,
    );
    await db.close();
    db = AppDatabase(NativeDatabase(file));
    try {
      final s = await AccountsRepository(db).snapshot(),
          after = dashboardReport(await AccountsRepository(db).snapshot(), now);
      expect(after.balance, before.balance);
      expect(after.current.expense, before.current.expense);
      expect(after.previous.income, before.previous.income);
      expect(
        after.categories.map((s) => (s.id, s.amount, s.tenths)),
        before.categories.map((s) => (s.id, s.amount, s.tenths)),
      );
      expect(s.defaultId, 2);
      expect((await db.loadProfile()).completed, isTrue);
      expect(await db.select(db.cashEntries).get(), hasLength(5));
      expect(await db.select(db.entryRevisions).get(), isEmpty);
    } finally {
      await db.close();
    }
  });
}
