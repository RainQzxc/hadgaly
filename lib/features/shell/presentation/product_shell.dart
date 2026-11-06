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

  bool _menuOpen = false;

  Future<void> openMenu() async {
    if (_menuOpen) return;
    _menuOpen = true;
    FocusManager.instance.primaryFocus?.unfocus();
    try {
      final module = await showGeneralDialog<int>(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Цэсийг гаднаас хаах',
        barrierColor: const Color(0x6614243E),
        transitionDuration: reduceMotion(context)
            ? Duration.zero
            : const Duration(milliseconds: 220),
        pageBuilder: (_, _, _) => _ModuleDrawer(selected: selected),
        transitionBuilder: (_, animation, _, child) => SlideTransition(
          position: animation.drive(
            Tween(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic)),
          ),
          child: child,
        ),
      );
      if (mounted && module != null) select(module);
    } finally {
      _menuOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: selected == 3,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && selected != 3) select(3);
    },
    child: PageMenu(
      onOpen: openMenu,
      child: ColoredBox(
        color: paper,
        child: IndexedStack(
          index: selected,
          children: [
            for (var i = 0; i < 3; i++) _ComingSoon(index: i),
            NavigatorPopHandler<Object?>(
              enabled: selected == 3,
              onPopWithResult: selected == 3
                  ? (_) {
                      final navigator = financeNavigator.currentState;
                      if (navigator != null && navigator.canPop()) {
                        navigator.pop();
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
  );
}

class _ModuleDrawer extends StatefulWidget {
  const _ModuleDrawer({required this.selected});
  final int selected;

  @override
  State<_ModuleDrawer> createState() => _ModuleDrawerState();
}

class _ModuleDrawerState extends State<_ModuleDrawer> {
  double _drag = 0;

  void close([int? module]) {
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      Navigator.of(context).pop(module);
    }
  }

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerRight,
    child: LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        width: (constraints.maxWidth - 48).clamp(0.0, 336.0),
        height: double.infinity,
        child: GestureDetector(
          excludeFromSemantics: true,
          onHorizontalDragStart: (_) => _drag = 0,
          onHorizontalDragUpdate: (event) => _drag += event.primaryDelta!,
          onHorizontalDragEnd: (event) {
            if (_drag > 56 || (_drag > 0 && event.primaryVelocity! > 500)) {
              close();
            }
          },
          child: ColoredBox(
            key: const Key('moduleDrawer'),
            color: paper,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 12, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Semantics(
                            container: true,
                            header: true,
                            child: const Text('Цэс', style: sectionStyle),
                          ),
                        ),
                        NavigationIconButton(
                          key: const Key('closeModuleMenu'),
                          label: 'Цэс хаах',
                          icon: CupertinoIcons.xmark,
                          onPressed: close,
                        ),
                      ],
                    ),
                  ),
                  const ColoredBox(color: line, child: SizedBox(height: 1)),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < moduleLabels.length; i++) ...[
                            if (i > 0) const SizedBox(height: 8),
                            _ModuleRow(
                              index: i,
                              active: widget.selected == i,
                              onPressed: () => close(i),
                            ),
                          ],
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
    ),
  );
}

class _ModuleRow extends StatelessWidget {
  const _ModuleRow({
    required this.index,
    required this.active,
    required this.onPressed,
  });
  final int index;
  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    label: moduleLabels[index],
    selected: active,
    button: true,
    onTap: onPressed,
    child: ExcludeSemantics(
      child: CupertinoButton(
        key: Key('module-$index'),
        minimumSize: const Size(48, 56),
        borderRadius: BorderRadius.circular(16),
        color: active ? teal : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onPressed: onPressed,
        child: Row(
          children: [
            Icon(moduleIcons[index], color: ink, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                moduleLabels[index],
                style: TextStyle(
                  color: ink,
                  fontSize: 16,
                  height: 1.25,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (active) ...[
              const SizedBox(width: 8),
              const Icon(CupertinoIcons.check_mark, color: ink, size: 16),
            ],
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
