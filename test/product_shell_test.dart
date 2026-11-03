import 'dart:ui' show Tristate;

import 'package:drift/native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadgaly/app.dart';
import 'package:hadgaly/core/presentation/design_tokens.dart';
import 'package:hadgaly/features/onboarding/application/onboarding_controller.dart';
import 'package:hadgaly/features/onboarding/data/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  setUpAll(() async {
    for (final entry in {
      fontFamily: 'GoogleSansFlex',
      'Noto Sans': 'NotoSans',
    }.entries) {
      await (FontLoader(
        entry.key,
      )..addFont(rootBundle.load('assets/fonts/${entry.value}.ttf'))).load();
    }
  });
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.loadProfile();
    await db.createFirstAccount('Өнөр Үүлэн', 'Хэтэвч', '-1200');
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

  Future<void> tap(WidgetTester t, String key) async {
    final finder = find.byKey(Key(key));
    await t.ensureVisible(finder);
    await t.tap(finder);
    await t.pumpAndSettle();
  }

  Future<void> finish(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pumpAndSettle();
  }

  testWidgets(
    'Bundled official fonts, Mongolian fallback, light theme and contrast tokens',
    (t) async {
      await mount(t);
      final context = t.element(find.byKey(const Key('homeBalance')));
      final theme = CupertinoTheme.of(context);
      expect(theme.brightness, Brightness.light);
      expect(theme.primaryColor, const Color(0xFF14243E));
      expect(theme.scaffoldBackgroundColor, const Color(0xFFF5F6F8));
      expect(theme.textTheme.textStyle.fontFamily, fontFamily);
      expect(theme.textTheme.textStyle.fontFamilyFallback, fontFallback);
      expect(find.text('Сайн уу, Өнөр Үүлэн'), findsOneWidget);
      expect(find.text('−1,200 ₮'), findsOneWidget);
      for (final font in ['GoogleSansFlex', 'NotoSans']) {
        expect(
          await rootBundle.loadString('assets/fonts/$font-OFL.txt'),
          contains('SIL OPEN FONT LICENSE'),
        );
      }
      double contrast(Color a, Color b) {
        final x = a.computeLuminance(), y = b.computeLuminance();
        return x > y ? (x + .05) / (y + .05) : (y + .05) / (x + .05);
      }

      for (final color in [ink, secondaryInk, incomeInk, errorInk]) {
        expect(contrast(color, paper), greaterThanOrEqualTo(4.5));
      }
      expect(contrast(ink, teal), greaterThanOrEqualTo(4.5));
      expect(contrast(ink, expense), greaterThanOrEqualTo(4.5));
      expect(t.takeException(), isNull);
      await finish(t);
    },
  );

  testWidgets(
    'Finance starts selected; other modules are honest placeholders without writes',
    (t) async {
      final semantics = t.ensureSemantics();
      await mount(t);
      expect(
        t
            .getSemantics(find.bySemanticsLabel('Санхүү'))
            .getSemanticsData()
            .flagsCollection
            .isSelected,
        Tristate.isTrue,
      );
      for (var i = 0; i < 3; i++) {
        await tap(t, 'module-$i');
        expect(find.text('Тун удахгүй'), findsOneWidget);
        expect(find.byKey(const Key('homeBalance')), findsNothing);
        expect(find.byKey(const Key('module-3')), findsOneWidget);
      }
      await tap(t, 'module-3');
      expect(find.text('−1,200 ₮'), findsOneWidget);
      expect(await db.select(db.accounts).get(), hasLength(1));
      expect(await db.select(db.balanceAdjustments).get(), isEmpty);
      expect(await db.select(db.adjustmentEdits).get(), isEmpty);
      semantics.dispose();
      await finish(t);
    },
  );

  testWidgets(
    'Persistent tabs preserve finance navigation and unsaved form; system Back is local',
    (t) async {
      await mount(t);
      await tap(t, 'myAccounts');
      expect(find.byKey(const Key('module-0')), findsOneWidget);
      await tap(t, 'addAccount');
      await t.enterText(find.byKey(const Key('accountName')), 'Өдрийн төсөв');
      t.testTextInput.hide();
      await t.pumpAndSettle();
      await tap(t, 'module-0');
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(find.byKey(const Key('accountName')), findsOneWidget);
      expect(
        t
            .widget<CupertinoTextField>(find.byKey(const Key('accountName')))
            .controller!
            .text,
        'Өдрийн төсөв',
      );
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(find.byKey(const Key('addAccount')), findsOneWidget);
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(find.byKey(const Key('homeBalance')), findsOneWidget);
      expect(await db.select(db.accounts).get(), hasLength(1));
      await finish(t);
    },
  );

  testWidgets(
    '320dp and 1.8x text keep all four tabs labeled, safe and reachable',
    (t) async {
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
      for (var i = 0; i < 4; i++) {
        final tab = find.byKey(Key('module-$i'));
        expect(t.getBottomRight(tab).dy, lessThanOrEqualTo(544));
        await tap(t, 'module-$i');
        expect(t.takeException(), isNull);
        await expectLater(t, meetsGuideline(androidTapTargetGuideline));
        await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(t, meetsGuideline(textContrastGuideline));
      }
      await tap(t, 'myAccounts');
      await tap(t, 'addAccount');
      t.view.viewInsets = const FakeViewPadding(bottom: 240);
      await t.pumpAndSettle();
      expect(find.byKey(const Key('module-3')), findsNothing);
      await t.ensureVisible(find.byKey(const Key('accountSave')));
      expect(t.takeException(), isNull);
      t.view.resetViewInsets();
      await t.pumpAndSettle();
      expect(find.byKey(const Key('module-3')), findsOneWidget);
      semantics.dispose();
      await finish(t);
    },
  );
}
