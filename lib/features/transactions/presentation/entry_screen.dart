import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/hadgaly_ui.dart';
import '../../accounts/application/accounts_providers.dart';
import '../../accounts/domain/ledger.dart';
import '../application/transactions_providers.dart';
import '../domain/entry_rules.dart';
import 'category_screens.dart';

class EntryScreen extends ConsumerStatefulWidget {
  const EntryScreen({super.key, required this.kind});
  final EventKind kind;
  @override
  ConsumerState<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends ConsumerState<EntryScreen> {
  final form = GlobalKey<FormState>();
  final amount = TextEditingController(), note = TextEditingController();
  final requestKey = newRequestKey();
  int? accountId, categoryId;
  DateTime date = calendarDay(DateTime.now());
  bool busy = false;
  String? error;
  @override
  void dispose() {
    amount.dispose();
    note.dispose();
    super.dispose();
  }

  Future<void> save(int chosenAccount) async {
    if (busy || !form.currentState!.validate()) return;
    if (categoryId == null) {
      setState(() => error = 'Ангиллаа сонгоорой.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await ref
          .read(transactionsRepositoryProvider)
          .post(
            kind: widget.kind,
            amount: amount.text,
            accountId: chosenAccount,
            categoryId: categoryId!,
            date: date,
            note: note.text,
            requestKey: requestKey,
          );
      if (mounted) Navigator.pop(context);
    } on FormatException catch (e) {
      if (mounted) setState(() => error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Хадгалж чадсангүй. Дахин оролдоорой.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> pickDate() async {
    FocusScope.of(context).unfocus();
    final latest = calendarDay(DateTime.now());
    if (latest.isBefore(DateTime(1970))) {
      setState(() => error = 'Төхөөрөмжийн огноогоо шалгаарай.');
      return;
    }
    // A device clock change must not make the native picker's initial date
    // exceed its maximum. Saving still validates against the current date.
    final initial = date.isAfter(latest) ? latest : date;
    var pending = initial;
    final selected = await showActionSheet<DateTime>(
      context,
      (sheetContext) => Container(
        color: paper,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: CupertinoButton(
                  key: const Key('dateDone'),
                  onPressed: () => Navigator.pop(sheetContext, pending),
                  child: const Text('Болсон'),
                ),
              ),
              SizedBox(
                height: 216,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initial,
                  minimumDate: DateTime(1970),
                  maximumDate: latest,
                  dateOrder: DatePickerDateOrder.ymd,
                  onDateTimeChanged: (value) => pending = calendarDay(value),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected != null && mounted) setState(() => date = selected);
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);
    final categories = ref.watch(categoriesProvider);
    return PopScope(
      canPop: !busy,
      child: HadgalyPage(
        title: widget.kind == EventKind.income
            ? 'Орлого нэмэх'
            : 'Зарлага нэмэх',
        backEnabled: !busy,
        child: accounts.when(
          loading: () => const LoadingContent(),
          error: (_, _) => const PageContent(
            children: [InlineError('Дансны мэдээллийг нээж чадсангүй.')],
          ),
          data: (snapshot) {
            final chosen = snapshot.byId(accountId ?? snapshot.defaultId!);
            return Form(
              key: form,
              child: PageContent(
                children: [
                  HadgalyField(
                    fieldKey: const Key('entryAmount'),
                    controller: amount,
                    label: 'Мөнгөн дүн',
                    money: true,
                    allowNegative: false,
                    autofocus: true,
                    enabled: !busy,
                    validator: (value) {
                      try {
                        parseEntryAmount(value ?? '');
                        return null;
                      } on FormatException catch (e) {
                        return e.message;
                      }
                    },
                    onSubmitted: (_) => FocusScope.of(context).unfocus(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Ангилал', style: sectionStyle),
                      ),
                      CupertinoButton(
                        key: const Key('manageCategories'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),
                        minimumSize: const Size(48, 48),
                        onPressed: busy
                            ? null
                            : () {
                                FocusScope.of(context).unfocus();
                                openPage<void>(
                                  context,
                                  CategoriesScreen(kind: widget.kind),
                                );
                              },
                        child: const Text(
                          'Удирдах',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  categories.when(
                    loading: () => const LoadingContent(),
                    error: (_, _) =>
                        const InlineError('Ангиллыг нээж чадсангүй.'),
                    data: (all) {
                      final active = all
                          .where(
                            (c) => c.kind == widget.kind.name && !c.archived,
                          )
                          .toList();
                      return active.isEmpty
                          ? const Text(
                              'Идэвхтэй ангилал алга. “Удирдах”-аас нэмээрэй.',
                              style: captionStyle,
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final c in active)
                                  Semantics(
                                    label: c.name,
                                    selected: categoryId == c.id,
                                    button: true,
                                    enabled: !busy,
                                    onTap: busy
                                        ? null
                                        : () => setState(() {
                                            categoryId = c.id;
                                            error = null;
                                          }),
                                    child: ExcludeSemantics(
                                      child: CupertinoButton(
                                        key: Key('category-${c.id}'),
                                        minimumSize: const Size(48, 48),
                                        color: categoryId == c.id
                                            ? accentSurface
                                            : CupertinoColors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                        onPressed: busy
                                            ? null
                                            : () => setState(() {
                                                categoryId = c.id;
                                                error = null;
                                              }),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              categoryIcon(c.icon),
                                              size: 20,
                                              color: ink,
                                            ),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                c.name,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: ink,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text('Данс', style: sectionStyle),
                  CupertinoButton(
                    key: const Key('entryAccount'),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(48, 56),
                    onPressed: busy
                        ? null
                        : () async {
                            FocusScope.of(context).unfocus();
                            final id = await showActionSheet<int>(
                              context,
                              (sheetContext) => CupertinoActionSheet(
                                title: const Text('Данс сонгох'),
                                actions: [
                                  for (final a in snapshot.accounts)
                                    CupertinoActionSheetAction(
                                      key: Key('entryAccount-${a.account.id}'),
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
                            if (id != null && mounted) {
                              setState(() => accountId = id);
                            }
                          },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            chosen.account.name,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const Icon(CupertinoIcons.chevron_down, size: 16),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    key: const Key('entryDate'),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(48, 48),
                    onPressed: busy ? null : pickDate,
                    child: Row(
                      children: [
                        const Text(
                          'Огноо',
                          style: TextStyle(fontSize: 15, color: secondaryInk),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            dateKey(date),
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(CupertinoIcons.calendar, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Тэмдэглэл · заавал биш', style: captionStyle),
                  const SizedBox(height: 8),
                  Semantics(
                    label: 'Тэмдэглэл · заавал биш',
                    child: CupertinoTextField(
                      key: const Key('entryNote'),
                      controller: note,
                      enabled: !busy,
                      maxLines: 3,
                      padding: const EdgeInsets.all(16),
                      textInputAction: TextInputAction.done,
                      style: const TextStyle(
                        fontFamily: fontFamily,
                        fontFamilyFallback: fontFallback,
                        fontSize: 16,
                        color: ink,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: fieldBorder),
                      ),
                    ),
                  ),
                  if (error != null) InlineError(error!),
                  const SizedBox(height: 24),
                  HadgalyButton(
                    key: const Key('entrySave'),
                    label: busy ? 'Хадгалж байна…' : 'Хадгалах',
                    onPressed: busy ? null : () => save(chosen.account.id),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
