import 'package:flutter/material.dart';

class AppTheme {
  static const Color bgDark = Color(0xFF1a1a2e);
  static const Color bgCard = Color(0xFF16213e);
  static const Color bgCardLight = Color(0xFF1f3050);
  static const Color textPrimary = Color(0xFFe8e8e8);
  static const Color textSecondary = Color(0xFF8892b0);

  static const LinearGradient aheadGradient = LinearGradient(
    colors: [Color(0xFF00b4d8), Color(0xFF48cae4)],
  );
  static const LinearGradient behindGradient = LinearGradient(
    colors: [Color(0xFFf77f00), Color(0xFFd62828)],
  );

  static const List<Color> goalColors = [
    Color(0xFF00b4d8),
    Color(0xFF8338ec),
    Color(0xFFff006e),
    Color(0xFFfb5607),
    Color(0xFFffbe0b),
    Color(0xFF06d6a0),
    Color(0xFF118ab2),
    Color(0xFFef476f),
  ];

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgDark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00b4d8),
          secondary: Color(0xFF48cae4),
          surface: bgCard,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bgDark,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF00b4d8),
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          color: bgCard,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: bgCardLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          labelStyle: const TextStyle(color: textSecondary),
        ),
      );
}
