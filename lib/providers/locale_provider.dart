import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  static const _supportedLanguages = ['en', 'es', 'de'];
  final SharedPreferences? _prefs;

  Locale? _selectedLocale;

  LocaleProvider({SharedPreferences? prefs}) : _prefs = prefs {
    if (prefs == null) {
      _loadLocalePreference();
    } else {
      _restoreLocalePreference(prefs);
    }
  }

  Locale? get selectedLocale => _selectedLocale;
  Locale get locale {
    if (_selectedLocale != null) return _selectedLocale!;
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    return _supportedLanguages.contains(deviceLocale.languageCode)
        ? Locale(deviceLocale.languageCode)
        : const Locale('en');
  }

  // Load saved locale preference from storage
  Future<void> _loadLocalePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _restoreLocalePreference(prefs);
    } catch (error) {
      debugPrint('Failed to load locale preference: $error');
    }
  }

  void _restoreLocalePreference(SharedPreferences prefs) {
    final savedLanguageCode = prefs.getString(_localeKey);
    if (_supportedLanguages.contains(savedLanguageCode)) {
      _selectedLocale = Locale(savedLanguageCode!);
      notifyListeners();
    }
  }

  // Save locale preference to storage
  Future<void> _saveLocalePreference() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final selectedLocale = _selectedLocale;
      if (selectedLocale == null) {
        await prefs.remove(_localeKey);
      } else {
        await prefs.setString(_localeKey, selectedLocale.languageCode);
      }
    } catch (error) {
      debugPrint('Failed to save locale preference: $error');
    }
  }

  Future<void> setLocale(Locale? locale) async {
    if (_selectedLocale != locale || locale == null) {
      _selectedLocale = locale;
      await _saveLocalePreference();
      notifyListeners();
    }
  }

  Future<void> setLanguage(String languageCode) async {
    await setLocale(Locale(languageCode));
  }

  bool get isEnglish => locale.languageCode == 'en';
  bool get isSpanish => locale.languageCode == 'es';
  bool get isGerman => locale.languageCode == 'de';
}
