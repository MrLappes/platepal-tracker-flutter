import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/main.dart';
import 'package:platepal_tracker/providers/locale_provider.dart';
import 'package:platepal_tracker/providers/theme_provider.dart';
import 'package:platepal_tracker/screens/main_navigation_screen.dart';
import 'package:platepal_tracker/screens/menu_screen.dart';
import 'package:platepal_tracker/screens/settings/macro_customization_screen.dart';
import 'package:platepal_tracker/services/storage/database_service.dart';
import 'package:platepal_tracker/services/storage/storage_service_provider.dart';
import 'package:platepal_tracker/services/storage/user_profile_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _Profiles extends UserProfileService {
  @override
  Future<Null> getUserProfile(String userId) async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  testWidgets('nutrition goals menu opens macro customization', (tester) async {
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
    GoRouter.of(tester.element(find.byType(MainNavigationScreen))).go('/menu');
    await tester.pumpAndSettle();
    expect(find.byType(MenuScreen), findsOneWidget);

    await tester.ensureVisible(find.text('NUTRITION GOALS'));
    await tester.tap(find.text('NUTRITION GOALS'));
    await tester.pumpAndSettle();

    expect(find.byType(MacroCustomizationScreen), findsOneWidget);
  });

  testWidgets('theme modes have selected semantics and 48dp targets', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final themeProvider = ThemeProvider(prefs: prefs);
    final localeProvider = LocaleProvider(prefs: prefs);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: themeProvider),
          ChangeNotifierProvider.value(value: localeProvider),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MenuScreen(),
        ),
      ),
    );

    await tester.scrollUntilVisible(find.text('DARK'), 200);
    final light = find.bySemanticsLabel(RegExp(r'^Light$'));
    final dark = find.bySemanticsLabel(RegExp(r'^Dark$'));
    final system =
        find
            .ancestor(of: find.text('SYSTEM'), matching: find.byType(Semantics))
            .first;
    expect(tester.getSize(light).height, greaterThanOrEqualTo(48));
    expect(tester.getSize(dark).height, greaterThanOrEqualTo(48));
    expect(tester.getSize(system).height, greaterThanOrEqualTo(48));
    expect(
      tester.getSemantics(dark).flagsCollection.isSelected,
      Tristate.isTrue,
    );

    await tester.ensureVisible(light);
    await tester.pumpAndSettle();
    await tester.tap(light);
    await tester.pump();
    expect(themeProvider.themePreference, ThemePreference.light);
    expect(
      tester.getSemantics(light).flagsCollection.isSelected,
      Tristate.isTrue,
    );
    semantics.dispose();
  });
}
