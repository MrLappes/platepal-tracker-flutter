import '../models/dish.dart';
import '../services/storage/dish_storage_service.dart';

class DishRepository {
  final DishStorageService _storageService = DishStorageService();

  Future<List<Dish>> getAllDishes() async {
    try {
      return await _storageService.getAllDishes();
    } catch (e) {
      throw Exception('Failed to load dishes: $e');
    }
  }

  Future<Dish?> getDishById(String id) async {
    try {
      return await _storageService.getDishById(id);
    } catch (e) {
      throw Exception('Failed to load dish: $e');
    }
  }

  Future<Dish> createDish(Dish dish) async {
    try {
      return await _storageService.saveDish(dish);
    } catch (e) {
      throw Exception('Failed to create dish: $e');
    }
  }

  Future<Dish> updateDish(Dish dish) async {
    try {
      return await _storageService.updateDish(dish);
    } catch (e) {
      throw Exception('Failed to update dish: $e');
    }
  }

  Future<void> deleteDish(String id) async {
    try {
      await _storageService.deleteDish(id);
    } catch (e) {
      throw Exception('Failed to delete dish: $e');
    }
  }

  Future<List<Dish>> searchDishes(String query) async {
    try {
      final allDishes = await getAllDishes();
      return allDishes
          .where(
            (dish) =>
                dish.name.toLowerCase().contains(query.toLowerCase()) ||
                (dish.description?.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ??
                    false),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to search dishes: $e');
    }
  }

  Future<List<Dish>> getFavoriteDishes() async {
    try {
      final allDishes = await getAllDishes();
      return allDishes.where((dish) => dish.isFavorite).toList();
    } catch (e) {
      throw Exception('Failed to load favorite dishes: $e');
    }
  }
}
