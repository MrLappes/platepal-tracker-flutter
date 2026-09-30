import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/app_theme.dart';

enum ThemePreference { dark, light, system }

class ThemeProvider extends ChangeNotifier with WidgetsBindingObserver {
  static const String _themePrefKey = 'theme_preference';
  static const String _themeNameKey = 'theme_name';
  final SharedPreferences? _prefs;

  ThemePreference _themePreference = ThemePreference.dark;
  String _currentThemeName = AppThemes.dark.name;
  AppTheme _currentTheme = AppThemes.dark;
  bool _isDark = true;
  bool _observingBrightness = false;
  bool _lastSaveFailed = false;

  ThemeProvider({SharedPreferences? prefs}) : _prefs = prefs {
    if (prefs == null) {
      _loadThemePreference();
      _updateSystemBrightness();
    } else {
      _restoreThemePreference(prefs);
    }
  }

  // Getters
  ThemePreference get themePreference => _themePreference;
  String get currentThemeName => _currentThemeName;
  AppTheme get currentTheme => _currentTheme;
  bool get isDark => _isDark;

  /// The latest choice is in effect but could not be persisted.
  bool get lastSaveFailed => _lastSaveFailed;
  ThemeData get materialTheme => _currentTheme.materialTheme;
  ThemeData get lightTheme =>
      AppThemes.getThemeByName(_currentThemeName).toLight().materialTheme;
  ThemeData get darkTheme =>
      AppThemes.getThemeByName(_currentThemeName).toDark().materialTheme;

  // Load saved theme preference from storage
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _restoreThemePreference(prefs);
    } catch (error) {
      debugPrint('Failed to load theme preference: $error');
    }
  }

  void _restoreThemePreference(SharedPreferences prefs) {
    final String? savedPreference;
    final String? savedThemeName;
    try {
      savedPreference = prefs.getString(_themePrefKey);
      savedThemeName = prefs.getString(_themeNameKey);
    } catch (error) {
      debugPrint('Failed to read theme preference: ${error.runtimeType}');
      return;
    }
    if (savedPreference != null) {
      _themePreference = ThemePreference.values.firstWhere(
        (preference) => preference.name == savedPreference,
        orElse: () => ThemePreference.dark,
      );
    }

    _currentThemeName = savedThemeName ?? AppThemes.dark.name;
    _updateTheme();
  }

  // Save theme preference to storage
  Future<void> _saveThemePreference() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setString(_themePrefKey, _themePreference.name);
      await prefs.setString(_themeNameKey, _currentThemeName);
      _lastSaveFailed = false;
    } catch (error) {
      debugPrint('Failed to save theme preference: ${error.runtimeType}');
      _lastSaveFailed = true;
    }
  }

  // Update the current theme based on preference and system brightness
  void _updateTheme() {
    if (_themePreference == ThemePreference.system && !_observingBrightness) {
      WidgetsBinding.instance.addObserver(this);
      _observingBrightness = true;
    } else if (_themePreference != ThemePreference.system &&
        _observingBrightness) {
      WidgetsBinding.instance.removeObserver(this);
      _observingBrightness = false;
    }

    // Determine if we should use dark mode
    bool useDark;
    switch (_themePreference) {
      case ThemePreference.dark:
        useDark = true;
        break;
      case ThemePreference.light:
        useDark = false;
        break;
      case ThemePreference.system:
        final brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        useDark = brightness == Brightness.dark;
        break;
    }

    _isDark = useDark;

    // Get the base theme and apply light/dark variant
    final baseTheme = AppThemes.getThemeByName(_currentThemeName);
    _currentTheme = useDark ? baseTheme.toDark() : baseTheme.toLight();

    _updateSystemBrightness();
    notifyListeners();
  }

  @override
  void didChangePlatformBrightness() {
    if (_themePreference == ThemePreference.system) {
      _updateTheme();
    }
  }

  @override
  void dispose() {
    if (_observingBrightness) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
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
      // Don't override theme preference when selecting a base theme
      // Only change preference if explicitly selecting "Light" or "Dark" themes
      if (themeName == 'Light') {
        _themePreference = ThemePreference.light;
      } else if (themeName == 'Dark') {
        _themePreference = ThemePreference.dark;
      }
      // For base themes (PlatePal, Oceanic, Forest), keep current preference
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

  List<String> get availableThemes =>
      AppThemes.allThemes.map((t) => t.name).toList();
  List<String> get allAvailableThemes =>
      AppThemes.allThemes.map((t) => t.name).toList();
}
