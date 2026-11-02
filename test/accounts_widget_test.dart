import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadgaly/app.dart';
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
      await t.pageBack();
      await t.pumpAndSettle();
      await t.pageBack();
      await t.pumpAndSettle();
      expect(find.text('Миний карт'), findsOneWidget);
      expect(find.text('80 ₮'), findsOneWidget);
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
