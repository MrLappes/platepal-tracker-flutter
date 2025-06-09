import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/chat_provider.dart';
import '../components/chat/message_bubble.dart';
import '../components/chat/chat_input.dart';
import '../components/chat/chat_welcome.dart';
import '../components/chat/chat_header.dart';
import '../components/chat/user_profile_customization_dialog.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  late ChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    _chatProvider = ChatProvider();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh API key configuration when screen is shown
    _chatProvider.refreshApiKeyConfiguration();
    // Don't add welcome message automatically to show the welcome screen
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return ChangeNotifierProvider.value(
      value: _chatProvider,
      child: Scaffold(
        appBar: AppBar(
          title: Consumer<ChatProvider>(
            builder: (context, chatProvider, _) {
              final botProfile = chatProvider.currentBotProfile;
              return botProfile != null
                  ? ChatHeader(
                    botProfile: botProfile,
                    onBotProfileUpdated: (updatedProfile) {
                      chatProvider.updateBotProfile(updatedProfile);
                    },
                  )
                  : Text(localizations.chatAssistant);
            },
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
          actions: [
            Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                if (!chatProvider.hasMessages) return const SizedBox.shrink();
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'clear') {
                      _showClearChatDialog(context, chatProvider);
                    } else if (value == 'edit_profile') {
                      _showUserProfileDialog(context, chatProvider);
                    }
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'edit_profile',
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text('Edit Profile'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'clear',
                          child: Row(
                            children: [
                              Icon(
                                Icons.clear_all,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Text(localizations.clearChat),
                            ],
                          ),
                        ),
                      ],
                );
              },
            ),
          ],
        ),
        body: Consumer<ChatProvider>(
          builder: (context, chatProvider, _) {
            return !chatProvider.isApiKeyConfigured
                ? _buildNoApiKeyState(context)
                : _buildChatBody(context, chatProvider);
          },
        ),
      ),
    );
  }

  Widget _buildChatBody(BuildContext context, ChatProvider chatProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child:
                chatProvider.hasMessages
                    ? _buildChatList(context, chatProvider)
                    : ChatWelcome(
                      onActionTap: (message) {
                        chatProvider.sendMessage(message, context: context);
                        _scrollToBottom();
                      },
                    ),
          ),
          if (chatProvider.isLoading &&
              chatProvider.currentTypingMessage != null)
            _buildThinkingIndicator(context, chatProvider),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ChatInput(
              onSendMessage: (message, {imageUrl}) {
                chatProvider.sendMessage(
                  message,
                  imageUrl: imageUrl,
                  context: context,
                );
                _scrollToBottom();
              },
              isLoading: chatProvider.isLoading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoApiKeyState(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.surface,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.key_off,
                  size: 60,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                localizations.noApiKeyConfigured,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                localizations.configureApiKeyToUseChat,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/settings/api-key');
                },
                icon: const Icon(Icons.settings),
                label: Text(localizations.configureApiKeyButton),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  _chatProvider.refreshApiKeyConfiguration();
                  // Show loading indicator
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(localizations.loading),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: Text(localizations.reloadApiKeyButton),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatList(BuildContext context, ChatProvider chatProvider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      itemCount: chatProvider.messages.length,
      itemBuilder: (context, index) {
        final message = chatProvider.messages[index];
        return MessageBubble(
          message: message,
          userProfile: chatProvider.currentUserProfile,
          botProfile: chatProvider.currentBotProfile,
          onRetry:
              message.hasFailed
                  ? () =>
                      chatProvider.retryMessage(message.id, context: context)
                  : null,
        );
      },
    );
  }

  Widget _buildThinkingIndicator(
    BuildContext context,
    ChatProvider chatProvider,
  ) {
    final theme = Theme.of(context);
    final currentStep = chatProvider.currentAgentStep;
    final message = chatProvider.currentTypingMessage ?? 'AI is thinking...';
    final thinkingSteps = chatProvider.currentThinkingSteps;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy,
              size: 20,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          currentStep ?? message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (thinkingSteps.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 120),
                      child: SingleChildScrollView(
                        reverse: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              thinkingSteps.length > 5
                                  ? thinkingSteps
                                      .sublist(thinkingSteps.length - 5)
                                      .map(
                                        (step) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 1,
                                          ),
                                          child: Text(
                                            step,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.6),
                                                  fontSize: 11,
                                                ),
                                          ),
                                        ),
                                      )
                                      .toList()
                                  : thinkingSteps
                                      .map(
                                        (step) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 1,
                                          ),
                                          child: Text(
                                            step,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.6),
                                                  fontSize: 11,
                                                ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearChatDialog(BuildContext context, ChatProvider chatProvider) {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localizations.clearChat),
            content: Text(localizations.clearChatConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localizations.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  chatProvider.clearChat(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localizations.chatCleared)),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text(localizations.clearChat),
              ),
            ],
          ),
    );
  }

  void _showUserProfileDialog(BuildContext context, ChatProvider chatProvider) {
    final userProfile = chatProvider.currentUserProfile;
    if (userProfile == null) return;

    showDialog(
      context: context,
      builder:
          (context) => UserProfileCustomizationDialog(
            initialProfile: userProfile,
            onProfileUpdated: (updatedProfile) {
              chatProvider.updateUserProfile(updatedProfile);
            },
          ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
