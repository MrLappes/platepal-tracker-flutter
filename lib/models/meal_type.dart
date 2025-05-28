/// Represents the type of meal
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  /// Display name for the meal type
  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  /// Convert from string to enum
  static MealType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'breakfast':
        return MealType.breakfast;
      case 'lunch':
        return MealType.lunch;
      case 'dinner':
        return MealType.dinner;
      case 'snack':
        return MealType.snack;
      default:
        throw ArgumentError('Invalid meal type: $value');
    }
  }

  /// Convert enum to string
  String toJsonValue() {
    return name;
  }
}
