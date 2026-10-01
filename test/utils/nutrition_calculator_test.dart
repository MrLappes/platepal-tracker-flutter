import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/models/user_profile.dart';
import 'package:platepal_tracker/utils/nutrition_calculator.dart';

FitnessGoals _goals({
  double calories = 2000,
  double protein = 100,
  double carbs = 250,
  double fat = 60,
  double fiber = 28,
}) => FitnessGoals(
  goal: 'maintain_weight',
  targetWeight: 70,
  targetCalories: calories,
  targetProtein: protein,
  targetCarbs: carbs,
  targetFat: fat,
  targetFiber: fiber,
);

void main() {
  group('mifflinStJeorBmr', () {
    test('male: 10*kg + 6.25*cm - 5*age + 5', () {
      expect(
        mifflinStJeorBmr(weightKg: 80, heightCm: 180, age: 30, gender: 'male'),
        1780,
      );
    });

    test('female: 10*kg + 6.25*cm - 5*age - 161', () {
      expect(
        mifflinStJeorBmr(
          weightKg: 60,
          heightCm: 165,
          age: 25,
          gender: 'female',
        ),
        1345.25,
      );
    });

    test('other and unknown use the midpoint offset -78', () {
      for (final gender in ['other', '', 'unknown']) {
        expect(
          mifflinStJeorBmr(weightKg: 70, heightCm: 170, age: 25, gender: gender),
          1559.5,
          reason: gender,
        );
      }
    });

    test('gender match is case-insensitive', () {
      expect(
        mifflinStJeorBmr(weightKg: 80, heightCm: 180, age: 30, gender: 'Male'),
        1780,
      );
    });
  });

  group('tdee', () {
    test('uses the standard activity multipliers', () {
      const expected = {
        'sedentary': 1200.0,
        'lightly_active': 1375.0,
        'moderately_active': 1550.0,
        'very_active': 1725.0,
        'extra_active': 1900.0,
        'unknown': 1550.0,
      };
      expected.forEach((level, value) {
        expect(
          totalDailyEnergyExpenditure(1000, level),
          closeTo(value, 1e-9),
          reason: level,
        );
      });
    });
  });

  group('calorieTargetForGoal', () {
    test('applies goal offsets', () {
      expect(calorieTargetForGoal(2500, 'lose_weight'), 2000);
      expect(calorieTargetForGoal(2500, 'gain_weight'), 2800);
      expect(calorieTargetForGoal(2500, 'build_muscle'), 2700);
      expect(calorieTargetForGoal(2500, 'maintain_weight'), 2500);
    });

    test('is not clamped to 1200 kcal', () {
      expect(calorieTargetForGoal(1400, 'lose_weight'), 900);
      expect(calorieTargetForGoal(1000, 'maintain_weight'), 1000);
      expect(calorieTargetForGoal(-50, 'gain_weight'), 250);
    });

    test('never returns a negative or non-finite target', () {
      expect(calorieTargetForGoal(300, 'lose_weight'), 0);
      expect(calorieTargetForGoal(-500, 'maintain_weight'), 0);
      expect(calorieTargetForGoal(double.nan, 'maintain_weight'), 0);
      expect(calorieTargetForGoal(double.infinity, 'gain_weight'), 0);
      expect(calorieTargetForGoal(double.negativeInfinity, 'lose_weight'), 0);
    });
  });

  group('isLowCalorieTarget', () {
    test('flags targets below the 1200 kcal warning threshold', () {
      expect(lowCalorieWarningThreshold, 1200);
      expect(isLowCalorieTarget(1199.9), isTrue);
      expect(isLowCalorieTarget(800), isTrue);
      expect(isLowCalorieTarget(0), isTrue);
      expect(isLowCalorieTarget(1200), isFalse);
      expect(isLowCalorieTarget(2500), isFalse);
      expect(isLowCalorieTarget(double.nan), isFalse);
    });
  });

  group('macroTargetsFor', () {
    test('uses 40/30/30 when there is no saved split', () {
      final m = macroTargetsFor(2000);
      expect(m.protein, closeTo(200, 1e-9));
      expect(m.carbs, closeTo(150, 1e-9));
      expect(m.fat, closeTo(2000 * 0.3 / 9, 1e-9));
      expect(m.fiber, closeTo(28, 1e-9));
    });

    test('keeps the saved energy split and scales it to the new target', () {
      // 100 g P (400 kcal), 250 g C (1000 kcal), 60 g F (540 kcal).
      final m = macroTargetsFor(3880, previous: _goals());
      expect(m.protein, closeTo(200, 1e-9));
      expect(m.carbs, closeTo(500, 1e-9));
      expect(m.fat, closeTo(120, 1e-9));
      expect(m.fiber, closeTo(3880 / 1000 * 14, 1e-9));
    });

    test('keeps saved fiber when calories did not change', () {
      final m = macroTargetsFor(2000, previous: _goals(fiber: 35));
      expect(m.fiber, 35);
      expect(m.protein, closeTo(100 * 2000 / 1940, 1e-9));
    });

    test('falls back to 40/30/30 when saved grams are all zero', () {
      final m = macroTargetsFor(
        2000,
        previous: _goals(protein: 0, carbs: 0, fat: 0),
      );
      expect(m.protein, closeTo(200, 1e-9));
    });
  });
}
