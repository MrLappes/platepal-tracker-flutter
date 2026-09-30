import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/screens/settings/statistics_screen.dart';

void main() {
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
