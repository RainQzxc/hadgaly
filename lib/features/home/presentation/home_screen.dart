import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/hadgaly_ui.dart';
import '../../accounts/application/accounts_providers.dart';
import '../../accounts/data/accounts_repository.dart';
import '../../accounts/presentation/accounts_screen.dart';
import '../../accounts/domain/ledger.dart';
import '../data/dashboard_report.dart';
import '../../transactions/domain/entry_rules.dart';
import '../domain/dashboard.dart';
import 'dashboard_details.dart';
import '../../transactions/presentation/entry_screen.dart';
import '../../transactions/presentation/history_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.name});
  final String name;
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  Timer? dayTimer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    scheduleDay();
  }

  void scheduleDay() {
    dayTimer?.cancel();
    final now = DateTime.now();
    dayTimer = Timer(
      DateTime(now.year, now.month, now.day + 1).difference(now),
      () {
        if (mounted) {
          setState(() {});
          scheduleDay();
        }
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
      scheduleDay();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    dayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HadgalyPage(
    title: 'хадгалъя',
    child: ref
        .watch(accountsProvider)
        .when(
          loading: () => const LoadingContent(),
          error: (_, _) => const PageContent(
            children: [
              InlineError('Дансны мэдээллийг нээж чадсангүй. Дахин нээгээрэй.'),
            ],
          ),
          data: _body,
        ),
  );

  Widget _body(AccountsSnapshot snapshot) {
    final month = DateTime.now();
    final report = dashboardReport(snapshot, month);
    final flows = report.current;
    final balance = signedMoney(report.balance).replaceFirst('+', '');
    return LayoutBuilder(
      builder: (context, constraints) {
        final textGrowth = math.max(
          0.0,
          MediaQuery.textScalerOf(context).scale(16) / 16 - 1,
        );
        // Short screens use less chrome; larger text grows the ring.
        final ringSize = math.min(
          constraints.maxWidth - 40,
          (constraints.maxHeight - 450).clamp(176, 200) + textGrowth * 40,
        );
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Сайн уу, ${widget.name}',
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          color: secondaryInk,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: _PeriodDonut(
                          // Normal size is about 30% below the old 340dp ring.
                          size: ringSize,
                          totals: flows,
                          shares: report.categories,
                          month: month,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Semantics(
                        label: 'Бүх дансны одоогийн нийт үлдэгдэл: $balance',
                        child: ExcludeSemantics(
                          child: Column(
                            children: [
                              const Text(
                                'Нийт үлдэгдэл',
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: secondaryInk,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                balance,
                                key: const Key('homeBalance'),
                                textAlign: TextAlign.center,
                                style: sectionStyle.copyWith(
                                  fontSize: 30,
                                  height: 1.2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _EntryAction(
                              label: 'Зарлага',
                              symbol: '−',
                              color: expense,
                              onTap: () => openPage<void>(
                                context,
                                const EntryScreen(kind: EventKind.expense),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _EntryAction(
                              label: 'Орлого',
                              symbol: '+',
                              color: teal,
                              onTap: () => openPage<void>(
                                context,
                                const EntryScreen(kind: EventKind.income),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      CupertinoButton(
                        key: const Key('historyAction'),
                        minimumSize: const Size(48, 48),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        onPressed: () =>
                            openPage<void>(context, const HistoryScreen()),
                        child: const Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Гүйлгээний түүх',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: secondaryInk,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              CupertinoIcons.chevron_right,
                              size: 16,
                              color: secondaryInk,
                            ),
                          ],
                        ),
                      ),
                      CupertinoButton(
                        key: const Key('myAccounts'),
                        minimumSize: const Size(48, 48),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        onPressed: () =>
                            openPage<void>(context, const AccountsScreen()),
                        child: const Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Миний данс',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: secondaryInk,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              CupertinoIcons.chevron_right,
                              size: 16,
                              color: secondaryInk,
                            ),
                          ],
                        ),
                      ),
                      DashboardDetails(
                        report: report,
                        categories: snapshot.categories,
                        month: month,
                      ),
                      const Text('Дансны тойм', style: sectionStyle),
                      const SizedBox(height: 8),
                      AccountSummary(snapshot: snapshot),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Both segments and center describe expense categories for the same month.
/// Income remains outside the chart; large text can grow/scroll without clipping.
class _PeriodDonut extends StatelessWidget {
  const _PeriodDonut({
    required this.size,
    required this.totals,
    required this.shares,
    required this.month,
  });
  final List<CategoryShare> shares;
  final double size;
  final FlowTotals totals;
  final DateTime month;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        '${month.year} оны ${month.month}-р сар',
        style: captionStyle,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 8),
      Center(
        child: Semantics(
          key: const Key('expenseDonut'),
          label:
              'Энэ сарын зарлагын ангиллын хуваарилалт. Нийт зарлага: −${formatFlow(totals.expense)}.${shares.isEmpty ? ' Зарлага бүртгэгдээгүй.' : ' Ангилал тус бүрийн дүн, хувь доор байна.'}',
          image: true,
          child: ExcludeSemantics(
            child: CustomPaint(
              painter: ExpenseRing(shares),
              child: Container(
                width: size,
                constraints: BoxConstraints(minHeight: size),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Сарын зарлага',
                      textAlign: TextAlign.center,
                      style: captionStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '−${formatFlow(totals.expense)}',
                      key: const Key('periodExpense'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                        color: ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        totals.expense > BigInt.zero
            ? 'Зарлага · ангиллаар'
            : totals.income == BigInt.zero
            ? 'Энэ сард гүйлгээ бүртгэгдээгүй.'
            : 'Зарлага бүртгэгдээгүй.',
        textAlign: TextAlign.center,
        style: captionStyle,
      ),
      const SizedBox(height: 16),
      DashboardValueRow(
        key: const Key('monthlyIncomeRow'),
        leading: const Text(
          'Сарын орлого',
          style: TextStyle(fontSize: 14, color: secondaryInk),
        ),
        value: Text(
          '+${formatFlow(totals.income)}',
          key: const Key('periodIncome'),
          style: const TextStyle(
            fontSize: 20,
            height: 1.3,
            fontWeight: FontWeight.w600,
            color: incomeInk,
          ),
        ),
      ),
    ],
  );
}

class _EntryAction extends StatelessWidget {
  const _EntryAction({
    required this.label,
    required this.symbol,
    required this.color,
    required this.onTap,
  });
  final String label, symbol;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '$label нэмэх',
    enabled: true,
    onTap: onTap,
    child: ExcludeSemantics(
      child: CupertinoButton(
        key: Key(label == 'Зарлага' ? 'expenseAction' : 'incomeAction'),
        color: color,
        foregroundColor: ink,
        borderRadius: BorderRadius.circular(18),
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.textScalerOf(context).scale(16) > 22 ? 4 : 12,
          vertical: 12,
        ),
        minimumSize: const Size(48, 64),
        onPressed: onTap,
        child: SizedBox(
          width: double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final icon = Icon(
                symbol == '+' ? CupertinoIcons.add : CupertinoIcons.minus,
                size: 20,
              );
              final text = Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              );
              return MediaQuery.textScalerOf(context).scale(16) > 22
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [icon, const SizedBox(height: 4), text],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        icon,
                        const SizedBox(width: 8),
                        Flexible(child: text),
                      ],
                    );
            },
          ),
        ),
      ),
    ),
  );
}
