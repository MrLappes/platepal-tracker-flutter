class Dish {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final List<Ingredient> ingredients;
  final NutritionInfo nutrition;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  final String? category;

  const Dish({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.ingredients,
    required this.nutrition,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.category,
  });
  factory Dish.fromJson(Map<String, dynamic> json) {
    // Handle nutrition data - can be nested object or direct fields
    NutritionInfo nutrition;
    if (json['nutrition'] != null &&
        json['nutrition'] is Map<String, dynamic>) {
      nutrition = NutritionInfo.fromJson(
        json['nutrition'] as Map<String, dynamic>,
      );
    } else {
      // Handle direct nutrition fields in dish object
      nutrition = NutritionInfo(
        calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
        protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
        carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
        fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
        fiber: (json['fiber'] as num?)?.toDouble() ?? 0.0,
        sugar: (json['sugar'] as num?)?.toDouble() ?? 0.0,
        sodium: (json['sodium'] as num?)?.toDouble() ?? 0.0,
      );
    }

    return Dish(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String? ?? json['imageUri'] as String?,
      ingredients:
          (json['ingredients'] as List<dynamic>)
              .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
              .toList(),
      nutrition: nutrition,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'nutrition': nutrition.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFavorite': isFavorite,
      'category': category,
    };
  }

  Dish copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    List<Ingredient>? ingredients,
    NutritionInfo? nutrition,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    String? category,
  }) {
    return Dish(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      nutrition: nutrition ?? this.nutrition,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
    );
  }
}

class Ingredient {
  final String id;
  final String name;
  final double amount;
  final String unit;
  final NutritionInfo? nutrition;
  final String? barcode;

  const Ingredient({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
    this.nutrition,
    this.barcode,
  });
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String,
      nutrition:
          json['nutrition'] != null
              ? NutritionInfo.fromJson(
                json['nutrition'] as Map<String, dynamic>,
              )
              : null,
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
      'barcode': barcode,
    };
  }
}

class NutritionInfo {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;

  const NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0.0,
    this.sugar = 0.0,
    this.sodium = 0.0,
  });
  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
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
}

class DishLog {
  final String id;
  final String dishId;
  final Dish? dish;
  final DateTime loggedAt;
  final String mealType;
  final double servingSize;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;

  const DishLog({
    required this.id,
    required this.dishId,
    this.dish,
    required this.loggedAt,
    required this.mealType,
    required this.servingSize,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0.0,
  });
  factory DishLog.fromJson(Map<String, dynamic> json) {
    return DishLog(
      id: json['id']?.toString() ?? '',
      dishId:
          json['dishId'] != null
              ? json['dishId'].toString()
              : json['dish_id'].toString(),
      dish:
          json['dish'] != null
              ? Dish.fromJson(json['dish'] as Map<String, dynamic>)
              : null,
      loggedAt: DateTime.parse(json['loggedAt'] ?? json['logged_at'] as String),
      mealType: json['mealType'] ?? json['meal_type'] as String,
      servingSize:
          (json['servingSize'] ?? json['serving_size'] as num?)?.toDouble() ??
          1.0,
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dishId': dishId,
      'dish': dish?.toJson(),
      'loggedAt': loggedAt.toIso8601String(),
      'mealType': mealType,
      'servingSize': servingSize,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
    };
  }

  DishLog copyWith({
    String? id,
    String? dishId,
    Dish? dish,
    DateTime? loggedAt,
    String? mealType,
    double? servingSize,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
  }) {
    return DishLog(
      id: id ?? this.id,
      dishId: dishId ?? this.dishId,
      dish: dish ?? this.dish,
      loggedAt: loggedAt ?? this.loggedAt,
      mealType: mealType ?? this.mealType,
      servingSize: servingSize ?? this.servingSize,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
    );
  }
}

class DailyMacroSummary {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;

  const DailyMacroSummary({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
  });
  factory DailyMacroSummary.fromJson(Map<String, dynamic> json) {
    return DailyMacroSummary(
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
    };
  }
}
