import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:platepal_tracker/models/dish.dart';
import 'package:platepal_tracker/services/data/auto_backup.dart';
import 'package:platepal_tracker/services/data/import_export_service.dart';
import 'package:platepal_tracker/services/storage/database_service.dart';
import 'package:platepal_tracker/services/storage/dish_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('isAutoBackupDue', () {
    final now = DateTime(2026, 9, 20, 8, 5);

    test('without a previous backup', () {
      for (final frequency in AutoBackupFrequency.values) {
        expect(
          isAutoBackupDue(lastBackup: null, frequency: frequency, now: now),
          isTrue,
        );
      }
    });

    test('daily: once per calendar day', () {
      bool due(DateTime last) => isAutoBackupDue(
        lastBackup: last,
        frequency: AutoBackupFrequency.daily,
        now: now,
      );
      expect(due(DateTime(2026, 9, 20, 0, 1)), isFalse);
      expect(due(DateTime(2026, 9, 19, 23, 59)), isTrue);
      expect(due(DateTime(2026, 9, 19, 8, 30)), isTrue);
      expect(due(DateTime(2026, 8, 1)), isTrue);
    });

    test('weekly: after seven calendar days', () {
      bool due(DateTime last) => isAutoBackupDue(
        lastBackup: last,
        frequency: AutoBackupFrequency.weekly,
        now: now,
      );
      expect(due(DateTime(2026, 9, 14, 23, 59)), isFalse);
      expect(due(DateTime(2026, 9, 13, 23, 59)), isTrue);
      // Across the end of daylight saving time in many zones.
      expect(
        isAutoBackupDue(
          lastBackup: DateTime(2026, 10, 22, 9),
          frequency: AutoBackupFrequency.weekly,
          now: DateTime(2026, 10, 29, 7),
        ),
        isTrue,
      );
    });

    test('a last backup in the future (clock changed) is due', () {
      expect(
        isAutoBackupDue(
          lastBackup: DateTime(2027, 1, 1),
          frequency: AutoBackupFrequency.weekly,
          now: now,
        ),
        isTrue,
      );
    });
  });

  group('file names and rotation', () {
    test('names are padded and sort by time', () {
      expect(
        autoBackupFileName(DateTime(2026, 9, 5, 7, 3, 9)),
        'platepal_auto_backup_20260905_070309.zip',
      );
      final names = [
        autoBackupFileName(DateTime(2026, 10, 1)),
        autoBackupFileName(DateTime(2026, 9, 30, 23, 59, 59)),
      ]..sort();
      expect(names.first, contains('20260930'));
    });

    test('only automatic backups beyond the newest five are deleted', () {
      final backups = [
        for (var day = 1; day <= 7; day++)
          autoBackupFileName(DateTime(2026, 9, day, 12)),
      ];
      final others = [
        'platepal_export_1700000000.zip',
        'notes.txt',
        'platepal_auto_backup_latest.zip',
        'platepal_auto_backup_20260901_120000.zip.part',
      ];
      expect(autoBackupsToDelete([...others, ...backups.reversed]), [
        backups[1],
        backups[0],
      ]);
      expect(autoBackupsToDelete(backups.take(5)), isEmpty);
      expect(autoBackupsToDelete(backups, keep: 6), [backups[0]]);
    });
  });

  group('AutoBackupService', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    late Directory tempDir;
    late Directory appDocs;
    late Directory defaultFolder;
    late AutoBackupService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
      tempDir = await Directory.systemTemp.createTemp('platepal_autobackup');
      appDocs = await Directory(p.join(tempDir.path, 'docs')).create();
      defaultFolder = Directory(p.join(tempDir.path, 'external', 'backups'));
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (_) async => appDocs.path,
          );
      final dishService = DishService();
      await dishService.saveDish(
        Dish(
          id: 'oats',
          name: 'Oats',
          ingredients: const [],
          nutrition: const NutritionInfo(
            calories: 300,
            protein: 10,
            carbs: 50,
            fat: 6,
          ),
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
          servings: 2,
        ),
      );
      service = AutoBackupService(
        importExportService: ImportExportService(dishService: dishService),
        defaultDirectory: () async => defaultFolder,
      );
    });

    tearDown(() => tempDir.delete(recursive: true));

    List<String> zips(Directory dir) =>
        dir
            .listSync()
            .whereType<File>()
            .map((f) => p.basename(f.path))
            .where((n) => n.endsWith('.zip'))
            .toList();

    test('does nothing while turned off', () async {
      expect(await service.runIfDue(), isNull);
      expect(defaultFolder.existsSync(), isFalse);
    });

    test('writes a full backup to the app folder once per day', () async {
      await service.setEnabled(true);

      final result = await service.runIfDue();
      expect(result?.success, isTrue);
      final written = zips(defaultFolder);
      expect(written, hasLength(1));
      expect(written.single, startsWith('platepal_auto_backup_'));
      final archive = ZipDecoder().decodeBytes(
        File(result!.filePath!).readAsBytesSync(),
      );
      expect(archive.find('platepal_data.json'), isNotNull);
      expect(zips(appDocs), isEmpty, reason: 'temporary export removed');

      final settings = await service.loadSettings();
      expect(settings.lastBackupAt, isNotNull);
      expect(await service.runIfDue(), isNull, reason: 'not due again today');
      expect(
        await service.runIfDue(now: DateTime.now().add(const Duration(days: 1))),
        isNotNull,
      );
    });

    test('uses the chosen folder and keeps the newest five', () async {
      final chosen = await Directory(p.join(tempDir.path, 'chosen')).create();
      for (var day = 1; day <= 6; day++) {
        File(
          p.join(chosen.path, autoBackupFileName(DateTime(2020, 1, day))),
        ).writeAsStringSync('old');
      }
      File(p.join(chosen.path, 'my_notes.zip')).writeAsStringSync('keep me');
      await service.setDirectory(chosen.path);

      final result = await service.backUpNow();

      expect(result.success, isTrue);
      expect(p.dirname(result.filePath!), chosen.path);
      final names = zips(chosen)..sort();
      expect(names, contains('my_notes.zip'));
      final backups = names.where((n) => n != 'my_notes.zip').toList();
      expect(backups, hasLength(5));
      expect(backups, isNot(contains(autoBackupFileName(DateTime(2020, 1, 1)))));
      expect(backups, isNot(contains(autoBackupFileName(DateTime(2020, 1, 2)))));
      expect(backups.last, p.basename(result.filePath!));
    });

    test('a failed automatic run is reported once on the next start', () async {
      final blocker = File(p.join(tempDir.path, 'not_a_folder'))
        ..writeAsStringSync('x');
      await service.setDirectory(blocker.path);
      await service.setEnabled(true);

      final result = await service.runIfDue();

      expect(result?.success, isFalse);
      final settings = await service.loadSettings();
      expect(settings.lastFailureAt, isNotNull);
      expect(settings.lastBackupAt, isNull);
      expect(await service.takeFailureNotice(), isTrue);
      expect(await service.takeFailureNotice(), isFalse);

      // A manual failure is shown on screen, not on the next start.
      await service.backUpNow();
      expect(await service.takeFailureNotice(), isFalse);

      await service.setDirectory(null);
      expect((await service.backUpNow()).success, isTrue);
      expect((await service.loadSettings()).lastFailureAt, isNull);
    });
  });
}
