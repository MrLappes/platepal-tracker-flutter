import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/screens/settings/health_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('health settings waits for availability before showing status', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HealthSettingsScreen(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      find.text('Health Connect is not available on this device.'),
      findsNothing,
    );
  });

  testWidgets('health settings shows an error and can retry initialization', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      SharedPreferences.setMockInitialValues({
        'health_write_meals_enabled': 'invalid',
      });
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HealthSettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unable to load your data.'), findsOneWidget);
      expect(
        find.text('Health Connect is not available on this device.'),
        findsNothing,
      );

      SharedPreferences.setMockInitialValues({});
      await tester.tap(find.widgetWithText(TextButton, 'Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Unable to load your data.'), findsNothing);
      expect(find.text('Connect to Health'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}