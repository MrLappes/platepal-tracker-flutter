import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/models/user_profile.dart';
import 'package:platepal_tracker/services/calorie_expenditure_service.dart';
import 'package:platepal_tracker/services/health_service.dart';
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

      final goals =
          (await UserProfileService().getUserProfile('default'))!.goals;
      expect(goals.targetCalories, 2500);
      expect(goals.targetProtein, closeTo(187.5, 1e-9));
      expect(goals.targetCarbs, closeTo(250, 1e-9));
      expect(goals.targetFat, closeTo(75, 1e-9));
      expect(goals.targetFiber, 30);
    });

    test('a zero current target does not produce infinite macros', () async {
      await UserProfileService().saveUserProfile(_profile(_goals(calories: 0)));

      expect(await service.updateCalorieTargets(2000), isTrue);

      final goals =
          (await UserProfileService().getUserProfile('default'))!.goals;
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

      final goals =
          (await UserProfileService().getUserProfile('default'))!.goals;
      expect(goals.targetCalories, 1200);
      expect(goals.targetProtein, closeTo(90, 1e-9));
    });
  });

  // Mifflin-St Jeor for the test profile: 800 + 1125 - 150 + 5.
  const profileBmr = 1780.0;

  group('resolveExpenditure', () {
    test('adds the profile BMR to active-only Health data', () async {
      await UserProfileService().saveUserProfile(_profile(_goals()));

      expect(
        await service.resolveExpenditure(const DailyEnergyBurned(active: 500)),
        (profileBmr + 500, true),
      );
    });

    test('uses a Health total as measured data', () async {
      expect(
        await service.resolveExpenditure(
          const DailyEnergyBurned(total: 2600, active: 500),
        ),
        (2600.0, false),
      );
    });
  });

  group('analyzeCalorieTargets', () {
    Future<void> cacheDays(Map<int, DailyEnergyBurned> byDaysAgo) async {
      final today = DateTime.now();
      SharedPreferences.setMockInitialValues({});
      await HealthService().storeEnergyBurned({
        for (final entry in byDaysAgo.entries)
          HealthService.dayKey(
                DateTime(today.year, today.month, today.day - entry.key),
              ):
              entry.value,
      });
    }

    test(
      'reports profile and expenditure availability as typed statuses',
      () async {
        final missingProfile = await service.analyzeCalorieTargets();
        expect(missingProfile.status, CalorieTargetStatus.profileNotFound);

        await UserProfileService().saveUserProfile(_profile(_goals()));
        final missingData = await service.analyzeCalorieTargets();
        expect(missingData.status, CalorieTargetStatus.noExpenditureData);
        expect(missingData.currentTarget, 2000);
      },
    );

    test('reports the recommendation status with calculated targets', () async {
      await UserProfileService().saveUserProfile(_profile(_goals()));
      await cacheDays({1: const DailyEnergyBurned(total: 4000)});

      final increase = await service.analyzeCalorieTargets(days: 1);
      expect(increase.status, CalorieTargetStatus.increaseIntake);
      expect(increase.suggestedTarget, 3200);

      await cacheDays({1: const DailyEnergyBurned(total: 1000)});
      final decrease = await service.analyzeCalorieTargets(days: 1);
      expect(decrease.status, CalorieTargetStatus.decreaseIntake);
      expect(decrease.suggestedTarget, 1200);

      await cacheDays({1: const DailyEnergyBurned(total: 2500)});
      final aligned = await service.analyzeCalorieTargets(days: 1);
      expect(aligned.status, CalorieTargetStatus.onTarget);
      expect(aligned.needsAdjustment, isFalse);
    });

    test('averages only the requested window', () async {
      await UserProfileService().saveUserProfile(_profile(_goals()));
      await cacheDays({
        for (var i = 1; i <= 14; i++) i: const DailyEnergyBurned(total: 2500),
        for (var i = 15; i <= 20; i++) i: const DailyEnergyBurned(total: 1000),
        0: const DailyEnergyBurned(total: 100), // partial today
      });

      final analysis = await service.analyzeCalorieTargets(days: 14);

      expect(analysis.averageExpenditure, closeTo(2500, 1e-9));
      expect(analysis.daysAnalyzed, 14);
    });

    test('daysAnalyzed counts only days with data', () async {
      await UserProfileService().saveUserProfile(_profile(_goals()));
      await cacheDays({
        2: const DailyEnergyBurned(total: 2400),
        5: const DailyEnergyBurned(total: 2600),
      });

      final analysis = await service.analyzeCalorieTargets(days: 14);

      expect(analysis.averageExpenditure, closeTo(2500, 1e-9));
      expect(analysis.daysAnalyzed, 2);
    });

    test('active-only days count as BMR + active, not as TDEE', () async {
      await UserProfileService().saveUserProfile(_profile(_goals()));
      await cacheDays({
        for (var i = 1; i <= 7; i++) i: const DailyEnergyBurned(active: 500),
      });

      final analysis = await service.analyzeCalorieTargets(days: 7);

      expect(analysis.averageExpenditure, closeTo(profileBmr + 500, 1e-9));
      expect(analysis.needsAdjustment, isFalse);
    });
  });
}
