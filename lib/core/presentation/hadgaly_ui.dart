import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'design_tokens.dart';
import 'brand_wordmark.dart';
export 'design_tokens.dart';

bool reduceMotion(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context) ||
    MediaQuery.accessibleNavigationOf(context);

Future<T?> openPage<T>(BuildContext context, Widget page) =>
    Navigator.of(context).push<T>(
      reduceMotion(context)
          ? PageRouteBuilder<T>(
              pageBuilder: (_, _, _) => page,
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            )
          : CupertinoPageRoute<T>(builder: (_) => page),
    );

class _MotionAwarePopup<T> extends CupertinoModalPopupRoute<T> {
  _MotionAwarePopup({required super.builder, required this.reduced})
    : super(semanticsDismissible: true);
  final bool reduced;
  @override
  Duration get transitionDuration =>
      reduced ? Duration.zero : super.transitionDuration;
  @override
  Duration get reverseTransitionDuration =>
      reduced ? Duration.zero : super.reverseTransitionDuration;
}

Future<T?> showActionSheet<T>(BuildContext context, WidgetBuilder builder) =>
    Navigator.of(context).push<T>(
      _MotionAwarePopup<T>(builder: builder, reduced: reduceMotion(context)),
    );

/// Cupertino structure with an Android toolbar sized for 48dp targets and scaled text.
class HadgalyPage extends StatelessWidget {
  const HadgalyPage({
    super.key,
    required this.title,
    required this.child,
    this.onBack,
    this.backEnabled = true,
    this.trailing,
  });
  final String title;
  final Widget child;
  final VoidCallback? onBack;
  final bool backEnabled;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    final canBack = onBack != null || Navigator.canPop(context);
    final back = canBack
        ? () {
            if (onBack != null) {
              onBack!();
            } else {
              Navigator.maybePop(context);
            }
          }
        : null;
    final leading = canBack
        ? Semantics(
            label: 'Буцах',
            button: true,
            enabled: backEnabled,
            onTap: backEnabled ? back : null,
            child: ExcludeSemantics(
              child: CupertinoButton(
                key: const Key('back'),
                minimumSize: const Size(48, 48),
                padding: EdgeInsets.zero,
                onPressed: backEnabled ? back : null,
                child: const Icon(CupertinoIcons.back, size: 24),
              ),
            ),
          )
        : const SizedBox(width: 48);
    final ObstructingPreferredSizeWidget bar;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      bar = CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        leading: leading,
        middle: MediaQuery(
          data: MediaQuery.of(context),
          child: title == 'хадгалъя'
              ? const BrandWordmark()
              : Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        trailing: trailing == null
            ? null
            : MediaQuery(data: MediaQuery.of(context), child: trailing!),
        backgroundColor: paper,
        border: const Border(bottom: BorderSide(color: line, width: 0.5)),
        transitionBetweenRoutes: false,
      );
    } else {
      bar = _AccessibleNavigationBar(
        textScaler: MediaQuery.textScalerOf(context),
        title: title,
        leading: leading,
        trailing: trailing,
      );
    }
    return CupertinoPageScaffold(
      backgroundColor: paper,
      navigationBar: bar,
      child: SafeArea(top: false, child: child),
    );
  }
}

class _AccessibleNavigationBar extends StatelessWidget
    implements ObstructingPreferredSizeWidget {
  const _AccessibleNavigationBar({
    required this.title,
    required this.textScaler,
    required this.leading,
    this.trailing,
  });
  final String title;
  final Widget leading;
  final TextScaler textScaler;
  final Widget? trailing;
  @override
  Size get preferredSize => const Size.fromHeight(60);
  @override
  bool shouldFullyObstruct(BuildContext context) => true;
  @override
  Widget build(BuildContext context) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: textScaler),
    child: DecoratedBox(
      decoration: const BoxDecoration(
        color: paper,
        border: Border(bottom: BorderSide(color: line, width: 0.5)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                leading,
                Expanded(
                  child: Semantics(
                    header: true,
                    child: title == 'хадгалъя'
                        ? const BrandWordmark()
                        : Text(
                            title,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                              color: ink,
                            ),
                          ),
                  ),
                ),
                SizedBox(width: trailing == null ? 48 : null, child: trailing),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class PageContent extends StatelessWidget {
  const PageContent({super.key, required this.children, this.scrollKey});
  final List<Widget> children;
  final Key? scrollKey;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    key: scrollKey,
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    ),
  );
}

class HadgalyButton extends StatelessWidget {
  const HadgalyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = true,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool filled;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => CupertinoButton(
    color: filled ? primary : null,
    foregroundColor: filled ? CupertinoColors.white : primary,
    disabledColor: disabledSurface,
    minimumSize: const Size(48, 56),
    borderRadius: BorderRadius.circular(18),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    onPressed: onPressed,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 10)],
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

class InsetGroup extends StatelessWidget {
  const InsetGroup({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: CupertinoColors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: line, width: 0.7),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: SizedBox(height: 0.7, child: ColoredBox(color: line)),
            ),
          children[i],
        ],
      ],
    ),
  );
}

class HadgalyField extends StatefulWidget {
  const HadgalyField({
    super.key,
    required this.fieldKey,
    required this.controller,
    required this.label,
    this.placeholder,
    this.money = false,
    this.allowNegative = true,
    this.autofocus = false,
    this.enabled = true,
    this.action = TextInputAction.done,
    this.validator,
    this.onChanged,
    this.onSubmitted,
  });
  final Key fieldKey;
  final TextEditingController controller;
  final String label;
  final String? placeholder;
  final bool money, enabled, allowNegative, autofocus;
  final TextInputAction action;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged, onSubmitted;
  @override
  State<HadgalyField> createState() => _HadgalyFieldState();
}

class _HadgalyFieldState extends State<HadgalyField> {
  final focus = FocusNode();
  @override
  void initState() {
    super.initState();
    focus.addListener(changed);
  }

  void changed() {
    setState(() {});
  }

  @override
  void dispose() {
    focus.removeListener(changed);
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FormField<String>(
    initialValue: widget.controller.text,
    validator: widget.validator,
    builder: (field) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: ink,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: widget.label,
          child: CupertinoTextField(
            key: widget.fieldKey,
            controller: widget.controller,
            focusNode: focus,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: field.hasError
                    ? errorInk
                    : focus.hasFocus
                    ? primary
                    : fieldBorder,
                width: focus.hasFocus ? 1.5 : 1,
              ),
            ),
            style: const TextStyle(
              fontFamily: fontFamily,
              fontFamilyFallback: fontFallback,
              fontSize: 17,
              height: 1.4,
              color: ink,
            ),
            placeholder: widget.placeholder,
            placeholderStyle: const TextStyle(
              fontFamily: fontFamily,
              fontFamilyFallback: fontFallback,
              fontSize: 17,
              color: secondaryInk,
            ),
            suffix: widget.money
                ? const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Text('₮', style: TextStyle(color: secondaryInk)),
                  )
                : null,
            keyboardType: widget.money
                ? TextInputType.numberWithOptions(signed: widget.allowNegative)
                : TextInputType.text,
            textCapitalization: widget.money
                ? TextCapitalization.none
                : TextCapitalization.words,
            textInputAction: widget.action,
            autocorrect: !widget.money,
            enableSuggestions: !widget.money,
            onChanged: (value) {
              field.didChange(value);
              widget.onChanged?.call(value);
            },
            onSubmitted: widget.onSubmitted,
          ),
        ),
        if (field.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Semantics(
              liveRegion: true,
              child: Text(
                field.errorText!,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: errorInk,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class InlineError extends StatelessWidget {
  const InlineError(this.message, {super.key});
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Semantics(
      liveRegion: true,
      child: Text(
        message,
        style: const TextStyle(fontSize: 14, height: 1.5, color: errorInk),
      ),
    ),
  );
}

class LoadingContent extends StatelessWidget {
  const LoadingContent({super.key});
  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      label: 'Мэдээлэл нээж байна',
      child: const CupertinoActivityIndicator(),
    ),
  );
}
