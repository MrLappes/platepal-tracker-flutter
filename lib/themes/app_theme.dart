import 'package:flutter/material.dart';

class AppThemeColors {
  final Color primary;
  final Color background;
  final Color card;
  final Color text;
  final Color border;
  final Color notification;
  final Color secondary;
  final Color success;
  final Color warning;
  final Color error;
  final Color accent;

  const AppThemeColors({
    required this.primary,
    required this.background,
    required this.card,
    required this.text,
    required this.border,
    required this.notification,
    required this.secondary,
    required this.success,
    required this.warning,
    required this.error,
    this.accent = const Color(0xFF00E5FF),
  });
}

class AppTheme {
  final String name;
  final AppThemeColors colors;
  final bool isDark;

  const AppTheme({
    required this.name,
    required this.colors,
    required this.isDark,
  });

  ThemeData get materialTheme {
    final baseTextTheme = Typography.material2021().black;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: colors.primary,
      brightness: isDark ? Brightness.dark : Brightness.light,
      surface: colors.card,
      onSurface: colors.text,
      error: colors.error,
      primary: colors.primary,
      secondary: colors.secondary,
      outline: colors.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      cardColor: colors.card,
      dividerColor: colors.border,
      
      // Modern Cyber-minimalistic Typography
      textTheme: TextTheme(
        displayLarge: TextStyle(color: colors.text, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        headlineLarge: TextStyle(color: colors.text, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        titleLarge: TextStyle(color: colors.text, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: colors.text, fontSize: 16),
        bodyMedium: TextStyle(color: colors.text.withValues(alpha: 0.8), fontSize: 14),
        labelLarge: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, letterSpacing: 1.1),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.text,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colors.text,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),

      cardTheme: CardThemeData(
        color: colors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.border, width: 1.5),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.text,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          side: BorderSide(color: colors.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        labelStyle: TextStyle(color: colors.text.withValues(alpha: 0.6)),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.background,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.text.withValues(alpha: 0.4),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}

class AppThemes {
  // Industrial Dark - Deep black and Cyber Cyan
  static const AppTheme industrialDark = AppTheme(
    name: 'Industrial',
    isDark: true,
    colors: AppThemeColors(
      primary: Color(0xFF00E5FF), // Cyber Cyan
      background: Color(0xFF0A0A0A), // Near Black
      card: Color(0xFF141414), // Dark Grey
      text: Color(0xFFE0E0E0), // Cold White
      border: Color(0xFF222222), // Steel
      notification: Color(0xFFFF3D00),
      secondary: Color(0xFF757575),
      success: Color(0xFF00E676),
      warning: Color(0xFFFFAB00),
      error: Color(0xFFFF1744),
    ),
  );

  // Studio Light - Clean, high contrast, precise
  static const AppTheme studioLight = AppTheme(
    name: 'Studio',
    isDark: false,
    colors: AppThemeColors(
      primary: Color(0xFF000000), // Pure Black actions
      background: Color(0xFFFFFFFF),
      card: Color(0xFFFBFBFB),
      text: Color(0xFF1A1A1A),
      border: Color(0xFFEEEEEE),
      notification: Color(0xFFFF3D00),
      secondary: Color(0xFF9E9E9E),
      success: Color(0xFF2E7D32),
      warning: Color(0xFFF57C00),
      error: Color(0xFFD32F2F),
    ),
  );

  static List<AppTheme> get allThemes => [
    industrialDark,
    studioLight,
  ];

  static AppTheme get dark => industrialDark;
  static AppTheme get light => studioLight;

  static AppTheme getThemeByName(String name) {
    return allThemes.firstWhere(
      (theme) => theme.name == name,
      orElse: () => industrialDark,
    );
  }
}
