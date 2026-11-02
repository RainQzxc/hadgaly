import 'package:flutter/material.dart';

import 'features/onboarding/presentation/onboarding_screen.dart';

const ink = Color(0xFF243E35);
const green = Color(0xFF356B50);
const mint = Color(0xFFE0EEDF);
const paper = Color(0xFFFAF9F4);

class HadgalyApp extends StatelessWidget {
  const HadgalyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Хадгалъя',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'Comfortaa',
      scaffoldBackgroundColor: paper,
      colorScheme: ColorScheme.fromSeed(
        seedColor: green,
        surface: paper,
        primary: green,
        onSurface: ink,
        error: const Color(0xFF9C342E),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 30,
          height: 1.35,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        bodyLarge: TextStyle(fontSize: 16, height: 1.6, color: ink),
        bodyMedium: TextStyle(fontSize: 14, height: 1.6, color: ink),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFFCAD5CC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFFCAD5CC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: green, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(58),
          padding: const EdgeInsets.all(18),
          textStyle: const TextStyle(
            fontFamily: 'Comfortaa',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    ),
    home: const OnboardingScreen(),
  );
}
