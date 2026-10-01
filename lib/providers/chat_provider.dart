import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import '../models/chat_message.dart';
import '../models/chat_types.dart' as agent_types;
import '../models/chat_types.dart' show ChatMessageRole;
import '../models/user_ingredient.dart';
import '../models/chat_profile.dart';
import '../services/chat/openai_service.dart';
import '../services/chat/chat_agent_service.dart';
import '../services/storage/chat_profile_service.dart';
import '../repositories/dish_repository.dart';
import '../repositories/meal_repository.dart';
import '../repositories/user_profile_repository.dart';
import '../services/storage/dish_service.dart';
import '../services/storage/storage_service_provider.dart';
import '../services/user_session_service.dart';

/// Storage problems the chat screen reports to the user.
enum ChatNotice {
  historyLoadFailed,
  historySaveFailed,
  settingsFailed,
  profilesLoadFailed,
  profileSaveFailed,
}

/// A failure the user has to see instead of a fallback reply.
class _ChatFailure implements Exception {
  final ChatErrorKind kind;
  const _ChatFailure(this.kind);
}

class ChatProvider extends ChangeNotifier {
  final OpenAIService _openAIService = OpenAIService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _currentTypingMessage;
  bool _isApiKeyConfigured = false;
  bool _apiKeyReadFailed = false;
  bool _disposed = false;
  final List<ChatNotice> _pendingNotices = [];
  final Set<ChatNotice> _shownNotices = {};

  // Agent system components (lazy-initialized)
  ChatAgentService? _chatAgentService;
  bool _agentModeEnabled = false;
  bool _deepSearchEnabled = false;

  // Agent thinking steps for real-time display
  final List<String> _currentThinkingSteps = [];
  String? _currentAgentStep; // Profile management
  ChatProfiles? _currentChatProfiles;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get currentTypingMessage => _currentTypingMessage;
  bool get hasMessages => _messages.isNotEmpty;
  bool get isApiKeyConfigured => _isApiKeyConfigured;

  /// The stored key could not be read (distinct from "no key saved").
  bool get apiKeyReadFailed => _apiKeyReadFailed;

  /// Returns notices not shown yet; storage notices are shown once per session.
  List<ChatNotice> takeNotices() {
    final notices = List.of(_pendingNotices);
    _pendingNotices.clear();
    _shownNotices.addAll(notices);
    return notices;
  }

  void _addNotice(ChatNotice notice, {bool once = true}) {
    if (once && _shownNotices.contains(notice)) return;
    if (!_pendingNotices.contains(notice)) _pendingNotices.add(notice);
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // Agent system getters and setters
  bool get isAgentModeEnabled => _agentModeEnabled;
  bool get isDeepSearchEnabled => _deepSearchEnabled;
  List<String> get currentThinkingSteps =>
      List.unmodifiable(_currentThinkingSteps);
  String? get currentAgentStep => _currentAgentStep;
  set agentModeEnabled(bool enabled) {
    _agentModeEnabled = enabled;
    if (enabled) {
      _initializeAgentService();
    }
    _saveAgentSettings(); // Save settings when changed
    notifyListeners();
  }

  /// Use this instead of the setter to ensure agent service is ready
  Future<void> setAgentModeEnabled(bool enabled) async {
    _agentModeEnabled = enabled;
    if (enabled) {
      await _initializeAgentService();
    }
    await _saveAgentSettings();
    notifyListeners();
  }

  set deepSearchEnabled(bool enabled) {
    _deepSearchEnabled = enabled;
    _chatAgentService?.enableDeepSearch(enabled);
    _saveAgentSettings(); // Save settings when changed
    notifyListeners();
  }

  ChatProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    await _checkApiKeyConfiguration();
    await _loadMessages();
    await _loadAgentSettings();
    await _loadProfiles();
  }

  /// Initialize agent service when needed
  Future<void> _initializeAgentService() async {
    if (_chatAgentService != null) return;
    try {
      // Get SharedPreferences for UserSessionService
      final prefs = await StorageServiceProvider().getPrefs();
      final userSessionService = UserSessionService(prefs);

      // Initialize default user if needed
      await userSessionService.initializeDefaultUser();

      // Create repositories - these are lazy wrappers around existing services
      final dishRepository = DishRepository();
      final mealRepository = MealRepository(
        userSessionService: userSessionService,
      );
      final userProfileRepository = UserProfileRepository(
        userSessionService: userSessionService,
      );
      final dishService = DishService();

      // Initialize default user profile if needed
      await userProfileRepository.initializeDefaultUserProfile();

      _chatAgentService = ChatAgentService(
        openaiService: _openAIService,
        dishRepository: dishRepository,
        mealRepository: mealRepository,
        userProfileRepository: userProfileRepository,
        dishService: dishService,
      );

      // Apply current settings
      _chatAgentService!.enableDeepSearch(_deepSearchEnabled);

      debugPrint('🤖 ChatProvider: Agent service initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize agent service: $e');
      _agentModeEnabled = false;
      notifyListeners();
    }
  }

  /// Load agent settings from SharedPreferences via StorageServiceProvider
  Future<void> _loadAgentSettings() async {
    try {
      final prefs = await StorageServiceProvider().getPrefs();
      _agentModeEnabled = prefs.getBool('agent_mode_enabled') ?? false;
      _deepSearchEnabled = prefs.getBool('deep_search_enabled') ?? false;
      if (_agentModeEnabled) {
        await _initializeAgentService();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading agent settings: $e');
      _addNotice(ChatNotice.settingsFailed);
    }
  }

  /// Save agent settings to SharedPreferences via StorageServiceProvider
  Future<void> _saveAgentSettings() async {
    try {
      final prefs = await StorageServiceProvider().getPrefs();
      await prefs.setBool('agent_mode_enabled', _agentModeEnabled);
      await prefs.setBool('deep_search_enabled', _deepSearchEnabled);
    } catch (e) {
      debugPrint('Error saving agent settings: $e');
      _addNotice(ChatNotice.settingsFailed);
    }
  }

  Future<void> addWelcomeMessage(BuildContext context) async {
    if (_messages.isEmpty) {
      final localizations = AppLocalizations.of(context);
      final welcomeContent =
          _isApiKeyConfigured
              ? localizations.providersChatProviderWelcomeToChat
              : localizations.providersChatProviderTestChatWelcome;

      final welcomeMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: welcomeContent,
        sender: MessageSender.assistant,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      );

      _messages.add(welcomeMessage);
      await _saveMessages();
      notifyListeners();
    }
  }

  Future<void> _checkApiKeyConfiguration() async {
    try {
      _isApiKeyConfigured = await _openAIService.isConfigured();
      _apiKeyReadFailed = false;
    } catch (e) {
      debugPrint('Error checking API key configuration: ${e.runtimeType}');
      // Keep the last known state instead of silently switching to test mode.
      _apiKeyReadFailed = true;
    }
    if (!_disposed) notifyListeners();
  }

  Future<void> refreshApiKeyConfiguration() async {
    await _checkApiKeyConfiguration();
  }

  Future<void> _loadMessages() async {
    var skipped = 0;
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getStringList('chat_messages') ?? [];

      _messages.clear();
      for (final messageJson in messagesJson) {
        try {
          final message = ChatMessage.fromJson(json.decode(messageJson));
          _messages.add(message);
        } catch (e) {
          debugPrint('Skipping unreadable chat message (${e.runtimeType})');
          skipped++;
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading chat messages: ${e.runtimeType}');
      skipped++;
    }
    if (skipped > 0) _addNotice(ChatNotice.historyLoadFailed);
  }

  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson =
          _messages.map((message) => json.encode(message.toJson())).toList();

      await prefs.setStringList('chat_messages', messagesJson);
    } catch (e) {
      debugPrint('Error saving chat messages: ${e.runtimeType}');
      _addNotice(ChatNotice.historySaveFailed);
    }
  }

  ChatErrorKind _errorKindOf(Object error) =>
      error is _ChatFailure ? error.kind : OpenAIService.errorKindOf(error);

  /// Re-reads the key after a read failure; throws if it is still unreadable.
  Future<void> _ensureApiKeyReadable() async {
    if (!_apiKeyReadFailed) return;
    await _checkApiKeyConfiguration();
    if (_apiKeyReadFailed) {
      throw const _ChatFailure(ChatErrorKind.keyUnreadable);
    }
  }

  Future<void> sendMessage(
    String content, {
    String? imageUrl,
    BuildContext? context,
    List<UserIngredient>? userIngredients,
  }) async {
    if (_isLoading ||
        (content.trim().isEmpty &&
            imageUrl == null &&
            (userIngredients == null || userIngredients.isEmpty))) {
      return;
    }
    final localizations = context == null ? null : AppLocalizations.of(context);
    final messageContent =
        content.trim().isEmpty && imageUrl == null
            ? localizations?.providersChatProviderIngredientsPrompt ??
                'What can I make with these ingredients?'
            : content;
    _isLoading = true;
    notifyListeners();

    debugPrint(
      '🔍 DEBUG: ChatProvider received ${userIngredients?.length ?? 0} ingredients',
    );

    ChatMessage? userMessage;
    try {
      // Always reload agent settings from SharedPreferences before sending a message
      await _loadAgentSettings();

      // Ensure agent service is initialized if agent mode is enabled
      if (_agentModeEnabled && _chatAgentService == null) {
        await _initializeAgentService();
      }
      final currentMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: messageContent,
        sender: MessageSender.user,
        timestamp: DateTime.now(),
        status: MessageStatus.sending,
        imageUrl: imageUrl,
        metadata:
            userIngredients != null && userIngredients.isNotEmpty
                ? {
                  'userIngredients':
                      userIngredients.map((e) => e.toJson()).toList(),
                }
                : null,
      );
      userMessage = currentMessage;

      _messages.add(currentMessage);
      notifyListeners();

      // Mark message as sent
      final sentMessage = currentMessage.copyWith(status: MessageStatus.sent);
      final index = _messages.indexWhere((m) => m.id == currentMessage.id);
      if (index != -1) {
        _messages[index] = sentMessage;
      }
      _currentTypingMessage =
          localizations != null
              ? localizations.providersChatProviderAiThinking
              : 'AI is thinking...';
      notifyListeners();
      await _ensureApiKeyReadable();
      String response;
      Map<String, dynamic>? responseMetadata;

      if (_isApiKeyConfigured &&
          _agentModeEnabled &&
          _chatAgentService != null) {
        debugPrint('🧠 [ChatProvider] Using full agent pipeline for reply');
        final agentResponse = await _processWithAgentService(
          messageContent,
          imageUrl,
          userIngredients,
          localizedFallbacks:
              localizations != null
                  ? _buildLocalizedFallbacks(localizations)
                  : null,
        );
        response = agentResponse['response'] as String;
        responseMetadata = agentResponse['metadata'] as Map<String, dynamic>?;
        // Ensure mode is set for UI detection
        if (responseMetadata != null) {
          responseMetadata['mode'] = 'full_agent_pipeline';
        }
      } else if (_isApiKeyConfigured) {
        debugPrint('💬 [ChatProvider] Using fallback OpenAI service');
        response = await _openAIService.sendMessage(
          messageContent,
          imageUrl: imageUrl,
        );
        responseMetadata = {
          'mode': 'fallback_openai',
          'reason':
              _agentModeEnabled
                  ? (_chatAgentService == null
                      ? 'Agent service was not initialized in time.'
                      : 'Unknown error: agent pipeline not used.')
                  : 'Agent mode is disabled.',
          'agentModeEnabled': _agentModeEnabled,
          'deepSearchEnabled': _deepSearchEnabled,
          'apiKeyConfigured': _isApiKeyConfigured,
        };
        debugPrint('💬 [ChatProvider] Response metadata: $responseMetadata');
      } else {
        debugPrint('📝 [ChatProvider] Using test response');
        response =
            localizations != null
                ? localizations.providersChatProviderTestChatResponse
                : 'Thanks for trying PlatePal! This is a test response to show you how our AI assistant works. To get real nutrition advice and meal suggestions, please configure your OpenAI API key in settings.';
        await Future.delayed(const Duration(milliseconds: 1500));
        responseMetadata = null;
      }

      // Create assistant message with metadata from agent processing
      final assistantMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response,
        sender: MessageSender.assistant,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
        metadata: responseMetadata,
      );

      _messages.add(assistantMessage);
      await _saveMessages();
    } catch (e) {
      debugPrint('Error sending message: ${e.runtimeType}');
      if (userMessage != null) {
        final failedMessage = userMessage.copyWith(
          status: MessageStatus.failed,
          metadata: {...?userMessage.metadata, 'errorKind': _errorKindOf(e).name},
        );
        final index = _messages.indexWhere((m) => m.id == failedMessage.id);
        if (index != -1) {
          _messages[index] = failedMessage;
        }
        await _saveMessages();
      }
    } finally {
      _isLoading = false;
      _currentTypingMessage = null;
      notifyListeners();
    }
  }

  Future<void> retryMessage(String messageId, {BuildContext? context}) async {
    final messageIndex = _messages.indexWhere((m) => m.id == messageId);
    if (messageIndex == -1) return;

    final message = _messages[messageIndex];
    if (message.sender != MessageSender.user) return;

    // Update message status to sending
    _messages[messageIndex] = message.copyWith(status: MessageStatus.sending);
    notifyListeners();
    try {
      _isLoading = true;
      final localizations =
          context != null ? AppLocalizations.of(context) : null;
      _currentTypingMessage =
          localizations?.providersChatProviderAiThinking ?? 'AI is thinking...';
      notifyListeners();
      await _ensureApiKeyReadable();

      String response;
      if (_isApiKeyConfigured) {
        // Get real AI response
        response = await _openAIService.sendMessage(
          message.content,
          imageUrl: message.imageUrl,
        );
      } else {
        // Generate test response
        response =
            localizations?.providersChatProviderTestChatResponse ??
            'Thanks for trying PlatePal! This is a test response to show you how our AI assistant works. To get real nutrition advice and meal suggestions, please configure your OpenAI API key in settings.';

        // Add a small delay to simulate AI thinking
        await Future.delayed(const Duration(milliseconds: 1500));
      }

      // Mark original message as sent
      _messages[messageIndex] = message.copyWith(
        status: MessageStatus.sent,
        metadata: {...?message.metadata}..remove('errorKind'),
      );

      // Add assistant response
      final assistantMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response,
        sender: MessageSender.assistant,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      );

      _messages.add(assistantMessage);
      await _saveMessages();
    } catch (e) {
      debugPrint('Error retrying message: ${e.runtimeType}');

      // Mark message as failed again
      _messages[messageIndex] = message.copyWith(
        status: MessageStatus.failed,
        metadata: {...?message.metadata, 'errorKind': _errorKindOf(e).name},
      );
      await _saveMessages();
    } finally {
      _isLoading = false;
      _currentTypingMessage = null;
      notifyListeners();
    }
  }

  Future<void> clearChat(BuildContext context) async {
    _messages.clear();
    await _saveMessages();
    // Don't add welcome message automatically to show the welcome screen
    notifyListeners();
  }

  void removeMessage(String messageId) {
    _messages.removeWhere((message) => message.id == messageId);
    _saveMessages();
    notifyListeners();
  }

  /// Public method to reload agent settings from SharedPreferences
  Future<void> reloadAgentSettings() async {
    await _loadAgentSettings();
  }

  /// Load profiles from storage
  Future<void> _loadProfiles() async {
    try {
      _currentChatProfiles = await ChatProfileService.loadChatProfiles();
    } catch (e) {
      debugPrint('Error loading chat profiles: ${e.runtimeType}');
      // Show defaults in memory only; never overwrite saved profiles after a read error.
      _currentChatProfiles ??= ChatProfiles.createDefault();
      _addNotice(ChatNotice.profilesLoadFailed);
    }
    notifyListeners();
  }

  /// Saves [profiles] and applies them only if saving worked.
  Future<bool> _applyProfiles(ChatProfiles profiles) async {
    var saved = false;
    try {
      saved = await ChatProfileService.saveChatProfiles(profiles);
    } catch (e) {
      debugPrint('Error saving chat profiles: ${e.runtimeType}');
    }
    if (!saved) {
      _addNotice(ChatNotice.profileSaveFailed, once: false);
      return false;
    }
    _currentChatProfiles = profiles;
    notifyListeners();
    return true;
  }

  /// Update user profile; returns false if it could not be saved.
  Future<bool> updateUserProfile(ChatUserProfile userProfile) async {
    if (_currentChatProfiles == null) return false;
    return _applyProfiles(
      _currentChatProfiles!.copyWith(userProfile: userProfile),
    );
  }

  /// Update bot profile; returns false if it could not be saved.
  Future<bool> updateBotProfile(ChatBotProfile botProfile) async {
    if (_currentChatProfiles == null) return false;
    return _applyProfiles(
      _currentChatProfiles!.copyWith(botProfile: botProfile),
    );
  }

  /// Reset profiles to default; returns false if it could not be saved.
  Future<bool> resetProfilesToDefault() =>
      _applyProfiles(ChatProfiles.createDefault());

  /// Get current chat profiles
  ChatProfiles? get currentChatProfiles => _currentChatProfiles;

  /// Get current user profile
  ChatUserProfile? get currentUserProfile => _currentChatProfiles?.userProfile;

  /// Get current bot profile
  ChatBotProfile? get currentBotProfile => _currentChatProfiles?.botProfile;

  /// Public method to reload profiles from storage
  Future<void> reloadProfiles() async {
    await _loadProfiles();
  }

  /// Process message using the agent service with real-time thinking steps
  Future<Map<String, dynamic>> _processWithAgentService(
    String content,
    String? imageUrl,
    List<UserIngredient>? userIngredients, {
    Map<String, String>? localizedFallbacks,
  }) async {
    try {
      // Clear previous thinking steps
      _currentThinkingSteps.clear();
      _currentAgentStep = null;
      _openAIService.lastErrorKind = null;
      notifyListeners();

      // Convert ChatMessage list to agent_types.ChatMessage list for the agent service
      final agentMessages =
          _messages
              .map(
                (msg) => agent_types.ChatMessage(
                  id: msg.id,
                  content: msg.content,
                  role:
                      msg.sender == MessageSender.user
                          ? ChatMessageRole.user.name
                          : ChatMessageRole.assistant.name,
                  timestamp: msg.timestamp,
                  metadata: {'imageUrl': msg.imageUrl, ...?msg.metadata},
                ),
              )
              .toList(); // Create bot configuration using current bot profile
      final botProfile = currentBotProfile;
      final botConfig = agent_types.BotConfiguration(
        type: 'nutrition_assistant',
        name: botProfile?.name ?? 'PlatePal Assistant',
        behaviorType: botProfile?.behaviorType ?? 'helpful_expert',
        additionalConfig: {
          if (botProfile?.personalityType != null)
            'personalityType': botProfile!.personalityType,
          ...?botProfile?.additionalConfig,
        },
      );

      // Process with agent service using thinking step callback
      final response = await _chatAgentService!.processMessage(
        userMessage: content,
        conversationHistory: agentMessages,
        botConfig: botConfig,
        imageUri: imageUrl,
        userIngredients: userIngredients,
        localizedFallbacks: localizedFallbacks,
        onThinkingStep: (step, details) {
          _currentAgentStep = step;
          _currentThinkingSteps.add(step);
          if (details != null) {
            _currentThinkingSteps.add('   $details');
          }
          notifyListeners();
        },
      ); // Clear thinking steps when done
      _currentAgentStep = null;
      notifyListeners();

      // The pipeline turns request errors into generic replies; report the real cause.
      final mode = response.metadata?['mode'];
      final lastErrorKind = _openAIService.lastErrorKind;
      if ((mode == 'step_failure' || mode == 'error_response') &&
          lastErrorKind != null &&
          lastErrorKind != ChatErrorKind.unknown) {
        throw _ChatFailure(lastErrorKind);
      }

      // Return both response and metadata, including recommendation
      final notes = responseNotes(response.metadata);
      final proposals = mealLogProposals(response.metadata);
      final combinedMetadata = {
        ...?response.metadata,
        if (response.recommendation != null)
          'recommendation': response.recommendation,
        if (notes.isNotEmpty) 'responseNotes': notes,
        if (proposals.isNotEmpty) 'mealLogProposals': proposals,
      };
      return {'response': response.replyText, 'metadata': combinedMetadata};
    } catch (e) {
      debugPrint('❌ Agent service processing failed: ${e.runtimeType}');
      // Clear thinking steps on error
      _currentThinkingSteps.clear();
      _currentAgentStep = null;
      notifyListeners();

      // A second endpoint cannot fix a rejected key, a quota or a dead connection.
      final kind = _errorKindOf(e);
      if (kind == ChatErrorKind.auth ||
          kind == ChatErrorKind.rateLimit ||
          kind == ChatErrorKind.network) {
        throw _ChatFailure(kind);
      }

      // Fallback to traditional service
      final fallbackResponse = await _openAIService.sendMessage(
        content,
        imageUrl: imageUrl,
      );
      return {'response': fallbackResponse, 'metadata': null};
    }
  }

  /// Notes for answers built from incomplete data, read from agent step results.
  @visibleForTesting
  static List<String> responseNotes(Map<String, dynamic>? metadata) {
    final steps = metadata?['stepResults'];
    if (steps is! List) return const [];
    Map? lastData(String stepName) {
      final data =
          steps
              .whereType<Map>()
              .where((step) => step['stepName'] == stepName)
              .lastOrNull?['data'];
      return data is Map ? data : null;
    }

    final failedContext = lastData('context_gathering')?['failedContextParts'];
    return [
      if (failedContext is List && failedContext.isNotEmpty) 'contextIncomplete',
      if (lastData('response_generation')?['imageAnalysisFailed'] == true)
        'imageNotAnalyzed',
    ];
  }

  /// `log_meal` proposals of the final response, read from agent step results.
  @visibleForTesting
  static List<Map<String, dynamic>> mealLogProposals(
    Map<String, dynamic>? metadata,
  ) {
    final steps = metadata?['stepResults'];
    if (steps is! List) return const [];
    final data =
        steps
            .whereType<Map>()
            .where((step) => step['stepName'] == 'response_generation')
            .lastOrNull?['data'];
    final proposals = data is Map ? data['mealLogProposals'] : null;
    if (proposals is! List) return const [];
    return [
      for (final proposal in proposals)
        if (proposal is Map) Map<String, dynamic>.from(proposal),
    ];
  }

  /// Remembers that the user logged or dismissed proposal [index] of
  /// [messageId], so the card stays resolved after a restart.
  Future<void> setMealLogProposalStatus(
    String messageId,
    int index,
    String status,
  ) async {
    final position = _messages.indexWhere((m) => m.id == messageId);
    if (position == -1) return;
    final message = _messages[position];
    final statuses = Map<String, dynamic>.from(
      message.metadata?['mealLogProposalStatus'] as Map? ?? const {},
    )..['$index'] = status;
    _messages[position] = message.copyWith(
      metadata: {...?message.metadata, 'mealLogProposalStatus': statuses},
    );
    notifyListeners();
    await _saveMessages();
  }

  /// Builds the map of localised fallback strings used by the agent pipeline
  /// for translated error/status messages shown to the user.
  Map<String, String> _buildLocalizedFallbacks(AppLocalizations l10n) => {
    'parsing': l10n.servicesChatAgentFallbackParsing,
    'critical': l10n.servicesChatAgentFallbackCritical,
    'network': l10n.servicesChatAgentFallbackNetwork,
    'context': l10n.servicesChatAgentFallbackContext,
    'generic': l10n.servicesChatAgentFallbackGeneric,
    'generateResponse': l10n.servicesChatAgentFallbackGenerateResponse,
    'temporaryIssue': l10n.servicesChatAgentFallbackTemporaryIssue,
    'rephrase': l10n.servicesChatAgentFallbackRephrase,
    'dishInfo': l10n.servicesChatAgentFallbackDishInfo,
  };
}
