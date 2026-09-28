import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/providers/locale_provider.dart';
import 'package:platepal_tracker/providers/theme_provider.dart';
import 'package:platepal_tracker/screens/menu_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
