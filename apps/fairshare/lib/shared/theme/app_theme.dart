import 'package:flutter/material.dart';

class AppColors {
  // Brand colors - warm, friendly, gender-neutral
  static const primary = Color(0xFF6C63FF); // Soft purple
  static const primaryLight = Color(0xFF9D97FF);
  static const primaryDark = Color(0xFF4A42DB);
  static const accent = Color(0xFFFF6B9D); // Warm pink
  static const accentLight = Color(0xFFFF9DC0);

  // Functional colors
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFB74D);
  static const error = Color(0xFFEF5350);
  static const info = Color(0xFF42A5F5);

  // Neutrals
  static const background = Color(0xFFF8F7FF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF0EEFF);
  static const border = Color(0xFFE0DEF0);
  static const textPrimary = Color(0xFF2D2B3D);
  static const textSecondary = Color(0xFF6E6B80);
  static const textHint = Color(0xFFA09DB0);

  // Dark mode
  static const darkBackground = Color(0xFF1A1A2E);
  static const darkSurface = Color(0xFF252540);
  static const darkSurfaceVariant = Color(0xFF2E2E4A);
  static const darkBorder = Color(0xFF3D3D5C);
  static const darkTextPrimary = Color(0xFFF0EEFF);
  static const darkTextSecondary = Color(0xFFA09DB0);

  // Member avatar colors
  static const avatarColors = [
    Color(0xFF6C63FF),
    Color(0xFFFF6B9D),
    Color(0xFF4CAF50),
    Color(0xFFFFB74D),
    Color(0xFF42A5F5),
    Color(0xFFAB47BC),
    Color(0xFF26A69A),
    Color(0xFFFF7043),
  ];
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double full = 9999;
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'SF Pro Display',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      fontFamily: 'SF Pro Display',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
