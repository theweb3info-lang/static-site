import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand colors - warm, emotional
  static const primary = Color(0xFFD4845A); // warm amber/terracotta
  static const primaryLight = Color(0xFFF5E6D3); // soft cream
  static const accent = Color(0xFF7B6B5D); // warm brown
  static const accentGold = Color(0xFFD4A855); // gold for unlock

  // Neutrals
  static const background = Color(0xFFFAF7F4); // warm off-white
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF0EBE5);
  static const border = Color(0xFFE0D8D0);
  static const textPrimary = Color(0xFF2D2420);
  static const textSecondary = Color(0xFF8A7E76);
  static const textTertiary = Color(0xFFB5AAA1);

  // Functional
  static const success = Color(0xFF6B9E78);
  static const warning = Color(0xFFD4A855);
  static const error = Color(0xFFCC6B5A);

  // Dark mode
  static const darkBackground = Color(0xFF1A1614);
  static const darkSurface = Color(0xFF2D2620);
  static const darkSurfaceVariant = Color(0xFF3D342C);
  static const darkBorder = Color(0xFF4A3F37);
  static const darkTextPrimary = Color(0xFFF5EDE6);
  static const darkTextSecondary = Color(0xFFAA9E94);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.notoSansScTextTheme().copyWith(
        displayLarge: GoogleFonts.notoSerifSc(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.notoSerifSc(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.notoSerifSc(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.notoSerifSc(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyLarge: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
        bodyMedium: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        bodySmall: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        labelSmall: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoSerifSc(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.darkSurface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: GoogleFonts.notoSansScTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.notoSerifSc(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: AppColors.darkTextPrimary,
        ),
        headlineLarge: GoogleFonts.notoSerifSc(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
        headlineMedium: GoogleFonts.notoSerifSc(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
        titleLarge: GoogleFonts.notoSerifSc(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.darkTextPrimary,
        ),
        bodyLarge: const TextStyle(fontSize: 16, color: AppColors.darkTextPrimary),
        bodyMedium: const TextStyle(fontSize: 14, color: AppColors.darkTextPrimary),
        bodySmall: const TextStyle(fontSize: 12, color: AppColors.darkTextSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoSerifSc(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder, width: 0.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
