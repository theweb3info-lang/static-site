import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand colors
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFF8B7CF7);
  static const Color accent = Color(0xFF00CEC9);

  // Battery colors
  static const Color batteryFull = Color(0xFF00B894);
  static const Color batteryMedium = Color(0xFFFDCB6E);
  static const Color batteryLow = Color(0xFFE17055);
  static const Color batteryCritical = Color(0xFFD63031);

  // Functional colors
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFD63031);
  static const Color info = Color(0xFF74B9FF);

  // Light theme
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE9ECEF);
  static const Color lightTextSecondary = Color(0xFF6C757D);
  static const Color lightTextPrimary = Color(0xFF212529);

  // Dark theme
  static const Color darkBg = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E2E);
  static const Color darkBorder = Color(0xFF2D2D3D);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextPrimary = Color(0xFFF3F4F6);

  static Color getBatteryColor(double percentage) {
    if (percentage > 60) return batteryFull;
    if (percentage > 30) return batteryMedium;
    if (percentage > 15) return batteryLow;
    return batteryCritical;
  }
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

class AppRadius {
  AppRadius._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double full = 9999;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: AppColors.primary,
        scaffoldBackgroundColor: AppColors.lightBg,
        fontFamily: 'sans-serif',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppColors.lightTextPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
        ),
        cardTheme: CardThemeData(
          color: AppColors.lightSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: const BorderSide(color: AppColors.lightBorder, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.lightSurface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.lightTextSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: AppColors.primary,
        scaffoldBackgroundColor: AppColors.darkBg,
        fontFamily: 'sans-serif',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppColors.darkTextPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: const BorderSide(color: AppColors.darkBorder, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkSurface,
          selectedItemColor: AppColors.primaryLight,
          unselectedItemColor: AppColors.darkTextSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      );
}
