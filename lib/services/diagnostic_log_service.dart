import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' show max;

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Removes text that could carry personal data (quoted values, keys,
/// e-mail addresses, URL paths, numbers of two or more digits) and caps the
/// length. Stack locations (`file.dart:12:5`) and frame numbers (`#12`) stay.
String sanitizeDiagnosticText(String text, {int maxLength = 500}) {
  var result = text
      .replaceAll(RegExp(r'"[^"\n]*"'), '"…"')
      .replaceAll(RegExp(r"'[^'\n]*'"), "'…'")
      .replaceAll(RegExp(r'[\w.+-]+@[\w-]+\.[\w.-]+'), '<email>')
      .replaceAllMapped(
        RegExp(r'(https?://[^/\s?#]+)[^\s]*'),
        (m) => '${m[1]}/…',
      )
      .replaceAll(RegExp(r'\b(?:sk|pk|rk)-[\w-]{8,}'), '<redacted>')
      .replaceAll(
        RegExp(r'\b(?=[A-Za-z_-]*\d)[A-Za-z0-9_-]{20,}\b'),
        '<redacted>',
      )
      .replaceAll(RegExp(r'\b\d+[.,]\d+\b'), '<n>')
      .replaceAllMapped(
        RegExp(
          r'(\.dart:\d+(?::\d+)?)|(^\s*#\d+)|(?<![A-Za-z_])\d{2,}(?![A-Za-z_])',
          multiLine: true,
        ),
        (m) => m[1] ?? m[2] ?? '<n>',
      );
  if (result.length > maxLength) {
    result = '${result.substring(0, maxLength)}…';
  }
  return result;
}

/// One uncaught error, without user data.
class DiagnosticEntry {
  const DiagnosticEntry({
    required this.time,
    required this.appVersion,
    required this.source,
    required this.type,
    required this.message,
    required this.stack,
  });

  final DateTime time;
  final String appVersion;
  final String source;
  final String type;
  final String message;
  final String stack;

  static const int maxStackLines = 20;

  factory DiagnosticEntry.fromError(
    Object error,
    StackTrace? stack, {
    required DateTime time,
    required String appVersion,
    required String source,
  }) {
    final frames = (stack?.toString() ?? '')
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .take(maxStackLines)
        .map((line) => sanitizeDiagnosticText(line, maxLength: 200));
    return DiagnosticEntry(
      time: time.toUtc(),
      appVersion: appVersion,
      source: source,
      type: error.runtimeType.toString(),
      // Later lines of a message often repeat input or data.
      message: sanitizeDiagnosticText(error.toString().split('\n').first),
      stack: frames.join('\n'),
    );
  }

  Map<String, dynamic> toJson() => {
    'time': time.toIso8601String(),
    'appVersion': appVersion,
    'source': source,
    'type': type,
    'message': message,
    'stack': stack,
  };

  static DiagnosticEntry? tryParse(String line) {
    try {
      final json = jsonDecode(line);
      if (json is! Map<String, dynamic>) return null;
      return DiagnosticEntry(
        time: DateTime.parse(json['time'] as String),
        appVersion: json['appVersion'] as String? ?? '',
        source: json['source'] as String? ?? '',
        type: json['type'] as String? ?? '',
        message: json['message'] as String? ?? '',
        stack: json['stack'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }
}

/// Keeps the most recent uncaught errors in a local file. Nothing is sent
/// anywhere; the user can share or clear the file from the menu.
class DiagnosticLogService {
  DiagnosticLogService({
    Future<Directory> Function()? directory,
    Future<String> Function()? appVersion,
    DateTime Function()? clock,
    this.maxEntries = 20,
  }) : _directory = directory ?? getApplicationSupportDirectory,
       _appVersion = appVersion ?? _platformVersion,
       _clock = clock ?? DateTime.now;

  static final DiagnosticLogService instance = DiagnosticLogService();

  static const String fileName = 'platepal_diagnostics.txt';

  final Future<Directory> Function() _directory;
  final Future<String> Function() _appVersion;
  final DateTime Function() _clock;
  final int maxEntries;

  Future<void> _pending = Future.value();
  String? _cachedVersion;

  static Future<String> _platformVersion() async {
    final info = await PackageInfo.fromPlatform();
    return '${info.version}+${info.buildNumber}';
  }

  Future<String> appVersion() async {
    if (_cachedVersion != null) return _cachedVersion!;
    try {
      return _cachedVersion = await _appVersion();
    } catch (_) {
      return 'unknown';
    }
  }

  Future<File> logFile() async =>
      File(p.join((await _directory()).path, fileName));

  /// Routes uncaught Flutter and platform errors into this log.
  void install() {
    final previousFlutterHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      unawaited(record(details.exception, details.stack, source: 'flutter'));
      (previousFlutterHandler ?? FlutterError.presentError)(details);
    };
    final dispatcher = PlatformDispatcher.instance;
    final previousPlatformHandler = dispatcher.onError;
    dispatcher.onError = (error, stack) {
      unawaited(record(error, stack, source: 'platform'));
      if (kDebugMode) debugPrint('Uncaught error: ${error.runtimeType}');
      return previousPlatformHandler?.call(error, stack) ?? true;
    };
  }

  /// Appends an entry, keeping only the newest [maxEntries]. Never throws.
  Future<void> record(
    Object error,
    StackTrace? stack, {
    String source = 'app',
  }) {
    return _pending = _pending.then((_) async {
      try {
        final entry = DiagnosticEntry.fromError(
          error,
          stack,
          time: _clock(),
          appVersion: await appVersion(),
          source: source,
        );
        final entries = [...await readEntries(), entry];
        await _write(entries.skip(max(0, entries.length - maxEntries)));
      } catch (e) {
        debugPrint('Diagnostic log write failed (${e.runtimeType})');
      }
    });
  }

  Future<List<DiagnosticEntry>> readEntries() async {
    final file = await logFile();
    if (!await file.exists()) return [];
    final lines = await file.readAsLines();
    return lines
        .map(DiagnosticEntry.tryParse)
        .whereType<DiagnosticEntry>()
        .toList();
  }

  Future<void> _write(Iterable<DiagnosticEntry> entries) async {
    final file = await logFile();
    await file.parent.create(recursive: true);
    final temp = File('${file.path}.tmp');
    await temp.writeAsString(
      entries.map((entry) => '${jsonEncode(entry.toJson())}\n').join(),
      flush: true,
    );
    await temp.rename(file.path);
  }

  /// The log file if it has at least one entry.
  Future<File?> shareableFile() async {
    await _pending;
    final file = await logFile();
    return await file.exists() && await file.length() > 0 ? file : null;
  }

  Future<void> clear() async {
    await _pending;
    final file = await logFile();
    if (await file.exists()) await file.delete();
  }
}
