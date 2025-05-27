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
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: isDark ? Brightness.dark : Brightness.light,
        surface: colors.card,
        error: colors.error,
      ),
      scaffoldBackgroundColor: colors.background,
      cardColor: colors.card,
      dividerColor: colors.border,
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: colors.text),
        bodyMedium: TextStyle(color: colors.text),
        bodySmall: TextStyle(color: colors.text),
        headlineLarge: TextStyle(color: colors.text),
        headlineMedium: TextStyle(color: colors.text),
        headlineSmall: TextStyle(color: colors.text),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.text,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.card,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.text.withValues(alpha: 0.6),
      ),
      cardTheme: CardTheme(
        color: colors.card,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: isDark ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: isDark ? Colors.black : Colors.white,
      ),
    );
  }
}

// Predefined themes
class AppThemes {
  // Light Theme - matching your React Native colors
  static const AppTheme light = AppTheme(
    name: 'Light',
    isDark: false,
    colors: AppThemeColors(
      primary: Color(0xFFfba9eb),
      background: Color(0xFFffffff),
      card: Color(0xFFf8f8f8),
      text: Color(0xFF000000),
      border: Color(0xFFe0e0e0),
      notification: Color(0xFFff3b30),
      secondary: Color(0xFF6C757D),
      success: Color(0xFF28A745),
      warning: Color(0xFFFFC107),
      error: Color(0xFFDC3545),
    ),
  );

  // Dark Theme - matching your React Native colors
  static const AppTheme dark = AppTheme(
    name: 'Dark',
    isDark: true,
    colors: AppThemeColors(
      primary: Color(0xFFfba9eb),
      background: Color(0xFF121212),
      card: Color(0xFF1e1e1e),
      text: Color(0xFFffffff),
      border: Color(0xFF2c2c2c),
      notification: Color(0xFFff453a),
      secondary: Color(0xFF6C757D),
      success: Color(0xFF28A745),
      warning: Color(0xFFFFC107),
      error: Color(0xFFDC3545),
    ),
  );

  // Future sponsor themes can be added here
  static const AppTheme oceanic = AppTheme(
    name: 'Oceanic',
    isDark: false,
    colors: AppThemeColors(
      primary: Color(0xFF0077BE),
      background: Color(0xFFffffff),
      card: Color(0xFFf0f8ff),
      text: Color(0xFF000000),
      border: Color(0xFFcce7ff),
      notification: Color(0xFFff3b30),
      secondary: Color(0xFF4A90A4),
      success: Color(0xFF00A86B),
      warning: Color(0xFFFFB347),
      error: Color(0xFFE74C3C),
    ),
  );

  static const AppTheme forest = AppTheme(
    name: 'Forest',
    isDark: false,
    colors: AppThemeColors(
      primary: Color(0xFF228B22),
      background: Color(0xFFffffff),
      card: Color(0xFFf0fff0),
      text: Color(0xFF000000),
      border: Color(0xFFc8e6c8),
      notification: Color(0xFFff3b30),
      secondary: Color(0xFF5D8A5D),
      success: Color(0xFF32CD32),
      warning: Color(0xFFFFD700),
      error: Color(0xFFDC143C),
    ),
  );

  static const AppTheme platePal = AppTheme(
    name: 'PlatePal',
    isDark: false,
    colors: AppThemeColors(
      primary: Color(0xFFe384c7), // Original PlatePal primary color
      background: Color(0xFFF5F5F5),
      card: Color(0xFFffffff),
      text: Color(0xFF5B5B5B),
      border: Color(0xFFe0e0e0),
      notification: Color(0xFFff3b30),
      secondary: Color(0xFF9e6593), // Original PlatePal secondary color
      success: Color(0xFF28A745),
      warning: Color(0xFFFFC107),
      error: Color(0xFFDC3545),
    ),
  );

  static List<AppTheme> get allThemes => [
    light,
    dark,
    oceanic,
    forest,
    platePal,
  ];

  static AppTheme getThemeByName(String name) {
    return allThemes.firstWhere(
      (theme) => theme.name == name,
      orElse: () => light,
    );
  }
}
