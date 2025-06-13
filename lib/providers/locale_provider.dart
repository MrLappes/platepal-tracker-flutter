import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';

  Locale _locale = const Locale('en');

  LocaleProvider() {
    _loadLocalePreference();
  }

  Locale get locale => _locale;

  // Load saved locale preference from storage
  Future<void> _loadLocalePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguageCode = prefs.getString(_localeKey);

      if (savedLanguageCode != null) {
        // Validate that the saved language is supported
        final supportedLanguages = ['en', 'es', 'de'];
        if (supportedLanguages.contains(savedLanguageCode)) {
          _locale = Locale(savedLanguageCode);
          notifyListeners();
        }
      }
    } catch (error) {
      debugPrint('Failed to load locale preference: $error');
    }
  }

  // Save locale preference to storage
  Future<void> _saveLocalePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, _locale.languageCode);
    } catch (error) {
      debugPrint('Failed to save locale preference: $error');
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale != locale) {
      _locale = locale;
      await _saveLocalePreference();
      notifyListeners();
    }
  }

  Future<void> setLanguage(String languageCode) async {
    await setLocale(Locale(languageCode));
  }

  bool get isEnglish => _locale.languageCode == 'en';
  bool get isSpanish => _locale.languageCode == 'es';
  bool get isGerman => _locale.languageCode == 'de';
}
