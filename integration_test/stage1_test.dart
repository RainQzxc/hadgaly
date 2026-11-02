import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hadgaly/app.dart';
import 'package:hadgaly/features/onboarding/application/onboarding_controller.dart';
import 'package:hadgaly/features/onboarding/data/app_database.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Android onboarding, partial draft, SQLite reopen and home', (
    tester,
  ) async {
    final filename =
        'hadgaly_stage1_test_${DateTime.now().microsecondsSinceEpoch}';
    var db = AppDatabase(driftDatabase(name: filename));
    Future<void> mount() async {
      await tester.pumpWidget(
        ProviderScope(
          key: UniqueKey(),
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const HadgalyApp(),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> next() async {
      await tester.ensureVisible(find.byKey(const Key('next')));
      await tester.tap(find.byKey(const Key('next')));
      await tester.pumpAndSettle();
    }

    Future<void> reopen() async {
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await db.close();
      db = AppDatabase(driftDatabase(name: filename));
      await mount();
    }

    try {
      await mount();
      expect(find.text('Сайн уу? 👋'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('nickname')), 'Өнөр');
      await next();
      await next();
      await tester.ensureVisible(find.byKey(const Key('accountName')));
      await tester.enterText(
        find.byKey(const Key('accountName')),
        'Миний хэтэвч',
      );
      await tester.ensureVisible(find.byKey(const Key('openingBalance')));
      await tester.enterText(find.byKey(const Key('openingBalance')), '-');
      await tester.pumpAndSettle();
      await ProviderScope.containerOf(tester.element(find.byType(HadgalyApp)))
          .read(onboardingProvider)
          .flushDrafts;
      await reopen();
      expect(find.text('Эхний дансаа үүсгэе'), findsOneWidget);
      expect(
        (tester.widget(
          find.byKey(const Key('accountName')),
        ) as TextField).controller!.text,
        'Миний хэтэвч',
      );
      expect(
        (tester.widget(
          find.byKey(const Key('openingBalance')),
        ) as TextField).controller!.text,
        '-',
      );
      await tester.ensureVisible(find.byKey(const Key('openingBalance')));
      await tester.enterText(find.byKey(const Key('openingBalance')), '-25000');
      await next();
      expect(find.text('Бэлэн боллоо, Өнөр! 🎉'), findsOneWidget);
      await next();
      expect(find.text('−25,000 ₮'), findsOneWidget);
      await reopen();
      expect(find.text('−25,000 ₮'), findsOneWidget);
      expect(await db.select(db.accounts).get(), hasLength(1));
      await tester.tap(find.text('−'));
      await tester.pumpAndSettle();
      expect(
        find.text('Гүйлгээ бүртгэх боломж хараахан нээгдээгүй байна.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    } finally {
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await db.close();
    }
  });
}
