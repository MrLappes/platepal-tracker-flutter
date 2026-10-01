import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/screens/settings/backup_settings_screen.dart';
import 'package:platepal_tracker/services/data/auto_backup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAutoBackupService extends AutoBackupService {
  _FakeAutoBackupService({required this.succeed, this.writable = true});

  final bool succeed;
  final bool writable;
  int runs = 0;
  final List<String> probed = [];

  @override
  Future<bool> canWriteTo(String directory) async {
    probed.add(directory);
    return writable;
  }

  @override
  Future<AutoBackupResult> backUpNow({bool reportFailure = false}) async {
    runs++;
    final prefs = await SharedPreferences.getInstance();
    if (!succeed) return const AutoBackupResult.failure();
    await prefs.setString(
      'auto_backup_last_at',
      DateTime(2026, 9, 20, 8, 15).toIso8601String(),
    );
    return const AutoBackupResult.success('/backups/x.zip');
  }
}

Future<void> _pump(
  WidgetTester tester,
  AutoBackupService service, {
  Future<String?> Function()? pick,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BackupSettingsScreen(service: service, pickDirectory: pick),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('turns automatic backups on and picks a folder', (tester) async {
    final service = _FakeAutoBackupService(succeed: true);
    await _pump(tester, service, pick: () async => '/storage/Backups');

    expect(find.text('No backup yet'), findsOneWidget);
    expect(
      find.text('App storage (deleted when the app is uninstalled)'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('auto-backup-switch')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Weekly'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose'));
    await tester.pumpAndSettle();

    final settings = await service.loadSettings();
    expect(settings.enabled, isTrue);
    expect(settings.frequency, AutoBackupFrequency.weekly);
    expect(settings.directory, '/storage/Backups');
    expect(find.text('/storage/Backups'), findsOneWidget);

    await tester.tap(find.text('Use app storage'));
    await tester.pumpAndSettle();
    expect((await service.loadSettings()).directory, isNull);
  });

  testWidgets('an unwritable folder is not saved', (tester) async {
    SharedPreferences.setMockInitialValues({
      'auto_backup_directory': '/storage/Old',
    });
    final service = _FakeAutoBackupService(succeed: true, writable: false);
    await _pump(tester, service, pick: () async => '/storage/ReadOnly');

    await tester.tap(find.text('Choose'));
    await tester.pumpAndSettle();

    expect(service.probed, ['/storage/ReadOnly']);
    expect(
      find.text("Couldn't use that folder. Choose another one."),
      findsOneWidget,
    );
    expect((await service.loadSettings()).directory, '/storage/Old');
    expect(find.text('/storage/Old'), findsOneWidget);
  });

  testWidgets('Back up now shows the result and the last backup', (
    tester,
  ) async {
    final service = _FakeAutoBackupService(succeed: true);
    await _pump(tester, service);

    await tester.tap(find.text('Back up now'));
    await tester.pumpAndSettle();

    expect(service.runs, 1);
    expect(find.text('Backup saved'), findsOneWidget);
    expect(find.textContaining('Last backup: Sep 20, 2026'), findsOneWidget);
  });

  testWidgets('a failed manual backup is shown', (tester) async {
    await _pump(tester, _FakeAutoBackupService(succeed: false));

    await tester.tap(find.text('Back up now'));
    await tester.pumpAndSettle();

    expect(
      find.text('Backup failed. Check the folder and free space.'),
      findsOneWidget,
    );
  });
}
