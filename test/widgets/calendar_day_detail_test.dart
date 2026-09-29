import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/components/calendar/calendar_day_detail.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/services/storage/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

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

  testWidgets('logged dish name survives a missing dish', (tester) async {
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
    final db = await DatabaseService.instance.database;
    await db.insert('dish_logs', {
      'id': 'missing-dish-log',
      'dish_id': 'deleted-dish',
      'dish_name': 'Homemade Soup',
      'logged_at': DateTime(2026, 9, 20, 12).toIso8601String(),
      'meal_type': 'lunch',
      'serving_size': 1.0,
      'calories': 200.0,
      'protein': 10.0,
      'carbs': 25.0,
      'fat': 5.0,
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: CalendarDayDetail(date: DateTime(2026, 9, 20))),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Homemade Soup'), findsOneWidget);
    expect(find.text('Unknown Dish'), findsNothing);
  });
}
