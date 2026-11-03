import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadgaly/app.dart';
import 'package:hadgaly/features/accounts/data/accounts_repository.dart';
import 'package:hadgaly/features/onboarding/application/onboarding_controller.dart';
import 'package:hadgaly/features/onboarding/data/app_database.dart';

Future<void> mountStage3(WidgetTester t, AppDatabase db) async {
  await t.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const HadgalyApp(),
    ),
  );
  await t.pumpAndSettle();
}

Future<void> tapStage3(WidgetTester t, String key) async {
  await readyStage3(t, key);
  await t.tap(find.byKey(Key(key)));
  await t.pumpAndSettle();
}

Future<void> readyStage3(WidgetTester t, String key) async {
  final f = find.byKey(Key(key));
  await waitStage3(t, f);
  for (var attempt = 0; attempt < 100; attempt++) {
    final route = ModalRoute.of(t.element(f));
    bool moving(Animation<double>? animation) =>
        animation?.status == AnimationStatus.forward ||
        animation?.status == AnimationStatus.reverse;
    if (!moving(route?.animation) && !moving(route?.secondaryAnimation)) break;
    await t.pump(const Duration(milliseconds: 100));
  }
  if (find
      .byType(EditableText)
      .evaluate()
      .any((e) => (e.widget as EditableText).focusNode.hasFocus)) {
    // Finish editing before scrolling to a selection or Save; ensureVisible
    // does not trigger the scroll view's onDrag keyboard dismissal.
    FocusManager.instance.primaryFocus?.unfocus();
    await t.pump(const Duration(milliseconds: 400));
    await t.pumpAndSettle();
  }
  await t.ensureVisible(f);
  await t.pumpAndSettle();
  await waitStage3(t, f.hitTestable());
}

Future<void> waitStage3(WidgetTester t, Finder finder) async {
  // Native SQLite streams finish outside Flutter's scheduled-frame queue.
  // pumpAndSettle alone can return before the updated snapshot arrives.
  for (var attempt = 0; attempt < 100 && finder.evaluate().isEmpty; attempt++) {
    await t.pump(const Duration(milliseconds: 100));
  }
  if (finder.evaluate().isEmpty) {
    debugPrint(
      'Synthetic UI diagnostic: ${find.byType(Text).evaluate().map((e) => (e.widget as Text).data).whereType<String>().toList()}',
    );
    debugPrint(
      'Synthetic field diagnostic: ${find.byType(CupertinoTextField).evaluate().map((e) => (e.widget as CupertinoTextField).controller?.text).toList()}',
    );
  }
  expect(finder, findsOneWidget);
}

/// Synthetic UI scenario shared by widget and native sandbox tests.
Future<void> verifyStage3Flow(WidgetTester t, AppDatabase db) async {
  final accounts = AccountsRepository(db);
  final card = await accounts.createAccount('Карт', '-500', 'test-card');
  await accounts.selectDefault(card);
  await mountStage3(t, db);
  final categories = await db.select(db.categories).get();
  final income = categories.firstWhere((c) => c.kind == 'income').id;
  final expense = categories.firstWhere((c) => c.kind == 'expense').id;
  await tapStage3(t, 'incomeAction');
  expect(find.text('Орлого нэмэх'), findsOneWidget);
  expect(
    find.descendant(
      of: find.byKey(const Key('entryAccount')),
      matching: find.text('Карт'),
    ),
    findsOneWidget,
  );
  await t.enterText(find.byKey(const Key('entryAmount')), '0');
  await tapStage3(t, 'entrySave');
  expect(await db.select(db.cashEntries).get(), isEmpty);
  await t.enterText(find.byKey(const Key('entryAmount')), '1000000000000');
  await tapStage3(t, 'entrySave');
  expect(await db.select(db.cashEntries).get(), isEmpty);
  await t.enterText(find.byKey(const Key('entryAmount')), '200');
  await tapStage3(t, 'category-$income');
  await t.enterText(find.byKey(const Key('entryNote')), 'Цалин');
  await readyStage3(t, 'entrySave');
  await t.tap(find.byKey(const Key('entrySave')));
  await t.tap(find.byKey(const Key('entrySave')), warnIfMissed: false);
  await t.pumpAndSettle();
  await waitStage3(t, find.text('+200 ₮'));
  expect(await db.select(db.cashEntries).get(), hasLength(1));
  expect((await accounts.snapshot()).byId(card).balance, -300);
  await tapStage3(t, 'expenseAction');
  expect(find.text('Зарлага нэмэх'), findsOneWidget);
  await t.enterText(find.byKey(const Key('entryAmount')), '50');
  await tapStage3(t, 'category-$expense');
  await tapStage3(t, 'entryAccount');
  await tapStage3(t, 'entryAccount-1');
  await tapStage3(t, 'entryDate');
  expect(find.byType(CupertinoDatePicker), findsOneWidget);
  await tapStage3(t, 'dateDone');
  await tapStage3(t, 'entrySave');
  await waitStage3(t, find.text('−50 ₮'));
  expect((await accounts.snapshot()).byId(1).balance, 950);
  expect(find.text('650 ₮'), findsOneWidget);
  // Canceling unsaved input never creates a record.
  await tapStage3(t, 'expenseAction');
  await t.enterText(find.byKey(const Key('entryAmount')), '999');
  await tapStage3(t, 'back');
  expect(await db.select(db.cashEntries).get(), hasLength(2));
  // Create/edit/icon/archive a category without touching posted money.
  await tapStage3(t, 'expenseAction');
  await tapStage3(t, 'manageCategories');
  await tapStage3(t, 'addCategory');
  await t.enterText(find.byKey(const Key('categoryName')), 'Ном');
  await tapStage3(t, 'icon-book');
  await tapStage3(t, 'categorySave');
  await waitStage3(t, find.byKey(const Key('addCategory')));
  var custom = (await db.select(db.categories).get()).singleWhere(
    (c) => c.name == 'Ном',
  );
  await tapStage3(t, 'manageCategory-${custom.id}');
  await t.enterText(find.byKey(const Key('categoryName')), 'Ном, соёл');
  await tapStage3(t, 'icon-gift');
  await tapStage3(t, 'categorySave');
  await tapStage3(t, 'back');
  await t.enterText(find.byKey(const Key('entryAmount')), '25');
  await tapStage3(t, 'category-${custom.id}');
  await tapStage3(t, 'entrySave');
  await tapStage3(t, 'expenseAction');
  await tapStage3(t, 'manageCategories');
  await tapStage3(t, 'manageCategory-${custom.id}');
  await tapStage3(t, 'archiveCategory');
  expect(find.text('Архивласан'), findsOneWidget);
  await tapStage3(t, 'back');
  expect(find.byKey(Key('category-${custom.id}')), findsNothing);
  await tapStage3(t, 'back');
  custom = (await db.select(db.categories).get()).singleWhere(
    (c) => c.id == custom.id,
  );
  expect(custom.archived, isTrue);
  expect(custom.icon, 'gift');
  expect((await db.select(db.cashEntries).get()).last.categoryId, custom.id);
  expect((await accounts.snapshot()).byId(card).balance, -325);
  await waitStage3(t, find.text('−75 ₮'));
  expect(find.text('625 ₮'), findsOneWidget);
  expect(t.takeException(), isNull);
}
