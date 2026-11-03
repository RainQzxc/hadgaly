import 'package:flutter/cupertino.dart';

import 'core/presentation/hadgaly_ui.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';

export 'core/presentation/hadgaly_ui.dart'
    show ink, secondaryInk, primary, accentSurface, paper;

class HadgalyApp extends StatelessWidget {
  const HadgalyApp({super.key});
  @override
  Widget build(BuildContext context) => const CupertinoApp(
    title: 'Хадгалъя',
    debugShowCheckedModeBanner: false,
    theme: CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      primaryContrastingColor: CupertinoColors.white,
      scaffoldBackgroundColor: paper,
      barBackgroundColor: paper,
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFallback,
          fontSize: 16,
          height: 1.5,
          color: ink,
        ),
        actionTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFallback,
          fontSize: 16,
          height: 1.4,
          color: primary,
        ),
        navTitleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFallback,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFallback,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),
    ),
    home: OnboardingScreen(),
  );
}
