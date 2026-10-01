import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/providers/locale_provider.dart';
import 'package:platepal_tracker/providers/theme_provider.dart';
import 'package:platepal_tracker/screens/menu_screen.dart';
import 'package:platepal_tracker/themes/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferences whose reads and writes always fail.
class _BrokenPrefs extends Fake implements SharedPreferences {
  @override
  String? getString(String key) => throw StateError('prefs unavailable');

  @override
  Future<bool> setString(String key, String value) async =>
      throw StateError('prefs unavailable');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('both brightness variants register macro colors', () {
    for (final theme in AppThemes.allThemes) {
      expect(
        theme.toLight().materialTheme.extension<MacroColors>(),
        same(MacroColors.light),
      );
      expect(
        theme.toDark().materialTheme.extension<MacroColors>(),
        same(MacroColors.dark),
      );
    }
  });

  test('macro palette copyWith preserves unspecified nutrient colors', () {
    final changed = MacroColors.light.copyWith(
      protein: const Color(0xFF123456),
    );

    expect(changed.protein, const Color(0xFF123456));
    expect(changed.calories, MacroColors.light.calories);
    expect(changed.carbs, MacroColors.light.carbs);
    expect(changed.fat, MacroColors.light.fat);
    expect(changed.fiber, MacroColors.light.fiber);
  });

  test('macro palette interpolates every color', () {
    final midpoint = MacroColors.light.lerp(MacroColors.dark, 0.5);

    expect(
      midpoint.calories,
      Color.lerp(MacroColors.light.calories, MacroColors.dark.calories, 0.5),
    );
    expect(
      midpoint.protein,
      Color.lerp(MacroColors.light.protein, MacroColors.dark.protein, 0.5),
    );
    expect(
      midpoint.carbs,
      Color.lerp(MacroColors.light.carbs, MacroColors.dark.carbs, 0.5),
    );
    expect(
      midpoint.fat,
      Color.lerp(MacroColors.light.fat, MacroColors.dark.fat, 0.5),
    );
    expect(
      midpoint.fiber,
      Color.lerp(MacroColors.light.fiber, MacroColors.dark.fiber, 0.5),
    );
    expect(MacroColors.light.lerp(null, 0.5), same(MacroColors.light));
  });

  test('storage failures keep the chosen theme and never throw', () async {
    final provider = ThemeProvider(prefs: _BrokenPrefs());
    addTearDown(provider.dispose);
    expect(provider.themePreference, ThemePreference.dark);

    await provider.setThemePreference(ThemePreference.light);

    expect(provider.themePreference, ThemePreference.light);
    expect(provider.isDark, isFalse);
    expect(provider.lastSaveFailed, isTrue);
  });

  test('applies saved theme synchronously from supplied preferences', () async {
    SharedPreferences.setMockInitialValues({
      'theme_preference': 'light',
      'theme_name': 'Forest',
    });
    final prefs = await SharedPreferences.getInstance();
    final provider = ThemeProvider(prefs: prefs);
    addTearDown(provider.dispose);

    expect(provider.themePreference, ThemePreference.light);
    expect(provider.currentThemeName, 'Forest');
    expect(provider.isDark, isFalse);
    expect(provider.currentTheme.colors.primary, const Color(0xFF228B22));
    expect(provider.lightTheme.brightness, Brightness.light);
    expect(provider.darkTheme.brightness, Brightness.dark);
  });

  test('setThemePreference saves the selected preference', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final provider = ThemeProvider(prefs: prefs);
    addTearDown(provider.dispose);

    await provider.setThemePreference(ThemePreference.system);

    expect(prefs.getString('theme_preference'), 'system');
  });

  testWidgets('system theme follows platform brightness changes', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'theme_preference': 'system',
      'theme_name': 'Oceanic',
    });
    tester.binding.platformDispatcher.platformBrightnessTestValue =
        Brightness.light;
    final provider = ThemeProvider();
    addTearDown(() {
      provider.dispose();
      tester.binding.platformDispatcher.clearPlatformBrightnessTestValue();
    });

    await tester.pump();
    expect(provider.themePreference, ThemePreference.system);
    expect(provider.isDark, isFalse);

    tester.binding.platformDispatcher.platformBrightnessTestValue =
        Brightness.dark;
    await tester.pump();
    expect(provider.isDark, isTrue);
  });

  testWidgets(
    'menu shows translated theme names without changing saved values',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'app_locale': 'es',
        'theme_name': 'Forest',
      });
      final prefs = await SharedPreferences.getInstance();
      final localeProvider = LocaleProvider(prefs: prefs);
      final themeProvider = ThemeProvider(prefs: prefs);
      addTearDown(localeProvider.dispose);
      addTearDown(themeProvider.dispose);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
            ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
          ],
          child: const MaterialApp(
            locale: Locale('es'),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: MenuScreen(),
          ),
        ),
      );
      await tester.scrollUntilVisible(find.text('Bosque'), 250);

      expect(find.text('Bosque'), findsOneWidget);
      expect(prefs.getString('theme_name'), 'Forest');
    },
  );
}
