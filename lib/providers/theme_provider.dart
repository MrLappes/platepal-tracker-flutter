import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/app_theme.dart';

enum ThemePreference { dark, light, system }

class ThemeProvider extends ChangeNotifier {
  static const String _themePrefKey = 'theme_preference';
  static const String _themeNameKey = 'theme_name';

  ThemePreference _themePreference = ThemePreference.system;
  String _currentThemeName = AppThemes.light.name;
  AppTheme _currentTheme = AppThemes.light;
  bool _isDark = false;

  ThemeProvider() {
    _loadThemePreference();
    _updateSystemBrightness();
  }

  // Getters
  ThemePreference get themePreference => _themePreference;
  String get currentThemeName => _currentThemeName;
  AppTheme get currentTheme => _currentTheme;
  bool get isDark => _isDark;
  ThemeData get materialTheme => _currentTheme.materialTheme;

  // Load saved theme preference from storage
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load theme preference
      final savedPreference = prefs.getString(_themePrefKey);
      if (savedPreference != null) {
        _themePreference = ThemePreference.values.firstWhere(
          (e) => e.name == savedPreference,
          orElse: () => ThemePreference.system,
        );
      } // Load theme name
      final savedThemeName = prefs.getString(_themeNameKey);
      if (savedThemeName != null) {
        // If the saved theme is Light or Dark, migrate to Oceanic
        if (['Light', 'Dark'].contains(savedThemeName)) {
          _currentThemeName = 'Oceanic';
          // Save the migrated theme name
          await prefs.setString(_themeNameKey, _currentThemeName);
        } else {
          _currentThemeName = savedThemeName;
        }
      } else {
        // Default to Oceanic for new users
        _currentThemeName = 'Oceanic';
      }

      _updateTheme();
    } catch (error) {
      debugPrint('Failed to load theme preference: $error');
    }
  }

  // Save theme preference to storage
  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themePrefKey, _themePreference.name);
      await prefs.setString(_themeNameKey, _currentThemeName);
    } catch (error) {
      debugPrint('Failed to save theme preference: $error');
    }
  }

  // Update the current theme based on preference and system brightness
  void _updateTheme() {
    // Determine if dark mode should be active
    switch (_themePreference) {
      case ThemePreference.dark:
        _isDark = true;
        break;
      case ThemePreference.light:
        _isDark = false;
        break;
      case ThemePreference.system:
        final brightness = PlatformDispatcher.instance.platformBrightness;
        _isDark = brightness == Brightness.dark;
        break;
    }

    // Get the base theme by name
    final baseTheme = AppThemes.getThemeByName(_currentThemeName);

    // Create the appropriate theme variant (light/dark)
    if (_isDark && !baseTheme.isDark) {
      // If we need dark but the selected theme is light, use the dark variant
      _currentTheme = _createDarkVariant(baseTheme);
    } else if (!_isDark && baseTheme.isDark) {
      // If we need light but the selected theme is dark, use the light variant
      _currentTheme = _createLightVariant(baseTheme);
    } else {
      _currentTheme = baseTheme;
    }

    _updateSystemBrightness();
    notifyListeners();
  }

  // Create a dark variant of a light theme
  AppTheme _createDarkVariant(AppTheme lightTheme) {
    return AppTheme(
      name: '${lightTheme.name} Dark',
      isDark: true,
      colors: AppThemeColors(
        primary: lightTheme.colors.primary,
        background: const Color(0xFF121212),
        card: const Color(0xFF1e1e1e),
        text: const Color(0xFFffffff),
        border: const Color(0xFF2c2c2c),
        notification: lightTheme.colors.notification,
        secondary: lightTheme.colors.secondary,
        success: lightTheme.colors.success,
        warning: lightTheme.colors.warning,
        error: lightTheme.colors.error,
      ),
    );
  }

  // Create a light variant of a dark theme
  AppTheme _createLightVariant(AppTheme darkTheme) {
    return AppTheme(
      name: '${darkTheme.name} Light',
      isDark: false,
      colors: AppThemeColors(
        primary: darkTheme.colors.primary,
        background: const Color(0xFFffffff),
        card: const Color(0xFFf8f8f8),
        text: const Color(0xFF000000),
        border: const Color(0xFFe0e0e0),
        notification: darkTheme.colors.notification,
        secondary: darkTheme.colors.secondary,
        success: darkTheme.colors.success,
        warning: darkTheme.colors.warning,
        error: darkTheme.colors.error,
      ),
    );
  }

  // Update system UI overlay style based on current theme
  void _updateSystemBrightness() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: _currentTheme.colors.background,
        systemNavigationBarIconBrightness:
            _isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  // Public methods to change theme
  Future<void> setThemePreference(ThemePreference preference) async {
    if (_themePreference != preference) {
      _themePreference = preference;
      _updateTheme();
      await _saveThemePreference();
    }
  }

  Future<void> setThemeByName(String themeName) async {
    if (_currentThemeName != themeName) {
      _currentThemeName = themeName;
      _updateTheme();
      await _saveThemePreference();
    }
  }

  Future<void> setTheme(ThemePreference preference, {String? themeName}) async {
    bool changed = false;

    if (_themePreference != preference) {
      _themePreference = preference;
      changed = true;
    }

    if (themeName != null && _currentThemeName != themeName) {
      _currentThemeName = themeName;
      changed = true;
    }

    if (changed) {
      _updateTheme();
      await _saveThemePreference();
    }
  }

  // Toggle between light and dark mode
  Future<void> toggleTheme() async {
    switch (_themePreference) {
      case ThemePreference.light:
        await setThemePreference(ThemePreference.dark);
        break;
      case ThemePreference.dark:
        await setThemePreference(ThemePreference.light);
        break;
      case ThemePreference.system:
        // If system, toggle to the opposite of current system setting
        final brightness = PlatformDispatcher.instance.platformBrightness;
        await setThemePreference(
          brightness == Brightness.dark
              ? ThemePreference.light
              : ThemePreference.dark,
        );
        break;
    }
  }

  // Get all available theme names (excluding base Light/Dark themes)
  List<String> get availableThemes =>
      AppThemes.allThemes
          .where((t) => !['Light', 'Dark'].contains(t.name))
          .map((t) => t.name)
          .toList();

  // Get all base theme names (including Light/Dark for backwards compatibility)
  List<String> get allAvailableThemes =>
      AppThemes.allThemes.map((t) => t.name).toList();

  // Check if a premium theme is selected (for sponsor themes)
  bool get isPremiumTheme => !['Light', 'Dark'].contains(_currentThemeName);
}
