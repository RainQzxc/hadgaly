import 'package:drift/native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadgaly/features/onboarding/data/app_database.dart';
import 'package:hadgaly/features/accounts/data/accounts_repository.dart';
import 'package:hadgaly/features/accounts/domain/ledger.dart';
import 'package:hadgaly/features/transactions/data/transactions_repository.dart';

import 'support/stage3_flow.dart';
import 'support/stage5_data.dart';
import 'support/stage5_flow.dart';

void main() {
  testWidgets(
    'Large exact amounts and long metadata remain readable at 320dp 1.8x',
    (t) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final now = DateTime.now();
      final ids = await seedStage5(db, now);
      final repo = TransactionsRepository(db, clock: () => now);
      await AccountsRepository(db).renameAccount(
        ids.card,
        'Өдөр тутмын хэрэглээний үндсэн урт нэртэй данс',
      );
      await repo.saveCategory(
        id: ids.cart,
        kind: EventKind.expense,
        name: 'Өдөр тутмын хэрэглээний урт нэртэй ангилал',
        icon: 'cart',
        requestKey: 'long-category',
      );
      for (final kind in [EventKind.income, EventKind.expense]) {
        await repo.post(
          kind: kind,
          amount: '999999999999',
          accountId: ids.card,
          categoryId: kind == EventKind.income ? ids.income : ids.cart,
          date: now,
          requestKey: 'max-${kind.name}',
        );
      }
      t.view.physicalSize = const Size(320, 568);
      t.view.devicePixelRatio = 1;
      t.platformDispatcher.textScaleFactorTestValue = 1.8;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
      await mountStage3(t, db);
      expect(
        t.widget<Text>(find.byKey(const Key('periodIncome'))).data,
        '+1,000,000,000,199 ₮',
      );
      expect(
        t.widget<Text>(find.byKey(const Key('periodExpense'))).data,
        '−1,000,000,000,074 ₮',
      );
      expect(
        t.widget<Text>(find.byKey(const Key('homeBalance'))).data,
        '375 ₮',
      );
      for (final key in [
        'categoryShare-${ids.cart}',
        'comparison-Орлого',
        'overview-account-${ids.card}',
      ]) {
        await t.ensureVisible(find.byKey(Key(key)));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        final box = t.getRect(find.byKey(Key(key)));
        expect(box.left, greaterThanOrEqualTo(0));
        expect(box.right, lessThanOrEqualTo(320));
      }
      expect(
        find.text('Өдөр тутмын хэрэглээний урт нэртэй ангилал'),
        findsOneWidget,
      );
      expect(
        find.text('Өдөр тутмын хэрэглээний үндсэн урт нэртэй данс'),
        findsOneWidget,
      );
      await t.pumpWidget(const SizedBox());
      await t.pumpAndSettle();
    },
  );
  for (final small in [false, true]) {
    testWidgets(
      'Dashboard real categories, comparison, quick add, navigation${small ? ' 320dp 1.8x' : ''}',
      (t) async {
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);
        t.view.physicalSize = Size(small ? 320 : 390, small ? 568 : 844);
        t.view.devicePixelRatio = 1;
        t.platformDispatcher.textScaleFactorTestValue = small ? 1.8 : 1;
        addTearDown(t.view.resetPhysicalSize);
        addTearDown(t.view.resetDevicePixelRatio);
        addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
        await seedStage5(db, DateTime.now());
        await verifyStage5Flow(t, db);
        await expectLater(t, meetsGuideline(textContrastGuideline));
        await t.pumpWidget(const SizedBox());
        await t.pumpAndSettle();
      },
    );
  }
}
