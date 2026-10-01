import '../../models/dish.dart';
import '../../models/meal_type.dart';
import '../storage/dish_service.dart';

/// Why a `log_meal` tool call or a stored proposal was rejected.
enum MealLogProposalError {
  missingFood,
  invalidDishId,
  invalidName,
  invalidNutrition,
  invalidServings,
  invalidMealType,
  invalidDate,
  invalidTime,
  dateOutOfRange,
  dishNotFound,
}

class MealLogProposalException implements Exception {
  const MealLogProposalException(this.error);

  final MealLogProposalError error;

  @override
  String toString() => 'MealLogProposalException(${error.name})';
}

/// A meal the chat agent suggests logging. Nothing is written until the user
/// confirms it; see [MealLogProposalLogger].
///
/// Either references a saved dish ([dishId]) or carries quick-add values
/// ([nutritionPerServing]) for food that is not in the catalog.
class MealLogProposal {
  /// Same portion range as the log sheet.
  static const double minServings = 0.01;
  static const double maxServings = 20;
  static const int maxNameLength = 100;
  static const int maxIdLength = 128;
  static const double maxCalories = 10000;
  static const double maxGrams = 1000;

  /// How far back and ahead a proposal may be dated (as in the log sheet).
  static const Duration maxPast = Duration(days: 365);
  static const Duration maxFuture = Duration(days: 30);

  const MealLogProposal({
    this.dishId,
    required this.name,
    this.nutritionPerServing,
    required this.servings,
    required this.mealType,
    required this.loggedAt,
  }) : assert(dishId != null || nutritionPerServing != null);

  final String? dishId;

  /// Food name; for dish references only shown until the dish is loaded.
  final String name;
  final NutritionInfo? nutritionPerServing;
  final double servings;

  /// One of [MealType] names.
  final String mealType;
  final DateTime loggedAt;

  bool get isQuickAdd => dishId == null;

  /// Validates the arguments of a `log_meal` tool call. Missing servings,
  /// meal type, date and time default to 1, the meal of the time of day,
  /// today and now. Throws [MealLogProposalException].
  static MealLogProposal fromToolArguments(
    Map<String, dynamic> args, {
    required DateTime now,
  }) {
    final dishId = _optionalString(
      args['dish_id'],
      maxIdLength,
      MealLogProposalError.invalidDishId,
    );
    final name =
        _optionalString(
          args['name'] ?? args['dish_name'],
          maxNameLength,
          MealLogProposalError.invalidName,
        ) ??
        '';

    NutritionInfo? nutrition;
    if (dishId == null) {
      if (name.isEmpty || args['calories'] == null) {
        throw const MealLogProposalException(MealLogProposalError.missingFood);
      }
      nutrition = NutritionInfo(
        calories: _number(args['calories'], max: maxCalories)!,
        protein: _number(args['protein'], max: maxGrams) ?? 0,
        carbs: _number(args['carbs'], max: maxGrams) ?? 0,
        fat: _number(args['fat'], max: maxGrams) ?? 0,
        fiber: _number(args['fiber'], max: maxGrams) ?? 0,
      );
    }

    final servings = _servings(args['servings']);
    final loggedAt = _loggedAt(args['date'], args['time'], now);
    final mealType = _mealType(args['meal_type'], loggedAt);

    return MealLogProposal(
      dishId: dishId,
      name: name,
      nutritionPerServing: nutrition,
      servings: servings,
      mealType: mealType,
      loggedAt: loggedAt,
    );
  }

  /// Reads a proposal stored in chat message metadata. Applies the same
  /// limits as [fromToolArguments] except the date range, which only matters
  /// when the proposal is made. Throws [MealLogProposalException].
  static MealLogProposal fromJson(Map<String, dynamic> json) {
    final dishId = _optionalString(
      json['dishId'],
      maxIdLength,
      MealLogProposalError.invalidDishId,
    );
    final name =
        _optionalString(
          json['name'],
          maxNameLength,
          MealLogProposalError.invalidName,
        ) ??
        '';
    final rawNutrition = json['nutritionPerServing'];
    NutritionInfo? nutrition;
    if (rawNutrition is Map) {
      nutrition = NutritionInfo(
        calories: _number(rawNutrition['calories'], max: maxCalories) ?? 0,
        protein: _number(rawNutrition['protein'], max: maxGrams) ?? 0,
        carbs: _number(rawNutrition['carbs'], max: maxGrams) ?? 0,
        fat: _number(rawNutrition['fat'], max: maxGrams) ?? 0,
        fiber: _number(rawNutrition['fiber'], max: maxGrams) ?? 0,
      );
    }
    if (dishId == null && (nutrition == null || name.isEmpty)) {
      throw const MealLogProposalException(MealLogProposalError.missingFood);
    }
    final loggedAt = DateTime.tryParse('${json['loggedAt']}');
    if (loggedAt == null) {
      throw const MealLogProposalException(MealLogProposalError.invalidDate);
    }
    final mealType = json['mealType'];
    if (mealType is! String ||
        !MealType.values.any((type) => type.name == mealType)) {
      throw const MealLogProposalException(
        MealLogProposalError.invalidMealType,
      );
    }
    return MealLogProposal(
      dishId: dishId,
      name: name,
      nutritionPerServing: dishId == null ? nutrition : null,
      servings: _servings(json['servings']),
      mealType: mealType,
      loggedAt: loggedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    if (dishId != null) 'dishId': dishId,
    'name': name,
    if (nutritionPerServing != null)
      'nutritionPerServing': nutritionPerServing!.toJson(),
    'servings': servings,
    'mealType': mealType,
    'loggedAt': loggedAt.toIso8601String(),
  };

  MealLogProposal copyWith({String? name}) => MealLogProposal(
    dishId: dishId,
    name: name ?? this.name,
    nutritionPerServing: nutritionPerServing,
    servings: servings,
    mealType: mealType,
    loggedAt: loggedAt,
  );

  static String? _optionalString(
    Object? value,
    int maxLength,
    MealLogProposalError error,
  ) {
    if (value == null) return null;
    if (value is! String) throw MealLogProposalException(error);
    final trimmed = value.trim();
    if (trimmed.length > maxLength) throw MealLogProposalException(error);
    return trimmed.isEmpty ? null : trimmed;
  }

  static double? _number(Object? value, {required double max}) {
    if (value == null) return null;
    final number =
        value is num ? value.toDouble() : double.tryParse(value.toString());
    if (number == null || !number.isFinite || number < 0 || number > max) {
      throw const MealLogProposalException(
        MealLogProposalError.invalidNutrition,
      );
    }
    return number;
  }

  static double _servings(Object? value) {
    if (value == null) return 1;
    final number =
        value is num ? value.toDouble() : double.tryParse(value.toString());
    if (number == null ||
        !number.isFinite ||
        number < minServings ||
        number > maxServings) {
      throw const MealLogProposalException(
        MealLogProposalError.invalidServings,
      );
    }
    return number;
  }

  static String _mealType(Object? value, DateTime loggedAt) {
    if (value == null || (value is String && value.trim().isEmpty)) {
      return defaultMealTypeForTime(loggedAt).name;
    }
    final normalized = value is String ? value.trim().toLowerCase() : null;
    if (!MealType.values.any((type) => type.name == normalized)) {
      throw const MealLogProposalException(
        MealLogProposalError.invalidMealType,
      );
    }
    return normalized!;
  }

  static final RegExp _datePattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
  static final RegExp _timePattern = RegExp(r'^(\d{1,2}):(\d{2})$');

  static DateTime _loggedAt(Object? date, Object? time, DateTime now) {
    var day = DateTime(now.year, now.month, now.day);
    if (date != null && !(date is String && date.trim().isEmpty)) {
      final match = date is String ? _datePattern.firstMatch(date.trim()) : null;
      if (match == null) {
        throw const MealLogProposalException(MealLogProposalError.invalidDate);
      }
      final (y, m, d) = (
        int.parse(match[1]!),
        int.parse(match[2]!),
        int.parse(match[3]!),
      );
      day = DateTime(y, m, d);
      if (day.year != y || day.month != m || day.day != d) {
        throw const MealLogProposalException(MealLogProposalError.invalidDate);
      }
    }

    var (hour, minute) = (now.hour, now.minute);
    if (time != null && !(time is String && time.trim().isEmpty)) {
      final match = time is String ? _timePattern.firstMatch(time.trim()) : null;
      if (match == null) {
        throw const MealLogProposalException(MealLogProposalError.invalidTime);
      }
      (hour, minute) = (int.parse(match[1]!), int.parse(match[2]!));
      if (hour > 23 || minute > 59) {
        throw const MealLogProposalException(MealLogProposalError.invalidTime);
      }
    }

    final loggedAt = DateTime(day.year, day.month, day.day, hour, minute);
    if (loggedAt.isBefore(now.subtract(maxPast)) ||
        loggedAt.isAfter(now.add(maxFuture))) {
      throw const MealLogProposalException(MealLogProposalError.dateOutOfRange);
    }
    return loggedAt;
  }
}

/// What a confirmation card shows for a proposal.
class MealLogPreview {
  const MealLogPreview({
    required this.name,
    required this.totalNutrition,
    this.dish,
  });

  final String name;

  /// Nutrition of the whole proposed portion.
  final NutritionInfo totalNutrition;

  /// The referenced dish, null for quick adds.
  final Dish? dish;
}

/// Turns confirmed proposals into diary entries through [DishService], so
/// they get the same snapshot and Health Connect behaviour as manual logs.
class MealLogProposalLogger {
  MealLogProposalLogger({DishService? dishService})
    : _dishService = dishService ?? DishService();

  final DishService _dishService;

  /// Resolves the referenced dish. Throws [MealLogProposalException] with
  /// [MealLogProposalError.dishNotFound] when it no longer exists.
  Future<MealLogPreview> preview(MealLogProposal proposal) async {
    final dishId = proposal.dishId;
    if (dishId == null) {
      return MealLogPreview(
        name: proposal.name,
        totalNutrition: proposal.nutritionPerServing!.scaled(
          proposal.servings,
        ),
      );
    }
    final dish = await _dishService.getDishById(dishId);
    if (dish == null) {
      throw const MealLogProposalException(MealLogProposalError.dishNotFound);
    }
    return MealLogPreview(
      name: dish.name,
      totalNutrition: dish.nutritionPerServing.scaled(proposal.servings),
      dish: dish,
    );
  }

  /// Writes the diary entry and returns its id.
  Future<String> confirm(MealLogProposal proposal) async {
    final dishId = proposal.dishId;
    if (dishId != null) {
      if (await _dishService.getDishById(dishId) == null) {
        throw const MealLogProposalException(MealLogProposalError.dishNotFound);
      }
      return _dishService.logDish(
        dishId: dishId,
        loggedAt: proposal.loggedAt,
        mealType: proposal.mealType,
        servingSize: proposal.servings,
      );
    }
    final total = proposal.nutritionPerServing!.scaled(proposal.servings);
    return _dishService.logQuickAdd(
      name: proposal.name,
      loggedAt: proposal.loggedAt,
      mealType: proposal.mealType,
      calories: total.calories,
      protein: total.protein,
      carbs: total.carbs,
      fat: total.fat,
      fiber: total.fiber,
    );
  }
}
