import 'package:flutter/material.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import '../../models/nutrition_analysis.dart';

class NutritionAnalysisCard extends StatelessWidget {
  final NutritionAnalysis analysis;
  final VoidCallback? onAddToMeals;

  const NutritionAnalysisCard({
    super.key,
    required this.analysis,
    this.onAddToMeals,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  localizations.componentsChatNutritionAnalysisCardNutritionAnalysis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dish Name
            _buildInfoRow(context, localizations.componentsChatNutritionAnalysisCardDishName, analysis.dishName),

            // Serving Size
            if (analysis.servingSize != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                localizations.componentsChatNutritionAnalysisCardServingSize,
                analysis.servingSize!,
              ),
            ],

            // Meal Type
            if (analysis.mealType != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                localizations.componentsChatNutritionAnalysisCardMealType,
                analysis.mealType!,
              ),
            ],

            const SizedBox(height: 16),

            // Nutrition Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNutritionItem(
                        context,
                        localizations.componentsCalendarMacroSummaryCalories,
                        '${analysis.nutritionInfo.calories.toInt()}',
                        'kcal',
                      ),
                      _buildNutritionItem(
                        context,
                        localizations.componentsCalendarMacroSummaryProtein,
                        '${analysis.nutritionInfo.protein.toInt()}',
                        'g',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNutritionItem(
                        context,
                        localizations.componentsCalendarMacroSummaryCarbs,
                        '${analysis.nutritionInfo.carbs.toInt()}',
                        'g',
                      ),
                      _buildNutritionItem(
                        context,
                        localizations.componentsCalendarMacroSummaryFat,
                        '${analysis.nutritionInfo.fat.toInt()}',
                        'g',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Ingredients
            if (analysis.ingredients.isNotEmpty) ...[
              Text(
                localizations.componentsChatMessageBubbleIngredients,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children:
                    analysis.ingredients.map((ingredient) {
                      return Chip(
                        label: Text(
                          ingredient,
                          style: theme.textTheme.bodySmall,
                        ),
                        backgroundColor: theme.colorScheme.secondaryContainer
                            .withValues(alpha: 0.5),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Cooking Instructions
            if (analysis.cookingInstructions != null) ...[
              Text(
                localizations.componentsChatNutritionAnalysisCardCookingInstructions,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                analysis.cookingInstructions!,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
            ],

            // Add to Meals Button
            if (onAddToMeals != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onAddToMeals,
                  icon: const Icon(Icons.add),
                  label: Text(localizations.componentsChatNutritionAnalysisCardAddToMeals),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
      ],
    );
  }

  Widget _buildNutritionItem(
    BuildContext context,
    String label,
    String value,
    String unit,
  ) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        children: [
          Text(
            '$value$unit',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
