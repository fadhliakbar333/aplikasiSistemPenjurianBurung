import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1A1A2E);
  static const Color secondary = Color(0xFFF28C28);
  static const Color tertiary = Color(0xFFA4DE02);

  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(
    0xFF101020,
  ); // Warna dasar untuk Dark Mode
  static const Color cardDark = Color(
    0xFF1A1A2E,
  ); // Warna kartu di Dark Mode, sama dengan primary

  static const Color accentWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFF555555);
  static const Color textHint = Color(0xFF999999);
  static const Color progressTrack = Color(0xFFF2D7C2);
}

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.accentWhite,
    ),
    cardTheme: CardThemeData(
      color: AppColors.accentWhite,
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.2),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.accentWhite,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.primary,
      selectedItemColor: AppColors.secondary,
      unselectedItemColor: AppColors.textHint,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.secondary, width: 2.0),
      ),
      labelStyle: TextStyle(color: AppColors.textGray),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.secondary,
      linearTrackColor: AppColors.progressTrack,
      circularTrackColor: AppColors.progressTrack,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textGray),
      bodyMedium: TextStyle(color: AppColors.textGray),
      titleLarge: TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary, // Tetap sama
      foregroundColor: AppColors.accentWhite,
    ),
    cardTheme: const CardThemeData(color: AppColors.cardDark, elevation: 4),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        // Di dark mode, tombol utama bisa menggunakan warna aksen agar menonjol
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.primary,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.primary, // Tetap sama
      selectedItemColor: AppColors.secondary,
      unselectedItemColor: AppColors.textHint,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.textHint),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.secondary, width: 2.0),
      ),
      labelStyle: TextStyle(color: AppColors.backgroundLight),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.secondary,
      linearTrackColor: AppColors.primary,
      circularTrackColor: AppColors.primary,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.backgroundLight),
      bodyMedium: TextStyle(color: AppColors.backgroundLight),
      titleLarge: TextStyle(
        color: AppColors.accentWhite,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
