import 'package:drift/native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadgaly/features/accounts/domain/ledger.dart';
import 'package:hadgaly/features/accounts/data/accounts_repository.dart';
import 'package:hadgaly/features/onboarding/data/app_database.dart';
import 'package:hadgaly/features/transactions/data/transactions_repository.dart';

import 'support/stage3_flow.dart';

void main() {
  late AppDatabase db;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.loadProfile();
    await db.createFirstAccount('Туршилт', 'Хэтэвч', '1000');
    await db.completeOnboarding();
  });
  tearDown(() => db.close());
  testWidgets(
    'Home separates past-month activity, openings and anchor targets from current flow',
    (t) async {
      final now = DateTime.now();
      final entries = TransactionsRepository(db, clock: () => now);
      final accounts = AccountsRepository(
        db,
        clock: () => now.toUtc().microsecondsSinceEpoch,
      );
      final categories = await db.select(db.categories).get();
      await entries.post(
        kind: EventKind.income,
        amount: '500',
        accountId: 1,
        categoryId: categories.firstWhere((c) => c.kind == 'income').id,
        date: DateTime(now.year, now.month, 0),
        requestKey: 'old-month',
      );
      final anchor = await accounts.adjustBalance(1, '900', 'anchor');
      await mountStage3(t, db);
      expect(find.text('+0 ₮'), findsOneWidget);
      expect(find.text('−0 ₮'), findsOneWidget);
      expect(
        t.widget<Text>(find.byKey(const Key('homeBalance'))).data,
        '900 ₮',
      );
      expect(find.text('Энэ сард гүйлгээ бүртгэгдээгүй.'), findsOneWidget);
      await entries.post(
        kind: EventKind.expense,
        amount: '50',
        accountId: 1,
        categoryId: categories.firstWhere((c) => c.kind == 'expense').id,
        date: now,
        requestKey: 'current-month',
      );
      await waitStage3(
        t,
        find.byWidgetPredicate(
          (w) =>
              w is Text &&
              w.key == const Key('homeBalance') &&
              w.data == '850 ₮',
        ),
      );
      expect(find.text('−50 ₮'), findsOneWidget);
      await accounts.editAdjustment(anchor, '950', 0, 'anchor-edit');
      await waitStage3(
        t,
        find.byWidgetPredicate(
          (w) =>
              w is Text &&
              w.key == const Key('homeBalance') &&
              w.data == '900 ₮',
        ),
      );
      expect(find.text('+0 ₮'), findsOneWidget);
      expect(find.text('−50 ₮'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
      await t.pumpAndSettle();
    },
  );
  testWidgets(
    'Income/expense, default/change, invalid/double/cancel, category management',
    (t) async {
      await verifyStage3Flow(t, db);
      await t.pumpWidget(const SizedBox());
      await t.pumpAndSettle();
    },
  );
  testWidgets(
    '320dp 1.8x entry keyboard, date, long category and account stay usable',
    (t) async {
      t.view.physicalSize = const Size(320, 568);
      t.view.devicePixelRatio = 1;
      t.platformDispatcher.textScaleFactorTestValue = 1.8;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
      await TransactionsRepository(db).saveCategory(
        kind: EventKind.expense,
        name: 'Өдөр тутмын хэрэглээний маш урт нэртэй ангилал',
        icon: 'cart',
        requestKey: 'long',
      );
      final semantics = t.ensureSemantics();
      await mountStage3(t, db);
      await tapStage3(t, 'expenseAction');
      t.view.viewInsets = const FakeViewPadding(bottom: 240);
      await t.pumpAndSettle();
      await t.enterText(find.byKey(const Key('entryAmount')), '123');
      await tapStage3(t, 'entrySave');
      expect(find.text('Ангиллаа сонгоорой.'), findsOneWidget);
      expect(t.takeException(), isNull);
      t.view.resetViewInsets();
      await t.pumpAndSettle();
      await tapStage3(t, 'entryDate');
      expect(t.takeException(), isNull);
      await tapStage3(t, 'dateDone');
      await tapStage3(t, 'manageCategories');
      await tapStage3(t, 'addCategory');
      await tapStage3(t, 'categorySave');
      expect(find.textContaining('Ангиллын нэр'), findsWidgets);
      expect(t.takeException(), isNull);
      await expectLater(t, meetsGuideline(androidTapTargetGuideline));
      await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(t, meetsGuideline(textContrastGuideline));
      semantics.dispose();
      await t.pumpWidget(const SizedBox());
      await t.pumpAndSettle();
    },
  );
  testWidgets('Large real period figures fit small screen with 1.8x text', (
    t,
  ) async {
    final entries = TransactionsRepository(db);
    final categories = await db.select(db.categories).get();
    final now = DateTime.now();
    // Offset cash entries keep balances valid while both flow figures are large.
    for (var i = 0; i < 4; i++) {
      final kind = i.isEven ? EventKind.expense : EventKind.income;
      await entries.post(
        kind: kind,
        amount: '999999999999',
        accountId: 1,
        categoryId: categories.firstWhere((c) => c.kind == kind.name).id,
        date: now,
        requestKey: 'large-$i',
      );
    }
    t.view.physicalSize = const Size(320, 568);
    t.view.devicePixelRatio = 1;
    t.platformDispatcher.textScaleFactorTestValue = 1.8;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    await mountStage3(t, db);
    expect(find.text('+1,999,999,999,998 ₮'), findsOneWidget);
    expect(find.text('−1,999,999,999,998 ₮'), findsOneWidget);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
    await t.pumpAndSettle();
  });
}
