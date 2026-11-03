import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/hadgaly_ui.dart';
import '../../accounts/application/accounts_providers.dart';
import '../../accounts/data/accounts_repository.dart';
import '../../accounts/presentation/accounts_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.name});
  final String name;
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool showUnavailable = false;
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
    // Sum verified current balances, including openings and authoritative anchors.
    // BigInt avoids overflow across many individually valid account balances.
    final total = snapshot.accounts.fold<BigInt>(
      BigInt.zero,
      (sum, account) => sum + BigInt.from(account.balance),
    );
    final digits = total.abs().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    final balance = '${total.isNegative ? '−' : ''}$digits ₮';
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: math.max(0, constraints.maxHeight - 28),
                maxWidth: 480,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Сайн уу, ${widget.name}', style: sectionStyle),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Center(
                          child: _EmptyExpenseDonut(
                            size: math.min(constraints.maxWidth - 40, 340),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Гүйлгээ бүртгэгдээгүй байна.',
                          textAlign: TextAlign.center,
                          style: captionStyle,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Semantics(
                        label: 'Бүх дансны одоогийн нийт үлдэгдэл: $balance',
                        child: ExcludeSemantics(
                          child: Text(
                            'Нийт үлдэгдэл: $balance',
                            key: const Key('homeBalance'),
                            textAlign: TextAlign.center,
                            style: sectionStyle.copyWith(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _EntryAction(
                              label: 'Зарлага',
                              symbol: '−',
                              color: expense,
                              onTap: _unavailable,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _EntryAction(
                              label: 'Орлого',
                              symbol: '+',
                              color: teal,
                              onTap: _unavailable,
                            ),
                          ),
                        ],
                      ),
                      if (showUnavailable)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Semantics(
                            liveRegion: true,
                            child: const Text(
                              'Гүйлгээ бүртгэх боломж хараахан нээгдээгүй байна.',
                              textAlign: TextAlign.center,
                              style: captionStyle,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      CupertinoButton(
                        key: const Key('myAccounts'),
                        minimumSize: const Size(48, 56),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        onPressed: () =>
                            openPage<void>(context, const AccountsScreen()),
                        child: const Text(
                          'Миний данс',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

  void _unavailable() => setState(() => showUnavailable = true);
}

/// Stage 2 has no transaction/category persistence. This neutral ring represents
/// no category data, never invented proportions or income/expense ratios.
class _EmptyExpenseDonut extends StatelessWidget {
  const _EmptyExpenseDonut({required this.size});
  final double size;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Text('Энэ сар', style: captionStyle),
      const SizedBox(height: 8),
      Semantics(
        key: const Key('expenseDonut'),
        label: 'Энэ сарын зарлагын ангиллын хуваарилалт. Гүйлгээ бүртгэгдээгүй. Орлого: +0 ₮. Зарлага: −0 ₮.',
        image: true,
        child: ExcludeSemantics(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: line, width: 14),
            ),
            padding: const EdgeInsets.all(20),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Орлого',
                  style: TextStyle(fontSize: 14, color: incomeInk),
                ),
                Text(
                  '+0 ₮',
                  key: Key('periodIncome'),
                  style: TextStyle(
                    fontSize: 20,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    color: incomeInk,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Зарлага',
                  style: TextStyle(fontSize: 14, color: errorInk),
                ),
                Text(
                  '−0 ₮',
                  key: Key('periodExpense'),
                  style: TextStyle(
                    fontSize: 20,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    color: errorInk,
                  ),
                ),
              ],
            ),
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
    label: '$label. Гүйлгээ бүртгэх боломж хараахан нээгдээгүй',
    enabled: true,
    onTap: onTap,
    child: ExcludeSemantics(
      child: CupertinoButton(
        key: Key(label == 'Зарлага' ? 'expenseAction' : 'incomeAction'),
        color: color,
        foregroundColor: ink,
        borderRadius: BorderRadius.circular(22),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 22),
        minimumSize: const Size(48, 80),
        onPressed: onTap,
        child: SizedBox(
          width: double.infinity,
          child: Text(
            '$symbol $label',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              height: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    ),
  );
}
