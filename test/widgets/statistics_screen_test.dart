import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart' show initializeDateFormatting;
import 'package:intl/intl.dart' show DateFormat;
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/models/user_profile.dart';
import 'package:platepal_tracker/screens/settings/statistics_screen.dart';
import 'package:platepal_tracker/services/storage/database_service.dart';
import 'package:platepal_tracker/services/storage/dish_service.dart';
import 'package:platepal_tracker/services/storage/meal_log_service.dart';
import 'package:platepal_tracker/services/storage/storage_service_provider.dart';
import 'package:platepal_tracker/services/storage/user_profile_service.dart';
import 'package:platepal_tracker/themes/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _RecordingProfiles extends UserProfileService {
  final requestedStartDates = <DateTime>[];

  @override
  Future<List<Map<String, dynamic>>> getUserMetricsHistory(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    requestedStartDates.add(startDate!);
    return super.getUserMetricsHistory(
      userId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  Future<_RecordingProfiles> pumpStatisticsWithHistory(
    WidgetTester tester, {
    bool includeBodyFat = false,
    Locale locale = const Locale('en'),
  }) async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
    final now = DateTime.now();
    await UserProfileService().saveUserProfile(
      UserProfile(
        id: 'default',
        name: 'Test',
        email: 'test@example.com',
        age: 30,
        gender: 'other',
        height: 170,
        weight: 70,
        activityLevel: 'moderately_active',
        goals: const FitnessGoals(
          goal: 'maintain_weight',
          targetWeight: 70,
          targetCalories: 2000,
          targetProtein: 100,
          targetCarbs: 200,
          targetFat: 60,
          targetFiber: 25,
        ),
        createdAt: now,
        updatedAt: now,
      ),
    );
    final db = await DatabaseService.instance.database;
    for (final age in [
      const Duration(days: 14),
      const Duration(hours: 3),
      const Duration(hours: 2),
      const Duration(hours: 1),
    ]) {
      await db.insert('user_metrics_history', {
        'user_id': 'default',
        'weight': 72.0,
        'height': 170.0,
        'body_fat':
            includeBodyFat && age == const Duration(days: 14) ? 21.0 : null,
        'recorded_date': now.subtract(age).toIso8601String(),
      });
    }
    final profiles = _RecordingProfiles();
    final storage =
        StorageServiceProvider()
          ..userProfileService = profiles
          ..dishService = DishService()
          ..mealLogService = MealLogService();
    await tester.pumpWidget(
      ChangeNotifierProvider<StorageServiceProvider>.value(
        value: storage,
        child: MaterialApp(
          theme: AppThemes.dark.materialTheme,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const StatisticsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return profiles;
  }

  testWidgets('calorie history failure shows a retry banner, not just empty', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
    final now = DateTime.now();
    await UserProfileService().saveUserProfile(
      UserProfile(
        id: 'default',
        name: 'Test',
        email: 'test@example.com',
        age: 30,
        gender: 'other',
        height: 170,
        weight: 70,
        activityLevel: 'moderately_active',
        goals: const FitnessGoals(
          goal: 'maintain_weight',
          targetWeight: 70,
          targetCalories: 2000,
          targetProtein: 100,
          targetCarbs: 200,
          targetFat: 60,
          targetFiber: 25,
        ),
        createdAt: now,
        updatedAt: now,
      ),
    );
    final db = await DatabaseService.instance.database;
    await db.execute('DROP TABLE dish_logs');
    final storage =
        StorageServiceProvider()
          ..userProfileService = UserProfileService()
          ..dishService = DishService()
          ..mealLogService = MealLogService();

    await tester.pumpWidget(
      ChangeNotifierProvider<StorageServiceProvider>.value(
        value: storage,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const StatisticsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining("calorie data couldn't be loaded"),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextButton, 'Try Again'), findsOneWidget);
  });

  testWidgets('weight and body-fat series use the theme primary color', (
    tester,
  ) async {
    await pumpStatisticsWithHistory(tester, includeBodyFat: true);
    final colors = AppThemes.dark.materialTheme.colorScheme;
    final weightChart = find.byWidgetPredicate(
      (widget) =>
          widget is CustomPaint &&
          widget.painter is LineChartPainter &&
          (widget.painter! as LineChartPainter).valueKey == 'weight',
    );
    expect(weightChart, findsOneWidget);
    final weight =
        tester.widget<CustomPaint>(weightChart).painter! as LineChartPainter;
    expect(weight.lineColor, colors.primary);
    expect(weight.pointColor, colors.primary);
    expect(weight.axisColor, colors.onSurfaceVariant.withValues(alpha: 0.5));
    expect(weight.labelColor, colors.onSurfaceVariant);

    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    final bodyFatChart = find.byWidgetPredicate(
      (widget) =>
          widget is CustomPaint &&
          widget.painter is LineChartPainter &&
          (widget.painter! as LineChartPainter).valueKey == 'body_fat',
    );
    expect(bodyFatChart, findsOneWidget);
    final bodyFat =
        tester.widget<CustomPaint>(bodyFatChart).painter! as LineChartPainter;
    expect(bodyFat.lineColor, colors.primary);
    expect(bodyFat.pointColor, colors.primary);
  });

  testWidgets('time range dropdown uses the card surface and changes range', (
    tester,
  ) async {
    final profiles = await pumpStatisticsWithHistory(tester);
    final dropdown = find.byType(DropdownButtonFormField<String>);
    expect(dropdown, findsOneWidget);
    expect(profiles.requestedStartDates, hasLength(1));
    expect(
      tester
          .widget<DropdownButtonFormField<String>>(dropdown)
          .decoration
          .fillColor,
      AppThemes.dark.materialTheme.colorScheme.surface,
    );

    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Last Week').last);
    await tester.pumpAndSettle();
    expect(
      tester.widget<DropdownButtonFormField<String>>(dropdown).initialValue,
      'week',
    );
    expect(profiles.requestedStartDates, hasLength(2));
    expect(
      profiles.requestedStartDates.last.isAfter(
        profiles.requestedStartDates.first,
      ),
      isTrue,
    );
  });

  testWidgets('unknown body fat uses a localized placeholder', (tester) async {
    await pumpStatisticsWithHistory(tester);

    expect(find.text('Not available'), findsOneWidget);
  });

  testWidgets('unknown body fat fits in German on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpStatisticsWithHistory(tester, locale: const Locale('de'));

    expect(find.text('Nicht verfügbar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('weekly weight medians keep ISO weeks separate across years', () {
    final medians = calculateWeeklyWeightMedian([
      {'recorded_date': '2024-12-30', 'weight': 70.0},
      {'recorded_date': '2025-01-01', 'weight': 72.0},
      {'recorded_date': '2025-12-29', 'weight': 80.0},
      {'recorded_date': '2026-01-01', 'weight': 82.0},
      {'recorded_date': '2026-01-05', 'weight': 90.0},
      {'recorded_date': '2026-01-06', 'weight': null},
    ]);

    expect(medians.map((entry) => entry['recorded_date']).toList(), [
      '2024-12-30T00:00:00.000',
      '2025-12-29T00:00:00.000',
      '2026-01-05T00:00:00.000',
    ]);
    expect(medians.map((entry) => entry['weight']).toList(), [
      71.0,
      81.0,
      90.0,
    ]);
  });

  test('weekly weight medians are empty when no weights are recorded', () {
    expect(
      calculateWeeklyWeightMedian([
        {'recorded_date': '2026-01-01', 'weight': null},
      ]),
      isEmpty,
    );
  });

  test('statistics axis dates follow the selected locale', () async {
    await initializeDateFormatting('en_US');
    await initializeDateFormatting('de');
    final date = DateTime(2026, 8, 31);
    final english = formatStatisticsAxisDate(date, 'en_US');
    final german = formatStatisticsAxisDate(date, 'de');

    expect(english, DateFormat.Md('en_US').format(date));
    expect(german, DateFormat.Md('de').format(date));
    expect(english, '8/31');
    expect(german, '31.8.');
    expect(english, isNot(german));
    expect(
      formatStatisticsAxisDate(date, 'de', includeYear: true),
      DateFormat.yM('de').format(date),
    );
  });

  test('phase day counts use localized singular and plural forms', () {
    final spanish = lookupAppLocalizations(const Locale('es'));
    final german = lookupAppLocalizations(const Locale('de'));

    expect(spanish.screensSettingsStatisticsPhaseDays(1), '(1 día)');
    expect(spanish.screensSettingsStatisticsPhaseDays(2), '(2 días)');
    expect(german.screensSettingsStatisticsPhaseDays(1), '(1 Tag)');
    expect(german.screensSettingsStatisticsPhaseDays(2), '(2 Tage)');
  });

  test('calorie chart repaints when its maintenance label changes locale', () {
    final data = <Map<String, dynamic>>[];
    final english = CalorieChartPainter(
      data: data,
      maintenanceCalories: 2000,
      minValue: 0,
      maxValue: 3000,
      maintenanceLabel: 'Maintenance',
    );
    final spanish = CalorieChartPainter(
      data: data,
      maintenanceCalories: 2000,
      minValue: 0,
      maxValue: 3000,
      maintenanceLabel: 'Mantenimiento',
    );

    expect(spanish.shouldRepaint(english), isTrue);
  });
}
