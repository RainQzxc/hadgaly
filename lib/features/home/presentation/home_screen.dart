import 'package:flutter/material.dart';

import '../../../app.dart';
import '../../../core/domain/money.dart';
import '../../onboarding/data/app_database.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.name, required this.account});
  final String name;
  final Account account;
  void _unavailable(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Гүйлгээ бүртгэх боломж хараахан нээгдээгүй байна.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'хадгалъя',
                  style: TextStyle(
                    fontSize: 22,
                    color: green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Сайн уу, $name',
                  style: const TextStyle(
                    fontSize: 24,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Өдөр тутмын мөнгөө хамтдаа цэгцэлье.',
                  style: TextStyle(color: ink),
                ),
                const SizedBox(height: 32),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final stack =
                        constraints.maxWidth < 300 ||
                        MediaQuery.textScalerOf(context).scale(16) > 22;
                    final actions = [
                      _EntryAction(
                        label: 'Орлого',
                        symbol: '+',
                        color: mint,
                        onTap: () => _unavailable(context),
                      ),
                      _EntryAction(
                        label: 'Зарлага',
                        symbol: '−',
                        color: const Color(0xFFF8E1D9),
                        onTap: () => _unavailable(context),
                      ),
                    ];
                    return stack
                        ? Column(
                            children: [
                              actions[0],
                              const SizedBox(height: 16),
                              actions[1],
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(child: actions[0]),
                              const SizedBox(width: 16),
                              Expanded(child: actions[1]),
                            ],
                          );
                  },
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFDDE5DC)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Үндсэн данс',
                        style: TextStyle(fontSize: 13, color: secondaryInk),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        account.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        formatMnt(account.openingBalance),
                        key: const Key('homeBalance'),
                        style: const TextStyle(
                          fontSize: 28,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
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
    child: Material(
      color: color,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
          child: ExcludeSemantics(
            child: Column(
              children: [
                Text(
                  symbol,
                  style: const TextStyle(
                    fontSize: 48,
                    height: 1.15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
