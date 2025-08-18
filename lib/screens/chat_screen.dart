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
  bool _isUserAtBottom =
      true; // track whether user is currently at the bottom (or near it)

  @override
  void initState() {
    super.initState();
    _chatProvider = ChatProvider();

    // Listen to user scroll to detect if they scrolled up (so we don't force-scroll)
    _scrollController.addListener(_onScroll);

    // Listen to chat provider changes so we can auto-scroll when new messages arrive
    _chatProvider.addListener(_onMessagesUpdated);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _chatProvider.removeListener(_onMessagesUpdated);
    _scrollController.dispose();
    // Dispose provider instance we created locally
    _chatProvider.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh API key configuration when screen is shown
    _chatProvider.refreshApiKeyConfiguration();
    // Don't add welcome message automatically to show the welcome screen

    // Ensure we scroll to bottom when the screen is opened (post frame so list is built)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Mark as at bottom on open so we behave like a real chat initially
      _isUserAtBottom = true;
      _scrollToBottom();
    });
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
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
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
                  color: Theme.of(
                    context,
                  ).colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ChatInput(
              onSendMessage: (message, {imageUrl, ingredients}) {
                chatProvider.sendMessage(
                  message,
                  imageUrl: imageUrl,
                  context: context,
                  userIngredients: ingredients,
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
            theme.colorScheme.primary.withValues(alpha: 0.1),
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
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
                    color: theme.colorScheme.shadow.withValues(alpha: 0.1),
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
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.8,
                            ),
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
                                                      .withValues(alpha: 0.6),
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
                                                      .withValues(alpha: 0.6),
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

  void _onScroll() {
    if (!_scrollController.hasClients ||
        !_scrollController.position.hasContentDimensions)
      return;
    final max = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    // Consider "near bottom" within 120 pixels as still at bottom (slightly larger tolerance)
    final atBottom = (max - current) <= 120;
    if (atBottom != _isUserAtBottom) {
      setState(() {
        _isUserAtBottom = atBottom;
      });
    }
  }

  void _onMessagesUpdated() {
    if (!mounted) return;
    // If user is at/near bottom, attempt to scroll to bottom. Use multiple attempts to
    // handle layout changes (e.g. thinking indicator or images that change the extent after build).
    if (_isUserAtBottom) {
      _scrollToBottom(retryAttempts: 3);
    }
  }

  void _scrollToBottom({int retryAttempts = 1}) {
    // Schedule scrolling on next frame, and optionally retry after short delays to
    // account for async layout changes (images, indicator appearing etc.).
    Future<void> tryScroll(int remaining) async {
      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!_scrollController.hasClients) return;

        try {
          final target = _scrollController.position.maxScrollExtent;
          final current = _scrollController.position.pixels;

          // If we're already close to the bottom just jump to avoid long animations
          if ((target - current).abs() < 8) {
            _scrollController.jumpTo(target);
            return;
          }

          // Clamp target to valid range
          final clamped = target.clamp(
            _scrollController.position.minScrollExtent,
            _scrollController.position.maxScrollExtent,
          );

          await _scrollController.animateTo(
            clamped,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        } catch (e) {
          // ignore errors if controller not ready
        }

        if (remaining > 0) {
          // Small delay before retrying to let any late layout changes settle
          await Future.delayed(const Duration(milliseconds: 120));
          await tryScroll(remaining - 1);
        }
      });
    }

    tryScroll(retryAttempts - 1);
  }
}
