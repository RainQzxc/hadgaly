import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/hadgaly_ui.dart';
import '../../accounts/application/accounts_providers.dart';
import '../../accounts/domain/ledger.dart';
import '../../../core/domain/money.dart';
import '../../onboarding/data/app_database.dart';
import '../application/transactions_providers.dart';
import '../domain/entry_rules.dart';

IconData categoryIcon(String value) => switch (value) {
  'briefcase' => CupertinoIcons.briefcase,
  'plus' => CupertinoIcons.plus_circle,
  'gift' => CupertinoIcons.gift,
  'food' => CupertinoIcons.flame,
  'cart' => CupertinoIcons.cart,
  'car' => CupertinoIcons.car,
  'home' => CupertinoIcons.house,
  'heart' => CupertinoIcons.heart,
  'book' => CupertinoIcons.book,
  'phone' => CupertinoIcons.phone,
  'card' => CupertinoIcons.creditcard,
  _ => CupertinoIcons.ellipsis_circle,
};
String iconLabel(String value) => switch (value) {
  'briefcase' => 'Ажил',
  'plus' => 'Нэмэлт',
  'gift' => 'Бэлэг',
  'food' => 'Хоол',
  'cart' => 'Хүнс',
  'car' => 'Унаа',
  'home' => 'Гэр',
  'heart' => 'Эрүүл мэнд',
  'book' => 'Ном',
  'phone' => 'Утас',
  'card' => 'Карт',
  _ => 'Бусад',
};

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key, required this.kind});
  final EventKind kind;
  @override
  Widget build(BuildContext context, WidgetRef ref) => HadgalyPage(
    title: kind == EventKind.income ? 'Орлогын ангилал' : 'Зарлагын ангилал',
    child: ref
        .watch(categoriesProvider)
        .when(
          loading: () => const LoadingContent(),
          error: (_, _) => const PageContent(
            children: [InlineError('Ангиллыг нээж чадсангүй.')],
          ),
          data: (categories) => PageContent(
            children: [
              HadgalyButton(
                key: const Key('addCategory'),
                label: 'Ангилал нэмэх',
                icon: CupertinoIcons.add,
                onPressed: () =>
                    openPage<void>(context, CategoryFormScreen(kind: kind)),
              ),
              const SizedBox(height: 24),
              InsetGroup(
                children: [
                  for (final c in categories.where(
                    (c) => c.kind == kind.name && !c.archived,
                  ))
                    CupertinoButton(
                      key: Key('manageCategory-${c.id}'),
                      minimumSize: const Size(48, 56),
                      padding: const EdgeInsets.all(16),
                      onPressed: () => openPage<void>(
                        context,
                        CategoryFormScreen(kind: kind, category: c),
                      ),
                      child: Row(
                        children: [
                          Icon(categoryIcon(c.icon), size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              c.name,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const Icon(CupertinoIcons.chevron_right, size: 16),
                        ],
                      ),
                    ),
                ],
              ),
              if (categories.any((c) => c.kind == kind.name && c.archived)) ...[
                const SizedBox(height: 24),
                const Text('Архивласан', style: sectionStyle),
                const SizedBox(height: 8),
                for (final c in categories.where(
                  (c) => c.kind == kind.name && c.archived,
                ))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(c.name, style: captionStyle),
                  ),
              ],
            ],
          ),
        ),
  );
}

class CategoryFormScreen extends ConsumerStatefulWidget {
  const CategoryFormScreen({super.key, required this.kind, this.category});
  final EventKind kind;
  final Category? category;
  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormState();
}

class _CategoryFormState extends ConsumerState<CategoryFormScreen> {
  final form = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.category?.name ?? '');
  late String icon = widget.category?.icon ?? 'other';
  final keyValue = newRequestKey();
  bool busy = false;
  String? error;
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  Future<void> save({bool archive = false}) async {
    if (busy || (!archive && !form.currentState!.validate())) return;
    FocusScope.of(context).unfocus();
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final repo = ref.read(transactionsRepositoryProvider);
      if (archive) {
        await repo.archiveCategory(widget.category!.id);
      } else {
        await repo.saveCategory(
          id: widget.category?.id,
          kind: widget.kind,
          name: name.text,
          icon: icon,
          requestKey: keyValue,
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

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: HadgalyPage(
      title: widget.category == null ? 'Шинэ ангилал' : 'Ангилал засах',
      backEnabled: !busy,
      child: Form(
        key: form,
        child: PageContent(
          children: [
            HadgalyField(
              fieldKey: const Key('categoryName'),
              controller: name,
              label: 'Ангиллын нэр',
              enabled: !busy,
              validator: (value) {
                try {
                  validateName(value ?? '', label: 'Ангиллын нэр');
                  return null;
                } on FormatException catch (e) {
                  return e.message;
                }
              },
            ),
            const SizedBox(height: 24),
            const Text('Дүрс', style: sectionStyle),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final value in categoryIcons)
                  Semantics(
                    label: iconLabel(value),
                    selected: icon == value,
                    button: true,
                    enabled: !busy,
                    onTap: busy ? null : () => setState(() => icon = value),
                    child: ExcludeSemantics(
                      child: CupertinoButton(
                        key: Key('icon-$value'),
                        minimumSize: const Size(56, 56),
                        padding: const EdgeInsets.all(16),
                        color: icon == value
                            ? accentSurface
                            : CupertinoColors.white,
                        onPressed: busy
                            ? null
                            : () => setState(() => icon = value),
                        child: Icon(categoryIcon(value), color: ink, size: 24),
                      ),
                    ),
                  ),
              ],
            ),
            if (error != null) InlineError(error!),
            const SizedBox(height: 24),
            HadgalyButton(
              key: const Key('categorySave'),
              label: busy ? 'Хадгалж байна…' : 'Хадгалах',
              onPressed: busy ? null : () => save(),
            ),
            if (widget.category != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Архивлахад өмнөх бүртгэлүүд хадгалагдана.',
                style: captionStyle,
              ),
              HadgalyButton(
                key: const Key('archiveCategory'),
                label: 'Архивлах',
                filled: false,
                onPressed: busy ? null : () => save(archive: true),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
