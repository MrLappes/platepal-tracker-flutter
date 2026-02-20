import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../models/chat_types.dart';
import '../../../models/dish_models.dart';
import '../../../models/meal_type.dart';
import '../../../models/user_ingredient.dart';
import '../../../repositories/dish_repository.dart';
import '../../../services/storage/dish_service.dart';

const _uuid = Uuid();

/// Processes and validates dishes from AI responses using new dish models
class DishProcessingStep extends AgentStep {
  // ignore: unused_field
  final DishRepository? _dishRepository;
  // ignore: unused_field
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
      final dishesData = input.metadata?['dishes'] as List<dynamic>? ?? [];
      final uploadedImageUri = input.metadata?['uploadedImageUri'] as String?;

      // Extract user-provided ingredients (may be passed as typed objects or maps)
      List<UserIngredient>? userIngredients;
      try {
        if (input.userIngredients != null &&
            input.userIngredients!.isNotEmpty) {
          userIngredients = input.userIngredients;
        } else {
          final raw = input.metadata?['userIngredients'] as List<dynamic>?;
          if (raw != null) {
            userIngredients = [];
            for (final item in raw) {
              try {
                if (item is UserIngredient) {
                  userIngredients.add(item);
                } else if (item is Map<String, dynamic>) {
                  userIngredients.add(
                    UserIngredient.fromJson(Map<String, dynamic>.from(item)),
                  );
                } else if (item is String) {
                  // Create a minimal UserIngredient when only name string is provided
                  userIngredients.add(
                    UserIngredient(
                      id: _generateIngredientId(),
                      name: item,
                      quantity: 0.0,
                      unit: 'g',
                    ),
                  );
                }
              } catch (e) {
                debugPrint('⚠️ Could not parse user ingredient: $e');
              }
            }
            if (userIngredients.isEmpty) userIngredients = null;
          }
        }
      } catch (e) {
        debugPrint('⚠️ Error extracting user ingredients: $e');
        userIngredients = null;
      }

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

          // If the AI referenced an existing DB dish by id (or minimal record),
          // attempt to load the full dish from the local DishService so we can
          // present complete details (ingredients, nutrition, image, etc.).
          ProcessedDish? processedDish;
          try {
            processedDish = await _tryLoadDishFromDatabaseReference(
              dishData,
              uploadedImageUri,
              userIngredients,
            );
          } catch (e) {
            debugPrint('⚠️ Error loading referenced DB dish: $e');
          }

          processedDish ??= await _processSingleDish(
            dishData,
            uploadedImageUri,
            userIngredients,
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
        return await _processAnalyzedDishData(
          dishData,
          uploadedImageUri,
          userIngredients,
        );
      } else {
        return await _processRawDishData(
          dishData,
          uploadedImageUri,
          userIngredients,
        );
      }
    } catch (error) {
      debugPrint('❌ Error processing single dish: $error');
      return null;
    }
  }

  /// Processes AnalyzedDishData format
  Future<ProcessedDish?> _processAnalyzedDishData(
    Map<String, dynamic> dishData,
    String? uploadedImageUri,
    List<UserIngredient>? userIngredients,
  ) async {
    try {
      final analyzedData = AnalyzedDishData.fromJson(dishData);

      // Calculate nutrition from ingredients instead of using estimated nutrition
      // Build ingredient list from analyzed data
      final ingredients = <FoodIngredient>[];
      for (final ing in analyzedData.ingredients) {
        final parsed = _parseIngredient(ing.toJson());
        if (parsed != null) ingredients.add(parsed);
      }

      // If user provided ingredients, merge them to ensure user input takes precedence
      final mergedIngredients =
          userIngredients != null && userIngredients.isNotEmpty
              ? _mergeUserIngredientsIntoIngredients(
                ingredients,
                userIngredients,
              )
              : ingredients;

      final calculatedNutrition = _calculateNutritionFromIngredients(
        mergedIngredients,
      );

      final now = DateTime.now();

      // Determine final dish id: accept only DB-backed ids, otherwise generate new
      final resolvedId = await _resolveDishId(dishData);

      return ProcessedDish(
        id: resolvedId,
        name: analyzedData.dishName,
        description: analyzedData.description,
        ingredients: mergedIngredients,
        totalNutrition: calculatedNutrition, // Use calculated nutrition
        servings: analyzedData.estimatedServings,
        imageUrl: uploadedImageUri,
        tags: analyzedData.detectedTags,
        mealType: analyzedData.suggestedMealType,
        createdAt: now,
        updatedAt: now,
        isFavorite: false,
        cookingInstructions: analyzedData.preparationMethod,
      );
    } catch (error) {
      debugPrint('❌ Error processing analyzed dish data: $error');
      return null;
    }
  }

  /// Processes raw dish data format
  Future<ProcessedDish?> _processRawDishData(
    Map<String, dynamic> dishData,
    String? uploadedImageUri,
    List<UserIngredient>? userIngredients,
  ) async {
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

      // Calculate nutrition from ingredients instead of using AI provided values
      // Merge/replace with user-provided ingredients if present
      final mergedIngredients =
          userIngredients != null && userIngredients.isNotEmpty
              ? _mergeUserIngredientsIntoIngredients(
                ingredients,
                userIngredients,
              )
              : ingredients;

      final nutrition = _calculateNutritionFromIngredients(mergedIngredients);

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

      // Determine final dish id: accept only DB-backed ids, otherwise generate new
      final resolvedId = await _resolveDishId(dishData);

      final dish = ProcessedDish(
        id: resolvedId,
        name: dishName.trim(),
        description: dishData['description'] as String?,
        ingredients: mergedIngredients,
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

  /// Resolve dish id policy: accept DB ids only; if AI requested 'random' or
  /// provided an unknown id, generate a new unpredictable id on the system side.
  Future<String> _resolveDishId(Map<String, dynamic> dishData) async {
    try {
      final rawId = dishData['id']?.toString();
      // If AI explicitly asked for a random/new id or didn't provide one, generate
      if (rawId == null || rawId.toLowerCase() == 'random') {
        return _generateDishId();
      }

      // If an id was provided, only accept it if it maps to an existing DB dish
      final ds = _dishService;
      if (ds != null) {
        try {
          final storageDish = await ds.getDishById(rawId);
          if (storageDish != null) {
            return storageDish.id;
          }
        } catch (_) {
          // ignore and fall back to generated id
        }
      }

      // Fallback: don't trust AI-created ids — generate a new one
      return _generateDishId();
    } catch (e) {
      debugPrint('⚠️ _resolveDishId failed: $e');
      return _generateDishId();
    }
  }

  /// Merge user-provided ingredients into parsed ingredients list.
  /// User ingredients take precedence: existing AI-derived ingredients with the same
  /// name (case-insensitive) are replaced, and any additional user ingredients are appended.
  List<FoodIngredient> _mergeUserIngredientsIntoIngredients(
    List<FoodIngredient> parsedIngredients,
    List<UserIngredient> userIngredients,
  ) {
    final merged = <FoodIngredient>[];

    // Map existing ingredients by lowercased name for quick lookup
    final existingByName = <String, FoodIngredient>{};
    for (final ing in parsedIngredients) {
      existingByName[ing.name.toLowerCase()] = ing;
    }

    // First, add/replace with user ingredients
    for (final ui in userIngredients) {
      final name = ui.name.trim();
      final key = name.toLowerCase();

      // Build a FoodIngredient from UserIngredient (preserve exact name and any provided quantity/unit)
      BasicNutrition? nutritionFromMetadata;
      try {
        final meta = ui.metadata;
        if (meta != null && meta['nutrition'] is Map<String, dynamic>) {
          nutritionFromMetadata = BasicNutrition.fromJson(
            Map<String, dynamic>.from(meta['nutrition'] as Map),
          );
        }
      } catch (_) {
        nutritionFromMetadata = null;
      }

      final userFood = FoodIngredient(
        id: ui.id,
        name: ui.name,
        amount: ui.quantity,
        unit: ui.unit,
        nutrition: nutritionFromMetadata,
      );

      merged.add(userFood);
      // Remove from existing map so we don't duplicate
      existingByName.remove(key);
    }

    // Then add any remaining AI-derived ingredients that the user didn't override
    for (final remaining in existingByName.values) {
      merged.add(remaining);
    }

    return merged;
  }

  /// Parses ingredient data from AI response
  /// Note: Ingredients store per-100g nutrition values, not calculated amounts
  FoodIngredient? _parseIngredient(Map<String, dynamic> ingredientData) {
    try {
      final name = ingredientData['name'] as String?;
      // Accept multiple possible keys for the amount (quantity, amount, qty, count, servingSize, weight)
      double? amount =
          _parseDouble(ingredientData['quantity']) ??
          _parseDouble(ingredientData['amount']) ??
          _parseDouble(ingredientData['qty']) ??
          _parseDouble(ingredientData['count']) ??
          _parseDouble(ingredientData['servingSize']) ??
          _parseDouble(ingredientData['weight']);
      String? unit = (ingredientData['unit'] as String?)?.trim();

      // If unit is missing but quantity is a string like '2 cups', try to extract unit
      if ((unit == null || unit.isEmpty) &&
          ingredientData['quantity'] is String) {
        final qStr = (ingredientData['quantity'] as String).trim();
        final unitMatch = RegExp(
          r'[-+]?\d*[\.,]?\d+\s*([a-zA-Z%]+)',
        ).firstMatch(qStr);
        if (unitMatch != null) {
          unit = unitMatch.group(1)!.toLowerCase();
        }
      }

      if (name == null || name.trim().isEmpty) {
        debugPrint('❌ Ingredient missing name');
        return null;
      }

      // Parse nutrition if available
      BasicNutrition? nutrition;

      // Handle existing nutrition object format
      if (ingredientData.containsKey('nutrition')) {
        nutrition = BasicNutrition.fromJson(
          ingredientData['nutrition'] as Map<String, dynamic>,
        );
      } // Handle per-100g nutrition format from AI (this is the main format we expect)
      else if (ingredientData.containsKey('caloriesPer100') ||
          ingredientData.containsKey('proteinPer100') ||
          ingredientData.containsKey('carbsPer100') ||
          ingredientData.containsKey('fatPer100')) {
        // Store per-100g nutrition values directly without calculating for the amount
        final per100Calories =
            _parseDouble(ingredientData['caloriesPer100']) ?? 0.0;
        final per100Protein =
            _parseDouble(ingredientData['proteinPer100']) ?? 0.0;
        final per100Carbs = _parseDouble(ingredientData['carbsPer100']) ?? 0.0;
        final per100Fat = _parseDouble(ingredientData['fatPer100']) ?? 0.0;
        final per100Fiber = _parseDouble(ingredientData['fiberPer100']) ?? 0.0;
        final per100Sugar = _parseDouble(ingredientData['sugarPer100']) ?? 0.0;
        final per100Sodium =
            _parseDouble(ingredientData['sodiumPer100']) ?? 0.0;

        // Store the per-100g values directly
        nutrition = BasicNutrition(
          calories: per100Calories,
          protein: per100Protein,
          carbs: per100Carbs,
          fat: per100Fat,
          fiber: per100Fiber,
          sugar: per100Sugar,
          sodium: per100Sodium,
        );
      }
      // Handle direct nutrition values (fallback)
      else if (ingredientData.containsKey('calories')) {
        nutrition = BasicNutrition(
          calories: _parseDouble(ingredientData['calories']) ?? 0.0,
          protein: _parseDouble(ingredientData['protein']) ?? 0.0,
          carbs: _parseDouble(ingredientData['carbs']) ?? 0.0,
          fat: _parseDouble(ingredientData['fat']) ?? 0.0,
          fiber: _parseDouble(ingredientData['fiber']) ?? 0.0,
          sugar: _parseDouble(ingredientData['sugar']) ?? 0.0,
          sodium: _parseDouble(ingredientData['sodium']) ?? 0.0,
        );
      }

      // If amount is missing but an explicit inGrams value is provided, use that as grams
      final inGramsExplicit =
          ingredientData['inGrams'] ??
          ingredientData['in_grams'] ??
          ingredientData['grams'];
      final amountFinal = amount ?? (_parseDouble(inGramsExplicit) ?? 1.0);

      return FoodIngredient(
        id: _generateIngredientId(),
        name: name.trim(),
        amount: amountFinal,
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
      final s = value.trim();
      if (s.isEmpty) return null;

      // Handle simple fractions like '1/2'
      final fracMatch = RegExp(r'^(\d+)\s*/\s*(\d+) ?').firstMatch(s);
      if (fracMatch != null) {
        try {
          final n = double.parse(fracMatch.group(1)!);
          final d = double.parse(fracMatch.group(2)!);
          if (d != 0) return n / d;
        } catch (_) {}
      }

      // Find the first numeric substring (handles '2', '2.5', '1,000.5', '100g')
      final numMatch = RegExp(
        r'[-+]?\d{1,3}(?:[.,]\d{3})*(?:[.,]\d+)?|[-+]?\d*\.?\d+',
      ).firstMatch(s);
      if (numMatch != null) {
        var numStr = numMatch.group(0)!.replaceAll(',', '.');
        try {
          return double.parse(numStr);
        } catch (_) {
          try {
            // Last resort: remove non-digit chars and parse
            final cleaned = numStr.replaceAll(RegExp(r'[^0-9\.]'), '');
            return double.parse(cleaned);
          } catch (_) {}
        }
      }

      return null;
    }

    return null;
  }

  /// Generates a unique dish ID using UUID v4 (no timestamp collisions).
  String _generateDishId() => _uuid.v4();

  /// Generates a unique ingredient ID using UUID v4 (no timestamp collisions).
  String _generateIngredientId() => _uuid.v4();

  /// Calculates total nutrition from all ingredients
  /// Ingredients store per-100g nutrition values, this method calculates actual totals
  BasicNutrition _calculateNutritionFromIngredients(
    List<FoodIngredient> ingredients,
  ) {
    double totalCalories = 0.0;
    double totalProtein = 0.0;
    double totalCarbs = 0.0;
    double totalFat = 0.0;
    double totalFiber = 0.0;
    double totalSugar = 0.0;
    double totalSodium = 0.0;
    for (final ingredient in ingredients) {
      if (ingredient.nutrition != null) {
        // Get the ingredient amount in grams for calculation
        final amountInGrams = _getAmountInGrams(
          ingredient.amount,
          ingredient.unit,
          null, // No explicit inGrams value from ingredient object
        );

        // Calculate nutrition based on per-100g values stored in ingredient
        final multiplier = amountInGrams / 100.0;

        totalCalories += ingredient.nutrition!.calories * multiplier;
        totalProtein += ingredient.nutrition!.protein * multiplier;
        totalCarbs += ingredient.nutrition!.carbs * multiplier;
        totalFat += ingredient.nutrition!.fat * multiplier;
        totalFiber += ingredient.nutrition!.fiber * multiplier;
        totalSugar += ingredient.nutrition!.sugar * multiplier;
        totalSodium += ingredient.nutrition!.sodium * multiplier;
      }
    }
    debugPrint(
      '📊 Calculated nutrition from ${ingredients.length} ingredients (per-100g values multiplied by amounts):',
    );
    debugPrint('   Calories: ${totalCalories.toStringAsFixed(1)}');
    debugPrint('   Protein: ${totalProtein.toStringAsFixed(1)}g');
    debugPrint('   Carbs: ${totalCarbs.toStringAsFixed(1)}g');
    debugPrint('   Fat: ${totalFat.toStringAsFixed(1)}g');

    return BasicNutrition(
      calories: totalCalories,
      protein: totalProtein,
      carbs: totalCarbs,
      fat: totalFat,
      fiber: totalFiber,
      sugar: totalSugar,
      sodium: totalSodium,
    );
  }

  /// Converts ingredient amount to grams for nutrition calculation
  double _getAmountInGrams(double amount, String unit, dynamic inGramsValue) {
    // If inGrams is explicitly provided, use it
    if (inGramsValue != null) {
      final inGrams = _parseDouble(inGramsValue);
      if (inGrams != null && inGrams > 0) {
        return inGrams;
      }
    }

    // Convert common units to grams
    switch (unit.toLowerCase()) {
      case 'g':
      case 'gram':
      case 'grams':
        return amount;
      case 'kg':
      case 'kilogram':
      case 'kilograms':
        return amount * 1000;
      case 'ml':
      case 'milliliter':
      case 'milliliters':
        // Assume density of water (1ml = 1g) for liquids
        return amount;
      case 'l':
      case 'liter':
      case 'liters':
        return amount * 1000;
      case 'oz':
      case 'ounce':
      case 'ounces':
        return amount * 28.35; // 1 oz ≈ 28.35g
      case 'lb':
      case 'pound':
      case 'pounds':
        return amount * 453.592; // 1 lb ≈ 453.592g
      case 'cup':
      case 'cups':
        return amount *
            240; // 1 cup ≈ 240g (varies by ingredient, but good average)
      case 'tbsp':
      case 'tablespoon':
      case 'tablespoons':
        return amount * 15; // 1 tbsp ≈ 15g
      case 'tsp':
      case 'teaspoon':
      case 'teaspoons':
        return amount * 5; // 1 tsp ≈ 5g
      case 'piece':
      case 'pieces':
      case 'item':
      case 'items':
        // For pieces, assume a reasonable weight (this is imprecise but better than nothing)
        return amount * 100; // Assume 100g per piece as default
      default:
        // Unknown unit, assume grams
        debugPrint('⚠️ Unknown unit "$unit", assuming grams');
        return amount;
    }
  }

  /// Attempts to load a dish from the database when the AI explicitly provided
  /// a known database ID (via [referenceExistingDishTool]).
  ///
  /// IMPORTANT: This method NO LONGER falls back to name-matching. A DB lookup
  /// is triggered only when the dish data contains an explicit, non-"random" id
  /// that was verified to come from a `reference_existing_dish` tool call.
  /// Removing name-based matching is the fix for Bug 1: a new dish with the
  /// same name as an existing dish was silently replaced by the old record.
  Future<ProcessedDish?> _tryLoadDishFromDatabaseReference(
    Map<String, dynamic> dishData,
    String? uploadedImageUri,
    List<UserIngredient>? userIngredients,
  ) async {
    try {
      // Only look at explicit id fields — never infer from name.
      final rawId =
          dishData['id']?.toString() ??
          dishData['dishId']?.toString() ??
          dishData['dbId']?.toString() ??
          dishData['db_id']?.toString();

      // If no id — or AI requested a random/new placeholder — this is not a
      // DB reference. Return null so the caller creates a fresh dish.
      if (rawId == null || rawId.isEmpty || rawId.toLowerCase() == 'random') {
        debugPrint(
          '🔍 _tryLoadDishFromDatabaseReference: No explicit id found, skipping DB lookup.',
        );
        return null;
      }

      final ds = _dishService ?? DishService();
      final storageDish = await ds.getDishById(rawId);

      if (storageDish == null) {
        debugPrint(
          '🔍 _tryLoadDishFromDatabaseReference: id "$rawId" not found in DB. '
          'Treating as new dish (no name-fallback).',
        );
        return null;
      }

      debugPrint(
        '🔍 _tryLoadDishFromDatabaseReference: Loaded DB dish: ${storageDish.name} (${storageDish.id})',
      );

      // Convert storage Ingredient → FoodIngredient
      final convertedIngredients = <FoodIngredient>[];
      for (final ing in storageDish.ingredients) {
        final nut = ing.nutrition;
        BasicNutrition? convertedNut;
        if (nut != null) {
          convertedNut = BasicNutrition(
            calories: nut.calories,
            protein: nut.protein,
            carbs: nut.carbs,
            fat: nut.fat,
            fiber: nut.fiber,
            sugar: nut.sugar,
            sodium: nut.sodium,
          );
        }
        convertedIngredients.add(
          FoodIngredient(
            id: ing.id,
            name: ing.name,
            amount: ing.amount,
            unit: ing.unit,
            nutrition: convertedNut,
            brand: null,
            barcode: ing.barcode,
          ),
        );
      }

      // Merge user-provided ingredients if present
      final finalIngredients =
          userIngredients != null && userIngredients.isNotEmpty
              ? _mergeUserIngredientsIntoIngredients(
                convertedIngredients,
                userIngredients,
              )
              : convertedIngredients;

      final recalculatedNutrition = _calculateNutritionFromIngredients(
        finalIngredients,
      );

      BasicNutrition convertedDishNut;
      if (finalIngredients.isEmpty && storageDish.nutrition.calories > 0) {
        final sn = storageDish.nutrition;
        convertedDishNut = BasicNutrition(
          calories: sn.calories,
          protein: sn.protein,
          carbs: sn.carbs,
          fat: sn.fat,
          fiber: sn.fiber,
          sugar: sn.sugar,
          sodium: sn.sodium,
        );
      } else {
        convertedDishNut = recalculatedNutrition;
      }

      return ProcessedDish(
        id: storageDish.id,
        name: storageDish.name,
        description: storageDish.description,
        ingredients: finalIngredients,
        totalNutrition: convertedDishNut,
        servings: 1.0,
        imageUrl: storageDish.imageUrl ?? uploadedImageUri,
        tags: const <String>[],
        mealType: null,
        createdAt: storageDish.createdAt,
        updatedAt: storageDish.updatedAt,
        isFavorite: storageDish.isFavorite,
      );
    } catch (e) {
      debugPrint('⚠️ _tryLoadDishFromDatabaseReference failed: $e');
      return null;
    }
  }
}
