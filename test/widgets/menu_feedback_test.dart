import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/providers/locale_provider.dart';
import 'package:platepal_tracker/providers/theme_provider.dart';
import 'package:platepal_tracker/screens/menu_screen.dart';
import 'package:platepal_tracker/services/diagnostic_log_service.dart';
import 'package:platepal_tracker/utils/feedback_mail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class _RecordingLauncher extends UrlLauncherPlatform {
  _RecordingLauncher({required this.succeeds});

  final bool succeeds;
  String? launched;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => succeeds;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launched = url;
    return succeeds;
  }
}

class _FakeDiagnostics extends DiagnosticLogService {
  _FakeDiagnostics() : super(appVersion: () async => '1.15.0+27');

  bool cleared = false;

  @override
  Future<File?> shareableFile() async => null;

  @override
  Future<void> clear() async {
    cleared = true;
  }
}

void main() {
  late _FakeDiagnostics diagnostics;

  setUp(() => diagnostics = _FakeDiagnostics());

  Future<void> pumpMenu(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: ThemeProvider(prefs: prefs)),
          ChangeNotifierProvider.value(value: LocaleProvider(prefs: prefs)),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MenuScreen(diagnostics: diagnostics),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapTile(WidgetTester tester, String title) async {
    await tester.tap(find.text(title));
    await tester.pumpAndSettle();
  }

  test('feedback mail goes to the developer with an encoded subject', () {
    final uri = feedbackMailUri('PlatePal Tracker feedback (v1.15.0+27)');

    expect(uri.scheme, 'mailto');
    expect(uri.path, developerContactEmail);
    expect(
      uri.toString(),
      'mailto:$developerContactEmail'
      '?subject=PlatePal%20Tracker%20feedback%20(v1.15.0%2B27)',
    );
  });

  testWidgets('send feedback opens a mail with the app version', (
    tester,
  ) async {
    final launcher = _RecordingLauncher(succeeds: true);
    final previous = UrlLauncherPlatform.instance;
    UrlLauncherPlatform.instance = launcher;
    addTearDown(() => UrlLauncherPlatform.instance = previous);

    await pumpMenu(tester);
    expect(
      find.textContaining('Nothing is sent automatically'),
      findsOneWidget,
    );
    await tapTile(tester, 'SEND FEEDBACK');

    expect(launcher.launched, startsWith('mailto:$developerContactEmail'));
    expect(launcher.launched, contains('v1.15.0%2B27'));
  });

  testWidgets('send feedback without a mail app shows the address', (
    tester,
  ) async {
    final previous = UrlLauncherPlatform.instance;
    UrlLauncherPlatform.instance = _RecordingLauncher(succeeds: false);
    addTearDown(() => UrlLauncherPlatform.instance = previous);

    await pumpMenu(tester);
    await tapTile(tester, 'SEND FEEDBACK');

    expect(find.textContaining(developerContactEmail), findsOneWidget);
  });

  testWidgets('report a problem with an empty log says so', (tester) async {
    await pumpMenu(tester);
    await tapTile(tester, 'REPORT A PROBLEM');

    expect(
      find.text('No problems recorded yet. The diagnostic log is empty.'),
      findsOneWidget,
    );
  });

  testWidgets('clear diagnostic log deletes recorded errors', (tester) async {
    await pumpMenu(tester);

    await tapTile(tester, 'CLEAR DIAGNOSTIC LOG');

    expect(diagnostics.cleared, isTrue);
    expect(find.text('Diagnostic log cleared.'), findsOneWidget);
  });

  testWidgets('the PlatePal entry opens its Play Store listing', (
    tester,
  ) async {
    final launcher = _RecordingLauncher(succeeds: true);
    final previous = UrlLauncherPlatform.instance;
    UrlLauncherPlatform.instance = launcher;
    addTearDown(() => UrlLauncherPlatform.instance = previous);

    await pumpMenu(tester);
    await tapTile(tester, 'PLATEPAL – SHARE MEALS WITH OTHERS');

    expect(
      launcher.launched,
      'https://play.google.com/store/apps/details?id=com.lappalis.plate_pal',
    );
  });
}
