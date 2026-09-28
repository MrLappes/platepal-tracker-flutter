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

  test(
    'applies saved locale synchronously from supplied preferences',
    () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'de'});
      final prefs = await SharedPreferences.getInstance();
      final provider = LocaleProvider(prefs: prefs);
      addTearDown(provider.dispose);

      expect(provider.selectedLocale, const Locale('de'));
      expect(provider.locale.languageCode, 'de');
    },
  );

  testWidgets('no saved locale follows the device language', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.binding.platformDispatcher.localeTestValue = const Locale('es');
    addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);
    final prefs = await SharedPreferences.getInstance();
    final provider = LocaleProvider(prefs: prefs);
    addTearDown(provider.dispose);

    expect(provider.selectedLocale, isNull);
    expect(provider.locale.languageCode, 'es');
  });

  testWidgets('unsupported device language falls back to English', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.binding.platformDispatcher.localeTestValue = const Locale('fr');
    addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);
    final prefs = await SharedPreferences.getInstance();
    final provider = LocaleProvider(prefs: prefs);
    addTearDown(provider.dispose);

    expect(provider.selectedLocale, isNull);
    expect(provider.locale.languageCode, 'en');
  });

  test('setLocale persists the selected app language', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final provider = LocaleProvider(prefs: prefs);
    addTearDown(provider.dispose);

    await provider.setLocale(const Locale('es'));

    expect(provider.selectedLocale, const Locale('es'));
    expect(prefs.getString('app_locale'), 'es');
  });

  test('selecting system removes the saved app language', () async {
    SharedPreferences.setMockInitialValues({'app_locale': 'de'});
    final prefs = await SharedPreferences.getInstance();
    final provider = LocaleProvider(prefs: prefs);
    addTearDown(provider.dispose);

    await provider.setLocale(null);

    expect(provider.selectedLocale, isNull);
    expect(prefs.containsKey('app_locale'), isFalse);
  });

  testWidgets('menu language selector restores the system locale', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'app_locale': 'de'});
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
    await tester.ensureVisible(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Predeterminado del sistema').last);
    await tester.pumpAndSettle();

    expect(prefs.containsKey('app_locale'), isFalse);
    expect(localeProvider.selectedLocale, isNull);
    expect(
      tester
          .widget<DropdownButton<String>>(find.byType(DropdownButton<String>))
          .value,
      'system',
    );
  });
}
