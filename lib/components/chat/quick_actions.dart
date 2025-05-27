import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QuickActions extends StatelessWidget {
  final Function(String) onActionTap;

  const QuickActions({super.key, required this.onActionTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    final actions = [
      _QuickAction(
        icon: Icons.restaurant_menu,
        label: localizations.suggestMeal,
        message: "Suggest a healthy meal for me based on my fitness goals",
      ),
      _QuickAction(
        icon: Icons.analytics,
        label: localizations.analyzeNutrition,
        message: "Help me analyze the nutrition in my meal",
      ),
      _QuickAction(
        icon: Icons.swap_horiz,
        label: localizations.findAlternatives,
        message: "Find healthier alternatives to my current meal",
      ),
      _QuickAction(
        icon: Icons.calculate,
        label: localizations.calculateMacros,
        message: "Help me calculate macros for my meals",
      ),
      _QuickAction(
        icon: Icons.calendar_today,
        label: localizations.mealPlan,
        message: "Help me create a weekly meal plan",
      ),
      _QuickAction(
        icon: Icons.info,
        label: localizations.ingredientInfo,
        message: "Tell me about the nutritional benefits of ingredients",
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.quickActions,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                actions.map((action) {
                  return _buildActionChip(context, action);
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(BuildContext context, _QuickAction action) {
    final theme = Theme.of(context);

    return ActionChip(
      avatar: Icon(action.icon, size: 16, color: theme.colorScheme.primary),
      label: Text(action.label, style: theme.textTheme.bodySmall),
      onPressed: () => onActionTap(action.message),
      backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
      side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final String message;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.message,
  });
}
