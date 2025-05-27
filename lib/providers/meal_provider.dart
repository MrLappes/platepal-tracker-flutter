import 'package:flutter/foundation.dart';
import '../models/dish.dart';
import '../repositories/dish_repository.dart';

class MealProvider extends ChangeNotifier {
  final DishRepository _dishRepository = DishRepository();

  List<Dish> _dishes = [];
  List<Dish> _favoriteDishes = [];
  final Map<DateTime, List<Dish>> _mealLog = {};
  bool _isLoading = false;
  String? _error;

  List<Dish> get dishes => _dishes;
  List<Dish> get favoriteDishes => _favoriteDishes;
  Map<DateTime, List<Dish>> get mealLog => _mealLog;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDishes() async {
    _setLoading(true);
    try {
      _dishes = await _dishRepository.getAllDishes();
      _favoriteDishes = _dishes.where((dish) => dish.isFavorite).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addDish(Dish dish) async {
    _setLoading(true);
    try {
      final newDish = await _dishRepository.createDish(dish);
      _dishes.add(newDish);
      if (newDish.isFavorite) {
        _favoriteDishes.add(newDish);
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateDish(Dish dish) async {
    _setLoading(true);
    try {
      final updatedDish = await _dishRepository.updateDish(dish);
      final index = _dishes.indexWhere((d) => d.id == dish.id);
      if (index != -1) {
        _dishes[index] = updatedDish;
      }

      if (updatedDish.isFavorite) {
        if (!_favoriteDishes.any((d) => d.id == updatedDish.id)) {
          _favoriteDishes.add(updatedDish);
        }
      } else {
        _favoriteDishes.removeWhere((d) => d.id == updatedDish.id);
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteDish(String dishId) async {
    _setLoading(true);
    try {
      await _dishRepository.deleteDish(dishId);
      _dishes.removeWhere((dish) => dish.id == dishId);
      _favoriteDishes.removeWhere((dish) => dish.id == dishId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logMeal(DateTime date, Dish dish) async {
    try {
      final dateKey = DateTime(date.year, date.month, date.day);
      if (_mealLog[dateKey] == null) {
        _mealLog[dateKey] = [];
      }
      _mealLog[dateKey]!.add(dish);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void toggleFavorite(String dishId) async {
    final dishIndex = _dishes.indexWhere((dish) => dish.id == dishId);
    if (dishIndex != -1) {
      final dish = _dishes[dishIndex];
      final updatedDish = dish.copyWith(isFavorite: !dish.isFavorite);
      await updateDish(updatedDish);
    }
  }

  List<Dish> searchDishes(String query) {
    if (query.isEmpty) return _dishes;

    return _dishes
        .where(
          (dish) =>
              dish.name.toLowerCase().contains(query.toLowerCase()) ||
              (dish.description?.toLowerCase().contains(query.toLowerCase()) ??
                  false) ||
              dish.ingredients.any(
                (ingredient) =>
                    ingredient.name.toLowerCase().contains(query.toLowerCase()),
              ),
        )
        .toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
