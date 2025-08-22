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

class ChatProvider extends ChangeNotifier {
  final OpenAIService _openAIService = OpenAIService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _currentTypingMessage;
  bool _isApiKeyConfigured = false;

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
      notifyListeners();
    } catch (e) {
      debugPrint('Error checking API key configuration: $e');
      _isApiKeyConfigured = false;
    }
  }

  Future<void> refreshApiKeyConfiguration() async {
    await _checkApiKeyConfiguration();
  }

  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getStringList('chat_messages') ?? [];

      _messages.clear();
      for (final messageJson in messagesJson) {
        try {
          final message = ChatMessage.fromJson(json.decode(messageJson));
          _messages.add(message);
        } catch (e) {
          debugPrint('Error loading message: $e');
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading chat messages: $e');
    }
  }

  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson =
          _messages.map((message) => json.encode(message.toJson())).toList();

      await prefs.setStringList('chat_messages', messagesJson);
    } catch (e) {
      debugPrint('Error saving chat messages: $e');
    }
  }

  Future<void> sendMessage(
    String content, {
    String? imageUrl,
    BuildContext? context,
    List<UserIngredient>? userIngredients,
  }) async {
    if (content.trim().isEmpty && imageUrl == null) return;

    // Debug: Print what we received
    debugPrint(
      '🔍 DEBUG: ChatProvider received ${userIngredients?.length ?? 0} ingredients',
    );
    if (userIngredients != null) {
      for (final ingredient in userIngredients) {
        debugPrint(
          '   - ${ingredient.name} (${ingredient.quantity}${ingredient.unit})',
        );
      }
    }

    // Always reload agent settings from SharedPreferences before sending a message
    await _loadAgentSettings();

    // Ensure agent service is initialized if agent mode is enabled
    if (_agentModeEnabled && _chatAgentService == null) {
      await _initializeAgentService();
    } // Create user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
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

    _messages.add(userMessage);
    notifyListeners();

    try {
      // Mark message as sent
      final sentMessage = userMessage.copyWith(status: MessageStatus.sent);
      final index = _messages.indexWhere((m) => m.id == userMessage.id);
      if (index != -1) {
        _messages[index] = sentMessage;
      }
      _isLoading = true;
      _currentTypingMessage =
          context != null
              // ignore: use_build_context_synchronously
              ? AppLocalizations.of(context).providersChatProviderAiThinking
              : 'AI is thinking...';
      notifyListeners();
      String response;
      Map<String, dynamic>? responseMetadata;

      if (_isApiKeyConfigured &&
          _agentModeEnabled &&
          _chatAgentService != null) {
        debugPrint('🧠 [ChatProvider] Using full agent pipeline for reply');
        final agentResponse = await _processWithAgentService(
          content,
          imageUrl,
          userIngredients,
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
          content,
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
            context != null
                // ignore: use_build_context_synchronously
                ? AppLocalizations.of(context).providersChatProviderTestChatResponse
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
      debugPrint('Error sending message: $e');
      // Mark message as failed
      final failedMessage = userMessage.copyWith(status: MessageStatus.failed);
      final index = _messages.indexWhere((m) => m.id == userMessage.id);
      if (index != -1) {
        _messages[index] = failedMessage;
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
      _currentTypingMessage =
          context != null
              ? AppLocalizations.of(context).providersChatProviderAiThinking
              : 'AI is thinking...';
      notifyListeners();

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
            context != null
                ? AppLocalizations.of(context).providersChatProviderTestChatResponse
                : 'Thanks for trying PlatePal! This is a test response to show you how our AI assistant works. To get real nutrition advice and meal suggestions, please configure your OpenAI API key in settings.';

        // Add a small delay to simulate AI thinking
        await Future.delayed(const Duration(milliseconds: 1500));
      }

      // Mark original message as sent
      _messages[messageIndex] = message.copyWith(status: MessageStatus.sent);

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
      debugPrint('Error retrying message: $e');

      // Mark message as failed again
      _messages[messageIndex] = message.copyWith(status: MessageStatus.failed);
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
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading chat profiles: $e');
      // Create default profiles if loading fails
      _currentChatProfiles = ChatProfiles.createDefault();
      await ChatProfileService.saveChatProfiles(_currentChatProfiles!);
      notifyListeners();
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(ChatUserProfile userProfile) async {
    if (_currentChatProfiles == null) return;

    try {
      final updatedProfiles = _currentChatProfiles!.copyWith(
        userProfile: userProfile,
      );

      await ChatProfileService.saveChatProfiles(updatedProfiles);
      _currentChatProfiles = updatedProfiles;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user profile: $e');
    }
  }

  /// Update bot profile
  Future<void> updateBotProfile(ChatBotProfile botProfile) async {
    if (_currentChatProfiles == null) return;

    try {
      final updatedProfiles = _currentChatProfiles!.copyWith(
        botProfile: botProfile,
      );

      await ChatProfileService.saveChatProfiles(updatedProfiles);
      _currentChatProfiles = updatedProfiles;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating bot profile: $e');
    }
  }

  /// Reset profiles to default
  Future<void> resetProfilesToDefault() async {
    try {
      _currentChatProfiles = ChatProfiles.createDefault();
      await ChatProfileService.saveChatProfiles(_currentChatProfiles!);
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting profiles: $e');
    }
  }

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
    List<UserIngredient>? userIngredients,
  ) async {
    try {
      // Clear previous thinking steps
      _currentThinkingSteps.clear();
      _currentAgentStep = null;
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

      // Return both response and metadata, including recommendation
      final combinedMetadata = {
        ...?response.metadata,
        if (response.recommendation != null)
          'recommendation': response.recommendation,
      };
      return {'response': response.replyText, 'metadata': combinedMetadata};
    } catch (e) {
      debugPrint('❌ Agent service processing failed: $e');
      // Clear thinking steps on error
      _currentThinkingSteps.clear();
      _currentAgentStep = null;
      notifyListeners();

      // Fallback to traditional service
      final fallbackResponse = await _openAIService.sendMessage(
        content,
        imageUrl: imageUrl,
      );
      return {'response': fallbackResponse, 'metadata': null};
    }
  }
}
