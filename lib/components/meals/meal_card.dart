import 'package:flutter/material.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../models/meal_type.dart';
import '../../services/storage/meal_log_service.dart';

class MealCard extends StatelessWidget {
  final MealLog mealLog;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const MealCard({super.key, required this.mealLog, this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    // Get meal type display name
    String getMealTypeDisplayName() {
      try {
        return MealType.fromString(mealLog.mealType).displayName;
      } catch (e) {
        return mealLog.mealType;
      }
    }

    // Calculate total calories with serving size
    final totalCalories = mealLog.dish.nutrition.calories * mealLog.servingSize;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with meal type and time
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getMealTypeColor(mealLog.mealType),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      getMealTypeDisplayName(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat.Hm().format(mealLog.loggedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  if (onDelete != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      iconSize: 20,
                      onPressed: onDelete,
                      color: theme.colorScheme.error,
                      tooltip: 'Delete meal',
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Dish name and serving info
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mealLog.dish.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (mealLog.servingSize != 1.0) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${mealLog.servingSize}x serving',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Calories info
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${totalCalories.round()} ${localizations.calories.toLowerCase()}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              // Nutrition summary
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildNutritionInfo(
                    context,
                    localizations.protein,
                    (mealLog.dish.nutrition.protein * mealLog.servingSize)
                        .toStringAsFixed(1),
                    'g',
                  ),
                  const SizedBox(width: 16),
                  _buildNutritionInfo(
                    context,
                    localizations.carbs,
                    (mealLog.dish.nutrition.carbs * mealLog.servingSize)
                        .toStringAsFixed(1),
                    'g',
                  ),
                  const SizedBox(width: 16),
                  _buildNutritionInfo(
                    context,
                    localizations.fat,
                    (mealLog.dish.nutrition.fat * mealLog.servingSize)
                        .toStringAsFixed(1),
                    'g',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionInfo(
    BuildContext context,
    String label,
    String value,
    String unit,
  ) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$value$unit',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMealTypeColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.green;
      case 'dinner':
        return Colors.blue;
      case 'snack':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
