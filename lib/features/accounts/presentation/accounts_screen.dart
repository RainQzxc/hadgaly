import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../../../core/domain/money.dart';
import '../application/accounts_providers.dart';
import '../data/accounts_repository.dart';
import 'account_forms.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});
  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  bool busy = false;
  Future<void> selectDefault(int id) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await ref.read(accountsRepositoryProvider).selectDefault(id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Үндсэн дансыг сольж чадсангүй. Дахин оролдоорой.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Миний данс')),
    body: ref
        .watch(accountsProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Дансны мэдээллийг нээж чадсангүй. Дахин нээгээрэй.'),
            ),
          ),
          data: (snapshot) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BalanceCard(
                      account: snapshot.defaultAccount,
                      label: 'Үндсэн данс',
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      key: const Key('addAccount'),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const AccountFormScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Данс нэмэх'),
                    ),
                    const SizedBox(height: 28),
                    Semantics(
                      header: true,
                      child: const Text(
                        'Миний бүх данс',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final account in snapshot.accounts)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Card(
                          margin: EdgeInsets.zero,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                            side: const BorderSide(color: Color(0xFFDDE5DC)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ListTile(
                                key: Key('account-${account.account.id}'),
                                contentPadding: const EdgeInsets.all(20),
                                title: Text(
                                  account.account.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    formatMnt(account.balance),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: ink,
                                    ),
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => AccountDetailScreen(
                                      id: account.account.id,
                                    ),
                                  ),
                                ),
                              ),
                              if (snapshot.defaultId == account.account.id)
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                                  child: Text(
                                    'Үндсэн данс',
                                    style: TextStyle(color: green),
                                  ),
                                )
                              else
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      8,
                                      0,
                                      8,
                                      8,
                                    ),
                                    child: TextButton(
                                      key: Key('default-${account.account.id}'),
                                      onPressed: busy
                                          ? null
                                          : () => selectDefault(
                                              account.account.id,
                                            ),
                                      child: const Text('Үндсэн болгох'),
                                    ),
                                  ),
                                ),
                            ],
                          ),
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

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key, required this.account, required this.label});
  final AccountView account;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: mint,
      borderRadius: BorderRadius.circular(28),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: secondaryInk)),
        const SizedBox(height: 12),
        Text(
          account.account.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Text(
          formatMnt(account.balance),
          key: const Key('defaultBalance'),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
        ),
      ],
    ),
  );
}

class AccountDetailScreen extends ConsumerWidget {
  const AccountDetailScreen({super.key, required this.id});
  final int id;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Дансны дэлгэрэнгүй')),
    body: ref
        .watch(accountsProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) =>
              const Center(child: Text('Дансны мэдээллийг нээж чадсангүй.')),
          data: (snapshot) {
            final account = snapshot.byId(id);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      BalanceCard(account: account, label: 'Үлдэгдэл'),
                      const SizedBox(height: 12),
                      Text(
                        'Эхний үлдэгдэл: ${formatMnt(account.account.openingBalance)}',
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => AccountFormScreen(account: account),
                          ),
                        ),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Дансны нэр засах'),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        key: const Key('adjustBalance'),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => BalanceFormScreen(account: account),
                          ),
                        ),
                        child: const Text('Үлдэгдэл тохируулах'),
                      ),
                      const SizedBox(height: 28),
                      Semantics(
                        header: true,
                        child: const Text(
                          'Үлдэгдэл тохируулгын түүх',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (account.adjustments.isEmpty)
                        const Text(
                          'Үлдэгдэл тохируулга хараахан хийгээгүй байна.',
                        ),
                      for (final adjustment in account.adjustments)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: const Color(0xFFDDE5DC),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  formatMnt(adjustment.record.target),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Хүчинтэй: ${displayTime(adjustment.record.effectiveAt)}',
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Анх ажигласан зөрүү: ${formatMnt(adjustment.originalDifference)}',
                                ),
                                Text(
                                  'Дахин тооцсон зөрүү: ${formatMnt(adjustment.point.difference!)}',
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Орлого, зарлагад тооцохгүй.',
                                  style: TextStyle(color: secondaryInk),
                                ),
                                TextButton(
                                  key: Key(
                                    'editAdjustment-${adjustment.record.id}',
                                  ),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (_) => BalanceFormScreen(
                                        account: account,
                                        adjustment: adjustment,
                                      ),
                                    ),
                                  ),
                                  child: const Text('Тохируулгын дүн засах'),
                                ),
                                for (final edit in adjustment.edits)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Text(
                                      'Засвар: ${formatMnt(edit.oldTarget)} → ${formatMnt(edit.newTarget)}\n${displayTime(edit.editedAt)}',
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
  );
}
