import 'package:drift/native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadgaly/app.dart';
import 'package:hadgaly/features/accounts/data/accounts_repository.dart';
import 'package:hadgaly/features/onboarding/application/onboarding_controller.dart';
import 'package:hadgaly/features/onboarding/data/app_database.dart';

void main() {
  late AppDatabase db;
  late AccountsRepository repo;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.loadProfile();
    await db.createFirstAccount('Өнөр', 'Хэтэвч', '1000');
    await db.completeOnboarding();
    repo = AccountsRepository(db, clock: () => 100);
  });
  tearDown(() => db.close());
  Future<void> mount(WidgetTester t) async {
    await t.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const HadgalyApp(),
      ),
    );
    await t.pumpAndSettle();
  }

  Future<void> finish(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pumpAndSettle();
  }

  void emptyTotals() {
    expect(find.text('+0 ₮'), findsOneWidget);
    expect(find.text('−0 ₮'), findsOneWidget);
    expect(find.text('Энэ сард гүйлгээ бүртгэгдээгүй.'), findsOneWidget);
    expect(find.text('Үндсэн данс'), findsOneWidget);
    expect(find.text('Хэтэвч'), findsOneWidget);
  }

  testWidgets(
    'Home aggregates current balances and anchor edits, independent of default',
    (t) async {
      final card = await repo.createAccount('Карт', '-500', 'card');
      await repo.createAccount('Хадгаламж', '0', 'savings');
      await mount(t);
      expect(find.text('500 ₮'), findsOneWidget);
      emptyTotals();
      final first = await repo.adjustBalance(card, '900', 'first');
      await t.pumpAndSettle();
      expect(find.text('1,900 ₮'), findsOneWidget);
      await repo.editAdjustment(first, '950', 0, 'edit');
      await t.pumpAndSettle();
      expect(find.text('1,950 ₮'), findsOneWidget);
      await repo.adjustBalance(card, '-1200', 'later');
      await repo.editAdjustment(first, '800', 1, 'earlier');
      await repo.selectDefault(card);
      await t.pumpAndSettle();
      expect(find.text('−200 ₮'), findsOneWidget);
      emptyTotals();
      final snapshot = await repo.snapshot();
      expect(snapshot.defaultId, card);
      expect(snapshot.byId(card).balance, -1200);
      expect(snapshot.byId(card).adjustments.last.edits, hasLength(2));
      await finish(t);
    },
  );

  testWidgets(
    'Combined balance is exact beyond the individual account input limit and at zero',
    (t) async {
      await repo.adjustBalance(1, '999999999999', 'max');
      final second = await repo.createAccount('Хоёр', '999999999999', 'two');
      await mount(t);
      expect(find.text('1,999,999,999,998 ₮'), findsOneWidget);
      await repo.adjustBalance(second, '-999999999999', 'negative');
      await t.pumpAndSettle();
      expect(t.widget<Text>(find.byKey(const Key('homeBalance'))).data, '0 ₮');
      emptyTotals();
      await finish(t);
    },
  );

  testWidgets(
    'Chart, balance and bottom actions have the approved hierarchy and correct entry navigation',
    (t) async {
      final semantics = t.ensureSemantics();
      t.view.physicalSize = const Size(390, 844);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      await mount(t);
      final chart = find.byKey(const Key('expenseDonut'));
      final balance = find.byKey(const Key('homeBalance'));
      final expense = find.byKey(const Key('expenseAction'));
      final income = find.byKey(const Key('incomeAction'));
      final navigation = find.byKey(const Key('myAccounts'));
      expect(t.getSize(chart).width, lessThanOrEqualTo(240));
      expect(t.getSize(expense).height, 64);
      expect(t.getSize(income).height, 64);
      expect(find.text('Нийт үлдэгдэл'), findsOneWidget);
      final greeting = find.text('Сайн уу, Өнөр');
      expect(
        t.getTopLeft(chart).dy - t.getBottomRight(greeting).dy,
        lessThanOrEqualTo(56),
      );
      expect(t.getCenter(chart).dx, closeTo(195, 1));
      expect(t.getBottomRight(chart).dy, lessThan(t.getTopLeft(balance).dy));
      expect(t.getBottomRight(balance).dy, lessThan(t.getTopLeft(expense).dy));
      expect(t.getCenter(expense).dx, lessThan(t.getCenter(income).dx));
      expect(
        t.getBottomRight(income).dy,
        lessThan(t.getTopLeft(navigation).dy),
      );
      expect(t.getBottomRight(navigation).dy, lessThanOrEqualTo(844));
      // Explicit section rhythm must not grow when the viewport has spare height.
      expect(
        t.getTopLeft(find.text('Нийт үлдэгдэл')).dy -
            t.getBottomRight(find.byKey(const Key('monthlyIncomeRow'))).dy,
        closeTo(24, 0.01),
      );
      expect(
        find.descendant(
          of: navigation,
          matching: find.byIcon(CupertinoIcons.chevron_right),
        ),
        findsOneWidget,
      );
      expect(t.getSize(navigation).height, greaterThanOrEqualTo(48));
      t.view.physicalSize = const Size(390, 1000);
      await t.pumpAndSettle();
      expect(
        t.getTopLeft(find.text('Нийт үлдэгдэл')).dy -
            t.getBottomRight(find.byKey(const Key('monthlyIncomeRow'))).dy,
        closeTo(24, 0.01),
      );
      expect(
        find.bySemanticsLabel(
          RegExp('Энэ сарын зарлагын ангиллын хуваарилалт'),
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Бүх дансны одоогийн нийт үлдэгдэл: 1,000 ₮'),
        findsOneWidget,
      );
      await t.tap(expense);
      await t.pumpAndSettle();
      expect(find.byKey(const Key('entryAmount')), findsOneWidget);
      expect(await db.select(db.accounts).get(), hasLength(1));
      expect(await db.select(db.balanceAdjustments).get(), isEmpty);
      semantics.dispose();
      await finish(t);
    },
  );

  testWidgets(
    'Home long name, 1.8x text, small screen, insets and accessibility',
    (t) async {
      await repo.adjustBalance(1, '-999999999999', 'large-negative');
      await db.customStatement(
        "UPDATE profiles SET nickname = 'Өдөр тутмын урт нэртэй хэрэглэгчийн нэр'",
      );
      t.view.physicalSize = const Size(320, 568);
      t.view.devicePixelRatio = 1;
      t.view.padding = const FakeViewPadding(top: 24, bottom: 24);
      t.platformDispatcher.textScaleFactorTestValue = 1.8;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      addTearDown(t.view.resetPadding);
      addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
      final semantics = t.ensureSemantics();
      await mount(t);
      emptyTotals();
      expect(t.takeException(), isNull);
      await t.ensureVisible(find.byKey(const Key('incomeAction')));
      await t.pumpAndSettle();
      await expectLater(t, meetsGuideline(androidTapTargetGuideline));
      await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(t, meetsGuideline(textContrastGuideline));
      t.view.viewInsets = const FakeViewPadding(bottom: 240);
      await t.pumpAndSettle();
      await t.ensureVisible(find.byKey(const Key('incomeAction')));
      await t.tap(find.byKey(const Key('incomeAction')));
      await t.pumpAndSettle();
      expect(find.byKey(const Key('entryAmount')), findsOneWidget);
      expect(t.takeException(), isNull);
      t.view.resetViewInsets();
      semantics.dispose();
      await finish(t);
    },
  );
}
