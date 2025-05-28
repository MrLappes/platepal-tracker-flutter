import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/dish_models.dart';
import '../../models/meal_type.dart';

class DishSuggestionCard extends StatelessWidget {
  final ProcessedDish dish;
  final VoidCallback? onAddToMeals;
  final VoidCallback? onViewDetails;

  const DishSuggestionCard({
    super.key,
    required this.dish,
    this.onAddToMeals,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(top: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with dish name and meal type
            Row(
              children: [
                Icon(
                  Icons.restaurant_menu,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dish.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                if (dish.mealType != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getMealTypeColor(dish.mealType!).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getMealTypeColor(
                          dish.mealType!,
                        ).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _getMealTypeDisplayName(dish.mealType!, localizations),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getMealTypeColor(dish.mealType!),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // Description if available
            if (dish.description != null && dish.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                dish.description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 12),

            // Nutrition information
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                  0.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        localizations.nutritionAnalysis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${dish.servings.toStringAsFixed(1)} ${dish.servings == 1 ? 'serving' : 'servings'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _NutrientChip(
                          label: localizations.calories,
                          value:
                              '${dish.totalNutrition.calories.toStringAsFixed(0)}',
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _NutrientChip(
                          label: localizations.protein,
                          value:
                              '${dish.totalNutrition.protein.toStringAsFixed(1)}g',
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _NutrientChip(
                          label: localizations.carbs,
                          value:
                              '${dish.totalNutrition.carbs.toStringAsFixed(1)}g',
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _NutrientChip(
                          label: localizations.fat,
                          value:
                              '${dish.totalNutrition.fat.toStringAsFixed(1)}g',
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Ingredients preview
            if (dish.ingredients.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '${localizations.ingredients}:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dish.ingredients.take(3).map((ing) => ing.name).join(', ') +
                    (dish.ingredients.length > 3
                        ? ', and ${dish.ingredients.length - 3} more...'
                        : ''),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],

            // Action buttons
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onAddToMeals,
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: Text(localizations.addToMeals),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                if (onViewDetails != null) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: onViewDetails,
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: Text(localizations.details),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getMealTypeColor(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return Colors.orange;
      case MealType.lunch:
        return Colors.green;
      case MealType.dinner:
        return Colors.purple;
      case MealType.snack:
        return Colors.blue;
    }
  }

  String _getMealTypeDisplayName(
    MealType mealType,
    AppLocalizations localizations,
  ) {
    switch (mealType) {
      case MealType.breakfast:
        return localizations.breakfast;
      case MealType.lunch:
        return localizations.lunch;
      case MealType.dinner:
        return localizations.dinner;
      case MealType.snack:
        return localizations.snack;
    }
  }
}

class _NutrientChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _NutrientChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
