import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/hadgaly_ui.dart';
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
  String? error;
  Future<void> chooseDefault(AccountsSnapshot snapshot) async {
    if (busy) return;
    final id = await showActionSheet<int>(
      context,
      (sheetContext) => CupertinoActionSheet(
        title: const Text('Үндсэн данс', style: sectionStyle),
        message: const Text(
          'Нүүрэнд харагдах дансаа сонгоорой.',
          style: captionStyle,
        ),
        actions: [
          for (final account in snapshot.accounts)
            CupertinoActionSheetAction(
              key: Key('default-${account.account.id}'),
              onPressed: () => Navigator.pop(sheetContext, account.account.id),
              child: Text(
                '${snapshot.defaultId == account.account.id ? '✓ ' : ''}${account.account.name}',
                style: const TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 17,
                  color: green,
                ),
              ),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          key: const Key('cancelDefault'),
          onPressed: () => Navigator.pop(sheetContext),
          child: const Text(
            'Болих',
            style: TextStyle(
              fontFamily: 'Comfortaa',
              color: green,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
    if (id == null || !mounted) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await ref.read(accountsRepositoryProvider).selectDefault(id);
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'Үндсэн дансыг сольж чадсангүй. Дахин оролдоорой.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => HadgalyPage(
    title: 'Миний данс',
    child: ref
        .watch(accountsProvider)
        .when(
          loading: () => const LoadingContent(),
          error: (_, _) => const PageContent(
            children: [
              InlineError('Дансны мэдээллийг нээж чадсангүй. Дахин нээгээрэй.'),
            ],
          ),
          data: (snapshot) => PageContent(
            children: [
              BalanceCard(
                account: snapshot.defaultAccount,
                label: 'Үндсэн данс',
                canChooseDefault: true,
                onChooseDefault: busy ? null : () => chooseDefault(snapshot),
              ),
              if (error != null) InlineError(error!),
              const SizedBox(height: 20),
              Semantics(
                header: true,
                child: const Text('Миний бүх данс', style: sectionStyle),
              ),
              const SizedBox(height: 12),
              InsetGroup(
                children: [
                  for (final account in snapshot.accounts)
                    CupertinoButton(
                      key: Key('account-${account.account.id}'),
                      minimumSize: const Size(48, 80),
                      padding: const EdgeInsets.all(18),
                      onPressed: () => openPage<void>(
                        context,
                        AccountDetailScreen(id: account.account.id),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  account.account.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.4,
                                    fontWeight: FontWeight.w700,
                                    color: ink,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  formatMnt(account.balance),
                                  style: const TextStyle(
                                    fontSize: 19,
                                    height: 1.4,
                                    color: ink,
                                  ),
                                ),
                                if (snapshot.defaultId ==
                                    account.account.id) ...[
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Үндсэн данс',
                                    style: captionStyle,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            CupertinoIcons.chevron_right,
                            size: 17,
                            color: secondaryInk,
                          ),
                        ],
                      ),
                    ),
                  CupertinoButton(
                    key: const Key('addAccount'),
                    minimumSize: const Size(48, 60),
                    padding: const EdgeInsets.all(18),
                    onPressed: () =>
                        openPage<void>(context, const AccountFormScreen()),
                    child: const Row(
                      children: [
                        Icon(CupertinoIcons.add_circled, size: 23),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Данс нэмэх',
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.4,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
  );
}

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.account,
    required this.label,
    this.canChooseDefault = false,
    this.onChooseDefault,
  });
  final AccountView account;
  final String label;
  final bool canChooseDefault;
  final VoidCallback? onChooseDefault;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: mint,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: captionStyle)),
            if (canChooseDefault)
              Semantics(
                label: 'Үндсэн данс солих',
                button: true,
                enabled: onChooseDefault != null,
                onTap: onChooseDefault,
                child: ExcludeSemantics(
                  child: CupertinoButton(
                    key: const Key('chooseDefault'),
                    minimumSize: const Size(48, 48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    onPressed: onChooseDefault,
                    child: const Text(
                      'Солих',
                      style: TextStyle(
                        fontFamily: 'Comfortaa',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: green,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(account.account.name, style: sectionStyle),
        const SizedBox(height: 12),
        Text(
          formatMnt(account.balance),
          key: const Key('defaultBalance'),
          style: const TextStyle(
            fontSize: 29,
            height: 1.35,
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
  Widget build(BuildContext context, WidgetRef ref) => HadgalyPage(
    title: 'Данс',
    child: ref
        .watch(accountsProvider)
        .when(
          loading: () => const LoadingContent(),
          error: (_, _) => const PageContent(
            children: [InlineError('Дансны мэдээллийг нээж чадсангүй.')],
          ),
          data: (snapshot) {
            final account = snapshot.byId(id);
            return PageContent(
              children: [
                BalanceCard(account: account, label: 'Үлдэгдэл'),
                const SizedBox(height: 12),
                Text(
                  'Эхний үлдэгдэл: ${formatMnt(account.account.openingBalance)}',
                  style: captionStyle,
                ),
                const SizedBox(height: 16),
                HadgalyButton(
                  label: 'Дансны нэр засах',
                  filled: false,
                  icon: CupertinoIcons.pencil,
                  onPressed: () => openPage<void>(
                    context,
                    AccountFormScreen(account: account),
                  ),
                ),
                const SizedBox(height: 8),
                HadgalyButton(
                  key: const Key('adjustBalance'),
                  label: 'Үлдэгдэл тохируулах',
                  onPressed: () => openPage<void>(
                    context,
                    BalanceFormScreen(account: account),
                  ),
                ),
                const SizedBox(height: 32),
                Semantics(
                  header: true,
                  child: const Text(
                    'Үлдэгдэл тохируулгын түүх',
                    style: sectionStyle,
                  ),
                ),
                const SizedBox(height: 14),
                if (account.adjustments.isEmpty)
                  const Text(
                    'Үлдэгдэл тохируулга хараахан хийгээгүй байна.',
                    style: TextStyle(color: secondaryInk),
                  ),
                if (account.adjustments.isNotEmpty)
                  InsetGroup(
                    children: [
                      for (final adjustment in account.adjustments)
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                formatMnt(adjustment.record.target),
                                style: const TextStyle(
                                  fontSize: 24,
                                  height: 1.4,
                                  fontWeight: FontWeight.w700,
                                  color: ink,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Хүчинтэй: ${displayTime(adjustment.record.effectiveAt)}',
                                style: captionStyle,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Анх ажигласан зөрүү: ${formatMnt(adjustment.originalDifference)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.6,
                                  color: ink,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Дахин тооцсон зөрүү: ${formatMnt(adjustment.point.difference!)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.6,
                                  color: ink,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Орлого, зарлагад тооцохгүй.',
                                style: captionStyle,
                              ),
                              const SizedBox(height: 4),
                              HadgalyButton(
                                key: Key(
                                  'editAdjustment-${adjustment.record.id}',
                                ),
                                label: 'Тохируулгын дүн засах',
                                filled: false,
                                onPressed: () => openPage<void>(
                                  context,
                                  BalanceFormScreen(
                                    account: account,
                                    adjustment: adjustment,
                                  ),
                                ),
                              ),
                              if (adjustment.edits.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                const Text(
                                  'Засварын түүх',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: ink,
                                  ),
                                ),
                                for (final edit in adjustment.edits)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Засвар: ${formatMnt(edit.oldTarget)} → ${formatMnt(edit.newTarget)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            height: 1.6,
                                            color: ink,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          displayTime(edit.editedAt),
                                          style: captionStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            );
          },
        ),
  );
}
