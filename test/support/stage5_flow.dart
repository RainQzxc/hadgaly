import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadgaly/features/accounts/data/accounts_repository.dart';
import 'package:hadgaly/features/home/data/dashboard_report.dart';
import 'package:hadgaly/features/onboarding/data/app_database.dart';

import 'stage3_flow.dart';

import 'package:hadgaly/features/home/presentation/dashboard_details.dart';
import 'package:hadgaly/core/presentation/design_tokens.dart';
import 'package:hadgaly/features/home/presentation/report_screen.dart';
import 'package:hadgaly/features/home/presentation/dashboard_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> verifyStage5Flow(WidgetTester t, AppDatabase db) async {
  await mountStage3(t, db);
  expect(t.widget<Text>(find.byKey(const Key('homeBalance'))).data, '375 ₮');
  expect(find.text('+200 ₮'), findsOneWidget);
  expect(find.text('−75 ₮'), findsOneWidget);
  final chart = find.byKey(const Key('expenseDonut'));
  expect(
    find.descendant(of: chart, matching: find.byKey(const Key('periodIncome'))),
    findsNothing,
  );
  expect(
    find.descendant(
      of: chart,
      matching: find.byKey(const Key('periodExpense')),
    ),
    findsOneWidget,
  );
  expect(
    t.widget<Semantics>(chart).properties.label,
    contains('Нийт зарлага: −75 ₮'),
  );
  expect(
    t.widget<Semantics>(chart).properties.label,
    isNot(contains('орлого')),
  );
  expect(find.byType(DashboardDetails), findsNothing);
  expect(find.byType(AccountSummary), findsNothing);
  expect(find.byKey(const Key('monthlyNet')), findsNothing);
  expect(find.byKey(const Key('reportAction')), findsOneWidget);
  final container = ProviderScope.containerOf(
    t.element(find.byKey(const Key('reportAction'))),
  );
  final homeReport = container.read(dashboardProvider).requireValue.report;
  await tapStage3(t, 'reportAction');
  await waitStage3(t, find.byType(ReportScreen));
  await tapStage3(t, 'openModuleMenu');
  expect(find.byKey(const Key('moduleDrawer')), findsOneWidget);
  await t.binding.handlePopRoute();
  await t.pumpAndSettle();
  expect(find.byKey(const Key('moduleDrawer')), findsNothing);
  expect(find.byType(ReportScreen), findsOneWidget);
  expect(
    container.read(dashboardProvider).requireValue.report,
    same(homeReport),
  );
  expect(
    t.widget<Text>(find.byKey(const Key('comparison-current-Орлого'))).data,
    '200 ₮',
  );
  expect(
    t.widget<Text>(find.byKey(const Key('comparison-current-Зарлага'))).data,
    '75 ₮',
  );
  expect(find.byKey(const Key('overview-default-2')), findsOneWidget);
  expect(find.byKey(const Key('overview-default-1')), findsNothing);
  expect(
    t.widget<Text>(find.byKey(const Key('overview-balance-2'))).data,
    '−525 ₮',
  );
  expect(find.text('Одоо: 200 ₮'), findsNothing);
  expect(
    find.text('Энэ сарын орлого − зарлага. Нийт үлдэгдлээс тусдаа.'),
    findsNothing,
  );

  expect(find.text('Цэвэр: +125 ₮'), findsOneWidget);
  expect(find.text('Хоол · архив'), findsOneWidget);
  expect(find.text('50 ₮ · 66.7%'), findsOneWidget);
  expect(find.text('25 ₮ · 33.3%'), findsOneWidget);
  expect(find.text('Өссөн · +100 ₮ (+100.0%)'), findsOneWidget);
  expect(find.text('Буурсан · −25 ₮ (−25.0%)'), findsOneWidget);
  final semantics = t.ensureSemantics();
  for (final key in ['monthlyNet', 'comparison-Орлого', 'overview-account-2']) {
    await t.ensureVisible(find.byKey(Key(key)));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);

    await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
  }
  // Check actual resolved text styles against the opaque page surface. Flutter's
  // pixel histogram guideline selects antialias fringe colors for clipped native
  // glyphs; widget tests separately retain the raster guideline.
  for (final element
      in find
          .descendant(
            of: find.byType(DashboardDetails),
            matching: find.byType(Text),
          )
          .evaluate()) {
    final text = element.widget as Text;
    final style = DefaultTextStyle.of(element).style.merge(text.style);
    final color = style.color!;
    final a = color.computeLuminance(), b = paper.computeLuminance();
    expect(
      (a > b ? (a + .05) / (b + .05) : (b + .05) / (a + .05)),
      greaterThanOrEqualTo(4.5),
    );
    expect(style.fontSize, greaterThanOrEqualTo(13));
  }
  await tapStage3(t, 'back');
  expect(find.byKey(const Key('homeBalance')), findsOneWidget);
  expect(find.byType(DashboardDetails), findsNothing);
  // Full layout bounds, not clipped semantics at a scroll boundary. A partially
  // visible sibling keeps its original tap area; Android clips its semantic rect.
  for (final key in [
    'expenseAction',
    'incomeAction',
    'historyAction',
    'myAccounts',
    'reportAction',
  ]) {
    await readyStage3(t, key);
    final target = find.byKey(Key(key));
    expect(t.getSize(target).height, greaterThanOrEqualTo(48));
    expect(t.getSize(target).width, greaterThanOrEqualTo(48));
    expect(target.hitTestable(), findsOneWidget);
  }
  // At the top, primary controls are fully visible or offscreen, never clipped.
  final scroll = find
      .descendant(
        of: find.byType(SingleChildScrollView).first,
        matching: find.byType(Scrollable),
      )
      .first;
  t.state<ScrollableState>(scroll).position.jumpTo(0);
  await t.pumpAndSettle();
  await expectLater(t, meetsGuideline(androidTapTargetGuideline));
  semantics.dispose();
  await tapStage3(t, 'incomeAction');
  expect(
    find.descendant(
      of: find.byKey(const Key('entryAccount')),
      matching: find.text('Карт'),
    ),
    findsOneWidget,
  );
  await t.enterText(find.byKey(const Key('entryAmount')), '10');
  final income = (await db.select(db.categories).get())
      .firstWhere((c) => c.kind == 'income')
      .id;
  await tapStage3(t, 'category-$income');
  await tapStage3(t, 'entrySave');
  await waitStage3(t, find.text('+210 ₮'));
  expect(t.widget<Text>(find.byKey(const Key('homeBalance'))).data, '385 ₮');
  expect(
    dashboardReport(
      await AccountsRepository(db).snapshot(),
      DateTime.now(),
    ).net,
    BigInt.from(135),
  );
  await tapStage3(t, 'expenseAction');
  await t.enterText(find.byKey(const Key('entryAmount')), '999');
  await tapStage3(t, 'back');
  expect(await db.select(db.cashEntries).get(), hasLength(6));
  await tapStage3(t, 'historyAction');
  expect(find.byKey(const Key('historyList')), findsOneWidget);
  await t.binding.handlePopRoute();
  await t.pumpAndSettle();
  expect(find.byKey(const Key('homeBalance')), findsOneWidget);
  await tapStage3(t, 'myAccounts');
  expect(find.byKey(const Key('addAccount')), findsOneWidget);
  await t.binding.handlePopRoute();
  await t.pumpAndSettle();
  for (var i = 0; i < 3; i++) {
    await tapStage3(t, 'openModuleMenu');
    await tapStage3(t, 'module-$i');
    expect(find.text('Тун удахгүй'), findsOneWidget);
  }
  await t.binding.handlePopRoute();
  await t.pumpAndSettle();
  expect(find.byKey(const Key('homeBalance')), findsOneWidget);
  await tapStage3(t, 'reportAction');
  expect(find.byType(ReportScreen), findsOneWidget);
  expect(
    t.widget<Text>(find.byKey(const Key('monthlyNet'))).data,
    'Цэвэр: +135 ₮',
  );
  await t.binding.handlePopRoute();
  await t.pumpAndSettle();
  expect(find.byKey(const Key('reportAction')), findsOneWidget);
  expect(find.byType(DashboardDetails), findsNothing);
  expect(t.takeException(), isNull);
}
