import 'package:drift/native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadgaly/features/accounts/data/accounts_repository.dart';
import 'package:hadgaly/features/accounts/domain/ledger.dart';
import 'package:hadgaly/features/onboarding/data/app_database.dart';
import 'package:hadgaly/features/transactions/data/transactions_repository.dart';

import 'support/stage3_flow.dart';
import 'support/stage4_flow.dart';

void main() {
  late AppDatabase db;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.loadProfile();
    await db.createFirstAccount('Тест', 'Хэтэвч', '1000');
    await db.completeOnboarding();
  });
  tearDown(() => db.close());
  testWidgets('Full history flow stays reachable at 320dp and 1.8x', (t) async {
    t.view.physicalSize = const Size(320, 568);
    t.view.devicePixelRatio = 1;
    t.platformDispatcher.textScaleFactorTestValue = 1.8;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    await verifyStage4Flow(t, db);
    await t.pumpWidget(const SizedBox());
    await t.pumpAndSettle();
  });
  testWidgets(
    'History create/edit/move/type/search/filter/delete confirmation/anchors/Home',
    (t) async {
      await verifyStage4Flow(t, db);
      await t.pumpWidget(const SizedBox());
      await t.pumpAndSettle();
    },
  );
  testWidgets(
    'History/edit/confirmation 320dp 1.8x, long notes/names, safe keyboard/accessibility',
    (t) async {
      t.view.physicalSize = const Size(320, 568);
      t.view.devicePixelRatio = 1;
      t.platformDispatcher.textScaleFactorTestValue = 1.8;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
      final repo = TransactionsRepository(db);
      final category = (await db.select(db.categories).get()).firstWhere(
        (c) => c.kind == 'expense',
      );
      final id = await repo.post(
        kind: EventKind.expense,
        amount: '5000',
        accountId: 1,
        categoryId: category.id,
        date: DateTime.now(),
        note: 'Өдрийн хэрэглээний маш урт тэмдэглэл ' * 5,
        requestKey: 'large',
      );
      await AccountsRepository(db)
          .renameAccount(1, 'Өдөр тутмын урт нэртэй хэрэглэгчийн үндсэн данс');
      final semantics = t.ensureSemantics();
      await mountStage3(t, db);
      await tapStage3(t, 'historyAction');
      await expectLater(t, meetsGuideline(androidTapTargetGuideline));
      await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(t, meetsGuideline(textContrastGuideline));
      await t.scrollUntilVisible(
        find.byKey(Key('history-entry-$id')),
        200,
        scrollable: find
            .descendant(
              of: find.byKey(const Key('historyList')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.text('−5,000 ₮'), findsOneWidget);
      expect(t.takeException(), isNull);
      await tapStage3(t, 'history-entry-$id');
      t.view.viewInsets = const FakeViewPadding(bottom: 240);
      await t.pumpAndSettle();
      await t.enterText(find.byKey(const Key('entryAmount')), '1.2');
      await tapStage3(t, 'entrySave');
      expect((await repo.load(id)).revision, 0);
      expect(t.takeException(), isNull);
      t.view.resetViewInsets();
      await t.pumpAndSettle();
      await tapStage3(t, 'deleteEntry');
      await expectLater(t, meetsGuideline(androidTapTargetGuideline));
      await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(t, meetsGuideline(textContrastGuideline));
      await tapStage3(t, 'cancelDelete');
      expect((await repo.load(id)).deleted, isFalse);
      expect(t.takeException(), isNull);
      semantics.dispose();
      await t.pumpWidget(const SizedBox());
      await t.pumpAndSettle();
    },
  );
}
