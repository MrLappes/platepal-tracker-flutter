import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/chat_message.dart';
import '../models/nutrition_analysis.dart';
import '../services/chat/openai_service.dart';

class ChatProvider extends ChangeNotifier {
  final OpenAIService _openAIService = OpenAIService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _currentTypingMessage;
  bool _isApiKeyConfigured = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get currentTypingMessage => _currentTypingMessage;
  bool get hasMessages => _messages.isNotEmpty;
  bool get isApiKeyConfigured => _isApiKeyConfigured;
  ChatProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    await _checkApiKeyConfiguration();
    await _loadMessages();
  }

  Future<void> addWelcomeMessage(BuildContext context) async {
    if (_messages.isEmpty) {
      final localizations = AppLocalizations.of(context)!;
      final welcomeContent =
          _isApiKeyConfigured
              ? localizations.welcomeToChat
              : localizations.testChatWelcome;

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
  }) async {
    if (content.trim().isEmpty && imageUrl == null) return;

    // Create user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
      imageUrl: imageUrl,
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
              ? AppLocalizations.of(context)!.aiThinking
              : 'AI is thinking...';
      notifyListeners();

      String response;
      if (_isApiKeyConfigured) {
        // Get real AI response
        response = await _openAIService.sendMessage(
          content,
          imageUrl: imageUrl,
        );
      } else {
        // Generate test response
        response =
            context != null
                ? AppLocalizations.of(context)!.testChatResponse
                : 'Thanks for trying PlatePal! This is a test response to show you how our AI assistant works. To get real nutrition advice and meal suggestions, please configure your OpenAI API key in settings.';

        // Add a small delay to simulate AI thinking
        await Future.delayed(const Duration(milliseconds: 1500));
      }

      // Create assistant message
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
              ? AppLocalizations.of(context)!.aiThinking
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
                ? AppLocalizations.of(context)!.testChatResponse
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

  Future<NutritionAnalysis?> analyzeNutrition(
    String content, {
    String? imageUrl,
  }) async {
    try {
      _isLoading = true;
      _currentTypingMessage = 'Analyzing nutrition...';
      notifyListeners();

      final analysis = await _openAIService.analyzeNutrition(
        content,
        imageUrl: imageUrl,
      );
      return analysis;
    } catch (e) {
      debugPrint('Error analyzing nutrition: $e');
      return null;
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
}
