import 'package:flutter/cupertino.dart';

import '../../../core/presentation/hadgaly_ui.dart';
import '../../home/presentation/home_screen.dart';

const moduleLabels = ['Хийх зүйл', 'Авах зүйл', 'Санаа', 'Санхүү'];
const moduleIcons = [
  CupertinoIcons.checkmark_square,
  CupertinoIcons.cart,
  CupertinoIcons.lightbulb,
  CupertinoIcons.chart_pie,
];

class ProductShell extends StatefulWidget {
  const ProductShell({super.key, required this.name});
  final String name;
  @override
  State<ProductShell> createState() => _ProductShellState();
}

class _ProductShellState extends State<ProductShell> {
  int selected = 3;
  final financeNavigator = GlobalKey<NavigatorState>();

  void select(int index) {
    if (index == selected) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => selected = index);
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: selected == 3,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && selected != 3) select(3);
    },
    child: ColoredBox(
      color: paper,
      child: Column(
        children: [
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              child: IndexedStack(
                index: selected,
                children: [
                  for (var i = 0; i < 3; i++) _ComingSoon(index: i),
                  NavigatorPopHandler<Object?>(
                    enabled: selected == 3,
                    onPopWithResult: selected == 3
                        ? (_) {
                            if (financeNavigator.currentState!.canPop()) {
                              financeNavigator.currentState!.pop();
                            }
                          }
                        : null,
                    child: Navigator(
                      key: financeNavigator,
                      onGenerateRoute: (_) => CupertinoPageRoute<void>(
                        builder: (_) => HomeScreen(name: widget.name),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Hide while the keyboard is open: retain form space and avoid covering
          // keyboard controls. The shell and selected tab are not reset.
          if (MediaQuery.viewInsetsOf(context).bottom == 0)
            _ModuleBar(selected: selected, onSelect: select),
        ],
      ),
    ),
  );
}

class _ModuleBar extends StatelessWidget {
  const _ModuleBar({required this.selected, required this.onSelect});
  final int selected;
  final ValueChanged<int> onSelect;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: paper,
      border: Border(top: BorderSide(color: line, width: 0.7)),
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.textScalerOf(context).scale(12) > 18 ? 0 : 4,
          vertical: 6,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < moduleLabels.length; i++)
              Expanded(
                child: Semantics(
                  label: moduleLabels[i],
                  selected: selected == i,
                  button: true,
                  onTap: () => onSelect(i),
                  child: ExcludeSemantics(
                    child: CupertinoButton(
                      key: Key('module-$i'),
                      minimumSize: const Size(48, 64),
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            MediaQuery.textScalerOf(context).scale(12) > 18
                            ? 0
                            : 3,
                        vertical: 6,
                      ),
                      onPressed: () => onSelect(i),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: selected == i ? midnight : null,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              moduleIcons[i],
                              size: 22,
                              color: selected == i ? teal : secondaryInk,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            moduleLabels[i],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.25,
                              color: selected == i ? ink : secondaryInk,
                              fontWeight: selected == i
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.index});
  final int index;
  @override
  Widget build(BuildContext context) => HadgalyPage(
    title: moduleLabels[index],
    child: LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: (c.maxHeight - 48).clamp(0, double.infinity),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(moduleIcons[index], color: primary, size: 40),
              const SizedBox(height: 20),
              const Text(
                'Тун удахгүй',
                style: headingStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Энэ хэсгийг бэлдэж байна.\nОдоогоор санхүүгээ цэгцлэх боломжтой.',
                style: TextStyle(color: secondaryInk),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
