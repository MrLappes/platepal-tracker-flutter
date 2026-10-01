import '../models/user_profile.dart';

/// Targets below this (kcal/day) get a warning; such diets need medical supervision.
const double lowCalorieWarningThreshold = 1200;

/// Whether [kcal], rounded to whole kcal as displayed, is low enough to warn about.
bool isLowCalorieTarget(double kcal) =>
    kcal.isFinite && kcal.round() < lowCalorieWarningThreshold;

/// [kcal] as a usable target: non-finite or negative input becomes 0.
double nonNegativeCalorieTarget(double kcal) =>
    kcal.isFinite && kcal > 0 ? kcal : 0;

/// Basal metabolic rate (kcal/day) via Mifflin-St Jeor.
///
/// Genders other than male/female use the midpoint of the two offsets.
double mifflinStJeorBmr({
  required double weightKg,
  required double heightCm,
  required int age,
  required String gender,
}) {
  final base = 10 * weightKg + 6.25 * heightCm - 5 * age;
  switch (gender.toLowerCase()) {
    case 'male':
      return base + 5;
    case 'female':
      return base - 161;
    default:
      return base - 78;
  }
}

/// Activity multiplier for [activityLevel]; unknown levels count as moderate.
double activityMultiplier(String activityLevel) {
  switch (activityLevel) {
    case 'sedentary':
      return 1.2;
    case 'lightly_active':
      return 1.375;
    case 'very_active':
      return 1.725;
    case 'extra_active':
      return 1.9;
    case 'moderately_active':
    default:
      return 1.55;
  }
}

/// Total daily energy expenditure (kcal/day).
double totalDailyEnergyExpenditure(double bmr, String activityLevel) =>
    bmr * activityMultiplier(activityLevel);

/// Daily calorie target for [goal]; never negative or non-finite.
double calorieTargetForGoal(double tdee, String goal) {
  final double target;
  switch (goal) {
    case 'lose_weight':
      target = tdee - 500;
      break;
    case 'gain_weight':
      target = tdee + 300;
      break;
    case 'build_muscle':
      target = tdee + 200;
      break;
    default:
      target = tdee;
  }
  return nonNegativeCalorieTarget(target);
}

/// Gram targets for protein, carbs, fat and fiber.
class MacroTargets {
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;

  const MacroTargets({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
  });
}

/// Macro gram targets for [calories].
///
/// Keeps the energy split of [previous] (e.g. a customized macro split) and
/// falls back to 40/30/30 protein/carbs/fat when there is none. Fiber follows
/// 14 g per 1000 kcal, but a saved value is kept if calories are unchanged.
MacroTargets macroTargetsFor(double calories, {FitnessGoals? previous}) {
  var proteinShare = 0.40;
  var carbsShare = 0.30;
  var fatShare = 0.30;

  if (previous != null) {
    final proteinKcal = previous.targetProtein * 4;
    final carbsKcal = previous.targetCarbs * 4;
    final fatKcal = previous.targetFat * 9;
    final totalKcal = proteinKcal + carbsKcal + fatKcal;
    if (totalKcal > 0) {
      proteinShare = proteinKcal / totalKcal;
      carbsShare = carbsKcal / totalKcal;
      fatShare = fatKcal / totalKcal;
    }
  }

  final double fiber;
  if (previous != null && (previous.targetCalories - calories).abs() < 0.5) {
    fiber = previous.targetFiber;
  } else {
    fiber = calories / 1000 * 14;
  }

  return MacroTargets(
    protein: calories * proteinShare / 4,
    carbs: calories * carbsShare / 4,
    fat: calories * fatShare / 9,
    fiber: fiber,
  );
}
