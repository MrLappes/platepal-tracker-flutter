import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/screens/settings/about_screen.dart';

void main() {
  testWidgets('about screen displays installed version and build', (
    tester,
  ) async {
    PackageInfo.setMockInitialValues(
      appName: 'PlatePal Tracker',
      packageName: 'com.platepal.platepaltracker',
      version: '8.4.2',
      buildNumber: '123',
      buildSignature: '',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AboutScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('8.4.2+123'), findsOneWidget);
    expect(find.textContaining('1.12.6'), findsNothing);
  });
}
