import 'package:flutter/cupertino.dart';

// Neutral surfaces dominate; midnight anchors typography/actions; teal accents
// selection. 60/30/10 is visual direction, not a dark theme or pixel quota.
const paper = Color(0xFFF5F6F8);
const midnight = Color(0xFF14243E);
const teal = Color(0xFF39B5AA);
const expense = Color(0xFFD66B72);
const ink = midnight;
const primary = midnight;
const secondaryInk = Color(0xFF4D5C72);
const accentSurface = Color(0xFFE1F3F1);
const line = Color(0xFFDCE1E8);
const fieldBorder = Color(0xFF8B97A7);
const disabledSurface = Color(0xFFE3E7ED);
// Brand accent swatches are not dark enough for small text on neutral surfaces.
const incomeInk = Color(0xFF13756E);
const errorInk = Color(0xFFA13948);
const fontFamily = 'Google Sans Flex';
const fontFallback = ['Noto Sans'];

const headingStyle = TextStyle(
  fontFamily: fontFamily,
  fontFamilyFallback: fontFallback,
  fontSize: 28,
  height: 1.3,
  fontWeight: FontWeight.w700,
  color: ink,
);
const sectionStyle = TextStyle(
  fontFamily: fontFamily,
  fontFamilyFallback: fontFallback,
  fontSize: 17,
  height: 1.4,
  fontWeight: FontWeight.w700,
  color: ink,
);
const captionStyle = TextStyle(
  fontFamily: fontFamily,
  fontFamilyFallback: fontFallback,
  fontSize: 13,
  height: 1.5,
  color: secondaryInk,
);
