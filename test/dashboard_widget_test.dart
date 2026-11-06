import 'package:drift/native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadgaly/features/onboarding/data/app_database.dart';
import 'package:hadgaly/features/accounts/data/accounts_repository.dart';
import 'package:hadgaly/features/accounts/domain/ledger.dart';
import 'package:hadgaly/features/transactions/data/transactions_repository.dart';
import 'package:hadgaly/features/home/presentation/dashboard_details.dart';
import 'package:hadgaly/features/home/presentation/report_screen.dart';

import 'support/stage3_flow.dart';
import 'support/stage5_data.dart';
import 'support/stage5_flow.dart';

void main() {
  testWidgets(
    'Report reacts to existing edits/default/anchors; system Back returns to compact Home',
    (t) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final now = DateTime.now(), ids = await seedStage5(db, DateTime.now());
      await mountStage3(t, db);
      expect(find.byType(DashboardDetails), findsNothing);
      expect(find.byType(AccountSummary), findsNothing);
      await tapStage3(t, 'reportAction');
      expect(find.byType(ReportScreen), findsOneWidget);
      final accounts = AccountsRepository(db);
      await accounts.selectDefault(1);
      await accounts.adjustBalance(ids.card, '-600', 'report-anchor');
      await TransactionsRepository(db, clock: () => now).edit(
        id: ids.currentIncome,
        expectedRevision: 0,
        kind: EventKind.income,
        amount: '250',
        accountId: 1,
        categoryId: ids.income,
        date: now,
        requestKey: 'report-edit',
      );
      await waitStage3(t, find.text('Цэвэр: +175 ₮'));
      expect(
        t.widget<Text>(find.byKey(const Key('comparison-current-Орлого'))).data,
        '250 ₮',
      );
      expect(
        t
            .widget<Text>(find.byKey(const Key('comparison-current-Зарлага')))
            .data,
        '75 ₮',
      );
      expect(
        t.widget<Text>(find.byKey(Key('overview-balance-${ids.card}'))).data,
        '−600 ₮',
      );
      expect(find.byKey(const Key('overview-default-1')), findsOneWidget);
      expect(find.byKey(Key('overview-default-${ids.card}')), findsNothing);
      expect(find.text('50 ₮ · 66.7%'), findsOneWidget);
      expect(find.text('25 ₮ · 33.3%'), findsOneWidget);
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(
        t.widget<Text>(find.byKey(const Key('homeBalance'))).data,
        '300 ₮',
      );
      expect(
        t.widget<Text>(find.byKey(const Key('periodIncome'))).data,
        '+250 ₮',
      );
      expect(find.byType(DashboardDetails), findsNothing);
      expect(find.byType(AccountSummary), findsNothing);
      await t.pumpWidget(const SizedBox());
      await t.pumpAndSettle();
    },
  );
  testWidgets(
    'Income-only month keeps the expense chart empty and zero baseline honest',
    (t) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await db.loadProfile();
      await db.createFirstAccount('Тест', 'Хэтэвч', '0');
      await db.completeOnboarding();
      final income = (await db.select(db.categories).get()).firstWhere(
        (c) => c.kind == 'income',
      );
      await TransactionsRepository(db).post(
        kind: EventKind.income,
        amount: '200',
        accountId: 1,
        categoryId: income.id,
        date: DateTime.now(),
        requestKey: 'income-only',
      );
      await mountStage3(t, db);
      final chart = find.byKey(const Key('expenseDonut'));
      expect(
        t.widget<Text>(find.byKey(const Key('periodExpense'))).data,
        '−0 ₮',
      );
      expect(
        t.widget<Text>(find.byKey(const Key('periodIncome'))).data,
        '+200 ₮',
      );
      expect(
        find.descendant(
          of: chart,
          matching: find.byKey(const Key('periodIncome')),
        ),
        findsNothing,
      );
      final paint = t.widget<CustomPaint>(
        find.descendant(of: chart, matching: find.byType(CustomPaint)),
      );
      expect((paint.painter! as ExpenseRing).shares, isEmpty);
      await tapStage3(t, 'reportAction');
      expect(find.text('Энэ сард зарлага бүртгэгдээгүй.'), findsOneWidget);
      expect(
        t.widget<Text>(find.byKey(const Key('comparison-Орлого'))).data,
        'Өссөн · +200 ₮',
      );
      expect(
        t.widget<Text>(find.byKey(const Key('comparison-Зарлага'))).data,
        'Өөрчлөлтгүй · 0 ₮',
      );
      await t.pumpWidget(const SizedBox());
      await t.pumpAndSettle();
    },
  );
  testWidgets(
    'Large exact amounts and long metadata remain readable at 320dp 1.8x',
    (t) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final now = DateTime.now();
      final ids = await seedStage5(db, now);
      final repo = TransactionsRepository(db, clock: () => now);
      await AccountsRepository(db).renameAccount(
        ids.card,
        'Өдөр тутмын хэрэглээний үндсэн урт нэртэй данс',
      );
      await repo.saveCategory(
        id: ids.cart,
        kind: EventKind.expense,
        name: 'Өдөр тутмын хэрэглээний урт нэртэй ангилал',
        icon: 'cart',
        requestKey: 'long-category',
      );
      for (final kind in [EventKind.income, EventKind.expense]) {
        await repo.post(
          kind: kind,
          amount: '999999999999',
          accountId: ids.card,
          categoryId: kind == EventKind.income ? ids.income : ids.cart,
          date: now,
          requestKey: 'max-${kind.name}',
        );
      }
      t.view.physicalSize = const Size(320, 568);
      t.view.devicePixelRatio = 1;
      t.platformDispatcher.textScaleFactorTestValue = 1.8;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
      await mountStage3(t, db);
      expect(
        t.widget<Text>(find.byKey(const Key('periodIncome'))).data,
        '+1,000,000,000,199 ₮',
      );
      expect(
        t.widget<Text>(find.byKey(const Key('periodExpense'))).data,
        '−1,000,000,000,074 ₮',
      );
      expect(
        t.widget<Text>(find.byKey(const Key('homeBalance'))).data,
        '375 ₮',
      );
      await tapStage3(t, 'reportAction');
      for (final key in [
        'categoryShare-${ids.cart}',
        'comparison-Орлого',
        'overview-account-${ids.card}',
      ]) {
        await t.ensureVisible(find.byKey(Key(key)));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        final box = t.getRect(find.byKey(Key(key)));
        expect(box.left, greaterThanOrEqualTo(0));
        expect(box.right, lessThanOrEqualTo(320));
      }
      expect(
        find.text('Өдөр тутмын хэрэглээний урт нэртэй ангилал'),
        findsOneWidget,
      );
      expect(
        find.text('Өдөр тутмын хэрэглээний үндсэн урт нэртэй данс'),
        findsOneWidget,
      );
      await t.pumpWidget(const SizedBox());
      await t.pumpAndSettle();
    },
  );
  for (final small in [false, true]) {
    testWidgets(
      'Dashboard real categories, comparison, quick add, navigation${small ? ' 320dp 1.8x' : ''}',
      (t) async {
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);
        t.view.physicalSize = Size(small ? 320 : 390, small ? 568 : 844);
        t.view.devicePixelRatio = 1;
        t.platformDispatcher.textScaleFactorTestValue = small ? 1.8 : 1;
        addTearDown(t.view.resetPhysicalSize);
        addTearDown(t.view.resetDevicePixelRatio);
        addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
        await seedStage5(db, DateTime.now());
        await verifyStage5Flow(t, db);
        await tapStage3(t, 'reportAction');
        await expectLater(t, meetsGuideline(textContrastGuideline));
        await t.pumpWidget(const SizedBox());
        await t.pumpAndSettle();
      },
    );
  }
}
