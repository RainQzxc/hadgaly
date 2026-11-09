import 'dart:math';

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

SemanticsHandle? _semantics;

void enablePlatformSemantics() {
  _semantics ??= SemanticsBinding.instance.ensureSemantics();
}

Widget platformViewport(BuildContext context, Widget child) {
  final media = MediaQuery.of(context);
  final root = web.document.documentElement!;
  final rootStyle = web.window.getComputedStyle(root);
  final size = _pixels(rootStyle.fontSize, fallback: 16);
  final scale = (size / 16).clamp(1.0, 2.5);
  final probe = web.document.getElementById('safe-area-probe');
  final safe = probe == null ? null : web.window.getComputedStyle(probe);
  final padding = EdgeInsets.fromLTRB(
    max(media.padding.left, _pixels(safe?.paddingLeft)),
    max(media.padding.top, _pixels(safe?.paddingTop)),
    max(media.padding.right, _pixels(safe?.paddingRight)),
    media.viewInsets.bottom > 0
        ? media.padding.bottom
        : max(media.padding.bottom, _pixels(safe?.paddingBottom)),
  );

  return MediaQuery(
    data: media.copyWith(
      padding: padding,
      textScaler: media.textScaler.scale(16) >= 16 * scale
          ? media.textScaler
          : TextScaler.linear(scale),
      disableAnimations:
          media.disableAnimations ||
          web.window.matchMedia('(prefers-reduced-motion: reduce)').matches,
    ),
    child: child,
  );
}

double _pixels(String? value, {double fallback = 0}) =>
    double.tryParse(value?.replaceAll('px', '') ?? '') ?? fallback;
