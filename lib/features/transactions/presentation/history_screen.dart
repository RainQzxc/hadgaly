import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/money.dart';
import '../../../core/presentation/hadgaly_ui.dart';
import '../../accounts/application/accounts_providers.dart';
import '../../accounts/domain/ledger.dart';
import '../../accounts/presentation/accounts_screen.dart';
import '../application/transactions_providers.dart';
import '../domain/entry_rules.dart';
import '../domain/history.dart';
import 'entry_screen.dart';

const periodLabels = {
  HistoryPeriod.all: 'Бүх хугацаа',
  HistoryPeriod.month: 'Энэ сар',
  HistoryPeriod.previousMonth: 'Өмнөх сар',
  HistoryPeriod.week: 'Сүүлийн 7 хоног',
};

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});
  @override
  ConsumerState<HistoryScreen> createState() => _HistoryState();
}

class _HistoryState extends ConsumerState<HistoryScreen>
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

  final search = TextEditingController();
  int? account;
  EventKind? kind;
  HistoryPeriod period = HistoryPeriod.all;
  String? error;
  bool opening = false;
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    dayTimer?.cancel();
    search.dispose();
    super.dispose();
  }

  Future<void> openEntry(int id) async {
    if (opening) return;
    setState(() {
      opening = true;
      error = null;
    });
    try {
      final state = await ref.read(transactionsRepositoryProvider).load(id);
      if (!mounted) return;
      if (state.deleted) throw const FormatException('Гүйлгээ устсан байна.');
      await openPage<void>(
        context,
        EntryScreen(
          kind: state.entry.kind == 'income'
              ? EventKind.income
              : EventKind.expense,
          entry: state.entry,
          revision: state.revision,
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Гүйлгээг нээж чадсангүй. Дахин оролдоорой.');
      }
    } finally {
      if (mounted) setState(() => opening = false);
    }
  }

  Widget filterButton(String key, String label, VoidCallback onTap) =>
      CupertinoButton(
        key: Key(key),
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        color: CupertinoColors.white,
        onPressed: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(label, style: const TextStyle(fontSize: 14))),
            const SizedBox(width: 8),
            const Icon(CupertinoIcons.chevron_down, size: 14),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    return HadgalyPage(
      title: 'Гүйлгээний түүх',
      child: ref
          .watch(accountsProvider)
          .when(
            loading: () => const LoadingContent(),
            error: (_, _) => const PageContent(
              children: [InlineError('Түүхийг нээж чадсангүй.')],
            ),
            data: (snapshot) => categories.when(
              loading: () => const LoadingContent(),
              error: (_, _) => const PageContent(
                children: [InlineError('Ангиллыг нээж чадсангүй.')],
              ),
              data: (catalog) {
                final names = {for (final c in catalog) c.id: c};
                final items = filterHistory(
                  [
                    for (final e in snapshot.entries)
                      HistoryItem(
                        id: e.id,
                        accountId: e.accountId,
                        kind: e.kind == 'income'
                            ? EventKind.income
                            : EventKind.expense,
                        amount: e.amount,
                        day: e.entryDate,
                        effectiveAt: e.effectiveAt,
                        note: e.note,
                        categoryId: e.categoryId,
                      ),
                    for (final a in snapshot.accounts)
                      for (final anchor in a.adjustments)
                        HistoryItem(
                          id: anchor.record.id,
                          accountId: a.account.id,
                          kind: EventKind.adjustment,
                          amount: anchor.record.target,
                          day: dateKey(
                            DateTime.fromMicrosecondsSinceEpoch(
                              anchor.record.effectiveAt,
                            ).toLocal(),
                          ),
                          effectiveAt: anchor.record.effectiveAt,
                        ),
                  ],
                  accountId: account,
                  kind: kind,
                  period: period,
                  query: search.text,
                  now: DateTime.now(),
                );
                final groups = <String, List<HistoryItem>>{};
                for (final item in items) {
                  groups.putIfAbsent(item.day, () => []).add(item);
                }
                return ListView(
                  key: const Key('historyList'),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    Semantics(
                      label: 'Гүйлгээний тэмдэглэлээс хайх',
                      child: CupertinoSearchTextField(
                        key: const Key('historySearch'),
                        controller: search,
                        placeholder: 'Тэмдэглэлээс хайх',
                        placeholderStyle: const TextStyle(
                          fontFamily: fontFamily,
                          fontFamilyFallback: fontFallback,
                          fontSize: 16,
                          color: secondaryInk,
                        ),
                        itemColor: secondaryInk,
                        style: const TextStyle(
                          fontFamily: fontFamily,
                          fontFamilyFallback: fontFallback,
                          fontSize: 16,
                          color: ink,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        filterButton(
                          'historyAccount',
                          account == null
                              ? 'Бүх данс'
                              : snapshot.byId(account!).account.name,
                          () async {
                            FocusScope.of(context).unfocus();
                            final selected = await showActionSheet<int>(
                              context,
                              (sheetContext) => CupertinoActionSheet(
                                title: const Text(
                                  'Дансаар шүүх',
                                  style: captionStyle,
                                ),
                                actions: [
                                  CupertinoActionSheetAction(
                                    key: const Key('filterAccount-all'),
                                    onPressed: () =>
                                        Navigator.pop(sheetContext, 0),
                                    child: const Text('Бүх данс'),
                                  ),
                                  for (final a in snapshot.accounts)
                                    CupertinoActionSheetAction(
                                      key: Key('filterAccount-${a.account.id}'),
                                      onPressed: () => Navigator.pop(
                                        sheetContext,
                                        a.account.id,
                                      ),
                                      child: Text(a.account.name),
                                    ),
                                ],
                                cancelButton: CupertinoActionSheetAction(
                                  onPressed: () => Navigator.pop(sheetContext),
                                  child: const Text('Болих'),
                                ),
                              ),
                            );
                            if (selected != null && mounted) {
                              setState(
                                () => account = selected == 0 ? null : selected,
                              );
                            }
                          },
                        ),
                        filterButton(
                          'historyPeriod',
                          periodLabels[period]!,
                          () async {
                            FocusScope.of(context).unfocus();
                            final selected =
                                await showActionSheet<HistoryPeriod>(
                                  context,
                                  (sheetContext) => CupertinoActionSheet(
                                    title: const Text(
                                      'Хугацаагаар шүүх',
                                      style: captionStyle,
                                    ),
                                    actions: [
                                      for (final p in HistoryPeriod.values)
                                        CupertinoActionSheetAction(
                                          key: Key('filterPeriod-${p.name}'),
                                          onPressed: () =>
                                              Navigator.pop(sheetContext, p),
                                          child: Text(periodLabels[p]!),
                                        ),
                                    ],
                                    cancelButton: CupertinoActionSheetAction(
                                      onPressed: () =>
                                          Navigator.pop(sheetContext),
                                      child: const Text('Болих'),
                                    ),
                                  ),
                                );
                            if (selected != null && mounted) {
                              setState(() => period = selected);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final value in [
                          null,
                          EventKind.income,
                          EventKind.expense,
                        ])
                          Semantics(
                            selected: kind == value,
                            child: CupertinoButton(
                              key: Key('historyKind-${value?.name ?? 'all'}'),
                              minimumSize: const Size(48, 48),
                              padding: const EdgeInsets.all(12),
                              color: kind == value ? accentSurface : null,
                              onPressed: () => setState(() => kind = value),
                              child: Text(
                                value == null
                                    ? 'Бүгд'
                                    : value == EventKind.income
                                    ? 'Орлого'
                                    : 'Зарлага',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (error != null) InlineError(error!),
                    if (items.isEmpty)
                      const Padding(
                        key: Key('historyEmpty'),
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          'Тохирох бүртгэл алга.',
                          textAlign: TextAlign.center,
                          style: captionStyle,
                        ),
                      ),
                    for (final group in groups.entries) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 24, bottom: 8),
                        child: Text(
                          group.key,
                          key: Key('historyDay-${group.key}'),
                          style: captionStyle,
                        ),
                      ),
                      InsetGroup(
                        children: [
                          for (final item in group.value)
                            CupertinoButton(
                              key: Key(
                                'history-${item.kind == EventKind.adjustment ? 'anchor' : 'entry'}-${item.id}',
                              ),
                              minimumSize: const Size(48, 56),
                              padding: const EdgeInsets.all(16),
                              onPressed: opening
                                  ? null
                                  : () => item.kind == EventKind.adjustment
                                        ? openPage<void>(
                                            context,
                                            AccountDetailScreen(
                                              id: item.accountId,
                                            ),
                                          )
                                        : openEntry(item.id),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        item.kind == EventKind.adjustment
                                            ? CupertinoIcons.equal_circle
                                            : item.kind == EventKind.income
                                            ? CupertinoIcons.plus_circle
                                            : CupertinoIcons.minus_circle,
                                        size: 20,
                                        color: item.kind == EventKind.adjustment
                                            ? secondaryInk
                                            : item.kind == EventKind.income
                                            ? incomeInk
                                            : errorInk,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          item.kind == EventKind.adjustment
                                              ? 'Үлдэгдэл тохируулсан'
                                              : names[item.categoryId]?.name ??
                                                    'Ангилал',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        CupertinoIcons.chevron_right,
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${item.kind == EventKind.adjustment
                                        ? ''
                                        : item.kind == EventKind.income
                                        ? '+'
                                        : '−'}${formatMnt(item.amount)}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: item.kind == EventKind.adjustment
                                          ? ink
                                          : item.kind == EventKind.income
                                          ? incomeInk
                                          : errorInk,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    snapshot.byId(item.accountId).account.name,
                                    style: captionStyle,
                                  ),
                                  if (item.kind == EventKind.adjustment)
                                    const Text(
                                      'Орлого, зарлагад орохгүй',
                                      style: captionStyle,
                                    ),
                                  if (names[item.categoryId]?.archived ?? false)
                                    const Text(
                                      'Архивласан ангилал',
                                      style: captionStyle,
                                    ),
                                  if (item.note.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        item.note,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: secondaryInk,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
    );
  }
}
