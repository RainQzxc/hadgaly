import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hadgaly/features/accounts/data/accounts_repository.dart';
import 'package:hadgaly/features/onboarding/data/app_database.dart';
import 'package:hadgaly/features/accounts/domain/ledger.dart';
import 'package:hadgaly/features/transactions/data/transactions_repository.dart';

import '../test/support/stage3_flow.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Programmatic enterText must not race the real IME's older editing buffer.
  // Native rendering/SQLite remain real. Actual Android keyboard input is
  // separately exercised on the disposable sandbox, never on founder data.
  setUp(() => binding.testTextInput.register());
  tearDown(() => binding.testTextInput.unregister());
  testWidgets(
    'Native SQLite backdating, stable anchors, rollback and durable retry',
    (t) async {
      final db = AppDatabase(
        driftDatabase(
          name:
              'hadgaly_native_ledger_${DateTime.now().microsecondsSinceEpoch}',
        ),
      );
      try {
        await db.loadProfile();
        await db.createFirstAccount('Туршилт', 'Хэтэвч', '1000');
        await db.completeOnboarding();
        final clock = DateTime.now();
        final accounts = AccountsRepository(
          db,
          clock: () => clock.toUtc().microsecondsSinceEpoch,
        );
        final entries = TransactionsRepository(db, clock: () => clock);
        final category = (await db.select(db.categories).get()).firstWhere(
          (c) => c.kind == 'income',
        );
        final a = await accounts.adjustBalance(1, '900', 'a');
        final date = DateTime(clock.year, clock.month, clock.day - 1);
        Future<int> post(String key, String amount, DateTime day) =>
            entries.post(
              kind: EventKind.income,
              amount: amount,
              accountId: 1,
              categoryId: category.id,
              date: day,
              requestKey: key,
            );
        final id = await post('backdated', '200', date);
        expect(await post('backdated', '200', date), id);
        var s = (await accounts.snapshot()).byId(1);
        expect(s.balance, 900);
        expect(s.adjustments.single.originalDifference, -100);
        expect(s.adjustments.single.point.difference, -300);
        await accounts.editAdjustment(a, '950', 0, 'edit');
        await post('after', '50', clock);
        expect((await accounts.snapshot()).byId(1).balance, 1000);
        final b = await accounts.adjustBalance(1, '800', 'b');
        await post('earlier', '10', date);
        s = (await accounts.snapshot()).byId(1);
        expect(s.balance, 800);
        expect(s.adjustments.first.record.id, b);
        expect(s.ledger.income, BigInt.from(260));
        expect(s.ledger.expense, BigInt.zero);
        final count = (await db.select(db.ledgerSequences).get()).length;
        await expectLater(
          post('overflow', '999999999999', date),
          throwsFormatException,
        );
        expect(await db.select(db.ledgerSequences).get(), hasLength(count));
        await entries.archiveCategory(category.id);
        expect(await post('backdated', '200', date), id);
        expect(
          await db.customSelect('PRAGMA foreign_key_check').get(),
          isEmpty,
        );
      } finally {
        await db.close();
      }
    },
  );
  testWidgets('Native Stage 3 synthetic entry/category/archive/reopen flow', (
    t,
  ) async {
    final name = 'hadgaly_stage3_${DateTime.now().microsecondsSinceEpoch}';
    var db = AppDatabase(driftDatabase(name: name));
    try {
      await db.loadProfile();
      await db.createFirstAccount('Туршилт', 'Хэтэвч', '1000');
      await db.completeOnboarding();
      await verifyStage3Flow(t, db);
      await binding.convertFlutterSurfaceToImage();
      await t.pumpAndSettle();
      await binding.takeScreenshot('stage3-synthetic-home');
      await t.pumpWidget(const SizedBox());
      await t.pumpAndSettle();
      await db.close();
      db = AppDatabase(driftDatabase(name: name));
      final s = await AccountsRepository(db).snapshot();
      expect(s.entries, hasLength(3));
      expect(s.defaultId, 2);
      expect(s.accounts.map((a) => a.balance), [950, -325]);
      expect((await db.loadProfile()).completed, isTrue);
      await mountStage3(t, db);
      expect(find.text('625 ₮'), findsOneWidget);
      expect(find.text('+200 ₮'), findsOneWidget);
      expect(find.text('−75 ₮'), findsOneWidget);
    } finally {
      await t.pumpWidget(const SizedBox());
      await t.pumpAndSettle();
      await db.close();
    }
  });
}
