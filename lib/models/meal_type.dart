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
    final v = value.trim().toLowerCase();
    // Accept several common synonyms and fuzzy matches
    if (v.isEmpty) return MealType.snack;
    if (v.contains('break')) return MealType.breakfast;
    if (v.contains('lunch') || v.contains('noon')) return MealType.lunch;
    if (v.contains('dinner') || v.contains('supper') || v.contains('evening'))
      return MealType.dinner;
    if (v.contains('snack') ||
        v.contains('between') ||
        v.contains('small') ||
        v.contains('snk'))
      return MealType.snack;

    // Handle short codes
    switch (v) {
      case 'bf':
      case 'bfast':
      case 'breakfast':
        return MealType.breakfast;
      case 'l':
      case 'ln':
      case 'lunch':
        return MealType.lunch;
      case 'd':
      case 'din':
      case 'dinner':
      case 'supper':
        return MealType.dinner;
      case 's':
      case 'sn':
      case 'snack':
        return MealType.snack;
      default:
        // As a safe fallback, return snack to ensure UI shows something consistent
        return MealType.snack;
    }
  }

  /// Convert enum to string
  String toJsonValue() {
    return name;
  }
}
