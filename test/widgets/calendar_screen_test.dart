import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/components/calendar/macro_summary.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/screens/calendar_screen.dart';
import 'package:platepal_tracker/services/storage/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  testWidgets('adjacent-month logs appear in a Monday-first week', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
    final now = DateTime.now();
    var monthsAhead = 1;
    var firstOfMonth = DateTime(now.year, now.month + monthsAhead);
    while (firstOfMonth.weekday != DateTime.sunday) {
      monthsAhead++;
      firstOfMonth = DateTime(now.year, now.month + monthsAhead);
    }
    final previousMonthDay = DateTime(firstOfMonth.year, firstOfMonth.month, 0);
    final db = await DatabaseService.instance.database;
    await db.insert('dish_logs', {
      'id': 'boundary-log',
      'dish_id': 'deleted-dish',
      'dish_name': 'Potaje',
      'logged_at':
          DateTime(
            previousMonthDay.year,
            previousMonthDay.month,
            previousMonthDay.day,
            12,
          ).toIso8601String(),
      'meal_type': 'lunch',
      'serving_size': 1.0,
      'calories': 200.0,
      'protein': 10.0,
      'carbs': 25.0,
      'fat': 5.0,
    });

    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CalendarScreen(),
      ),
    );
    await tester.pumpAndSettle();
    for (var month = 0; month < monthsAhead; month++) {
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
    }

    expect(
      find.bySemanticsLabel(RegExp('Mahlzeiten eingetragen')),
      findsOneWidget,
    );
    await tester.tap(find.bySemanticsLabel(RegExp('Mahlzeiten eingetragen')));
    await tester.pumpAndSettle();
    expect(find.text('POTAJE'), findsOneWidget);
    expect(
      tester.getSize(find.byTooltip('Protokoll löschen')).width,
      greaterThanOrEqualTo(48),
    );
    semantics.dispose();
  });

  testWidgets('health data info has a full-size localized button', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: MacroSummary(
            calories: 200,
            protein: 10,
            carbs: 25,
            fat: 5,
            caloriesBurned: 100,
            isCaloriesBurnedEstimated: false,
            isCollapsible: true,
          ),
        ),
      ),
    );

    final infoButton = find.byIcon(Icons.info_outline);
    expect(tester.getSize(infoButton).width, 16);
    expect(
      tester
          .getSize(
            find
                .ancestor(of: infoButton, matching: find.byType(IconButton))
                .first,
          )
          .width,
      greaterThanOrEqualTo(48),
    );
    await tester.tap(infoButton);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
  });
}
