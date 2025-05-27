class NutritionAnalysis {
  final String dishName;
  final List<String> ingredients;
  final NutritionInfo nutritionInfo;
  final String? servingSize;
  final String? cookingInstructions;
  final String? mealType;
  final double confidence;

  const NutritionAnalysis({
    required this.dishName,
    required this.ingredients,
    required this.nutritionInfo,
    this.servingSize,
    this.cookingInstructions,
    this.mealType,
    this.confidence = 1.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'dishName': dishName,
      'ingredients': ingredients,
      'nutritionInfo': nutritionInfo.toJson(),
      'servingSize': servingSize,
      'cookingInstructions': cookingInstructions,
      'mealType': mealType,
      'confidence': confidence,
    };
  }

  factory NutritionAnalysis.fromJson(Map<String, dynamic> json) {
    return NutritionAnalysis(
      dishName: json['dishName'] as String,
      ingredients: (json['ingredients'] as List<dynamic>).cast<String>(),
      nutritionInfo: NutritionInfo.fromJson(
        json['nutritionInfo'] as Map<String, dynamic>,
      ),
      servingSize: json['servingSize'] as String?,
      cookingInstructions: json['cookingInstructions'] as String?,
      mealType: json['mealType'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
    );
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

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0.0,
      sugar: (json['sugar'] as num?)?.toDouble() ?? 0.0,
      sodium: (json['sodium'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
