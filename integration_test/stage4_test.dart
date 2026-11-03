import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hadgaly/features/accounts/data/accounts_repository.dart';
import 'package:hadgaly/features/onboarding/data/app_database.dart';

import '../test/support/stage3_flow.dart';
import '../test/support/stage4_flow.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => binding.testTextInput.register());
  tearDown(() => binding.testTextInput.unregister());
  testWidgets(
    'Native Stage 4 history editing/deletion/filter/audit/persistence',
    (t) async {
      final name = 'hadgaly_stage4_${DateTime.now().microsecondsSinceEpoch}';
      var db = AppDatabase(driftDatabase(name: name));
      try {
        await db.loadProfile();
        await db.createFirstAccount('Тест', 'Хэтэвч', '1000');
        await db.completeOnboarding();
        await verifyStage4Flow(t, db);
        await tapStage3(t, 'historyAction');
        await binding.convertFlutterSurfaceToImage();
        await t.pumpAndSettle();
        await binding.takeScreenshot('stage4-synthetic-history');
        await t.pumpWidget(const SizedBox());
        await t.pumpAndSettle();
        await db.close();
        db = AppDatabase(driftDatabase(name: name));
        final s = await AccountsRepository(db).snapshot();
        expect(s.accounts.map((a) => a.balance), [900, -500]);
        expect(s.entries, hasLength(1));
        expect(await db.select(db.entryRevisions).get(), hasLength(3));
        expect((await db.loadProfile()).completed, isTrue);
        expect(s.defaultId, 1);
        await mountStage3(t, db);
        await tapStage3(t, 'historyAction');
        await revealHistory(
          t,
          'history-anchor-${s.byId(1).adjustments.single.record.id}',
        );
        expect(find.text('Үлдэгдэл тохируулсан'), findsOneWidget);
        await revealHistory(t, 'history-entry-${s.entries.single.id}');
        expect(find.text('−50 ₮'), findsOneWidget);
        await binding.takeScreenshot('stage4-synthetic-history-scrolled');
      } finally {
        await t.pumpWidget(const SizedBox());
        await t.pumpAndSettle();
        await db.close();
      }
    },
  );
}
