import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/main.dart';
import 'package:platepal_tracker/providers/locale_provider.dart';
import 'package:platepal_tracker/providers/theme_provider.dart';
import 'package:platepal_tracker/screens/main_navigation_screen.dart';
import 'package:platepal_tracker/screens/menu_screen.dart';
import 'package:platepal_tracker/screens/settings/privacy_policy_screen.dart';
import 'package:platepal_tracker/services/storage/database_service.dart';
import 'package:platepal_tracker/services/storage/storage_service_provider.dart';
import 'package:platepal_tracker/services/storage/user_profile_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class _Profiles extends UserProfileService {
  @override
  Future<Null> getUserProfile(String userId) async => null;
}

class _FailingUrlLauncher extends UrlLauncherPlatform {
  String? attemptedUrl;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => false;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    attemptedUrl = url;
    return false;
  }
}

Future<void> _pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
  final prefs = await SharedPreferences.getInstance();
  final storage = StorageServiceProvider()..userProfileService = _Profiles();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ThemeProvider(prefs: prefs)),
        ChangeNotifierProvider.value(value: LocaleProvider(prefs: prefs)),
        ChangeNotifierProvider.value(value: storage),
      ],
      child: const PlatePalApp(),
    ),
  );
  await tester.pumpAndSettle();
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/');
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  testWidgets('privacy route opens from the app router', (tester) async {
    await _pumpApp(tester);
    GoRouter.of(
      tester.element(find.byType(MainNavigationScreen)),
    ).go('/privacy');
    await tester.pumpAndSettle();

    expect(find.text('Privacy policy'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(MainNavigationScreen), findsOneWidget);
  });

  for (final (locale, titles, bodyFragment) in [
    (
      const Locale('en'),
      [
        'At a glance',
        'Data on your device',
        'AI chat',
        'Open Food Facts',
        'Health Connect and Apple Health',
        'External links and images',
        'Export and import',
        'Diagnostic log and feedback',
        'Android backup',
        'Delete your data',
        'Children',
        'Changes to this policy',
        'Contact',
      ],
      'Google account',
    ),
    (
      const Locale('de'),
      [
        'Auf einen Blick',
        'Daten auf deinem Gerät',
        'KI-Chat',
        'Open Food Facts',
        'Health Connect und Apple Health',
        'Externe Links und Bilder',
        'Export und Import',
        'Diagnoseprotokoll und Feedback',
        'Android-Sicherung',
        'Daten löschen',
        'Kinder',
        'Änderungen dieser Richtlinie',
        'Kontakt',
      ],
      'Google-Konto',
    ),
  ]) {
    testWidgets(
      'privacy screen renders every section in ${locale.languageCode}',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PrivacyPolicyScreen(),
          ),
        );

        for (final title in titles) {
          expect(find.text(title), findsOneWidget);
        }
        expect(find.textContaining(bodyFragment), findsOneWidget);
      },
    );
  }

  testWidgets('online policy link reports an unavailable browser in German', (
    tester,
  ) async {
    final launcher = _FailingUrlLauncher();
    final previousLauncher = UrlLauncherPlatform.instance;
    UrlLauncherPlatform.instance = launcher;
    addTearDown(() => UrlLauncherPlatform.instance = previousLauncher);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const PrivacyPolicyScreen(),
      ),
    );

    await tester.ensureVisible(find.text('Online ansehen'));
    await tester.tap(find.text('Online ansehen'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      launcher.attemptedUrl,
      'https://github.com/MrLappes/platepal-tracker-flutter/blob/main/PRIVACY.md',
    );
    expect(
      find.text('Datenschutzerklärung konnte nicht geöffnet werden.'),
      findsOneWidget,
    );
  });

  testWidgets('menu privacy entry opens the policy', (tester) async {
    await _pumpApp(tester);
    GoRouter.of(tester.element(find.byType(MainNavigationScreen))).go('/menu');
    await tester.pumpAndSettle();
    expect(find.byType(MenuScreen), findsOneWidget);

    await tester.scrollUntilVisible(find.text('PRIVACY POLICY'), 220);
    await tester.ensureVisible(find.text('PRIVACY POLICY'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PRIVACY POLICY'));
    await tester.pumpAndSettle();

    expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
  });

  testWidgets('about screen links to the privacy policy', (tester) async {
    PackageInfo.setMockInitialValues(
      appName: 'PlatePal Tracker',
      packageName: 'com.platepal.platepaltracker',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    await _pumpApp(tester);
    GoRouter.of(
      tester.element(find.byType(MainNavigationScreen)),
    ).go('/settings/about');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Privacy policy'));
    await tester.tap(find.text('Privacy policy'));
    await tester.pumpAndSettle();

    expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
  });
}
