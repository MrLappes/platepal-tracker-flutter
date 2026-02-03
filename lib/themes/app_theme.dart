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
        onSurface: colors.text,
        primary: colors.primary,
        secondary: colors.secondary,
        error: colors.error,
        outline: colors.border,
      ),
      scaffoldBackgroundColor: colors.background,
      cardColor: colors.card,
      dividerColor: colors.border,
      
      // SHARP MODERN TYPOGRAPHY
      textTheme: TextTheme(
        displayLarge: TextStyle(color: colors.text, fontWeight: FontWeight.w900, letterSpacing: -1.0),
        headlineLarge: TextStyle(color: colors.text, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        titleLarge: TextStyle(color: colors.text, fontWeight: FontWeight.bold, fontSize: 18),
        bodyLarge: TextStyle(color: colors.text, fontSize: 16),
        bodyMedium: TextStyle(color: colors.text.withValues(alpha: 0.9), fontSize: 14),
        labelLarge: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, letterSpacing: 1.1),
        labelSmall: TextStyle(
          fontWeight: FontWeight.w900, 
          letterSpacing: 1.5, 
          fontSize: 10, 
          fontFamily: 'monospace',
          color: colors.text.withValues(alpha: 0.7),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colors.text,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),

      cardTheme: CardThemeData(
        color: colors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2), 
          side: BorderSide(color: colors.border, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: isDark ? Colors.black : Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)), 
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.text,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          side: BorderSide(color: colors.border, width: 2),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, 
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.black : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.card,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.text.withValues(alpha: 0.3),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      
      tabBarTheme: TabBarThemeData(
        indicatorColor: colors.primary,
        labelColor: colors.primary,
        unselectedLabelColor: colors.text.withValues(alpha: 0.5),
        indicatorSize: TabBarIndicatorSize.tab,
      ),
    );
  }
}

class AppThemes {
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

  static const AppTheme dark = AppTheme(
    name: 'Dark',
    isDark: true,
    colors: AppThemeColors(
      primary: Color(0xFFfba9eb),
      background: Color(0xFF0A0A0A),
      card: Color(0xFF121212),
      text: Color(0xFFffffff),
      border: Color(0xFF222222),
      notification: Color(0xFFff453a),
      secondary: Color(0xFF6C757D),
      success: Color(0xFF28A745),
      warning: Color(0xFFFFC107),
      error: Color(0xFFDC3545),
    ),
  );

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
      primary: Color(0xFFe384c7),
      background: Color(0xFFF5F5F5),
      card: Color(0xFFffffff),
      text: Color(0xFF5B5B5B),
      border: Color(0xFFe0e0e0),
      notification: Color(0xFFff3b30),
      secondary: Color(0xFF9e6593),
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
      orElse: () => dark,
    );
  }
}
