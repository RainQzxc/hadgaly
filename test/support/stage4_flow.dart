import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadgaly/features/accounts/data/accounts_repository.dart';
import 'package:hadgaly/features/accounts/domain/ledger.dart';
import 'package:hadgaly/features/onboarding/data/app_database.dart';
import 'package:hadgaly/features/transactions/data/transactions_repository.dart';
import 'package:hadgaly/features/transactions/presentation/history_screen.dart';

import 'stage3_flow.dart';

Future<void> revealHistory(WidgetTester t, String key) async {
  final list = find.byKey(const Key('historyList'));
  await waitStage3(t, list);
  FocusManager.instance.primaryFocus?.unfocus();
  await t.pumpAndSettle();
  final scroll = find
      .descendant(of: list, matching: find.byType(Scrollable))
      .first;
  t.state<ScrollableState>(scroll).position.jumpTo(0);
  await t.pumpAndSettle();
  await t.scrollUntilVisible(
    find.byKey(Key(key)),
    180,
    scrollable: scroll,
    maxScrolls: 30,
  );
  await t.pumpAndSettle();
}

Future<void> tapHistory(WidgetTester t, String key) async {
  await revealHistory(t, key);
  await tapStage3(t, key);
}

Future<void> searchHistory(WidgetTester t, String value) async {
  await revealHistory(t, 'historySearch');
  await t.enterText(find.byKey(const Key('historySearch')), value);
  await t.pumpAndSettle();
}

Future<void> verifyStage4Flow(WidgetTester t, AppDatabase db) async {
  final now = DateTime.now();
  final accounts = AccountsRepository(
    db,
    clock: () => now.toUtc().microsecondsSinceEpoch,
  );
  final repo = TransactionsRepository(db, clock: () => now);
  final card = await accounts.createAccount('Карт', '-500', 'history-card');
  final cats = await db.select(db.categories).get();
  final income = cats.firstWhere((c) => c.kind == 'income').id;
  final expense = cats.firstWhere((c) => c.kind == 'expense').id;
  await mountStage3(t, db);
  await tapStage3(t, 'incomeAction');
  await t.enterText(find.byKey(const Key('entryAmount')), '200');
  await t.enterText(find.byKey(const Key('entryNote')), 'Цалин');
  await tapStage3(t, 'category-$income');
  await tapStage3(t, 'entrySave');
  await waitStage3(t, find.text('+200 ₮'));
  final id = (await accounts.snapshot()).entries.single.id;
  await repo.archiveCategory(income);
  final old = await repo.post(
    kind: EventKind.expense,
    amount: '50',
    accountId: 1,
    categoryId: expense,
    date: DateTime(now.year, now.month, 0),
    note: 'Өдрийн хоол',
    requestKey: 'old-month',
  );
  final anchor = await accounts.adjustBalance(1, '900', 'history-anchor');
  await tapStage3(t, 'historyAction');
  await revealHistory(t, 'history-entry-$id');
  expect(find.byKey(Key('history-anchor-$anchor')), findsOneWidget);
  expect(find.text('Архивласан ангилал'), findsOneWidget);
  await searchHistory(t, 'ЦАЛИН');
  expect(find.byKey(Key('history-entry-$old')), findsNothing);
  expect(find.byKey(Key('history-anchor-$anchor')), findsNothing);
  await tapHistory(t, 'history-entry-$id');
  expect(find.text('Гүйлгээ засах'), findsOneWidget);
  expect(find.text('Цалин · архив'), findsOneWidget);
  await t.enterText(find.byKey(const Key('entryAmount')), '300');
  await t.enterText(find.byKey(const Key('entryNote')), 'Цалин шинэ');
  await tapStage3(t, 'entryAccount');
  await tapStage3(t, 'entryAccount-$card');
  await tapStage3(t, 'entrySave');
  await revealHistory(t, 'history-entry-$id');
  var s = await accounts.snapshot();
  expect(s.byId(1).balance, 900);
  expect(s.byId(card).balance, -200);
  expect(s.byId(1).adjustments.single.originalDifference, -250);
  expect(s.byId(1).adjustments.single.point.difference, -50);
  await tapHistory(t, 'history-entry-$id');
  await tapStage3(t, 'entryKind-expense');
  await t.enterText(find.byKey(const Key('entryAmount')), '100');
  await t.enterText(find.byKey(const Key('entryNote')), 'Шинэ хоол');
  await tapStage3(t, 'category-$expense');
  await tapStage3(t, 'entrySave');
  // Current search no longer matches the edited note.
  await waitStage3(t, find.text('Тохирох бүртгэл алга.'));
  expect((await accounts.snapshot()).byId(card).balance, -600);
  await searchHistory(t, '');
  await tapHistory(t, 'historyAccount');
  await tapStage3(t, 'filterAccount-$card');
  await revealHistory(t, 'history-entry-$id');
  expect(find.byKey(Key('history-entry-$id')), findsOneWidget);
  expect(find.byKey(Key('history-entry-$old')), findsNothing);
  await searchHistory(t, 'ӨДРИЙН');
  await revealHistory(t, 'historyEmpty');
  expect(find.text('Тохирох бүртгэл алга.'), findsOneWidget);
  await tapHistory(t, 'historyAccount');
  await tapStage3(t, 'filterAccount-all');
  await tapHistory(t, 'historyPeriod');
  await tapStage3(t, 'filterPeriod-previousMonth');
  await revealHistory(t, 'history-entry-$old');
  expect(find.byKey(Key('history-entry-$old')), findsOneWidget);
  await tapHistory(t, 'historyKind-income');
  await revealHistory(t, 'historyEmpty');
  expect(find.text('Тохирох бүртгэл алга.'), findsOneWidget);
  await tapHistory(t, 'historyKind-all');
  await searchHistory(t, '');
  await tapHistory(t, 'historyPeriod');
  await tapStage3(t, 'filterPeriod-all');
  await tapHistory(t, 'history-entry-$id');
  await tapStage3(t, 'deleteEntry');
  await tapStage3(t, 'cancelDelete');
  expect((await repo.load(id)).revision, 2);
  expect((await repo.load(id)).deleted, isFalse);
  await tapStage3(t, 'deleteEntry');
  await tapStage3(t, 'confirmDelete');
  await waitStage3(t, find.byType(HistoryScreen));
  // DB transaction completes before the edit route closes; stream may follow.
  for (
    var i = 0;
    i < 100 && find.byKey(Key('history-entry-$id')).evaluate().isNotEmpty;
    i++
  ) {
    await t.pump(const Duration(milliseconds: 100));
  }
  expect(find.byKey(Key('history-entry-$id')), findsNothing);
  expect((await repo.load(id)).deleted, isTrue);
  expect(await db.select(db.entryRevisions).get(), hasLength(3));
  expect(await db.select(db.cashEntries).get(), hasLength(2));
  await tapHistory(t, 'history-anchor-$anchor');
  expect(find.byKey(Key('editAdjustment-$anchor')), findsOneWidget);
  await tapStage3(t, 'back');
  await tapStage3(t, 'back');
  await waitStage3(t, find.text('400 ₮'));
  expect(find.text('+0 ₮'), findsOneWidget);
  expect(find.text('−0 ₮'), findsOneWidget);
  expect((await accounts.snapshot()).defaultId, 1);
  expect(t.takeException(), isNull);
}
