import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage/storage_service_provider.dart';
import '../services/storage/user_profile_service.dart';
import '../services/storage/dish_service.dart';
import '../services/storage/meal_log_service.dart';

/// Extension methods to easily access storage services from any widget
extension StorageServiceExtensions on BuildContext {
  /// Get the storage service provider
  StorageServiceProvider get storageServiceProvider =>
      Provider.of<StorageServiceProvider>(this, listen: false);

  /// Get the user profile service
  UserProfileService get userProfileService =>
      Provider.of<StorageServiceProvider>(
        this,
        listen: false,
      ).userProfileService;

  /// Get the dish service
  DishService get dishService =>
      Provider.of<StorageServiceProvider>(this, listen: false).dishService;

  /// Get the meal log service
  MealLogService get mealLogService =>
      Provider.of<StorageServiceProvider>(this, listen: false).mealLogService;
}
