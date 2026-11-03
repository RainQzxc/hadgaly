import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hadgaly/app.dart';
import 'package:hadgaly/features/onboarding/application/onboarding_controller.dart';
import 'package:hadgaly/features/onboarding/data/app_database.dart';
import 'package:hadgaly/features/accounts/data/accounts_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Android Stage 2 accounts/default/anchors/audit/restart', (
    t,
  ) async {
    final name = 'hadgaly_stage2_${DateTime.now().microsecondsSinceEpoch}';
    var db = AppDatabase(driftDatabase(name: name));
    await db.loadProfile();
    await db.createFirstAccount('Өнөр', 'Хэтэвч', '1000');
    await db.completeOnboarding();
    Future<void> mount() async {
      await t.pumpWidget(
        ProviderScope(
          key: UniqueKey(),
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const HadgalyApp(),
        ),
      );
      await t.pumpAndSettle();
    }

    Future<void> tap(Finder f) async {
      await t.ensureVisible(f);
      await t.tap(f);
      await t.pumpAndSettle();
    }

    try {
      await mount();
      // Only finance is active; future modules neither collect nor save data.
      expect(find.byKey(const Key('homeBalance')), findsOneWidget);
      for (var i = 0; i < 3; i++) {
        await tap(find.byKey(Key('module-$i')));
        expect(find.text('Тун удахгүй'), findsOneWidget);
        await tap(find.byKey(const Key('module-3')));
        expect(find.text('1,000 ₮'), findsOneWidget);
      }
      await tap(find.byKey(const Key('myAccounts')));
      expect(find.byKey(const Key('module-3')), findsOneWidget);
      await tap(find.byKey(const Key('addAccount')));
      await t.enterText(find.byKey(const Key('accountName')), 'Миний карт');
      await t.enterText(find.byKey(const Key('openingBalance')), '-500');
      await tap(find.byKey(const Key('accountSave')));
      await tap(find.byKey(const Key('chooseDefault')));
      await tap(find.byKey(const Key('default-2')));
      expect(
        t.widget<Text>(find.byKey(const Key('defaultBalance'))).data,
        '−500 ₮',
      );
      await tap(find.byKey(const Key('account-2')));
      await tap(find.byKey(const Key('adjustBalance')));
      await t.enterText(find.byKey(const Key('targetBalance')), '900');
      await tap(find.byKey(const Key('adjustmentSave')));
      var repo = AccountsRepository(db);
      final a = (await repo.snapshot()).byId(2).adjustments.single.record.id;
      await tap(find.byKey(Key('editAdjustment-$a')));
      await t.enterText(find.byKey(const Key('targetBalance')), '950');
      await tap(find.byKey(const Key('adjustmentSave')));
      expect(find.textContaining('Засвар: 900 ₮ → 950 ₮'), findsOneWidget);
      await tap(find.byKey(const Key('adjustBalance')));
      await t.enterText(find.byKey(const Key('targetBalance')), '800');
      await tap(find.byKey(const Key('adjustmentSave')));
      await tap(find.byKey(Key('editAdjustment-$a')));
      await t.enterText(find.byKey(const Key('targetBalance')), '1000');
      await tap(find.byKey(const Key('adjustmentSave')));
      expect((await repo.snapshot()).byId(2).balance, 800);
      await t.pumpWidget(const SizedBox());
      await t.pumpAndSettle();
      await db.close();
      db = AppDatabase(driftDatabase(name: name));
      repo = AccountsRepository(db);
      await mount();
      expect(find.text('1,800 ₮'), findsOneWidget);
      expect(find.text('+0 ₮'), findsOneWidget);
      expect(find.text('−0 ₮'), findsOneWidget);
      final snapshot = await repo.snapshot();
      expect(snapshot.defaultId, 2);
      final first = snapshot
          .byId(2)
          .adjustments
          .singleWhere((v) => v.record.id == a);
      expect(first.originalDifference, 1400);
      expect(first.edits, hasLength(2));
      expect(snapshot.byId(2).ledger.income, BigInt.zero);
      expect(snapshot.byId(2).ledger.expense, BigInt.zero);
      expect(t.takeException(), isNull);
    } finally {
      await t.pumpWidget(const SizedBox());
      await t.pumpAndSettle();
      await db.close();
    }
  });
}
