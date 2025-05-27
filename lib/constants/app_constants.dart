class AppConstants {
  // App Information
  static const String appName = 'PlatePal Tracker';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseApiUrl = 'https://api.platepal.com';
  static const String openFoodFactsBaseUrl =
      'https://world.openfoodfacts.org/api/v0';

  // Storage Keys
  static const String userProfileKey = 'user_profile';
  static const String settingsKey = 'app_settings';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String apiKeyKey = 'api_key';

  // Default Values
  static const String defaultLanguage = 'en';
  static const String defaultUnit = 'metric';

  // Limits and Constraints
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int maxIngredientsPerDish = 50;
  static const double minCalorieValue = 0.0;
  static const double maxCalorieValue = 10000.0;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double cardElevation = 4.0;
}
