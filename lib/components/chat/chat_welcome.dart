import 'package:flutter/material.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';

class ChatWelcome extends StatelessWidget {
  final Function(String) onActionTap;

  const ChatWelcome({super.key, required this.onActionTap});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isDark
                ? theme.colorScheme.surface
                : theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
            theme.colorScheme.surface,
          ],
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header with animated card
            _buildWelcomeHeader(context, theme, localizations, isDark),

            const SizedBox(height: 32),

            // Get Started Section
            _buildGetStartedSection(context, theme, localizations),

            const SizedBox(height: 16),

            // Quick Action Options
            _buildQuickActionOptions(context, theme, localizations, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(
    BuildContext context,
    ThemeData theme,
    AppLocalizations localizations,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDark
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                : theme.colorScheme.primary.withValues(alpha: 0.05),
            isDark
                ? theme.colorScheme.primary.withValues(alpha: 0.05)
                : theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Logo or Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.restaurant_menu,
              size: 32,
              color: theme.colorScheme.onPrimary,
            ),
          ),

          const SizedBox(height: 20),

          // Welcome Title
          Text(
            localizations.chatWelcomeTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 8),

          // Welcome Subtitle
          Text(
            localizations.chatWelcomeSubtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGetStartedSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.getStartedToday,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 16),

        Text(
          localizations.whatCanIHelpWith,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionOptions(
    BuildContext context,
    ThemeData theme,
    AppLocalizations localizations,
    bool isDark,
  ) {
    final quickActions = [
      _QuickActionOption(
        icon: Icons.restaurant_menu,
        title: localizations.suggestMeal,
        subtitle: "Get personalized meal recommendations",
        message: "Suggest a healthy meal for me based on my fitness goals",
        gradient: LinearGradient(
          colors:
              isDark
                  ? [Colors.pink.shade800, Colors.purple.shade900]
                  : [Colors.pink.shade400, Colors.purple.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      _QuickActionOption(
        icon: Icons.analytics,
        title: localizations.analyzeNutrition,
        subtitle: "Analyze the nutrition in your meals",
        message: "Help me analyze the nutrition in my meal",
        gradient: LinearGradient(
          colors:
              isDark
                  ? [Colors.teal.shade700, Colors.blue.shade900]
                  : [Colors.teal.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      _QuickActionOption(
        icon: Icons.swap_horiz,
        title: localizations.findAlternatives,
        subtitle: "Discover healthier food alternatives",
        message: "Find healthier alternatives to my current meal",
        gradient: LinearGradient(
          colors:
              isDark
                  ? [Colors.amber.shade700, Colors.orange.shade800]
                  : [Colors.amber.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      _QuickActionOption(
        icon: Icons.calculate,
        title: localizations.calculateMacros,
        subtitle: "Calculate macros for your meals",
        message: "Help me calculate macros for my meals",
        gradient: LinearGradient(
          colors:
              isDark
                  ? [Colors.deepPurple.shade700, Colors.indigo.shade900]
                  : [Colors.deepPurple.shade400, Colors.indigo.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      _QuickActionOption(
        icon: Icons.calendar_today,
        title: localizations.mealPlan,
        subtitle: "Create weekly meal plans",
        message: "Help me create a weekly meal plan",
        gradient: LinearGradient(
          colors:
              isDark
                  ? [Colors.green.shade800, Colors.teal.shade900]
                  : [Colors.green.shade500, Colors.teal.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      _QuickActionOption(
        icon: Icons.info_outline,
        title: localizations.ingredientInfo,
        subtitle: "Learn about ingredient benefits",
        message: "Tell me about the nutritional benefits of ingredients",
        gradient: LinearGradient(
          colors:
              isDark
                  ? [Colors.red.shade700, Colors.pink.shade900]
                  : [Colors.red.shade400, Colors.pink.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ];

    return Column(
      children:
          quickActions
              .map((action) => _buildActionCard(context, theme, action, isDark))
              .toList(),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    ThemeData theme,
    _QuickActionOption action,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onActionTap(action.message),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  isDark
                      ? theme.colorScheme.surfaceContainerHighest
                      : theme.colorScheme.surface,
                  isDark
                      ? theme.colorScheme.surface
                      : theme.colorScheme.surfaceContainerLowest,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.15),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Icon Container with Gradient
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: action.gradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: action.gradient.colors.first.withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(action.icon, color: Colors.white, size: 26),
                  ),

                  const SizedBox(width: 16),

                  // Text Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          action.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          action.subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrow Icon with Container
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final String message;
  final Gradient gradient;

  const _QuickActionOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.message,
    required this.gradient,
  });
}
