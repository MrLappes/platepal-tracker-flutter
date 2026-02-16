import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import '../models/user_profile.dart';
import '../repositories/user_profile_repository.dart';
import '../services/user_session_service.dart';
import 'health_service.dart';

class CalorieExpenditureService {
  static final CalorieExpenditureService _instance =
      CalorieExpenditureService._internal();
  factory CalorieExpenditureService() => _instance;
  CalorieExpenditureService._internal();

  final HealthService _healthService = HealthService();
  late final UserProfileRepository _userProfileRepository;
  bool _isInitialized = false;

  /// Initialize the service with required dependencies
  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final userSessionService = UserSessionService(prefs);
    _userProfileRepository = UserProfileRepository(
      userSessionService: userSessionService,
    );
    _isInitialized = true;
  }

  /// Get calories burned for a specific date, with fallback to estimated values
  /// Returns a tuple of (calories, isEstimated)
  Future<(double?, bool)> getCaloriesBurnedForDateWithStatus(
    DateTime date,
  ) async {
    await initialize();

    try {
      final dateStr = date.toIso8601String().split('T')[0];
      developer.log(
        'Getting calories burned for date: $dateStr',
        name: 'CalorieExpenditureService',
      );

      // Check if health service is connected
      if (!_healthService.isConnected) {
        developer.log(
          'Health service not connected, using estimation',
          name: 'CalorieExpenditureService',
        );
        final estimatedCalories = await _estimateCaloriesBurned(date);
        developer.log(
          'Using estimated calories: $estimatedCalories',
          name: 'CalorieExpenditureService',
        );
        return (estimatedCalories, true); // true = estimated
      } // First try to get from health service for specific date using smart method
      final healthCalories = await _healthService.getCaloriesBurnedForDateSmart(
        date,
      );
      if (healthCalories != null && healthCalories > 0) {
        developer.log(
          'Found health data: $healthCalories calories for $dateStr',
          name: 'CalorieExpenditureService',
        );
        return (healthCalories, false); // false = real data
      } else {
        developer.log(
          'No health data found for $dateStr (returned: $healthCalories)',
          name: 'CalorieExpenditureService',
        );
      }

      // Check stored data for this specific date
      final storedData = await _healthService.getStoredCaloriesBurnedData();
      final dateKey = date.toIso8601String().split('T')[0];

      if (storedData.containsKey(dateKey)) {
        final storedCalories = storedData[dateKey]!;
        developer.log(
          'Found stored data: $storedCalories calories',
          name: 'CalorieExpenditureService',
        );
        return (
          storedCalories,
          false,
        ); // false = real data (stored from health)
      }

      // If it's today or recent dates, try a cache refresh and retry
      final isRecentDate = DateTime.now().difference(date).inDays <= 7;
      if (isRecentDate && _healthService.isConnected) {
        developer.log(
          'Attempting to refresh calorie cache for recent data',
          name: 'CalorieExpenditureService',
        );
        await _healthService.refreshCaloriesBurnedCache();
        final syncedCalories = await _healthService
            .getCaloriesBurnedForDateSmart(date);
        if (syncedCalories != null && syncedCalories > 0) {
          developer.log(
            'Found synced data: $syncedCalories calories',
            name: 'CalorieExpenditureService',
          );
          return (syncedCalories, false); // false = real data
        }
      }

      // For historical dates without data, estimate based on user profile
      final estimatedCalories = await _estimateCaloriesBurned(date);
      developer.log(
        'Using estimated calories: $estimatedCalories',
        name: 'CalorieExpenditureService',
      );
      return (estimatedCalories, true); // true = estimated
    } catch (e) {
      developer.log(
        'Error getting calories burned for date: $e',
        name: 'CalorieExpenditureService',
      );
      // Return estimated calories as final fallback
      final estimatedCalories = await _estimateCaloriesBurned(date);
      return (estimatedCalories, true); // true = estimated
    }
  }

  /// Get calories burned for a specific date (backward compatibility)
  Future<double?> getCaloriesBurnedForDate(DateTime date) async {
    final (calories, _) = await getCaloriesBurnedForDateWithStatus(date);
    return calories;
  }

  /// Estimate calories burned based on user profile when health data is not available
  Future<double?> _estimateCaloriesBurned(DateTime date) async {
    try {
      final userProfile = await _userProfileRepository.getCurrentUserProfile();
      if (userProfile == null) return null;

      // Basic estimation based on BMR and activity level
      final bmr = _calculateBMR(userProfile);
      final activityMultiplier = _getActivityMultiplier(
        userProfile.activityLevel,
      );

      // Calculate TDEE (Total Daily Energy Expenditure)
      final tdee = bmr * activityMultiplier;

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

      final estimatedCalories = tdee * variabilityFactor;

      developer.log(
        'Estimated calories for ${date.toIso8601String().split('T')[0]}: '
        'BMR=$bmr, Activity=${userProfile.activityLevel} (${activityMultiplier}x), '
        'TDEE=$tdee, Final=$estimatedCalories',
        name: 'CalorieExpenditureService',
      );

      return estimatedCalories;
    } catch (e) {
      developer.log(
        'Error estimating calories burned: $e',
        name: 'CalorieExpenditureService',
      );
      return null;
    }
  }

  /// Calculate Basal Metabolic Rate using Mifflin-St Jeor Equation
  double _calculateBMR(UserProfile profile) {
    double bmr;

    if (profile.gender == 'male') {
      bmr = 10 * profile.weight + 6.25 * profile.height - 5 * profile.age + 5;
    } else {
      bmr = 10 * profile.weight + 6.25 * profile.height - 5 * profile.age - 161;
    }

    return bmr;
  }

  /// Get activity level multiplier for TDEE calculation
  double _getActivityMultiplier(String activityLevel) {
    switch (activityLevel) {
      case 'sedentary':
        return 1.2;
      case 'lightly_active':
        return 1.375;
      case 'moderately_active':
        return 1.55;
      case 'very_active':
        return 1.725;
      case 'extra_active':
        return 1.9;
      default:
        return 1.55; // Default to moderately active
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
          analysisMessage: 'User profile not found',
        );
      }

      // Get calories burned data for analysis period from cache
      final caloriesData = await _healthService.refreshCaloriesBurnedCache(
        days: days,
      );
      final storedData = await _healthService.getStoredCaloriesBurnedData();

      // Combine fresh data with stored data
      final combinedData = Map<String, double>.from(storedData);
      combinedData.addAll(caloriesData);

      if (combinedData.isEmpty) {
        return CalorieTargetAnalysis(
          needsAdjustment: false,
          currentTarget: userProfile.goals.targetCalories,
          suggestedTarget: userProfile.goals.targetCalories,
          averageExpenditure: 0,
          analysisMessage: 'No calorie expenditure data available for analysis',
        );
      }

      // Calculate average daily expenditure
      final totalExpenditure = combinedData.values.fold(
        0.0,
        (sum, calories) => sum + calories,
      );
      final averageExpenditure = totalExpenditure / combinedData.length;

      // Analyze if target needs adjustment
      final currentTarget = userProfile.goals.targetCalories;
      final expenditureRatio =
          averageExpenditure > 0 ? currentTarget / averageExpenditure : 1.0;

      bool needsAdjustment = false;
      double suggestedTarget = currentTarget;
      String analysisMessage = '';

      // If user consistently burns more calories than their target intake suggests
      if (expenditureRatio < 0.7) {
        needsAdjustment = true;
        // Increase target calories to match expenditure better
        suggestedTarget =
            averageExpenditure * 0.8; // 80% of expenditure for moderate deficit
        analysisMessage =
            'Your calorie expenditure is significantly higher than your current target suggests. Consider increasing your calorie intake.';
      }
      // If user burns much fewer calories than target suggests
      else if (expenditureRatio > 1.3) {
        needsAdjustment = true;
        // Decrease target calories to match lower expenditure
        suggestedTarget =
            averageExpenditure *
            1.1; // 110% of expenditure for moderate surplus
        analysisMessage =
            'Your calorie expenditure is lower than your current target suggests. Consider adjusting your calorie intake or increasing activity.';
      } else {
        analysisMessage =
            'Your current calorie targets seem well-aligned with your activity level.';
      }

      return CalorieTargetAnalysis(
        needsAdjustment: needsAdjustment,
        currentTarget: currentTarget,
        suggestedTarget: suggestedTarget,
        averageExpenditure: averageExpenditure,
        analysisMessage: analysisMessage,
        daysAnalyzed: combinedData.length,
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
        analysisMessage: 'Error occurred during analysis: $e',
      );
    }
  }

  /// Update user's calorie targets based on analysis
  Future<bool> updateCalorieTargets(double newTargetCalories) async {
    await initialize();

    try {
      final userProfile = await _userProfileRepository.getCurrentUserProfile();
      if (userProfile == null) return false;

      // Calculate new macro targets proportionally
      final calorieRatio = newTargetCalories / userProfile.goals.targetCalories;

      final newGoals = FitnessGoals(
        goal: userProfile.goals.goal,
        targetWeight: userProfile.goals.targetWeight,
        targetCalories: newTargetCalories,
        targetProtein: userProfile.goals.targetProtein * calorieRatio,
        targetCarbs: userProfile.goals.targetCarbs * calorieRatio,
        targetFat: userProfile.goals.targetFat * calorieRatio,
        targetFiber:
            userProfile.goals.targetFiber, // Keep fiber target unchanged
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
  Future<CalorieTargetAnalysis> syncAndAnalyze() async {
    await initialize();

    // Refresh calorie cache from Health Connect
    if (_healthService.isConnected) {
      await _healthService.refreshCaloriesBurnedCache(days: 14);
    }

    // Perform analysis
    return await analyzeCalorieTargets();
  }
}

class CalorieTargetAnalysis {
  final bool needsAdjustment;
  final double currentTarget;
  final double suggestedTarget;
  final double averageExpenditure;
  final String analysisMessage;
  final int daysAnalyzed;

  CalorieTargetAnalysis({
    required this.needsAdjustment,
    required this.currentTarget,
    required this.suggestedTarget,
    required this.averageExpenditure,
    required this.analysisMessage,
    this.daysAnalyzed = 0,
  });
}
