import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'import_export_service.dart';

enum AutoBackupFrequency { daily, weekly }

/// Automatic backups kept per folder; older ones are deleted.
const int autoBackupsToKeep = 5;

final RegExp _autoBackupName = RegExp(
  r'^platepal_auto_backup_(\d{8}_\d{6})\.zip$',
);

/// Whether an automatic backup is due. Compares local calendar days, so a
/// daily backup runs on the first app start of each day; a last backup in
/// the future (clock changed) counts as due.
bool isAutoBackupDue({
  required DateTime? lastBackup,
  required AutoBackupFrequency frequency,
  required DateTime now,
}) {
  if (lastBackup == null || lastBackup.isAfter(now)) return true;
  final lastDay = DateTime(lastBackup.year, lastBackup.month, lastBackup.day);
  final today = DateTime(now.year, now.month, now.day);
  final days = (today.difference(lastDay).inHours / 24).round();
  return days >= (frequency == AutoBackupFrequency.daily ? 1 : 7);
}

/// File name of an automatic backup made at [time] (local time, sortable).
String autoBackupFileName(DateTime time) {
  String two(int v) => v.toString().padLeft(2, '0');
  return 'platepal_auto_backup_${time.year.toString().padLeft(4, '0')}'
      '${two(time.month)}${two(time.day)}_'
      '${two(time.hour)}${two(time.minute)}${two(time.second)}.zip';
}

/// Automatic backups among [fileNames] beyond the newest [keep]. Other files
/// in the folder are never returned.
List<String> autoBackupsToDelete(
  Iterable<String> fileNames, {
  int keep = autoBackupsToKeep,
}) {
  final backups =
      fileNames.where(_autoBackupName.hasMatch).toList()
        ..sort((a, b) => b.compareTo(a));
  return backups.length <= keep ? const [] : backups.sublist(keep);
}

class AutoBackupSettings {
  const AutoBackupSettings({
    this.enabled = false,
    this.frequency = AutoBackupFrequency.daily,
    this.directory,
    this.lastBackupAt,
    this.lastFailureAt,
    this.failureNoticePending = false,
  });

  final bool enabled;
  final AutoBackupFrequency frequency;

  /// Folder chosen by the user; null uses [AutoBackupService.defaultDirectory].
  final String? directory;
  final DateTime? lastBackupAt;
  final DateTime? lastFailureAt;

  /// A failed run not yet reported to the user.
  final bool failureNoticePending;
}

class AutoBackupResult {
  const AutoBackupResult.success(this.filePath) : success = true;
  const AutoBackupResult.failure() : success = false, filePath = null;

  final bool success;
  final String? filePath;
}

/// Writes full zip backups (data and photos) into a folder on app start or
/// resume when one is due. Never throws: failures are recorded and reported
/// on the next app start.
class AutoBackupService {
  AutoBackupService({
    ImportExportService? importExportService,
    Future<Directory> Function()? defaultDirectory,
  }) : _importExportService = importExportService ?? ImportExportService(),
       _defaultDirectory = defaultDirectory ?? appBackupDirectory;

  final ImportExportService _importExportService;
  final Future<Directory> Function() _defaultDirectory;

  static const String _enabledKey = 'auto_backup_enabled';
  static const String _frequencyKey = 'auto_backup_frequency';
  static const String _directoryKey = 'auto_backup_directory';
  static const String _lastBackupKey = 'auto_backup_last_at';
  static const String _lastFailureKey = 'auto_backup_last_failure_at';
  static const String _noticeKey = 'auto_backup_failure_notice';

  static Future<AutoBackupResult>? _running;

  /// The app's external documents folder on Android, documents elsewhere.
  static Future<Directory> appBackupDirectory() async {
    final base =
        Platform.isAndroid
            ? await getExternalStorageDirectory() ??
                await getApplicationDocumentsDirectory()
            : await getApplicationDocumentsDirectory();
    return Directory(p.join(base.path, 'backups'));
  }

  Future<AutoBackupSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    DateTime? time(String key) {
      final value = prefs.getString(key);
      return value == null ? null : DateTime.tryParse(value);
    }

    return AutoBackupSettings(
      enabled: prefs.getBool(_enabledKey) ?? false,
      frequency:
          AutoBackupFrequency.values.asNameMap()[prefs.getString(
            _frequencyKey,
          )] ??
          AutoBackupFrequency.daily,
      directory: prefs.getString(_directoryKey),
      lastBackupAt: time(_lastBackupKey),
      lastFailureAt: time(_lastFailureKey),
      failureNoticePending: prefs.getBool(_noticeKey) ?? false,
    );
  }

  Future<void> setEnabled(bool enabled) async =>
      (await SharedPreferences.getInstance()).setBool(_enabledKey, enabled);

  Future<void> setFrequency(AutoBackupFrequency frequency) async =>
      (await SharedPreferences.getInstance()).setString(
        _frequencyKey,
        frequency.name,
      );

  /// Sets the backup folder; null goes back to the app folder.
  Future<void> setDirectory(String? directory) async {
    final prefs = await SharedPreferences.getInstance();
    if (directory == null) {
      await prefs.remove(_directoryKey);
    } else {
      await prefs.setString(_directoryKey, directory);
    }
  }

  /// Returns true once if a failure was recorded since the last call.
  Future<bool> takeFailureNotice() async {
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getBool(_noticeKey) ?? false;
    if (pending) await prefs.remove(_noticeKey);
    return pending;
  }

  /// Runs a backup when automatic backups are on and one is due.
  Future<AutoBackupResult?> runIfDue({DateTime? now}) async {
    try {
      final settings = await loadSettings();
      if (!settings.enabled ||
          !isAutoBackupDue(
            lastBackup: settings.lastBackupAt,
            frequency: settings.frequency,
            now: now ?? DateTime.now(),
          )) {
        return null;
      }
      return await backUpNow(reportFailure: true);
    } catch (e) {
      debugPrint('Automatic backup check failed: ${e.runtimeType}');
      return const AutoBackupResult.failure();
    }
  }

  /// Writes a backup now. With [reportFailure] a failure is shown on the
  /// next app start; manual runs report it on screen instead.
  Future<AutoBackupResult> backUpNow({bool reportFailure = false}) {
    return _running ??= _backUp(reportFailure: reportFailure).whenComplete(
      () => _running = null,
    );
  }

  Future<AutoBackupResult> _backUp({required bool reportFailure}) async {
    final prefs = await SharedPreferences.getInstance();
    String? exported;
    try {
      final settings = await loadSettings();
      final folder =
          settings.directory != null
              ? Directory(settings.directory!)
              : await _defaultDirectory();
      await folder.create(recursive: true);

      final result = await _importExportService.exportData(
        dataTypes: [DataType.allData],
        format: ExportFormat.zip,
      );
      exported = result.filePath;
      if (!result.success || exported == null) {
        throw StateError('export failed: ${result.errorCode?.name}');
      }

      final now = DateTime.now();
      final target = p.join(folder.path, autoBackupFileName(now));
      await File(exported).copy(target);

      final names = [
        for (final entity in folder.listSync())
          if (entity is File) p.basename(entity.path),
      ];
      for (final name in autoBackupsToDelete(names)) {
        try {
          await File(p.join(folder.path, name)).delete();
        } catch (e) {
          debugPrint('Could not delete an old backup: ${e.runtimeType}');
        }
      }

      await prefs.setString(_lastBackupKey, now.toIso8601String());
      await prefs.remove(_lastFailureKey);
      await prefs.remove(_noticeKey);
      return AutoBackupResult.success(target);
    } catch (e) {
      debugPrint('Automatic backup failed: ${e.runtimeType}');
      await prefs.setString(_lastFailureKey, DateTime.now().toIso8601String());
      if (reportFailure) await prefs.setBool(_noticeKey, true);
      return const AutoBackupResult.failure();
    } finally {
      if (exported != null) {
        try {
          await File(exported).delete();
        } catch (_) {
          // Only the temporary export copy; the backup itself is written.
        }
      }
    }
  }
}
