import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/models/dish.dart';
import 'package:platepal_tracker/services/chat/agent_steps/dish_validation_step.dart';

void main() {
  test('a stored dish card shows one serving, like the log sheet', () {
    final stew = Dish(
      id: 'stew',
      name: 'Stew',
      ingredients: const [
        Ingredient(id: 'beef', name: 'Beef', amount: 600, unit: 'g'),
      ],
      nutrition: const NutritionInfo(
        calories: 2000,
        protein: 160,
        carbs: 80,
        fat: 100,
        fiber: 12,
        sugar: 8,
        sodium: 4,
      ),
      createdAt: DateTime(2026, 9, 1),
      updatedAt: DateTime(2026, 9, 1),
      servings: 4,
    );

    final card = processedDishFromStorage(stew);

    expect(card.id, 'stew');
    expect(card.servings, 1);
    expect(card.totalNutrition.calories, stew.nutritionPerServing.calories);
    expect(card.totalNutrition.calories, 500);
    expect(card.totalNutrition.protein, 40);
    expect(card.totalNutrition.sodium, 1);
    expect(card.ingredients.single.amount, 600);
  });
}
