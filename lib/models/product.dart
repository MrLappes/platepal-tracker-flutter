class Product {
  final String? barcode;
  final String? name;
  final String? brand;
  final String? imageUrl;
  final String? quantity;
  final ProductNutrition? nutrition;
  final Map<String, dynamic>? rawData;

  const Product({
    this.barcode,
    this.name,
    this.brand,
    this.imageUrl,
    this.quantity,
    this.nutrition,
    this.rawData,
  });

  factory Product.fromOpenFoodFacts(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    if (product == null) {
      throw Exception('Invalid product data');
    }

    return Product(
      barcode: product['code'] as String?,
      name:
          product['product_name'] as String? ??
          product['product_name_en'] as String?,
      brand: product['brands'] as String?,
      imageUrl:
          product['image_url'] as String? ??
          product['image_front_url'] as String?,
      quantity: product['quantity'] as String?,
      nutrition: ProductNutrition.fromOpenFoodFacts(product),
      rawData: product,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'name': name,
      'brand': brand,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'nutrition': nutrition?.toJson(),
      'rawData': rawData,
    };
  }

  bool get hasNutrition => nutrition != null && nutrition!.hasAnyNutrition;

  bool get isValid => name != null && name!.isNotEmpty;
}

class ProductNutrition {
  final double? energyKcal100g;
  final double? proteins100g;
  final double? carbohydrates100g;
  final double? fat100g;
  final double? fiber100g;
  final double? sugars100g;
  final double? sodium100g;
  final double? salt100g;

  const ProductNutrition({
    this.energyKcal100g,
    this.proteins100g,
    this.carbohydrates100g,
    this.fat100g,
    this.fiber100g,
    this.sugars100g,
    this.sodium100g,
    this.salt100g,
  });

  factory ProductNutrition.fromOpenFoodFacts(Map<String, dynamic> product) {
    final nutriments = product['nutriments'] as Map<String, dynamic>?;
    if (nutriments == null) {
      return const ProductNutrition();
    }

    return ProductNutrition(
      energyKcal100g: _parseNutrient(nutriments['energy-kcal_100g']),
      proteins100g: _parseNutrient(nutriments['proteins_100g']),
      carbohydrates100g: _parseNutrient(nutriments['carbohydrates_100g']),
      fat100g: _parseNutrient(nutriments['fat_100g']),
      fiber100g: _parseNutrient(nutriments['fiber_100g']),
      sugars100g: _parseNutrient(nutriments['sugars_100g']),
      sodium100g: _parseNutrient(nutriments['sodium_100g']),
      salt100g: _parseNutrient(nutriments['salt_100g']),
    );
  }

  static double? _parseNutrient(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'energyKcal100g': energyKcal100g,
      'proteins100g': proteins100g,
      'carbohydrates100g': carbohydrates100g,
      'fat100g': fat100g,
      'fiber100g': fiber100g,
      'sugars100g': sugars100g,
      'sodium100g': sodium100g,
      'salt100g': salt100g,
    };
  }

  bool get hasAnyNutrition {
    return energyKcal100g != null ||
        proteins100g != null ||
        carbohydrates100g != null ||
        fat100g != null ||
        fiber100g != null ||
        sugars100g != null ||
        sodium100g != null ||
        salt100g != null;
  }

  double get calories => energyKcal100g ?? 0.0;
  double get protein => proteins100g ?? 0.0;
  double get carbs => carbohydrates100g ?? 0.0;
  double get fat => fat100g ?? 0.0;
  double get fiber => fiber100g ?? 0.0;
  double get sugar => sugars100g ?? 0.0;
  double get sodium => sodium100g ?? 0.0;
}

/// Represents a serving size suggestion
class ServingSizeSuggestion {
  final double amount;
  final String unit;
  final String description;

  const ServingSizeSuggestion({
    required this.amount,
    required this.unit,
    required this.description,
  });
}
