import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/screens/settings/export_data_screen.dart';
import 'package:platepal_tracker/screens/settings/import_data_screen.dart';
import 'package:platepal_tracker/services/data/import_export_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(Widget child, {Locale locale = const Locale('en')}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('invalid base URL message is localized', (tester) async {
    for (final (locale, expected) in [
      (
        const Locale('en'),
        'Base URL must start with https:// (http:// is only allowed for localhost)',
      ),
      (
        const Locale('es'),
        'La URL base debe empezar con https:// (http:// solo se permite para localhost)',
      ),
      (
        const Locale('de'),
        'Die Basis-URL muss mit https:// beginnen (http:// ist nur für localhost erlaubt)',
      ),
    ]) {
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => Text(
              AppLocalizations.of(context).screensSettingsApiKeySettingsInvalidBaseUrl,
            ),
          ),
          locale: locale,
        ),
      );
      expect(find.text(expected), findsOneWidget);
    }
  });

  testWidgets('partial import shows a warning with expandable reasons', (
    tester,
  ) async {
    final result = ImportExportResult(
      success: true,
      message: 'Import completed',
      itemsProcessed: 3,
      itemsSkipped: 2,
      duplicatesFound: 0,
      errors: const [],
      detailedResults: ImportDetailedResults(
        validationErrors: [
          const ValidationError(
            field: 'servings',
            error: 'Missing servings',
            value: '',
          ),
        ],
        processingErrors: [
          const ProcessingError(
            type: 'mealLogs',
            index: 1,
            error: 'Invalid date',
            item: '',
          ),
        ],
      ),
    );

    await tester.pumpWidget(_app(ImportResultsCard(result: result)));

    expect(find.text('Imported 3, skipped 2'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    await tester.tap(find.text('Show reasons'));
    await tester.pumpAndSettle();
    expect(find.text('Missing servings'), findsOneWidget);
    expect(find.text('Invalid date'), findsOneWidget);
  });

  testWidgets('capped import reasons say how many more there are', (
    tester,
  ) async {
    for (final (locale, expected) in [
      (const Locale('en'), '…and 70 more'),
      (const Locale('es'), '…y 70 más'),
      (const Locale('de'), '…und 70 weitere'),
    ]) {
      final result = ImportExportResult(
        success: true,
        message: 'Import completed',
        itemsProcessed: 1,
        itemsSkipped: 120,
        duplicatesFound: 0,
        errors: const [],
        detailedResults: ImportDetailedResults(
          validationErrors: [
            const ValidationError(field: 'name', error: 'Missing name', value: ''),
          ],
          omittedErrors: 70,
        ),
      );

      await tester.pumpWidget(
        _app(ImportResultsCard(key: UniqueKey(), result: result), locale: locale),
      );
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();
      expect(find.text(expected), findsOneWidget);
    }
  });

  testWidgets('partial import localizes its summary and parsing reasons', (
    tester,
  ) async {
    final result = ImportExportResult(
      success: false,
      message: 'Import completed with errors',
      itemsProcessed: 2,
      itemsSkipped: 1,
      duplicatesFound: 0,
      errors: const [],
      detailedResults: ImportDetailedResults(
        parsingErrors: [
          const ParsingError(
            line: 3,
            column: 0,
            error: 'Invalid CSV row',
            context: [],
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      _app(ImportResultsCard(result: result), locale: const Locale('de')),
    );

    expect(find.text('Importiert: 2, übersprungen: 1'), findsOneWidget);
    await tester.tap(find.text('Gründe anzeigen'));
    await tester.pumpAndSettle();
    expect(
      find.text('Datei- und Zeilendetails (möglicherweise auf Englisch):'),
      findsOneWidget,
    );
    expect(find.text('Invalid CSV row'), findsOneWidget);
  });

  testWidgets('Spanish import failure uses its code instead of English message', (
    tester,
  ) async {
    const result = ImportExportResult(
      success: false,
      message: 'Import failed: File not found',
      errorCode: ImportExportErrorCode.importFileMissing,
      itemsProcessed: 0,
      duplicatesFound: 0,
      errors: [],
    );

    await tester.pumpWidget(
      _app(const ImportResultsCard(result: result), locale: const Locale('es')),
    );

    expect(find.text('No se encontró el archivo. Selecciónalo de nuevo.'), findsOneWidget);
    expect(find.textContaining('Import failed'), findsNothing);
  });

  testWidgets('failed restore shows the recovery copy path without raw error', (
    tester,
  ) async {
    const result = ImportExportResult(
      success: false,
      message: 'Restore failed: private exception text',
      errorCode: ImportExportErrorCode.restoreRollbackFailed,
      filePath: '/tmp/recovery.json',
      itemsProcessed: 0,
      duplicatesFound: 0,
      errors: [],
    );

    await tester.pumpWidget(
      _app(const ImportResultsCard(result: result), locale: const Locale('es')),
    );

    expect(find.textContaining('/tmp/recovery.json'), findsOneWidget);
    expect(find.textContaining('private exception text'), findsNothing);
  });

  testWidgets('confirmation describes selected sections and strategy', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const SizedBox()));
    final context = tester.element(find.byType(Scaffold));

    final confirmation = showImportConfirmationDialog(
      context,
      sectionNames: ['Dishes', 'Meal Logs'],
      duplicateHandlingLabel: 'Skip Duplicates',
    );
    await tester.pumpAndSettle();

    expect(find.text('Dishes'), findsOneWidget);
    expect(find.text('Meal Logs'), findsOneWidget);
    expect(find.textContaining('Skip Duplicates'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(await confirmation, isFalse);
  });

  testWidgets('failed backup defaults to cancel and needs explicit consent', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const SizedBox()));
    final context = tester.element(find.byType(Scaffold));

    final cancelled = showBackupFailureDialog(context);
    await tester.pumpAndSettle();
    expect(find.text('Continue without backup'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(await cancelled, isFalse);

    final confirmed = showBackupFailureDialog(context);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue without backup'));
    await tester.pumpAndSettle();
    expect(await confirmed, isTrue);
  });

  testWidgets('Spanish import controls and safety dialogs are localized', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      _app(const ImportDataScreen(), locale: const Locale('es')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Selección de archivo'), findsOneWidget);
    expect(
      find.text('Conservar los datos existentes; omitir los duplicados importados'),
      findsOneWidget,
    );

    final context = tester.element(find.byType(ImportDataScreen));
    final confirmation = showImportConfirmationDialog(
      context,
      sectionNames: ['Platos'],
      duplicateHandlingLabel: 'Omitir duplicados',
    );
    await tester.pumpAndSettle();
    expect(find.text('Confirmar importación'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(await confirmation, isFalse);

    final backupFailure = showBackupFailureDialog(context);
    await tester.pumpAndSettle();
    expect(find.text('Falló la copia de seguridad'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(await backupFailure, isFalse);
  });

  testWidgets('import defaults to skip and does not offer merge', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(_app(const ImportDataScreen()));
    await tester.pumpAndSettle();

    expect(
      tester.widget<RadioGroup<DuplicateHandling>>(
        find.byType(RadioGroup<DuplicateHandling>),
      ).groupValue,
      DuplicateHandling.skip,
    );
    expect(find.text('Merge Duplicates'), findsNothing);
  });

  testWidgets('export form has no inert advanced controls', (tester) async {
    await tester.pumpWidget(_app(const ExportDataScreen()));

    expect(find.text('Advanced Options'), findsNothing);
    expect(find.byType(SwitchListTile), findsNothing);
  });

  testWidgets('Spanish export preview shows localized details', (tester) async {
    await tester.pumpWidget(
      _app(const ExportDataScreen(), locale: const Locale('es')),
    );

    expect(find.text('Vista previa de la exportación'), findsOneWidget);
    expect(find.text('Formato: JSON'), findsOneWidget);
    expect(find.text('Tipos de datos seleccionados: 2 tipos'), findsOneWidget);
    expect(find.text('Listo para exportar'), findsOneWidget);
  });
}