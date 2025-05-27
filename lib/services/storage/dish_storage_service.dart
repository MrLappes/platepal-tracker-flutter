import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/dish.dart';

class DishStorageService {
  static const String _dishesKey = 'dishes';

  Future<List<Dish>> getAllDishes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dishesJson = prefs.getStringList(_dishesKey) ?? [];

      return dishesJson.map((dishJson) {
        final Map<String, dynamic> map = jsonDecode(dishJson);
        return Dish.fromJson(map);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load dishes from storage: $e');
    }
  }

  Future<Dish?> getDishById(String id) async {
    try {
      final dishes = await getAllDishes();
      return dishes.firstWhere(
        (dish) => dish.id == id,
        orElse: () => throw Exception('Dish not found'),
      );
    } catch (e) {
      return null;
    }
  }

  Future<Dish> saveDish(Dish dish) async {
    try {
      final dishes = await getAllDishes();
      dishes.add(dish);
      await _saveDishesToStorage(dishes);
      return dish;
    } catch (e) {
      throw Exception('Failed to save dish: $e');
    }
  }

  Future<Dish> updateDish(Dish dish) async {
    try {
      final dishes = await getAllDishes();
      final index = dishes.indexWhere((d) => d.id == dish.id);

      if (index == -1) {
        throw Exception('Dish not found');
      }

      dishes[index] = dish;
      await _saveDishesToStorage(dishes);
      return dish;
    } catch (e) {
      throw Exception('Failed to update dish: $e');
    }
  }

  Future<void> deleteDish(String id) async {
    try {
      final dishes = await getAllDishes();
      dishes.removeWhere((dish) => dish.id == id);
      await _saveDishesToStorage(dishes);
    } catch (e) {
      throw Exception('Failed to delete dish: $e');
    }
  }

  Future<void> _saveDishesToStorage(List<Dish> dishes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dishesJson =
          dishes.map((dish) => jsonEncode(dish.toJson())).toList();
      await prefs.setStringList(_dishesKey, dishesJson);
    } catch (e) {
      throw Exception('Failed to save dishes to storage: $e');
    }
  }

  Future<void> clearAllDishes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_dishesKey);
    } catch (e) {
      throw Exception('Failed to clear dishes: $e');
    }
  }
}
