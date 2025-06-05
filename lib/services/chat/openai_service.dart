import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/image_utils.dart'; // Adjust the import based on your project structure

class OpenAIModel {
  final String id;
  final String displayName;
  final String? description;

  const OpenAIModel({
    required this.id,
    required this.displayName,
    this.description,
  });

  factory OpenAIModel.fromJson(Map<String, dynamic> json) {
    return OpenAIModel(
      id: json['id'] as String,
      displayName: _formatModelDisplayName(json['id'] as String),
      description: json['description'] as String?,
    );
  }

  static String _formatModelDisplayName(String modelId) {
    // Convert model IDs like "gpt-4-1106-preview" to "GPT-4 (1106 Preview)"
    final parts = modelId.split('-');

    if (parts[0] == 'gpt') {
      if (parts[1] == '3.5' && parts[2] == 'turbo') {
        final version = parts.length > 3 ? ' (${parts.skip(3).join(' ')})' : '';
        return 'GPT-3.5 Turbo$version';
      } else if (parts[1] == '4' || parts[1] == '4o') {
        final baseModel = 'GPT-${parts[1].toUpperCase()}';

        if (parts.length <= 2) return baseModel;

        // Check if it has a date pattern (YYMM)
        final datePattern = RegExp(r'^\d{4}$');
        if (parts[2].isNotEmpty && datePattern.hasMatch(parts[2])) {
          final year = parts[2].substring(0, 2);
          final month = parts[2].substring(2);
          final date = '20$year-$month';

          final suffix = parts.length > 3 ? ' ${parts.skip(3).join(' ')}' : '';
          return '$baseModel ($date$suffix)';
        }

        return '$baseModel ${parts.skip(2).join(' ')}';
      }
    }

    // For any other model format, just join with spaces and capitalize
    return parts
        .map((p) => p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1))
        .join(' ');
  }
}

class ApiKeyTestResult {
  final bool success;
  final String message;
  final bool isAuthError;

  const ApiKeyTestResult({
    required this.success,
    required this.message,
    this.isAuthError = false,
  });
}

/// Response models for chat completions
class ChatChoice {
  final OpenAiMessage message;
  final String finishReason;
  final int index;

  const ChatChoice({
    required this.message,
    required this.finishReason,
    required this.index,
  });

  factory ChatChoice.fromJson(Map<String, dynamic> json) {
    return ChatChoice(
      message: OpenAiMessage.fromJson(json['message'] as Map<String, dynamic>),
      finishReason: json['finish_reason'] as String,
      index: json['index'] as int,
    );
  }
}

class OpenAiMessage {
  final String role;
  final String? content;

  const OpenAiMessage({required this.role, this.content});

  factory OpenAiMessage.fromJson(Map<String, dynamic> json) {
    return OpenAiMessage(
      role: json['role'] as String,
      content: json['content'] as String?,
    );
  }
}

class ChatUsage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  const ChatUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory ChatUsage.fromJson(Map<String, dynamic> json) {
    return ChatUsage(
      promptTokens: json['prompt_tokens'] as int,
      completionTokens: json['completion_tokens'] as int,
      totalTokens: json['total_tokens'] as int,
    );
  }
}

class ChatCompletionResponse {
  final String id;
  final String object;
  final int created;
  final String model;
  final List<ChatChoice> choices;
  final ChatUsage? usage;

  const ChatCompletionResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    this.usage,
  });

  factory ChatCompletionResponse.fromJson(Map<String, dynamic> json) {
    return ChatCompletionResponse(
      id: json['id'] as String,
      object: json['object'] as String,
      created: json['created'] as int,
      model: json['model'] as String,
      choices:
          (json['choices'] as List<dynamic>)
              .map((e) => ChatChoice.fromJson(e as Map<String, dynamic>))
              .toList(),
      usage:
          json['usage'] != null
              ? ChatUsage.fromJson(json['usage'] as Map<String, dynamic>)
              : null,
    );
  }
}

class OpenAIService {
  static const String _apiKeyKey = 'openai_api_key';
  static const String _selectedModelKey = 'openai_selected_model';

  // Default models to show before fetching from API
  static const List<OpenAIModel> _defaultModels = [
    OpenAIModel(id: 'gpt-4o', displayName: 'GPT-4O'),
    OpenAIModel(id: 'gpt-4', displayName: 'GPT-4'),
    OpenAIModel(id: 'gpt-3.5-turbo', displayName: 'GPT-3.5 Turbo'),
    OpenAIModel(id: 'gpt-4o-mini', displayName: 'GPT-4O Mini'),
  ];

  /// Get the currently selected model
  String get selectedModel => _selectedModelCache ?? 'gpt-4o';
  String? _selectedModelCache;
  Future<String?> _getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }

  Future<String> getSelectedModel() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedModelCache = prefs.getString(_selectedModelKey) ?? 'gpt-4o';
    return _selectedModelCache!;
  }

  Future<void> setSelectedModel(String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedModelKey, model);
    _selectedModelCache = model;
  }

  Future<bool> isConfigured() async {
    final apiKey = await _getApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }

  Future<ApiKeyTestResult> testApiKey(String apiKey, String model) async {
    // Test the API key by sending a minimal chat completion request
    try {
      final url = Uri.parse('https://api.openai.com/v1/chat/completions');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      };
      final body = jsonEncode({
        'model': model,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are an assistant for PlatePal Tracker, a nutrition tracking app. Reply with a short welcome message.',
          },
          {
            'role': 'user',
            'content': 'Say hello to the new user of PlatePal Tracker',
          },
        ],
        'max_tokens': 100,
      });
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'] ?? '';
        if (content.isEmpty) {
          return const ApiKeyTestResult(
            success: false,
            message:
                'Received empty response from OpenAI. The API key might be valid but the model may not be available.',
          );
        }
        return ApiKeyTestResult(success: true, message: content);
      } else {
        String errorMessage =
            'Network error occurred while testing the API key.';
        bool isAuthError = false;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error']?['message'] ?? errorMessage;
        } catch (_) {}
        if (response.statusCode == 401) {
          errorMessage =
              'Invalid API key. Please check your key and try again.';
          isAuthError = true;
        } else if (response.statusCode == 403) {
          errorMessage =
              'Access denied. Your account may not have permission to use this service.';
          isAuthError = true;
        } else if (response.statusCode == 429) {
          errorMessage =
              'Rate limit exceeded or insufficient quota. Please check your plan and billing details.';
        } else if (response.statusCode == 404) {
          errorMessage =
              'The model "$model" was not found or is not available for your account.';
        }
        return ApiKeyTestResult(
          success: false,
          message: errorMessage,
          isAuthError: isAuthError,
        );
      }
    } catch (e) {
      return ApiKeyTestResult(
        success: false,
        message: 'Failed to test API key: $e',
      );
    }
  }

  Future<List<OpenAIModel>> getAvailableModels(String apiKey) async {
    try {
      final url = Uri.parse('https://api.openai.com/v1/models');
      final headers = {'Authorization': 'Bearer $apiKey'};
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = (data['data'] as List<dynamic>?) ?? [];
        final filteredModels =
            models
                .where(
                  (model) =>
                      model['id'] != null &&
                      model['id'].toString().startsWith('gpt-') &&
                      !model['id'].toString().contains('instruct') &&
                      model['id'].toString() != 'gpt',
                )
                .map(
                  (model) => OpenAIModel(
                    id: model['id'],
                    displayName: OpenAIModel._formatModelDisplayName(
                      model['id'],
                    ),
                  ),
                )
                .toList();
        filteredModels.sort((a, b) {
          if (a.id.contains('gpt-4') && !b.id.contains('gpt-4')) return -1;
          if (!a.id.contains('gpt-4') && b.id.contains('gpt-4')) return 1;
          return a.displayName.compareTo(b.displayName);
        });
        return filteredModels.isEmpty ? _defaultModels : filteredModels;
      } else {
        return _defaultModels;
      }
    } catch (e) {
      return _defaultModels;
    }
  }

  List<OpenAIModel> getDefaultModels() {
    return _defaultModels;
  }

  Future<String> sendMessage(
    String message, {
    String? imageUrl,
    bool isHighDetail = false,
  }) async {
    final apiKey = await _getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OpenAI API key not configured');
    }
    final model = await getSelectedModel();
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
    List<Map<String, dynamic>> requestMessages;
    if (imageUrl != null) {
      String imageDataUrl;
      try {
        final base64String = await ImageUtils.resizeAndEncodeImage(
          imageUrl,
          isHighDetail: isHighDetail,
        );
        imageDataUrl = ImageUtils.createImageDataUrl(
          base64String,
          imagePath: imageUrl,
        );
        debugPrint(
          'imageDataUrl (first 100 chars): \\${imageDataUrl.substring(0, imageDataUrl.length > 100 ? 100 : imageDataUrl.length)}',
        );
      } catch (e) {
        throw Exception('Failed to process image file: $e');
      }
      requestMessages = [
        {
          'role': 'assistant',
          'content': [
            {'type': 'text', 'text': message},
          ],
        },
        {
          'role': 'user',
          'content': [
            {
              'type': 'image_url',
              'image_url': {'url': imageDataUrl},
            },
          ],
        },
      ];
    } else {
      requestMessages = [
        {
          'role': 'system',
          'content':
              'You are a helpful nutrition and fitness assistant for PlatePal Tracker app.',
        },
        {'role': 'user', 'content': message},
      ];
    }
    final body = jsonEncode({
      'model': model,
      'messages': requestMessages,
      'temperature': 0.7,
      'max_tokens': 1000,
    });
    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final choices = data['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final texts = choices
              .map((choice) => choice['message']?['content'])
              .where(
                (text) => text != null && text.toString().trim().isNotEmpty,
              )
              .join('\n\n');
          return texts.isNotEmpty ? texts : 'No response received';
        } else {
          return 'No response received';
        }
      } else {
        String errorMessage = 'OpenAI API error: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error']?['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Send a structured chat request to OpenAI using manual HTTP requests
  Future<ChatCompletionResponse> sendChatRequest({
    required List<Map<String, dynamic>> messages,
    double temperature = 0.7,
    int? maxTokens,
    Map<String, dynamic>? responseFormat,
    String? imageUri,
  }) async {
    final apiKey = await _getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OpenAI API key not configured');
    }
    final model = await getSelectedModel();
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
    final body = <String, dynamic>{
      'model': model,
      'messages': messages,
      'temperature': temperature,
    };
    if (maxTokens != null) {
      body['max_tokens'] = maxTokens;
    }
    if (responseFormat != null) {
      body['response_format'] = responseFormat;
    }
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ChatCompletionResponse.fromJson(data);
      } else {
        String errorMessage = 'OpenAI API error: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error']?['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Failed to send chat request: $e');
    }
  }
}
