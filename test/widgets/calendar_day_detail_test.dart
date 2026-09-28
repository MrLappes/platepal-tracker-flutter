import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/components/calendar/calendar_day_detail.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';

void main() {
  testWidgets('failed meal fetch shows a localized error and retry', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: CalendarDayDetail(date: DateTime(2026, 9, 20))),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Keine Mahlzeiten für diesen Tag protokolliert'),
      findsNothing,
    );
    expect(
      find.text('Mahlzeiten konnten nicht geladen werden'),
      findsOneWidget,
    );
    expect(find.text('Wiederholen'), findsOneWidget);

    await tester.tap(find.text('Wiederholen'));
    await tester.pumpAndSettle();
    expect(
      find.text('Mahlzeiten konnten nicht geladen werden'),
      findsOneWidget,
    );
  });
}
