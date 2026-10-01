import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/components/scanner/barcode_scanner_screen.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';

void main() {
  Future<({Future<BarcodeNotFoundAction?> action})> open(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    bool canEnterManually = true,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(),
      ),
    );
    final result = showBarcodeNotFoundSheet(
      tester.element(find.byType(Scaffold)),
      '4006381333931',
      canEnterManually: canEnterManually,
    );
    await tester.pumpAndSettle();
    return (action: result);
  }

  for (final (label, action) in [
    ('Search by name', BarcodeNotFoundAction.searchByName),
    ('Enter manually', BarcodeNotFoundAction.enterManually),
    ('Scan again', BarcodeNotFoundAction.scanAgain),
  ]) {
    testWidgets('"$label" returns $action', (tester) async {
      final sheet = await open(tester);

      expect(find.text('Product not found'), findsOneWidget);
      expect(find.textContaining('4006381333931'), findsOneWidget);
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();

      expect(await sheet.action, action);
      expect(find.text('Product not found'), findsNothing);
    });
  }

  testWidgets('manual entry is hidden when the caller cannot handle it', (
    tester,
  ) async {
    await open(tester, canEnterManually: false);

    expect(find.text('Enter manually'), findsNothing);
    expect(find.text('Search by name'), findsOneWidget);
  });

  testWidgets('sheet is localized in German', (tester) async {
    await open(tester, locale: const Locale('de'));

    expect(find.text('Nach Namen suchen'), findsOneWidget);
    expect(find.text('Manuell eingeben'), findsOneWidget);
    expect(find.text('Erneut scannen'), findsOneWidget);
  });
}
