import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' as intl;
import 'package:platepal_tracker/l10n/app_localizations.dart';

/// Represents the type of meal
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  /// Display name using the current intl locale for callers without context.
  String get displayName {
    final locale = intl.Intl.getCurrentLocale().split(RegExp('[_-]')).first;
    final supportedLocale = switch (locale) {
      'es' => const Locale('es'),
      'de' => const Locale('de'),
      _ => const Locale('en'),
    };
    return localizedDisplayName(lookupAppLocalizations(supportedLocale));
  }

  /// Display name using the active widget localization.
  String localizedDisplayName(AppLocalizations localizations) {
    switch (this) {
      case MealType.breakfast:
        return localizations.componentsModalsDishLogModalBreakfast;
      case MealType.lunch:
        return localizations.componentsModalsDishLogModalLunch;
      case MealType.dinner:
        return localizations.componentsModalsDishLogModalDinner;
      case MealType.snack:
        return localizations.componentsModalsDishLogModalSnack;
    }
  }

  /// Convert from string to enum
  static MealType fromString(String value) {
    final v = value.trim().toLowerCase();
    // Accept several common synonyms and fuzzy matches
    if (v.isEmpty) return MealType.snack;
    if (v.contains('break')) return MealType.breakfast;
    if (v.contains('lunch') || v.contains('noon')) return MealType.lunch;
    if (v.contains('dinner') || v.contains('supper') || v.contains('evening')) {
      return MealType.dinner;
    }
    if (v.contains('snack') ||
        v.contains('between') ||
        v.contains('small') ||
        v.contains('snk')) {
      return MealType.snack;
    }

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

/// Chooses the meal type for a local date and time.
MealType defaultMealTypeForTime(DateTime dateTime) {
  final minutesSinceMidnight = dateTime.hour * 60 + dateTime.minute;
  if (minutesSinceMidnight < 10 * 60 + 30) return MealType.breakfast;
  if (minutesSinceMidnight < 15 * 60) return MealType.lunch;
  if (minutesSinceMidnight < 21 * 60) return MealType.dinner;
  return MealType.snack;
}
