import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/hadgaly_ui.dart';
import '../../accounts/application/accounts_providers.dart';
import '../../accounts/domain/ledger.dart';
import '../application/transactions_providers.dart';
import '../../onboarding/data/app_database.dart';
import '../domain/entry_rules.dart';
import 'category_screens.dart';

class EntryScreen extends ConsumerStatefulWidget {
  const EntryScreen({
    super.key,
    required this.kind,
    this.entry,
    this.revision = 0,
  });
  final CashEntry? entry;
  final int revision;
  final EventKind kind;
  @override
  ConsumerState<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends ConsumerState<EntryScreen> {
  final form = GlobalKey<FormState>();
  late final amount = TextEditingController(
    text: widget.entry?.amount.toString() ?? '',
  );
  late final note = TextEditingController(text: widget.entry?.note ?? '');
  late EventKind kind = widget.kind;
  final requestKey = newRequestKey();
  late int? accountId = widget.entry?.accountId,
      categoryId = widget.entry?.categoryId;
  late DateTime date = widget.entry == null
      ? calendarDay(DateTime.now())
      : DateTime.parse(widget.entry!.entryDate);
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
      final repository = ref.read(transactionsRepositoryProvider);
      if (widget.entry == null) {
        await repository.post(
          kind: kind,
          amount: amount.text,
          accountId: chosenAccount,
          categoryId: categoryId!,
          date: date,
          note: note.text,
          requestKey: requestKey,
        );
      } else {
        await repository.edit(
          id: widget.entry!.id,
          expectedRevision: widget.revision,
          kind: kind,
          amount: amount.text,
          accountId: chosenAccount,
          categoryId: categoryId!,
          date: date,
          note: note.text,
          requestKey: requestKey,
        );
      }
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

  Future<void> remove() async {
    if (busy) return;
    FocusScope.of(context).unfocus();
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final confirm = await showActionSheet<bool>(
        context,
        (sheetContext) => CupertinoActionSheet(
          title: const Text(
            'Гүйлгээг устгах уу?',
            style: TextStyle(
              color: ink,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          message: Text(
            '${widget.entry!.kind == 'income' ? 'Орлого' : 'Зарлага'} ${widget.entry!.amount} ₮ · ${widget.entry!.entryDate}\nДансны үлдэгдэл дахин бодогдоно.',
            style: captionStyle,
          ),
          actions: [
            CupertinoActionSheetAction(
              key: const Key('confirmDelete'),
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(sheetContext, true),
              child: const Text('Устгах', style: TextStyle(color: errorInk)),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            key: const Key('cancelDelete'),
            onPressed: () => Navigator.pop(sheetContext, false),
            child: const Text('Болих'),
          ),
        ),
      );
      if (confirm != true || !mounted) return;
      await ref
          .read(transactionsRepositoryProvider)
          .delete(
            id: widget.entry!.id,
            expectedRevision: widget.revision,
            requestKey: deleteKey,
          );
      if (mounted) Navigator.pop(context);
    } on FormatException catch (e) {
      if (mounted) setState(() => error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Устгаж чадсангүй. Дахин оролдоорой.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  final deleteKey = newRequestKey();

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
        title: widget.entry != null
            ? 'Гүйлгээ засах'
            : kind == EventKind.income
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
                  if (widget.entry != null) ...[
                    CupertinoSlidingSegmentedControl<EventKind>(
                      groupValue: kind,
                      children: const {
                        EventKind.expense: Padding(
                          key: Key('entryKind-expense'),
                          padding: EdgeInsets.all(12),
                          child: Text('Зарлага'),
                        ),
                        EventKind.income: Padding(
                          key: Key('entryKind-income'),
                          padding: EdgeInsets.all(12),
                          child: Text('Орлого'),
                        ),
                      },
                      onValueChanged: (value) {
                        if (!busy && value != null && value != kind) {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            kind = value;
                            categoryId = null;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
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
                                  CategoriesScreen(kind: kind),
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
                            (c) =>
                                c.kind == kind.name &&
                                (!c.archived ||
                                    (widget.entry?.categoryId == c.id &&
                                        widget.entry?.kind == kind.name)),
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
                                                '${c.name}${c.archived ? ' · архив' : ''}',
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
                  if (widget.entry != null)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text(
                        'Огноог өөрчлөхгүй бол гүйлгээний анхны дараалал хадгалагдана.',
                        style: captionStyle,
                      ),
                    ),
                  if (error != null) InlineError(error!),
                  const SizedBox(height: 24),
                  HadgalyButton(
                    key: const Key('entrySave'),
                    label: busy ? 'Хадгалж байна…' : 'Хадгалах',
                    onPressed: busy ? null : () => save(chosen.account.id),
                  ),
                  if (widget.entry != null) ...[
                    const SizedBox(height: 8),
                    CupertinoButton(
                      key: const Key('deleteEntry'),
                      minimumSize: const Size(48, 48),
                      onPressed: busy ? null : remove,
                      child: const Text(
                        'Гүйлгээ устгах',
                        style: TextStyle(color: errorInk),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
