import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/chat_profile.dart';
import 'bot_profile_customization_dialog.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';

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
    final theme = Theme.of(context);
    // Use transparent Material, let parent control color
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      elevation: 0,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(shape: BoxShape.circle),
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
      ),
    );
  }

  Widget _buildDefaultBotAvatar(BuildContext context) {
    return Icon(
      Icons.smart_toy,
      size: 24,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  String _getPersonalityDescription(
    BuildContext context,
    String personalityType,
  ) {
    final l10n = AppLocalizations.of(context);
    switch (personalityType) {
      case 'nutritionist':
        return l10n.componentsChatBotPersonalityDescriptionNutritionist;
      case 'casualGymbro':
        return l10n.componentsChatBotPersonalityDescriptionCasualGymbro;
      case 'angryGreg':
        return l10n.componentsChatBotPersonalityDescriptionAngryGreg;
      case 'veryAngryBro':
        return l10n.componentsChatBotPersonalityDescriptionVeryAngryBro;
      case 'fitnessCoach':
        return l10n.componentsChatBotPersonalityDescriptionFitnessCoach;
      case 'nice':
      default:
        return l10n.componentsChatBotPersonalityDescriptionNice;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use Material to match AppBar elevation and color
    return Material(
      elevation: theme.appBarTheme.scrolledUnderElevation ?? 1,
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => _editBotProfile(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

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
                      _getPersonalityDescription(
                        context,
                        botProfile.personalityType,
                      ),
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
                tooltip:
                    AppLocalizations.of(
                      context,
                    ).componentsChatEditBotProfileTooltip,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
