import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/chat_profile.dart';
import 'bot_profile_customization_dialog.dart';

class ChatHeader extends StatelessWidget {
  final ChatBotProfile botProfile;
  final Function(ChatBotProfile) onBotProfileUpdated;

  const ChatHeader({
    super.key,
    required this.botProfile,
    required this.onBotProfileUpdated,
  });

  void _editBotProfile(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => BotProfileCustomizationDialog(
            initialProfile: botProfile,
            onProfileUpdated: onBotProfileUpdated,
          ),
    );
  }

  Widget _buildBotAvatar(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child:
          botProfile.avatarUrl != null
              ? ClipOval(
                child:
                    botProfile.avatarUrl!.startsWith('http')
                        ? Image.network(
                          botProfile.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  _buildDefaultBotAvatar(context),
                        )
                        : Image.file(
                          File(botProfile.avatarUrl!),
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  _buildDefaultBotAvatar(context),
                        ),
              )
              : _buildDefaultBotAvatar(context),
    );
  }

  Widget _buildDefaultBotAvatar(BuildContext context) {
    return Icon(
      Icons.smart_toy,
      size: 24,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  String _getPersonalityDescription(String personalityType) {
    switch (personalityType) {
      case 'nutritionist':
        return 'Professional & Evidence-based';
      case 'casualGymbro':
        return 'Casual & Motivational';
      case 'angryGreg':
        return 'Intense & Supplement-focused';
      case 'veryAngryBro':
        return 'Extremely Intense';
      case 'fitnessCoach':
        return 'Encouraging & Supportive';
      case 'nice':
      default:
        return 'Friendly & Helpful';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildBotAvatar(context),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  botProfile.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _getPersonalityDescription(botProfile.personalityType),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _editBotProfile(context),
            icon: Icon(
              Icons.edit,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            tooltip: 'Edit Bot Profile',
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
