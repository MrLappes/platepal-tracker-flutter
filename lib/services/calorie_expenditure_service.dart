import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import '../models/user_profile.dart';
import '../repositories/user_profile_repository.dart';
import '../services/user_session_service.dart';
import '../utils/nutrition_calculator.dart';
import 'health_service.dart';

class CalorieExpenditureService {
  static final CalorieExpenditureService _instance =
      CalorieExpenditureService._internal();
  factory CalorieExpenditureService() => _instance;
  CalorieExpenditureService._internal();

  final HealthService _healthService = HealthService();
  late final UserProfileRepository _userProfileRepository;
  Future<void>? _initialization;
  bool _isInitialized = false;

  /// Initialize the service with required dependencies.
  ///
  /// Concurrent callers share one initialization.
  Future<void> initialize() async {
    if (_isInitialized) return;
    await (_initialization ??= _initialize());
    _isInitialized = true;
  }

  Future<void> _initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userSessionService = UserSessionService(prefs);
      _userProfileRepository = UserProfileRepository(
        userSessionService: userSessionService,
      );
    } catch (_) {
      _initialization = null;
      rethrow;
    }
  }

  /// Get calories burned for a specific date, with fallback to estimated values
  /// Returns a tuple of (calories, isEstimated)
  Future<(double?, bool)> getCaloriesBurnedForDateWithStatus(
    DateTime date,
  ) async {
    await initialize();

    try {
      if (!_healthService.isConnected) {
        return (await _estimateCaloriesBurned(date), true);
      }

      // Falls back to the local cache when Health can't be read.
      final day =
          await _healthService.getEnergyBurnedForDate(date) ??
          (await _healthService.getStoredEnergyBurned())[HealthService.dayKey(
            date,
          )];
      final resolved = day == null ? null : await resolveExpenditure(day);
      if (resolved != null) return resolved;

      // Health is the source of truth once connected: no data means no value.
      return (null, false);
    } catch (e) {
      developer.log(
        'Error getting calories burned for date: $e',
        name: 'CalorieExpenditureService',
      );
      // Only fall back to estimation if health is not connected
      if (!_healthService.isConnected) {
        final estimatedCalories = await _estimateCaloriesBurned(date);
        return (estimatedCalories, true); // true = estimated
      }
      return (null, false);
    }
  }

  /// Get calories burned for a specific date (backward compatibility)
  Future<double?> getCaloriesBurnedForDate(DateTime date) async {
    final (calories, _) = await getCaloriesBurnedForDateWithStatus(date);
    return calories;
  }

  /// Total expenditure for a Health day as (kcal, isEstimated). Without a
  /// basal record, the profile's Mifflin-St Jeor BMR stands in for it.
  Future<(double, bool)?> resolveExpenditure(DailyEnergyBurned day) async {
    await initialize();
    return day.totalExpenditure() ??
        day.totalExpenditure(estimatedBasal: await _profileBmr());
  }

  /// Total expenditure per local day key (see [HealthService.dayKey]) in
  /// [start, end) from one Health read, or the local cache if that fails.
  Future<Map<String, (double, bool)>> getExpenditureByDay(
    DateTime start,
    DateTime end,
  ) async {
    await initialize();
    if (!_healthService.isConnected) return {};

    Map<String, DailyEnergyBurned> days;
    try {
      days = await _healthService.readEnergyBurnedByDay(start, end);
    } catch (e) {
      developer.log(
        'Health range read failed, using cache: $e',
        name: 'CalorieExpenditureService',
      );
      final startKey = HealthService.dayKey(start);
      final endKey = HealthService.dayKey(end);
      days = {
        for (final entry in (await _healthService.getStoredEnergyBurned())
            .entries)
          if (entry.key.compareTo(startKey) >= 0 &&
              entry.key.compareTo(endKey) <= 0)
            entry.key: entry.value,
      };
    }
    return _resolveAll(days);
  }

  Future<Map<String, (double, bool)>> _resolveAll(
    Map<String, DailyEnergyBurned> days,
  ) async {
    final bmr = await _profileBmr();
    return {
      for (final entry in days.entries)
        if (entry.value.totalExpenditure(estimatedBasal: bmr) case final value?)
          entry.key: value,
    };
  }

  Future<double?> _profileBmr() async {
    try {
      final profile = await _userProfileRepository.getCurrentUserProfile();
      if (profile == null) return null;
      return mifflinStJeorBmr(
        weightKg: profile.weight,
        heightCm: profile.height,
        age: profile.age,
        gender: profile.gender,
      );
    } catch (e) {
      developer.log(
        'Error loading profile for BMR: $e',
        name: 'CalorieExpenditureService',
      );
      return null;
    }
  }

  /// Estimate calories burned based on user profile when health data is not available
  Future<double?> _estimateCaloriesBurned(DateTime date) async {
    try {
      final userProfile = await _userProfileRepository.getCurrentUserProfile();
      if (userProfile == null) return null;

      // Basic estimation based on BMR and activity level
      final bmr = mifflinStJeorBmr(
        weightKg: userProfile.weight,
        heightCm: userProfile.height,
        age: userProfile.age,
        gender: userProfile.gender,
      );
      final multiplier = activityMultiplier(userProfile.activityLevel);

      // Calculate TDEE (Total Daily Energy Expenditure)
      final tdee = bmr * multiplier;

      // Add some variability for different days
      final dayOfWeek = date.weekday;
      double variabilityFactor = 1.0;

      // Weekend days might have different activity patterns
      if (dayOfWeek == DateTime.saturday || dayOfWeek == DateTime.sunday) {
        // Slightly lower activity on weekends for most people
        variabilityFactor = 0.95;
      } else {
        // Weekdays might have more consistent activity
        variabilityFactor = 1.0;
      }

      return tdee * variabilityFactor;
    } catch (e) {
      developer.log(
        'Error estimating calories burned: $e',
        name: 'CalorieExpenditureService',
      );
      return null;
    }
  }

  /// Analyze user's calorie expenditure patterns and suggest target adjustments
  Future<CalorieTargetAnalysis> analyzeCalorieTargets({int days = 14}) async {
    await initialize();

    try {
      final userProfile = await _userProfileRepository.getCurrentUserProfile();
      if (userProfile == null) {
        return CalorieTargetAnalysis(
          needsAdjustment: false,
          currentTarget: 0,
          suggestedTarget: 0,
          averageExpenditure: 0,
          status: CalorieTargetStatus.profileNotFound,
        );
      }

      // The refresh merges into the cache; a failed refresh leaves the cache.
      await _healthService.refreshCaloriesBurnedCache(days: days);
      final storedData = await _healthService.getStoredEnergyBurned();

      // The last [days] complete days; today is partial and would skew low.
      final now = DateTime.now();
      final window = {
        for (var i = 1; i <= days; i++)
          HealthService.dayKey(DateTime(now.year, now.month, now.day - i)),
      };
      final expenditures = await _resolveAll({
        for (final entry in storedData.entries)
          if (window.contains(entry.key)) entry.key: entry.value,
      });

      if (expenditures.isEmpty) {
        return CalorieTargetAnalysis(
          needsAdjustment: false,
          currentTarget: userProfile.goals.targetCalories,
          suggestedTarget: userProfile.goals.targetCalories,
          averageExpenditure: 0,
          status: CalorieTargetStatus.noExpenditureData,
        );
      }

      // Calculate average daily expenditure
      final totalExpenditure = expenditures.values.fold(
        0.0,
        (sum, day) => sum + day.$1,
      );
      final averageExpenditure = totalExpenditure / expenditures.length;

      // Analyze if target needs adjustment
      final currentTarget = userProfile.goals.targetCalories;
      final expenditureRatio =
          averageExpenditure > 0 ? currentTarget / averageExpenditure : 1.0;

      bool needsAdjustment = false;
      double suggestedTarget = currentTarget;
      late CalorieTargetStatus status;

      // If user consistently burns more calories than their target intake suggests
      if (expenditureRatio < 0.7) {
        needsAdjustment = true;
        // Increase target calories to match expenditure better
        suggestedTarget =
            averageExpenditure * 0.8; // 80% of expenditure for moderate deficit
        status = CalorieTargetStatus.increaseIntake;
      }
      // If user burns much fewer calories than target suggests
      else if (expenditureRatio > 1.3) {
        needsAdjustment = true;
        // Decrease target calories to match lower expenditure
        suggestedTarget =
            averageExpenditure *
            1.1; // 110% of expenditure for moderate surplus
        status = CalorieTargetStatus.decreaseIntake;
      } else {
        status = CalorieTargetStatus.onTarget;
      }

      return CalorieTargetAnalysis(
        needsAdjustment: needsAdjustment,
        currentTarget: currentTarget,
        suggestedTarget:
            needsAdjustment && suggestedTarget < minimumCalorieTarget
                ? minimumCalorieTarget
                : suggestedTarget,
        averageExpenditure: averageExpenditure,
        status: status,
        daysAnalyzed: expenditures.length,
      );
    } catch (e) {
      developer.log(
        'Error analyzing calorie targets: $e',
        name: 'CalorieExpenditureService',
      );
      return CalorieTargetAnalysis(
        needsAdjustment: false,
        currentTarget: 0,
        suggestedTarget: 0,
        averageExpenditure: 0,
        status: CalorieTargetStatus.error,
        errorDetails: e.toString(),
      );
    }
  }

  /// Update user's calorie targets based on analysis
  Future<bool> updateCalorieTargets(double newTargetCalories) async {
    await initialize();

    try {
      final userProfile = await _userProfileRepository.getCurrentUserProfile();
      if (userProfile == null) return false;

      final targetCalories =
          newTargetCalories < minimumCalorieTarget
              ? minimumCalorieTarget
              : newTargetCalories;
      final goals = userProfile.goals;
      final double protein;
      final double carbs;
      final double fat;
      if (goals.targetCalories > 0) {
        final calorieRatio = targetCalories / goals.targetCalories;
        protein = goals.targetProtein * calorieRatio;
        carbs = goals.targetCarbs * calorieRatio;
        fat = goals.targetFat * calorieRatio;
      } else {
        // No current target to scale from: rebuild grams from the saved split.
        final macros = macroTargetsFor(targetCalories, previous: goals);
        protein = macros.protein;
        carbs = macros.carbs;
        fat = macros.fat;
      }

      final newGoals = FitnessGoals(
        goal: goals.goal,
        targetWeight: goals.targetWeight,
        targetCalories: targetCalories,
        targetProtein: protein,
        targetCarbs: carbs,
        targetFat: fat,
        targetFiber: goals.targetFiber, // Keep fiber target unchanged
      );
      final updatedProfile = UserProfile(
        id: userProfile.id,
        name: userProfile.name,
        email: userProfile.email,
        age: userProfile.age,
        gender: userProfile.gender,
        height: userProfile.height,
        weight: userProfile.weight,
        activityLevel: userProfile.activityLevel,
        goals: newGoals,
        preferences: userProfile.preferences,
        preferredUnit: userProfile.preferredUnit,
        createdAt: userProfile.createdAt,
        updatedAt: DateTime.now(),
      );

      await _userProfileRepository.saveUserProfile(updatedProfile);
      return true;
    } catch (e) {
      developer.log(
        'Error updating calorie targets: $e',
        name: 'CalorieExpenditureService',
      );
      return false;
    }
  }

  /// Sync health data and perform automatic analysis
  Future<CalorieTargetAnalysis> syncAndAnalyze() =>
      // analyzeCalorieTargets refreshes the cache itself.
      analyzeCalorieTargets();
}

/// Analysis outcome for the UI to translate without a BuildContext in the service.
enum CalorieTargetStatus {
  profileNotFound,
  noExpenditureData,
  increaseIntake,
  decreaseIntake,
  onTarget,
  error,
}

class CalorieTargetAnalysis {
  final bool needsAdjustment;
  final double currentTarget;
  final double suggestedTarget;
  final double averageExpenditure;
  final CalorieTargetStatus status;
  final String? errorDetails;
  final int daysAnalyzed;

  CalorieTargetAnalysis({
    required this.needsAdjustment,
    required this.currentTarget,
    required this.suggestedTarget,
    required this.averageExpenditure,
    required this.status,
    this.errorDetails,
    this.daysAnalyzed = 0,
  });
}
