import 'package:flutter/material.dart';

class AppTheme {
  // Main Colors
  static const Color primary = Color(0xFF2F5D50); // Forest Green
  static const Color accent = Color(0xFFD9773D); // Warm Orange

  // Background Colors
  static const Color background = Color(0xFFF7F3EA); // Warm Cream
  static const Color surface = Color(0xFFFFFCF6); // Light Cream

  // Supporting Colors
  static const Color sage = Color(0xFFA8BFA3); // Sage Green
  static const Color darkText = Color(0xFF2E3A32); // Dark Green
  static const Color secondaryText = Color(0xFF6B6258); // Warm Brown

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
        surface: surface,
      ),
    );

    return base.copyWith(
      // Background
      scaffoldBackgroundColor: background,

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),

      // Main Text
      textTheme: base.textTheme.apply(
        bodyColor: darkText,
        displayColor: darkText,
      ),

      // Elevated Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      // Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
        ),
      ),

      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,

        labelStyle: const TextStyle(
          color: secondaryText,
        ),

        hintStyle: TextStyle(
          color: secondaryText.withValues(alpha: 0.7),
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: sage,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: sage,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: primary,
            width: 2,
          ),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: surface,
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFFDDE5D9),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Floating Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFE5EBDD),
        selectedColor: sage,
        labelStyle: const TextStyle(
          color: darkText,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
      ),
    );
  }
}