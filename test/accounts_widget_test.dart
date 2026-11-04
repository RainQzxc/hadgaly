import 'package:drift/native.dart';

import 'dart:ui' show SemanticsAction;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadgaly/app.dart';
import 'package:hadgaly/features/accounts/presentation/accounts_screen.dart';
import 'package:hadgaly/features/onboarding/data/app_database.dart';
import 'package:hadgaly/features/onboarding/application/onboarding_controller.dart';
import 'package:hadgaly/features/accounts/data/accounts_repository.dart';

void main() {
  late AppDatabase db;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.loadProfile();
    await db.createFirstAccount('Өнөр', 'Хэтэвч', '1000');
    await db.completeOnboarding();
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

  Future<void> tap(WidgetTester t, Finder finder) async {
    await t.ensureVisible(finder);
    await t.tap(finder);
    await t.pumpAndSettle();
  }

  Future<void> finish(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pumpAndSettle();
  }

  testWidgets('iOS navigation retains scaled titles and safe back behavior', (
    t,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    t.platformDispatcher.textScaleFactorTestValue = 1.8;
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    await mount(t);
    await tap(t, find.byKey(const Key('myAccounts')));
    expect(find.byType(CupertinoNavigationBar), findsOneWidget);
    expect(
      MediaQuery.textScalerOf(t.element(find.text('Миний данс'))).scale(10),
      18,
    );
    expect(t.takeException(), isNull);
    await tap(t, find.byKey(const Key('back')));
    expect(find.byKey(const Key('homeBalance')), findsOneWidget);
    await finish(t);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets(
    'Cupertino shell, canceled default picker and Android system back preserve selection',
    (t) async {
      final semantics = t.ensureSemantics();
      await mount(t);
      expect(find.byType(CupertinoApp), findsOneWidget);
      expect(
        t
            .getSemantics(find.bySemanticsLabel('Орлого нэмэх'))
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        isTrue,
      );
      await tap(t, find.byKey(const Key('myAccounts')));
      expect(
        t
            .getSemantics(find.bySemanticsLabel('Буцах'))
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        isTrue,
      );
      expect(
        t
            .getSemantics(find.bySemanticsLabel('Үндсэн данс солих'))
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        isTrue,
      );
      final before = (await db.loadProfile()).defaultAccountId;
      await tap(t, find.byKey(const Key('chooseDefault')));
      expect(find.byType(CupertinoActionSheet), findsOneWidget);
      await tap(t, find.byKey(const Key('cancelDefault')));
      expect((await db.loadProfile()).defaultAccountId, before);
      await tap(t, find.byKey(const Key('chooseDefault')));
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(find.byType(CupertinoActionSheet), findsNothing);
      expect((await db.loadProfile()).defaultAccountId, before);
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(find.byKey(const Key('homeBalance')), findsOneWidget);
      semantics.dispose();
      await finish(t);
    },
  );

  testWidgets('Reduced motion removes page and sheet transitions', (t) async {
    t.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(
          disableAnimations: true,
          accessibleNavigation: true,
        );
    addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await mount(t);
    await t.pumpAndSettle();
    await tap(t, find.byKey(const Key('myAccounts')));
    final page =
        ModalRoute.of(t.element(find.byType(AccountsScreen)))!
            as TransitionRoute<dynamic>;
    expect(page.transitionDuration, Duration.zero);
    expect(page.reverseTransitionDuration, Duration.zero);
    await tap(t, find.byKey(const Key('chooseDefault')));
    final sheet =
        ModalRoute.of(t.element(find.byType(CupertinoActionSheet)))!
            as TransitionRoute<dynamic>;
    expect(sheet.transitionDuration, Duration.zero);
    expect(sheet.reverseTransitionDuration, Duration.zero);
    await tap(t, find.byKey(const Key('cancelDefault')));
    await finish(t);
  });

  testWidgets(
    'Account form keyboard, long input, safe areas and large text retain accessibility',
    (t) async {
      t.view.physicalSize = const Size(320, 568);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      t.platformDispatcher.textScaleFactorTestValue = 1.8;
      addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
      final semantics = t.ensureSemantics();
      await mount(t);
      await tap(t, find.byKey(const Key('myAccounts')));
      final title = find.text('Миний данс');
      expect(MediaQuery.textScalerOf(t.element(title)).scale(10), 18);
      await tap(t, find.byKey(const Key('addAccount')));
      await t.ensureVisible(find.byKey(const Key('accountName')));
      await t.enterText(
        find.byKey(const Key('accountName')),
        'Өдөр тутмын хувийн хэрэглээний урт нэртэй данс',
      );
      await t.ensureVisible(find.byKey(const Key('openingBalance')));
      await t.enterText(
        find.byKey(const Key('openingBalance')),
        '-999999999999',
      );
      t.view.viewInsets = const FakeViewPadding(bottom: 250);
      await t.pumpAndSettle();
      await t.ensureVisible(find.byKey(const Key('accountSave')));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      t.view.resetViewInsets();
      await t.pumpAndSettle();
      await expectLater(t, meetsGuideline(androidTapTargetGuideline));
      await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(t, meetsGuideline(textContrastGuideline));
      expect(await db.select(db.accounts).get(), hasLength(1));
      semantics.dispose();
      await finish(t);
    },
  );

  testWidgets(
    'My Accounts navigation, create/default/rename/adjust/edit and live Home',
    (t) async {
      await mount(t);
      await tap(t, find.byKey(const Key('myAccounts')));
      expect(find.text('Миний данс'), findsOneWidget);
      expect(find.text('1,000 ₮'), findsNWidgets(2));
      await tap(t, find.byKey(const Key('addAccount')));
      await tap(t, find.byKey(const Key('accountSave')));
      expect(find.text('Дансны нэр хоосон байж болохгүй.'), findsOneWidget);
      await t.enterText(find.byKey(const Key('accountName')), 'Карт');
      await t.enterText(find.byKey(const Key('openingBalance')), '-500');
      await t.ensureVisible(find.byKey(const Key('accountSave')));
      await t.tap(find.byKey(const Key('accountSave')));
      await t.tap(find.byKey(const Key('accountSave')));
      await t.pumpAndSettle();
      expect(await db.select(db.accounts).get(), hasLength(2));
      await tap(t, find.byKey(const Key('chooseDefault')));
      await tap(t, find.byKey(const Key('default-2')));
      expect(
        t.widget<Text>(find.byKey(const Key('defaultBalance'))).data,
        '−500 ₮',
      );
      await tap(t, find.byKey(const Key('account-2')));
      await tap(t, find.text('Дансны нэр засах'));
      await t.enterText(find.byKey(const Key('accountName')), 'Миний карт');
      await tap(t, find.byKey(const Key('accountSave')));
      expect(find.text('Миний карт'), findsOneWidget);
      await tap(t, find.byKey(const Key('adjustBalance')));
      await t.enterText(find.byKey(const Key('targetBalance')), '0');
      await tap(t, find.byKey(const Key('adjustmentSave')));
      expect(find.text('Анх ажигласан зөрүү: 500 ₮'), findsOneWidget);
      final repo = AccountsRepository(db);
      final a = (await repo.snapshot()).byId(2).adjustments.single.record.id;
      await tap(t, find.byKey(Key('editAdjustment-$a')));
      await t.enterText(find.byKey(const Key('targetBalance')), '100');
      await tap(t, find.byKey(const Key('adjustmentSave')));
      expect(find.textContaining('Засвар: 0 ₮ → 100 ₮'), findsOneWidget);
      await repo.adjustBalance(2, '80', 'later');
      await t.pumpAndSettle();
      await repo.editAdjustment(a, '120', 1, 'earlier');
      await t.pumpAndSettle();
      expect((await repo.snapshot()).byId(2).balance, 80);
      await t.tap(find.byKey(const Key('back')));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const Key('back')));
      await t.pumpAndSettle();
      expect(find.text('Миний карт'), findsOneWidget);
      expect(find.text('1,080 ₮'), findsOneWidget);
      expect(find.byKey(const Key('addAccount')), findsNothing);
      await finish(t);
    },
  );

  testWidgets(
    'Accounts and history support small screen/large text and accessibility',
    (t) async {
      final repo = AccountsRepository(db, clock: () => 100);
      final id = await repo.createAccount(
        'Өдөр тутмын хувийн хэрэглээний карт',
        '-999999999999',
        'card',
      );
      await repo.selectDefault(id);
      final a = await repo.adjustBalance(id, '999999999999', 'a');
      await repo.editAdjustment(a, '0', 0, 'e');
      t.view.physicalSize = const Size(320, 568);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      t.platformDispatcher.textScaleFactorTestValue = 1.8;
      addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
      final semantics = t.ensureSemantics();
      await mount(t);
      await tap(t, find.byKey(const Key('myAccounts')));
      expect(t.takeException(), isNull);
      await tap(t, find.byKey(Key('account-$id')));
      expect(t.takeException(), isNull);
      await t.ensureVisible(find.byKey(Key('editAdjustment-$a')));
      await t.pumpAndSettle();
      await expectLater(t, meetsGuideline(androidTapTargetGuideline));
      await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(t, meetsGuideline(textContrastGuideline));
      semantics.dispose();
      await finish(t);
    },
  );
}
