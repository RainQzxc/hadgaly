import 'package:drift/native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadgaly/app.dart';
import 'package:hadgaly/features/onboarding/application/onboarding_controller.dart';
import 'package:hadgaly/features/onboarding/data/app_database.dart';

Future<void> tapNext(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const Key('next')));
  await tester.tap(find.byKey(const Key('next')));
  await tester.pumpAndSettle();
}

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());
  Future<void> mount(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const HadgalyApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Welcome accessibility and system back preserve checkpoints', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await mount(tester);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await tester.enterText(find.byKey(const Key('nickname')), 'Ану');
    await tapNext(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('nickname')), findsOneWidget);
    expect(
      (tester.widget(
        find.byKey(const Key('nickname')),
      ) as CupertinoTextField).controller!.text,
      'Ану',
    );
    expect((await db.loadProfile()).step, 0);
    semantics.dispose();
  });

  testWidgets('Invalid saved state fails visibly without resetting data', (
    tester,
  ) async {
    await db.loadProfile();
    await db.customStatement('DROP TRIGGER valid_completed_profile');
    await db.customStatement('UPDATE profiles SET step = 4, completed = 1');
    await mount(tester);
    expect(
      find.text('Хадгалсан мэдээллийг нээж чадсангүй. Аппаа дахин нээгээрэй.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('next')), findsNothing);
    expect((await db.loadProfile()).step, 4);
    expect(await db.select(db.accounts).get(), isEmpty);
  });

  testWidgets('Full fresh flow, validation, back and unavailable actions', (
    tester,
  ) async {
    await mount(tester);
    expect(find.text('Сайн уу? 👋'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('nickname')), '   ');
    await tapNext(tester);
    expect(find.byKey(const Key('error')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('nickname')), 'Болд');
    await tapNext(tester);
    expect(find.text('Танилцахад таатай байна, Болд! 💚'), findsOneWidget);
    await tapNext(tester);
    await tester.ensureVisible(find.byKey(const Key('back')));
    await tester.tap(find.byKey(const Key('back')));
    await tester.pumpAndSettle();
    expect(find.text('Танилцахад таатай байна, Болд! 💚'), findsOneWidget);
    await tapNext(tester);
    await tapNext(tester);
    expect(find.byKey(const Key('error')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('accountName')), 'Карт');
    await tester.enterText(find.byKey(const Key('openingBalance')), '1.2');
    await tapNext(tester);
    expect(find.byKey(const Key('error')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('openingBalance')), '-120');
    await tapNext(tester);
    expect(find.text('Бэлэн боллоо, Болд! 🎉'), findsOneWidget);
    await tapNext(tester);
    expect(find.text('−120 ₮'), findsOneWidget);
    await tester.tap(find.text('+'));
    await tester.pumpAndSettle();
    expect(
      find.text('Гүйлгээ бүртгэх боломж хараахан нээгдээгүй байна.'),
      findsOneWidget,
    );
    expect(await db.select(db.accounts).get(), hasLength(1));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
  testWidgets('Small screen, keyboard, large text and accessibility', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semantics = tester.ensureSemantics();

    tester.platformDispatcher.textScaleFactorTestValue = 1.8;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await mount(tester);
    await tester.ensureVisible(find.byKey(const Key('nickname')));
    await tester.tap(find.byKey(const Key('nickname')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('nickname')),
      'Өнөржаргал ' * 5,
    );
    await tapNext(tester);
    await tapNext(tester);
    await tester.enterText(
      find.byKey(const Key('accountName')),
      'Хувийн өдөр тутмын хэрэглээний данс',
    );
    await tester.ensureVisible(find.byKey(const Key('openingBalance')));
    await tester.enterText(
      find.byKey(const Key('openingBalance')),
      '-999999999999',
    );
    tester.view.viewInsets = const FakeViewPadding(bottom: 250);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tapNext(tester);
    tester.view.resetViewInsets();
    await tester.pumpAndSettle();
    await tapNext(tester);
    expect(tester.takeException(), isNull);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    semantics.dispose();
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
