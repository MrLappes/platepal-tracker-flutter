import '../models/user_profile.dart';
import '../services/storage/user_profile_service.dart';
import '../services/user_session_service.dart';

/// Repository for user profile operations
class UserProfileRepository {
  final UserProfileService _userProfileService;
  final UserSessionService _userSessionService;

  UserProfileRepository({
    UserProfileService? userProfileService,
    required UserSessionService userSessionService,
  }) : _userProfileService = userProfileService ?? UserProfileService(),
       _userSessionService = userSessionService;

  /// Get the current user's profile
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final userId = _userSessionService.getCurrentUserId();
      return await _userProfileService.getUserProfile(userId);
    } catch (e) {
      throw Exception('Failed to get current user profile: $e');
    }
  }

  /// Get user profile by ID
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      return await _userProfileService.getUserProfile(userId);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Save or update user profile
  Future<UserProfile> saveUserProfile(UserProfile userProfile) async {
    try {
      return await _userProfileService.saveUserProfile(userProfile);
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  /// Update user metrics and store history
  Future<void> updateUserMetrics({
    required String userId,
    double? weight,
    double? height,
    double? bodyFat,
    double? dailyCalories,
  }) async {
    try {
      await _userProfileService.updateUserMetrics(
        userId: userId,
        weight: weight,
        height: height,
        bodyFat: bodyFat,
        dailyCalories: dailyCalories,
      );
    } catch (e) {
      throw Exception('Failed to update user metrics: $e');
    }
  }

  /// Get user metrics history
  Future<List<Map<String, dynamic>>> getUserMetricsHistory(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _userProfileService.getUserMetricsHistory(
        userId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to get user metrics history: $e');
    }
  }

  /// Initialize default user profile if none exists
  Future<void> initializeDefaultUserProfile() async {
    try {
      final currentProfile = await getCurrentUserProfile();
      if (currentProfile == null) {
        // Create a basic default user profile
        final defaultProfile = UserProfile(
          id: _userSessionService.getCurrentUserId(),
          name: 'Default User',
          email: '',
          age: 25,
          gender: 'other',
          height: 170.0,
          weight: 70.0,
          activityLevel: 'moderately_active',
          goals: FitnessGoals(
            goal: 'maintain_weight',
            targetWeight: 70.0,
            targetCalories: 2000.0,
            targetProtein: 150.0,
            targetCarbs: 250.0,
            targetFat: 67.0,
          ),
          preferences: DietaryPreferences(
            dietType: 'omnivore',
            allergies: [],
            dislikes: [],
            cuisinePreferences: [],
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await saveUserProfile(defaultProfile);
      }
    } catch (e) {
      throw Exception('Failed to initialize default user profile: $e');
    }
  }

  /// Delete user profile and all related data
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _userProfileService.deleteUserProfile(userId);
    } catch (e) {
      throw Exception('Failed to delete user profile: $e');
    }
  }
}
