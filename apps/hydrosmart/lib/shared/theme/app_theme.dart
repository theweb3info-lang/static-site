import 'package:flutter/material.dart';

class AppColors {
  // Primary: Ocean Blue
  static const primary = Color(0xFF2196F3);
  static const primaryLight = Color(0xFF64B5F6);
  static const primaryDark = Color(0xFF1565C0);

  // Accent: Coral
  static const accent = Color(0xFFFF7043);

  // Functional
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFC107);
  static const error = Color(0xFFEF5350);
  static const info = Color(0xFF29B6F6);

  // Light neutrals
  static const lightBg = Color(0xFFF5F7FA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE0E0E0);
  static const lightTextSecondary = Color(0xFF757575);
  static const lightTextPrimary = Color(0xFF212121);

  // Dark neutrals
  static const darkBg = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkBorder = Color(0xFF333333);
  static const darkTextSecondary = Color(0xFFBDBDBD);
  static const darkTextPrimary = Color(0xFFFAFAFA);
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const base = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

class AppRadius {
  static const small = 8.0;
  static const medium = 12.0;
  static const large = 16.0;
  static const full = 9999.0;
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: AppColors.primary,
        scaffoldBackgroundColor: AppColors.lightBg,
        cardTheme: CardThemeData(
          color: AppColors.lightSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.large),
            side: const BorderSide(color: AppColors.lightBorder, width: 0.5),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightBg,
          foregroundColor: AppColors.lightTextPrimary,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(44, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lightSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            borderSide: const BorderSide(color: AppColors.lightBorder),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.md,
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: AppColors.primary,
        scaffoldBackgroundColor: AppColors.darkBg,
        cardTheme: CardThemeData(
          color: AppColors.darkSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.large),
            side: const BorderSide(color: AppColors.darkBorder, width: 0.5),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBg,
          foregroundColor: AppColors.darkTextPrimary,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(44, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.md,
          ),
        ),
      );
}
