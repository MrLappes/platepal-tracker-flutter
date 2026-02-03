import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/app_theme.dart';

enum ThemePreference { dark, light, system }

class ThemeProvider extends ChangeNotifier {
  static const String _themePrefKey = 'theme_preference';
  static const String _themeNameKey = 'theme_name';

  ThemePreference _themePreference = ThemePreference.dark; // Default to Dark
  String _currentThemeName = AppThemes.originalCyber.name;
  AppTheme _currentTheme = AppThemes.originalCyber;
  bool _isDark = true;

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
          orElse: () => ThemePreference.dark,
        );
      } 

      final savedThemeName = prefs.getString(_themeNameKey);
      if (savedThemeName != null) {
        _currentThemeName = savedThemeName;
      } else {
        _currentThemeName = AppThemes.originalCyber.name;
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

    _currentTheme = _isDark ? AppThemes.originalCyber : AppThemes.customLight;

    _updateSystemBrightness();
    notifyListeners();
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

  Future<void> toggleTheme() async {
    if (_themePreference == ThemePreference.light) {
      await setThemePreference(ThemePreference.dark);
    } else {
      await setThemePreference(ThemePreference.light);
    }
  }

  // Restore logic for MenuScreen
  List<String> get availableThemes => AppThemes.allThemes.map((t) => t.name).toList();

  Future<void> setThemeByName(String themeName) async {
    if (_currentThemeName != themeName) {
      _currentThemeName = themeName;
      _updateTheme();
      await _saveThemePreference();
    }
  }

  List<String> get allAvailableThemes => AppThemes.allThemes.map((t) => t.name).toList();
}
