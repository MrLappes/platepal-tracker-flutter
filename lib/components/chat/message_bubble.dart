import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/chat_message.dart';
import '../../models/dish_models.dart';
import 'agent_steps_modal.dart';
import 'dish_suggestion_card.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onRetry;

  const MessageBubble({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final isUser = message.isFromUser;
    final isDark = theme.brightness == Brightness.dark;

    // Determine alignment and layout based on sender
    final avatar = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child:
            isUser
                ? Container(
                  color: theme.colorScheme.secondary,
                  child: Icon(
                    Icons.person,
                    size: 24,
                    color: theme.colorScheme.onSecondary,
                  ),
                )
                : Container(
                  color: theme.colorScheme.primary,
                  child: Icon(
                    Icons.smart_toy,
                    size: 24,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
      ),
    );

    final nameAndTime = Expanded(
      child: Row(
        children: [
          Text(
            isUser ? 'You' : 'PlatePal Assistant',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (!isUser) ...[
            const SizedBox(width: 4),
            Text(
              '(bot)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const Spacer(),
          Text(
            _formatTime(context, message.timestamp),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    ); // Bubble content
    final bubble = Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
      decoration: BoxDecoration(
        gradient: _getMessageGradient(isUser, isDark, theme),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => _handleMessageTap(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.hasImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  message.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: theme.colorScheme.surfaceContainerHigh,
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
            GestureDetector(
              onLongPress: () => _copyToClipboard(context, message.content),
              child: SelectableText(
                message.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _getTextColor(isUser, isDark, theme),
                  height: 1.4,
                ),
              ),
            ),
            if (message.isSending || message.hasFailed) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.isSending) ...[
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sending...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ] else if (message.hasFailed) ...[
                    GestureDetector(
                      onTap: onRetry,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.refresh,
                              size: 14,
                              color: theme.colorScheme.onError,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              localizations.retryMessage,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onError,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
            if (!isUser && _hasAgentMetadata()) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.psychology,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      localizations.tapToViewAgentSteps,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (!isUser && _hasDishes()) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? theme.colorScheme.surfaceContainer
                          : theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Suggested Dishes',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._buildDishCards(context),
                  ],
                ),
              ),
            ],
            if (!isUser && _hasRecommendation()) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? theme.colorScheme.secondaryContainer
                          : theme.colorScheme.secondaryContainer.withOpacity(
                            0.3,
                          ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.secondary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 18,
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Recommendation',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getRecommendationText(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ); // Layout: both user and bot messages are left-aligned
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name/time row with space for avatar
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 52), // Space for avatar
              nameAndTime,
            ],
          ),
          // Bubble with avatar overlay
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                margin: const EdgeInsets.only(left: 18),
                child: bubble,
              ),
              Positioned(top: -35, left: 0, child: avatar),
            ],
          ),
        ],
      ),
    );
  }

  /// Get gradient colors for message bubble based on user type, theme, and current theme colors
  LinearGradient _getMessageGradient(
    bool isUser,
    bool isDark,
    ThemeData theme,
  ) {
    if (isUser) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors:
            isDark
                ? [
                  // Dark theme user gradients - based on current theme's primary color
                  theme.colorScheme.primary.withOpacity(0.3),
                  theme.colorScheme.primary.withOpacity(0.2),
                ]
                : [
                  // Light theme user gradients - softer primary colors
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.primary.withOpacity(0.05),
                ],
      );
    } else {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors:
            isDark
                ? [
                  // Dark theme bot gradients
                  theme.colorScheme.surfaceContainer,
                  theme.colorScheme.surfaceContainerHigh,
                ]
                : [
                  // Light theme bot gradients
                  Colors.white,
                  theme.colorScheme.surfaceContainerLow,
                ],
      );
    }
  }

  /// Get text color based on message type and theme
  Color _getTextColor(bool isUser, bool isDark, ThemeData theme) {
    if (isUser) {
      return isDark
          ? Colors.white.withOpacity(0.95)
          : theme.colorScheme.onSurface;
    } else {
      return theme.colorScheme.onSurface;
    }
  }

  /// Handle message tap for agent steps
  void _handleMessageTap(BuildContext context) {
    if (!message.isFromUser && _hasAgentMetadata()) {
      showDialog(
        context: context,
        builder: (context) => AgentStepsModal(metadata: message.metadata!),
      );
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.messageCopied),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatTime(BuildContext context, DateTime dateTime) {
    final localizations = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return '$displayHour:$minute $period';
    } else if (difference.inDays == 1) {
      return localizations.yesterday;
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  /// Check if this message has agent processing metadata
  bool _hasAgentMetadata() {
    return message.metadata != null &&
        message.metadata!['mode'] == 'full_agent_pipeline';
  }

  /// Check if this message has processed dishes
  bool _hasDishes() {
    final dishesProcessedRaw = message.metadata?['dishesProcessed'];

    // Debug logging to understand the data structure
    if (dishesProcessedRaw != null) {
      debugPrint('dishesProcessed type: ${dishesProcessedRaw.runtimeType}');
      debugPrint('dishesProcessed value: $dishesProcessedRaw');
    }

    if (dishesProcessedRaw == null ||
        dishesProcessedRaw is! Map<String, dynamic>) {
      return false;
    }

    final validatedDishes = dishesProcessedRaw['validatedDishes'];
    return validatedDishes is List && validatedDishes.isNotEmpty;
  }

  /// Check if this message has a recommendation
  bool _hasRecommendation() {
    final recommendation = message.metadata?['recommendation'];
    if (recommendation is String) {
      return recommendation.trim().isNotEmpty;
    } else if (recommendation is List<String>) {
      return recommendation.isNotEmpty;
    }
    return false;
  }

  /// Build dish suggestion cards from metadata
  List<Widget> _buildDishCards(BuildContext context) {
    final dishesProcessedRaw = message.metadata?['dishesProcessed'];
    if (dishesProcessedRaw == null ||
        dishesProcessedRaw is! Map<String, dynamic>) {
      return [];
    }

    final validatedDishes = dishesProcessedRaw['validatedDishes'];

    if (validatedDishes is! List || validatedDishes.isEmpty) {
      return [];
    }

    return validatedDishes.map((dishData) {
      try {
        // Convert the dish data back to ProcessedDish
        final dish = ProcessedDish.fromJson(dishData as Map<String, dynamic>);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: DishSuggestionCard(
            dish: dish,
            onAddToMeals: () => _handleAddToMeals(context, dish),
            onViewDetails: () => _handleViewDishDetails(context, dish),
          ),
        );
      } catch (e) {
        debugPrint('Error building dish card: $e');
        return const SizedBox.shrink();
      }
    }).toList();
  }

  String _getRecommendationText() {
    final recommendation = message.metadata?['recommendation'];
    if (recommendation is String) {
      return recommendation;
    } else if (recommendation is List<String>) {
      return recommendation.join(', ');
    } else {
      return 'No recommendations available.';
    }
  }

  /// Handle adding dish to meals
  void _handleAddToMeals(BuildContext context, ProcessedDish dish) {
    // TODO: Implement meal logging functionality
    final localizations = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations.addedToMealsSuccess(dish.name)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Handle viewing dish details
  void _handleViewDishDetails(BuildContext context, ProcessedDish dish) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(dish.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dish.description != null) ...[
                  Text(dish.description!),
                  const SizedBox(height: 12),
                ],
                Text(
                  '${localizations.calories}: ${dish.totalNutrition.calories.toStringAsFixed(0)}',
                ),
                Text(
                  '${localizations.protein}: ${dish.totalNutrition.protein.toStringAsFixed(1)}g',
                ),
                Text(
                  '${localizations.carbs}: ${dish.totalNutrition.carbs.toStringAsFixed(1)}g',
                ),
                Text(
                  '${localizations.fat}: ${dish.totalNutrition.fat.toStringAsFixed(1)}g',
                ),
                if (dish.ingredients.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    '${localizations.ingredients}:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...dish.ingredients.map((ing) => Text('• ${ing.name}')),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localizations.close),
              ),
            ],
          ),
    );
  }
}
