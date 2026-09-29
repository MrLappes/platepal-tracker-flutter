import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/models/user_profile.dart';
import 'package:platepal_tracker/services/calorie_expenditure_service.dart';
import 'package:platepal_tracker/services/storage/database_service.dart';
import 'package:platepal_tracker/services/storage/user_profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

UserProfile _profile(FitnessGoals goals) {
  final now = DateTime(2026, 1, 1);
  return UserProfile(
    id: 'default',
    name: 'Test',
    email: 'test@example.com',
    age: 30,
    gender: 'male',
    height: 180,
    weight: 80,
    activityLevel: 'moderately_active',
    goals: goals,
    createdAt: now,
    updatedAt: now,
  );
}

FitnessGoals _goals({double calories = 2000}) => FitnessGoals(
  goal: 'maintain_weight',
  targetWeight: 80,
  targetCalories: calories,
  targetProtein: 150,
  targetCarbs: 200,
  targetFat: 60,
  targetFiber: 30,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  final service = CalorieExpenditureService();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
  });

  // Must run first: the service is a process-wide singleton.
  test('concurrent initialize() calls share one initialization', () async {
    await expectLater(
      Future.wait([
        service.initialize(),
        service.initialize(),
        service.initialize(),
      ]),
      completes,
    );
    await expectLater(service.initialize(), completes);
  });

  group('updateCalorieTargets', () {
    test('scales macros with the new target and keeps fiber', () async {
      await UserProfileService().saveUserProfile(_profile(_goals()));

      expect(await service.updateCalorieTargets(2500), isTrue);

      final goals = (await UserProfileService().getUserProfile('default'))!.goals;
      expect(goals.targetCalories, 2500);
      expect(goals.targetProtein, closeTo(187.5, 1e-9));
      expect(goals.targetCarbs, closeTo(250, 1e-9));
      expect(goals.targetFat, closeTo(75, 1e-9));
      expect(goals.targetFiber, 30);
    });

    test('a zero current target does not produce infinite macros', () async {
      await UserProfileService().saveUserProfile(_profile(_goals(calories: 0)));

      expect(await service.updateCalorieTargets(2000), isTrue);

      final goals = (await UserProfileService().getUserProfile('default'))!.goals;
      expect(goals.targetCalories, 2000);
      for (final grams in [
        goals.targetProtein,
        goals.targetCarbs,
        goals.targetFat,
      ]) {
        expect(grams.isFinite, isTrue);
        expect(grams, greaterThan(0));
      }
      // Saved grams keep their energy split: 600 + 800 + 540 = 1940 kcal.
      expect(goals.targetProtein, closeTo(2000 * 600 / 1940 / 4, 1e-9));
    });

    test('clamps the new target to the 1200 kcal floor', () async {
      await UserProfileService().saveUserProfile(_profile(_goals()));

      expect(await service.updateCalorieTargets(400), isTrue);

      final goals = (await UserProfileService().getUserProfile('default'))!.goals;
      expect(goals.targetCalories, 1200);
      expect(goals.targetProtein, closeTo(90, 1e-9));
    });
  });
}
