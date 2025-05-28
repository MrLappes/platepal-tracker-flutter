import 'package:flutter/foundation.dart';
import '../../../models/chat_types.dart';
import '../../../models/dish_models.dart';
import '../../../models/meal_type.dart';
import '../../../models/user_ingredient.dart';
import '../../../repositories/dish_repository.dart';
import '../../../services/storage/dish_service.dart';

/// Processes and validates dishes from AI responses using new dish models
class DishProcessingStep extends AgentStep {
  final DishRepository? _dishRepository;
  final DishService? _dishService;

  DishProcessingStep({DishRepository? dishRepository, DishService? dishService})
    : _dishRepository = dishRepository,
      _dishService = dishService;

  @override
  String get stepName => 'dish_processing';

  @override
  Future<ChatStepResult> execute(ChatStepInput input) async {
    try {
      debugPrint('🍽️ DishProcessingStep: Starting dish processing');

      // Handle both analyzed dishes and raw dish data
      final dishesData =
          input.metadata?['dishes'] as List<dynamic>? ??
          input.metadata?['analyzedDishes'] as List<dynamic>? ??
          [];
      final uploadedImageUri = input.metadata?['uploadedImageUri'] as String?;

      if (dishesData.isEmpty) {
        debugPrint('ℹ️ DishProcessingStep: No dishes to process');
        return ChatStepResult.success(
          stepName: stepName,
          data: {'validatedDishes': <ProcessedDish>[]},
        );
      }

      debugPrint(
        '🍽️ DishProcessingStep: Processing ${dishesData.length} dishes',
      );

      final validatedDishes = <ProcessedDish>[];
      final processingErrors = <String>[];

      for (int i = 0; i < dishesData.length; i++) {
        try {
          final dishData = dishesData[i] as Map<String, dynamic>;
          debugPrint(
            '   Processing dish ${i + 1}: ${dishData['name'] ?? dishData['dishName']}',
          );

          final processedDish = await _processSingleDish(
            dishData,
            uploadedImageUri,
            input.userIngredients,
          );

          if (processedDish != null) {
            validatedDishes.add(processedDish);
            debugPrint('   ✅ Successfully processed: ${processedDish.name}');
          } else {
            final dishName =
                dishData['name'] ?? dishData['dishName'] ?? 'Unknown dish';
            processingErrors.add('Failed to process dish: $dishName');
            debugPrint('   ❌ Failed to process: $dishName');
          }
        } catch (dishError) {
          processingErrors.add('Error processing dish ${i + 1}: $dishError');
          debugPrint('   ❌ Error processing dish ${i + 1}: $dishError');
        }
      }

      debugPrint('🍽️ DishProcessingStep: Completed processing');
      debugPrint('   Successfully processed: ${validatedDishes.length}');
      debugPrint('   Errors: ${processingErrors.length}');

      return ChatStepResult.success(
        stepName: stepName,
        data: {
          'validatedDishes': validatedDishes,
          'processingErrors': processingErrors,
        },
      );
    } catch (error) {
      debugPrint('❌ DishProcessingStep: Error during execution: $error');

      return ChatStepResult.failure(
        stepName: stepName,
        error: ChatAgentError(
          type: ChatErrorType.processingError,
          message: 'Failed to process dishes',
          details: error.toString(),
          retryable: true,
        ),
      );
    }
  }

  @override
  Future<ChatStepVerificationResult> verify(
    ChatStepResult result,
    ChatStepInput input,
  ) async {
    if (!result.success) {
      return ChatStepVerificationResult.invalid(
        message: 'Step execution failed',
        error: result.error,
      );
    }

    final validatedDishes =
        result.data!['validatedDishes'] as List<ProcessedDish>;
    final processingErrors = result.data!['processingErrors'] as List<String>;

    final issues = <String>[];
    final suggestions = <String>[];

    // Check for processing errors
    if (processingErrors.isNotEmpty) {
      issues.add('${processingErrors.length} dishes failed to process');
      suggestions.add('Review dish data structure and validation logic');
    }

    // Validate dish integrity
    for (final dish in validatedDishes) {
      if (dish.name.trim().isEmpty) {
        issues.add('Dish has empty name');
        suggestions.add('Ensure all dishes have valid names');
      }
      if (!dish.hasCompleteNutrition) {
        issues.add('Dish "${dish.name}" has incomplete nutrition data');
        suggestions.add('Ensure nutrition calculation accuracy');
      }
      if (dish.totalNutrition.calories < 0 ||
          dish.totalNutrition.calories > 5000) {
        issues.add(
          'Dish "${dish.name}" has invalid calories: ${dish.totalNutrition.calories}',
        );
        suggestions.add('Validate nutritional calculation accuracy');
      }
      if (dish.ingredients.isEmpty) {
        issues.add('Dish "${dish.name}" has no ingredients');
        suggestions.add('Ensure dishes include ingredient lists');
      }
      // Check for reasonable nutrition ratios
      final nutrition = dish.totalNutrition;
      final totalMacros = nutrition.protein + nutrition.carbs + nutrition.fat;
      if (totalMacros > 0) {
        final calculatedCalories =
            (nutrition.protein * 4) +
            (nutrition.carbs * 4) +
            (nutrition.fat * 9);
        final calorieDifference =
            (nutrition.calories - calculatedCalories).abs();
        if (calorieDifference > nutrition.calories * 0.2) {
          issues.add(
            'Dish "${dish.name}" has inconsistent macro/calorie ratio',
          );
          suggestions.add('Review nutritional calculation formulas');
        }
      }
      if (dish.createdAt.isAfter(DateTime.now().add(Duration(minutes: 1)))) {
        issues.add('Dish "${dish.name}" has future creation timestamp');
        suggestions.add('Use current time for dish creation');
      }
    }

    if (issues.isEmpty) {
      return ChatStepVerificationResult.valid();
    } else {
      return ChatStepVerificationResult.invalid(
        message: 'Dish processing verification found issues',
        error: null,
      );
    }
  }

  /// Processes a single dish from AI response data
  Future<ProcessedDish?> _processSingleDish(
    Map<String, dynamic> dishData,
    String? uploadedImageUri,
    List<UserIngredient>? userIngredients,
  ) async {
    try {
      // Handle both AnalyzedDishData format and raw dish data
      if (dishData.containsKey('dishName')) {
        // This is AnalyzedDishData format
        return _processAnalyzedDishData(dishData, uploadedImageUri);
      } else {
        // This is raw dish data format
        return _processRawDishData(dishData, uploadedImageUri, userIngredients);
      }
    } catch (error) {
      debugPrint('❌ Error processing single dish: $error');
      return null;
    }
  }

  /// Processes AnalyzedDishData format
  ProcessedDish? _processAnalyzedDishData(
    Map<String, dynamic> dishData,
    String? uploadedImageUri,
  ) {
    try {
      final analyzedData = AnalyzedDishData.fromJson(dishData);
      return analyzedData.toProcessedDish(imageUrl: uploadedImageUri);
    } catch (error) {
      debugPrint('❌ Error processing analyzed dish data: $error');
      return null;
    }
  }

  /// Processes raw dish data format
  ProcessedDish? _processRawDishData(
    Map<String, dynamic> dishData,
    String? uploadedImageUri,
    List<UserIngredient>? userIngredients,
  ) {
    try {
      final dishName = dishData['name'] as String?;
      if (dishName == null || dishName.trim().isEmpty) {
        debugPrint('❌ New dish missing name');
        return null;
      }

      // Parse ingredients
      final ingredientsData = dishData['ingredients'] as List<dynamic>? ?? [];
      final ingredients = <FoodIngredient>[];

      for (final ingredientData in ingredientsData) {
        final ingredient = _parseIngredient(
          ingredientData as Map<String, dynamic>,
        );
        if (ingredient != null) {
          ingredients.add(ingredient);
        }
      }

      // Parse nutrition
      final nutrition = BasicNutrition(
        calories: _parseDouble(dishData['calories']) ?? 0.0,
        protein: _parseDouble(dishData['protein']) ?? 0.0,
        carbs: _parseDouble(dishData['carbs']) ?? 0.0,
        fat: _parseDouble(dishData['fat']) ?? 0.0,
        fiber: _parseDouble(dishData['fiber']) ?? 0.0,
        sugar: _parseDouble(dishData['sugar']) ?? 0.0,
        sodium: _parseDouble(dishData['sodium']) ?? 0.0,
      );

      // Parse meal type
      MealType? mealType;
      final mealTypeStr = dishData['mealType'] as String?;
      if (mealTypeStr != null) {
        try {
          mealType = MealType.fromString(mealTypeStr);
        } catch (e) {
          debugPrint('⚠️ Invalid meal type: $mealTypeStr');
        }
      }

      // Parse tags
      final tags =
          (dishData['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          <String>[];

      // Create the dish
      final now = DateTime.now();
      final dish = ProcessedDish(
        id: _generateDishId(),
        name: dishName.trim(),
        description: dishData['description'] as String?,
        ingredients: ingredients,
        totalNutrition: nutrition,
        servings: _parseDouble(dishData['servings']) ?? 1.0,
        imageUrl: uploadedImageUri,
        tags: tags,
        mealType: mealType,
        createdAt: now,
        updatedAt: now,
        isFavorite: false,
        preparationTime: dishData['preparationTime'] as String?,
        cookingInstructions:
            dishData['cookingInstructions'] as String? ??
            dishData['preparationMethod'] as String?,
      );

      // Save the dish (if dish service supports ProcessedDish)
      // await _dishService.saveDish(dish);
      debugPrint('✅ Created new dish: ${dish.name}');

      return dish;
    } catch (error) {
      debugPrint('❌ Error processing raw dish data: $error');
      return null;
    }
  }

  /// Parses ingredient data from AI response
  FoodIngredient? _parseIngredient(Map<String, dynamic> ingredientData) {
    try {
      final name = ingredientData['name'] as String?;
      final amount =
          _parseDouble(ingredientData['amount']) ??
          _parseDouble(ingredientData['quantity']);
      final unit = ingredientData['unit'] as String?;

      if (name == null || name.trim().isEmpty) {
        debugPrint('❌ Ingredient missing name');
        return null;
      }

      // Parse nutrition if available
      BasicNutrition? nutrition;
      if (ingredientData.containsKey('nutrition')) {
        nutrition = BasicNutrition.fromJson(
          ingredientData['nutrition'] as Map<String, dynamic>,
        );
      } else if (ingredientData.containsKey('calories')) {
        nutrition = BasicNutrition(
          calories: _parseDouble(ingredientData['calories']) ?? 0.0,
          protein: _parseDouble(ingredientData['protein']) ?? 0.0,
          carbs: _parseDouble(ingredientData['carbs']) ?? 0.0,
          fat: _parseDouble(ingredientData['fat']) ?? 0.0,
        );
      }

      return FoodIngredient(
        id: _generateIngredientId(),
        name: name.trim(),
        amount: amount ?? 1.0,
        unit: unit ?? 'item',
        nutrition: nutrition,
        brand: ingredientData['brand'] as String?,
        barcode: ingredientData['barcode'] as String?,
      );
    } catch (error) {
      debugPrint('❌ Error parsing ingredient: $error');
      return null;
    }
  }

  /// Safely parses a double value from dynamic data
  double? _parseDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  /// Generates a unique dish ID
  String _generateDishId() {
    return 'dish_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (999 * DateTime.now().microsecond / 1000000)).round()}';
  }

  /// Generates a unique ingredient ID
  String _generateIngredientId() {
    return 'ingredient_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (999 * DateTime.now().microsecond / 1000000)).round()}';
  }
}
