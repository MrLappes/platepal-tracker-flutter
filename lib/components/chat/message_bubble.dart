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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary,
              child: Icon(
                Icons.smart_toy,
                size: 16,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Column(
                crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isUser
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(18).copyWith(
                        bottomRight: isUser ? const Radius.circular(4) : null,
                        bottomLeft: !isUser ? const Radius.circular(4) : null,
                      ),
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
                                width: 200,
                                height: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 200,
                                    height: 150,
                                    color:
                                        theme.colorScheme.surfaceContainerHigh,
                                    child: const Icon(Icons.error),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          GestureDetector(
                            onLongPress:
                                () =>
                                    _copyToClipboard(context, message.content),
                            child: Text(
                              message.content,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color:
                                    isUser
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (!isUser && _hasAgentMetadata()) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.psychology,
                                    size: 14,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
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
                          // Display dishes if they exist in the metadata
                          if (!isUser && _hasDishes()) ...[
                            const SizedBox(height: 8),
                            ..._buildDishCards(context),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(context, message.timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      if (message.isSending) ...[
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ] else if (message.hasFailed) ...[
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: onRetry,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              localizations.retryMessage,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onError,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.secondary,
              child: Icon(
                Icons.person,
                size: 16,
                color: theme.colorScheme.onSecondary,
              ),
            ),
          ],
        ],
      ),
    );
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
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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

        return DishSuggestionCard(
          dish: dish,
          onAddToMeals: () => _handleAddToMeals(context, dish),
          onViewDetails: () => _handleViewDishDetails(context, dish),
        );
      } catch (e) {
        debugPrint('Error building dish card: $e');
        return const SizedBox.shrink();
      }
    }).toList();
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
    // TODO: Implement dish details view
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

  /// Handle tap on assistant message to show agent steps
  void _handleMessageTap(BuildContext context) {
    if (!message.isFromUser && _hasAgentMetadata()) {
      showDialog(
        context: context,
        builder: (context) => AgentStepsModal(metadata: message.metadata!),
      );
    }
  }
}
