import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/services/diagnostic_log_service.dart';

void main() {
  late Directory dir;
  late DateTime now;
  late DiagnosticLogService service;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('platepal_diagnostics');
    now = DateTime.utc(2026, 10, 1, 12);
    service = DiagnosticLogService(
      directory: () async => dir,
      appVersion: () async => '1.15.0+27',
      clock: () => now,
    );
  });

  tearDown(() => dir.delete(recursive: true));

  group('sanitizeDiagnosticText', () {
    test('removes values that could be personal data', () {
      final text = sanitizeDiagnosticText(
        'Dish "Grandma\'s lasagne" failed for jane@example.com '
        "with key sk-abc123def456ghi789 at 72.5 kg via "
        'https://api.example.com/v1/chat?key=secret',
      );

      expect(text, isNot(contains('lasagne')));
      expect(text, isNot(contains('jane@example.com')));
      expect(text, isNot(contains('sk-abc123')));
      expect(text, isNot(contains('72.5')));
      expect(text, isNot(contains('secret')));
      expect(text, contains('https://api.example.com/…'));
      expect(text, contains('<email>'));
    });

    test('keeps code locations readable and caps length', () {
      const frame =
          '#0      _DishCreateScreenAdvancedState._saveDish '
          '(package:platepal_tracker/screens/dish_create_screen.dart:241:7)';
      expect(sanitizeDiagnosticText(frame, maxLength: 200), frame);
      expect(sanitizeDiagnosticText('x' * 600).length, 501);
    });
  });

  test('records type, version and sanitized message', () async {
    await service.record(
      const FormatException('Bad value "Chicken curry"'),
      StackTrace.fromString('#0 main (package:app/main.dart:1:1)'),
      source: 'flutter',
    );

    final [entry] = await service.readEntries();
    expect(entry.type, 'FormatException');
    expect(entry.appVersion, '1.15.0+27');
    expect(entry.source, 'flutter');
    expect(entry.time, now);
    expect(entry.message, isNot(contains('Chicken')));
    expect(entry.stack, contains('package:app/main.dart'));
  });

  test('keeps only the newest entries', () async {
    final small = DiagnosticLogService(
      directory: () async => dir,
      appVersion: () async => '1.0.0+1',
      clock: () => now,
      maxEntries: 3,
    );
    for (var i = 0; i < 5; i++) {
      now = now.add(const Duration(minutes: 1));
      await small.record(StateError('error $i'), null);
    }

    final entries = await small.readEntries();
    expect(entries.map((e) => e.message), [
      'Bad state: error 2',
      'Bad state: error 3',
      'Bad state: error 4',
    ]);
  });

  test('default limit is 20 entries', () async {
    for (var i = 0; i < 25; i++) {
      await service.record(StateError('e$i'), null);
    }
    expect(await service.readEntries(), hasLength(20));
  });

  test('shareable file is null until something was recorded', () async {
    expect(await service.shareableFile(), isNull);

    await service.record(StateError('boom'), null);
    final file = await service.shareableFile();
    expect(file, isNotNull);
    expect(file!.path, endsWith(DiagnosticLogService.fileName));

    await service.clear();
    expect(await service.shareableFile(), isNull);
    expect(await service.readEntries(), isEmpty);
  });

  test('a failing version lookup still records the error', () async {
    final failing = DiagnosticLogService(
      directory: () async => dir,
      appVersion: () async => throw StateError('no plugin'),
      clock: () => now,
    );
    await failing.record(StateError('boom'), null);

    expect((await failing.readEntries()).single.appVersion, 'unknown');
  });

  test('unwritable directory does not throw', () async {
    final broken = DiagnosticLogService(
      directory: () async => throw const FileSystemException('denied'),
      clock: () => now,
    );

    await expectLater(broken.record(StateError('boom'), null), completes);
  });
}
