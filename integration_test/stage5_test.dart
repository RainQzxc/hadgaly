import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hadgaly/features/accounts/data/accounts_repository.dart';
import 'package:hadgaly/features/home/data/dashboard_report.dart';
import 'package:hadgaly/features/onboarding/data/app_database.dart';

import '../test/support/stage3_flow.dart';
import '../test/support/stage5_data.dart';
import '../test/support/stage5_flow.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => binding.testTextInput.register());
  tearDown(() => binding.testTextInput.unregister());
  testWidgets(
    'Native Stage5 dashboard, quick add, navigation and durable resolved reports',
    (t) async {
      final name = 'hadgaly_stage5_${DateTime.now().microsecondsSinceEpoch}';
      var db = AppDatabase(driftDatabase(name: name));
      try {
        await seedStage5(db, DateTime.now());
        await verifyStage5Flow(t, db);
        await t.pumpWidget(const SizedBox());
        await t.pumpAndSettle();
        await db.close();
        db = AppDatabase(driftDatabase(name: name));
        final s = await AccountsRepository(db).snapshot(),
            r = dashboardReport(
              await AccountsRepository(db).snapshot(),
              DateTime.now(),
            );
        expect(r.balance, BigInt.from(385));
        expect(r.net, BigInt.from(135));
        expect(r.current.expense, BigInt.from(75));
        expect(r.previous.expense, BigInt.from(100));
        expect(s.defaultId, 2);
        expect(s.byId(2).balance, -515);
        expect(s.categories.any((c) => c.archived), isTrue);
        expect(await db.select(db.entryRevisions).get(), isEmpty);
        await mountStage3(t, db);
        expect(
          t.widget<Text>(find.byKey(const Key('homeBalance'))).data,
          '385 ₮',
        );
        // Convert the Android surface only after all interactive checks/reopen.
        // Do not remount an app or inject gestures across an image-surface swap.
        await binding.convertFlutterSurfaceToImage();
        await t.pump(const Duration(milliseconds: 100));
        await t.pumpAndSettle();
        await binding.takeScreenshot('stage5-synthetic-home');
        await binding.takeScreenshot('stage5-synthetic-reopened');
        await t.ensureVisible(find.byKey(const Key('monthlyNet')));
        await t.pump(const Duration(milliseconds: 100));
        await t.pumpAndSettle();
        await binding.takeScreenshot('stage5-synthetic-details');
      } finally {
        await t.pumpWidget(const SizedBox());
        await t.pumpAndSettle();
        await db.close();
      }
    },
  );
}
