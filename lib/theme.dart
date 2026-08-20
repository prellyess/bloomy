import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF4A5E3A);
  static const Color primaryLight = Color(0xFF6B7F55);
  static const Color accent = Color(0xFFE8A4A4);
  static const Color accentDark = Color(0xFFD4848A);
  static const Color background = Color(0xFFF5EDE8);
  static const Color surface = Color(0xFFFDF6F3);
  static const Color textDark = Color(0xFF2D2D2D);
  static const Color textMedium = Color(0xFF6B6B6B);
  static const Color textLight = Color(0xFF9E9E9E);
  static const Color divider = Color(0xFFE8DDD8);
  static const Color inputBg = Color(0xFFF0E8E3);
  static const Color error = Color(0xFFE57373);
  static const Color success = Color(0xFF81C784);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.dmSans(color: AppColors.textLight, fontSize: 14),
      ),
    );
  }
}