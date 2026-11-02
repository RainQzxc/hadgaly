import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/hadgaly_ui.dart';
import '../../../core/domain/money.dart';
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
          data: (snapshot) => _body(snapshot.defaultAccount),
        ),
  );
  Widget _body(AccountView current) => PageContent(
    children: [
      Text(
        'Сайн уу, ${widget.name}',
        style: const TextStyle(
          fontSize: 23,
          height: 1.4,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'Өдөр тутмын мөнгөө хамтдаа цэгцэлье.',
        style: TextStyle(color: secondaryInk),
      ),
      const SizedBox(height: 28),
      LayoutBuilder(
        builder: (context, c) {
          final actions = [
            _EntryAction(
              label: 'Орлого',
              symbol: '+',
              color: mint,
              onTap: () => setState(() => showUnavailable = true),
            ),
            _EntryAction(
              label: 'Зарлага',
              symbol: '−',
              color: const Color(0xFFF8E1D9),
              onTap: () => setState(() => showUnavailable = true),
            ),
          ];
          return c.maxWidth < 300 ||
                  MediaQuery.textScalerOf(context).scale(16) > 22
              ? Column(
                  children: [
                    actions[0],
                    const SizedBox(height: 14),
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
      if (showUnavailable)
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Semantics(
            liveRegion: true,
            child: const Text(
              'Гүйлгээ бүртгэх боломж хараахан нээгдээгүй байна.',
              style: captionStyle,
            ),
          ),
        ),
      const SizedBox(height: 28),
      InsetGroup(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Үндсэн данс', style: captionStyle),
                const SizedBox(height: 8),
                Text(current.account.name, style: sectionStyle),
                const SizedBox(height: 10),
                Text(
                  formatMnt(current.balance),
                  key: const Key('homeBalance'),
                  style: const TextStyle(
                    fontSize: 29,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            key: const Key('myAccounts'),
            minimumSize: const Size(48, 56),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            onPressed: () => openPage<void>(context, const AccountsScreen()),
            child: const Row(
              children: [
                Icon(CupertinoIcons.creditcard, size: 21),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Миний данс',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                Icon(CupertinoIcons.chevron_right, size: 16),
              ],
            ),
          ),
        ],
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
        color: color,
        foregroundColor: ink,
        borderRadius: BorderRadius.circular(26),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        minimumSize: const Size(48, 132),
        onPressed: onTap,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Text(
                symbol,
                style: const TextStyle(
                  fontSize: 44,
                  height: 1.15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
