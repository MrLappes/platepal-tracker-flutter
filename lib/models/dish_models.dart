import 'meal_type.dart';

/// Core nutrition information without micronutrients
class BasicNutrition {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;

  const BasicNutrition({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0.0,
    this.sugar = 0.0,
    this.sodium = 0.0,
  });

  factory BasicNutrition.empty() {
    return const BasicNutrition(
      calories: 0.0,
      protein: 0.0,
      carbs: 0.0,
      fat: 0.0,
      fiber: 0.0,
      sugar: 0.0,
      sodium: 0.0,
    );
  }

  factory BasicNutrition.fromJson(Map<String, dynamic> json) {
    return BasicNutrition(
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0.0,
      sugar: (json['sugar'] as num?)?.toDouble() ?? 0.0,
      sodium: (json['sodium'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
    };
  }

  BasicNutrition copyWith({
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    double? sugar,
    double? sodium,
  }) {
    return BasicNutrition(
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      sodium: sodium ?? this.sodium,
    );
  }

  /// Add two nutrition objects together
  BasicNutrition operator +(BasicNutrition other) {
    return BasicNutrition(
      calories: calories + other.calories,
      protein: protein + other.protein,
      carbs: carbs + other.carbs,
      fat: fat + other.fat,
      fiber: fiber + other.fiber,
      sugar: sugar + other.sugar,
      sodium: sodium + other.sodium,
    );
  }

  /// Scale nutrition by a factor
  BasicNutrition operator *(double factor) {
    return BasicNutrition(
      calories: calories * factor,
      protein: protein * factor,
      carbs: carbs * factor,
      fat: fat * factor,
      fiber: fiber * factor,
      sugar: sugar * factor,
      sodium: sodium * factor,
    );
  }
}

/// Represents a food ingredient
class FoodIngredient {
  final String id;
  final String name;
  final double amount;
  final String unit;
  final BasicNutrition? nutrition;
  final String? brand;
  final String? barcode;

  const FoodIngredient({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
    this.nutrition,
    this.brand,
    this.barcode,
  });

  factory FoodIngredient.fromJson(Map<String, dynamic> json) {
    return FoodIngredient(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      unit: json['unit'] as String,
      nutrition:
          json['nutrition'] != null
              ? BasicNutrition.fromJson(
                json['nutrition'] as Map<String, dynamic>,
              )
              : null,
      brand: json['brand'] as String?,
      barcode: json['barcode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'unit': unit,
      'nutrition': nutrition?.toJson(),
      'brand': brand,
      'barcode': barcode,
    };
  }

  FoodIngredient copyWith({
    String? id,
    String? name,
    double? amount,
    String? unit,
    BasicNutrition? nutrition,
    String? brand,
    String? barcode,
  }) {
    return FoodIngredient(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      nutrition: nutrition ?? this.nutrition,
      brand: brand ?? this.brand,
      barcode: barcode ?? this.barcode,
    );
  }
}

/// Represents a complete dish or meal
class ProcessedDish {
  final String id;
  final String name;
  final String? description;
  final List<FoodIngredient> ingredients;
  final BasicNutrition totalNutrition;
  final double servings;
  final String? imageUrl;
  final List<String> tags;
  final MealType? mealType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  final String? preparationTime;
  final String? cookingInstructions;

  const ProcessedDish({
    required this.id,
    required this.name,
    this.description,
    required this.ingredients,
    required this.totalNutrition,
    this.servings = 1.0,
    this.imageUrl,
    this.tags = const [],
    this.mealType,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.preparationTime,
    this.cookingInstructions,
  });

  factory ProcessedDish.fromJson(Map<String, dynamic> json) {
    return ProcessedDish(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      ingredients:
          (json['ingredients'] as List<dynamic>)
              .map((e) => FoodIngredient.fromJson(e as Map<String, dynamic>))
              .toList(),
      totalNutrition: BasicNutrition.fromJson(
        json['totalNutrition'] as Map<String, dynamic>,
      ),
      servings: (json['servings'] as num?)?.toDouble() ?? 1.0,
      imageUrl: json['imageUrl'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      mealType:
          json['mealType'] != null
              ? MealType.fromString(json['mealType'] as String)
              : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
      preparationTime: json['preparationTime'] as String?,
      cookingInstructions: json['cookingInstructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'totalNutrition': totalNutrition.toJson(),
      'servings': servings,
      'imageUrl': imageUrl,
      'tags': tags,
      'mealType': mealType?.toJsonValue(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFavorite': isFavorite,
      'preparationTime': preparationTime,
      'cookingInstructions': cookingInstructions,
    };
  }

  ProcessedDish copyWith({
    String? id,
    String? name,
    String? description,
    List<FoodIngredient>? ingredients,
    BasicNutrition? totalNutrition,
    double? servings,
    String? imageUrl,
    List<String>? tags,
    MealType? mealType,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    String? preparationTime,
    String? cookingInstructions,
  }) {
    return ProcessedDish(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      totalNutrition: totalNutrition ?? this.totalNutrition,
      servings: servings ?? this.servings,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      mealType: mealType ?? this.mealType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      preparationTime: preparationTime ?? this.preparationTime,
      cookingInstructions: cookingInstructions ?? this.cookingInstructions,
    );
  }

  /// Calculate nutrition per serving
  BasicNutrition get nutritionPerServing {
    if (servings <= 0) return totalNutrition;
    return totalNutrition * (1.0 / servings);
  }

  /// Check if dish has all required nutrition info
  bool get hasCompleteNutrition {
    return totalNutrition.calories > 0 &&
        totalNutrition.protein >= 0 &&
        totalNutrition.carbs >= 0 &&
        totalNutrition.fat >= 0;
  }
}

/// Represents a meal entry in the meal log
class MealEntry {
  final String id;
  final ProcessedDish dish;
  final double servingsConsumed;
  final MealType mealType;
  final DateTime consumedAt;
  final String? notes;
  final String userId;

  const MealEntry({
    required this.id,
    required this.dish,
    required this.servingsConsumed,
    required this.mealType,
    required this.consumedAt,
    this.notes,
    required this.userId,
  });

  factory MealEntry.fromJson(Map<String, dynamic> json) {
    return MealEntry(
      id: json['id'] as String,
      dish: ProcessedDish.fromJson(json['dish'] as Map<String, dynamic>),
      servingsConsumed: (json['servingsConsumed'] as num).toDouble(),
      mealType: MealType.fromString(json['mealType'] as String),
      consumedAt: DateTime.parse(json['consumedAt'] as String),
      notes: json['notes'] as String?,
      userId: json['userId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dish': dish.toJson(),
      'servingsConsumed': servingsConsumed,
      'mealType': mealType.toJsonValue(),
      'consumedAt': consumedAt.toIso8601String(),
      'notes': notes,
      'userId': userId,
    };
  }

  MealEntry copyWith({
    String? id,
    ProcessedDish? dish,
    double? servingsConsumed,
    MealType? mealType,
    DateTime? consumedAt,
    String? notes,
    String? userId,
  }) {
    return MealEntry(
      id: id ?? this.id,
      dish: dish ?? this.dish,
      servingsConsumed: servingsConsumed ?? this.servingsConsumed,
      mealType: mealType ?? this.mealType,
      consumedAt: consumedAt ?? this.consumedAt,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
    );
  }

  /// Calculate actual nutrition consumed based on servings
  BasicNutrition get actualNutritionConsumed {
    return dish.nutritionPerServing * servingsConsumed;
  }
}

/// Represents analyzed dish data from AI processing
class AnalyzedDishData {
  final String dishName;
  final String? description;
  final List<FoodIngredient> ingredients;
  final BasicNutrition estimatedNutrition;
  final double estimatedServings;
  final List<String> detectedTags;
  final MealType? suggestedMealType;
  final double confidenceScore;
  final String? preparationMethod;

  const AnalyzedDishData({
    required this.dishName,
    this.description,
    required this.ingredients,
    required this.estimatedNutrition,
    this.estimatedServings = 1.0,
    this.detectedTags = const [],
    this.suggestedMealType,
    this.confidenceScore = 1.0,
    this.preparationMethod,
  });

  factory AnalyzedDishData.fromJson(Map<String, dynamic> json) {
    return AnalyzedDishData(
      dishName: json['dishName'] as String,
      description: json['description'] as String?,
      ingredients:
          (json['ingredients'] as List<dynamic>)
              .map((e) => FoodIngredient.fromJson(e as Map<String, dynamic>))
              .toList(),
      estimatedNutrition: BasicNutrition.fromJson(
        json['estimatedNutrition'] as Map<String, dynamic>,
      ),
      estimatedServings: (json['estimatedServings'] as num?)?.toDouble() ?? 1.0,
      detectedTags:
          (json['detectedTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      suggestedMealType:
          json['suggestedMealType'] != null
              ? MealType.fromString(json['suggestedMealType'] as String)
              : null,
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 1.0,
      preparationMethod: json['preparationMethod'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dishName': dishName,
      'description': description,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'estimatedNutrition': estimatedNutrition.toJson(),
      'estimatedServings': estimatedServings,
      'detectedTags': detectedTags,
      'suggestedMealType': suggestedMealType?.toJsonValue(),
      'confidenceScore': confidenceScore,
      'preparationMethod': preparationMethod,
    };
  }

  /// Convert analyzed data to a processed dish
  ProcessedDish toProcessedDish({
    String? id,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return ProcessedDish(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: dishName,
      description: description,
      ingredients: ingredients,
      totalNutrition: estimatedNutrition,
      servings: estimatedServings,
      imageUrl: imageUrl,
      tags: detectedTags,
      mealType: suggestedMealType,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      isFavorite: false,
      cookingInstructions: preparationMethod,
    );
  }
}
