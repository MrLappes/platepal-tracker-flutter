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

  bool get isToolCall => finishReason == 'tool_calls';

  factory ChatChoice.fromJson(Map<String, dynamic> json) {
    return ChatChoice(
      message: OpenAiMessage.fromJson(json['message'] as Map<String, dynamic>),
      finishReason: json['finish_reason'] as String? ?? 'stop',
      index: json['index'] as int,
    );
  }
}

class ToolCall {
  final String id;
  final String type;
  final String functionName;
  final String functionArguments;

  const ToolCall({
    required this.id,
    required this.type,
    required this.functionName,
    required this.functionArguments,
  });

  factory ToolCall.fromJson(Map<String, dynamic> json) {
    final function = json['function'] as Map<String, dynamic>? ?? {};
    return ToolCall(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'function',
      functionName: function['name'] as String? ?? '',
      functionArguments: function['arguments'] as String? ?? '{}',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'function': {'name': functionName, 'arguments': functionArguments},
  };

  /// Parse the arguments as JSON. Returns an empty map on parse failure.
  Map<String, dynamic> parseArguments() {
    try {
      return jsonDecode(functionArguments) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}

class OpenAiMessage {
  final String role;
  final String? content;

  /// Non-null when finish_reason == "tool_calls".
  final List<ToolCall>? toolCalls;

  /// Non-null for role=="tool" reply messages.
  final String? toolCallId;

  const OpenAiMessage({
    required this.role,
    this.content,
    this.toolCalls,
    this.toolCallId,
  });

  factory OpenAiMessage.fromJson(Map<String, dynamic> json) {
    final rawToolCalls = json['tool_calls'] as List<dynamic>?;
    return OpenAiMessage(
      role: json['role'] as String,
      content: json['content'] as String?,
      toolCallId: json['tool_call_id'] as String?,
      toolCalls:
          rawToolCalls
              ?.map((e) => ToolCall.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'role': role,
    if (content != null) 'content': content,
    if (toolCallId != null) 'tool_call_id': toolCallId,
    if (toolCalls != null)
      'tool_calls': toolCalls!.map((t) => t.toJson()).toList(),
  };
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
  static const String _isCompatibilityModeKey = 'openai_compatibility_mode';
  static const String _customBaseUrlKey = 'openai_custom_base_url';
  static const String _customModelKey = 'openai_custom_model';

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

  Future<bool> getIsCompatibilityMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isCompatibilityModeKey) ?? false;
  }

  Future<void> setIsCompatibilityMode(bool isCompatibility) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isCompatibilityModeKey, isCompatibility);
  }

  Future<String?> getCustomBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_customBaseUrlKey);
  }

  Future<void> setCustomBaseUrl(String? url) async {
    final prefs = await SharedPreferences.getInstance();
    if (url == null || url.isEmpty) {
      await prefs.remove(_customBaseUrlKey);
    } else {
      await prefs.setString(_customBaseUrlKey, url);
    }
  }

  Future<String?> getCustomModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_customModelKey);
  }

  Future<void> setCustomModel(String? model) async {
    final prefs = await SharedPreferences.getInstance();
    if (model == null || model.isEmpty) {
      await prefs.remove(_customModelKey);
    } else {
      await prefs.setString(_customModelKey, model);
    }
  }

  Future<String> getSelectedModel() async {
    final isCompatibility = await getIsCompatibilityMode();
    if (isCompatibility) {
      final customModel = await getCustomModel();
      _selectedModelCache = customModel ?? 'gpt-3.5-turbo';
    } else {
      final prefs = await SharedPreferences.getInstance();
      _selectedModelCache = prefs.getString(_selectedModelKey) ?? 'gpt-4o';
    }
    return _selectedModelCache!;
  }

  Future<void> setSelectedModel(String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedModelKey, model);
    _selectedModelCache = model;
  }

  Future<bool> isConfigured() async {
    final apiKey = await _getApiKey();
    final isCompatibility = await getIsCompatibilityMode();

    if (isCompatibility) {
      final customUrl = await getCustomBaseUrl();
      final customModel = await getCustomModel();
      return apiKey != null &&
          apiKey.isNotEmpty &&
          customUrl != null &&
          customUrl.isNotEmpty &&
          customModel != null &&
          customModel.isNotEmpty;
    }

    return apiKey != null && apiKey.isNotEmpty;
  }

  Future<String> _getBaseUrl() async {
    final isCompatibility = await getIsCompatibilityMode();
    if (isCompatibility) {
      final customUrl = await getCustomBaseUrl();
      if (customUrl != null && customUrl.isNotEmpty) {
        // Ensure URL ends with /v1 if it doesn't already have it
        if (customUrl.endsWith('/v1')) {
          return customUrl;
        } else if (customUrl.endsWith('/')) {
          return '${customUrl}v1';
        } else {
          return '$customUrl/v1';
        }
      }
    }
    return 'https://api.openai.com/v1';
  }

  /// Helper to check if model requires alternate max_tokens key
  bool _useCompletionTokens(String model) {
    return model.contains('-5');
  }

  /// Helper to check if model should omit temperature
  bool _omitTemperature(String model) {
    return model.contains('-5');
  }

  Future<ApiKeyTestResult> testApiKey(
    String apiKey,
    String model, {
    String? customBaseUrl,
  }) async {
    try {
      // Clean the API key of any unwanted characters
      final cleanedApiKey = apiKey.trim().replaceAll(
        RegExp(r'[\x00-\x1F\x7F]'),
        '',
      );

      final baseUrl = customBaseUrl ?? 'https://api.openai.com/v1';
      final url = Uri.parse('$baseUrl/chat/completions');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $cleanedApiKey',
      };
      final bool useCompletionTokens = _useCompletionTokens(model);
      final bool omitTemperature = _omitTemperature(model);
      final body = {
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
        if (useCompletionTokens) ...{
          'max_completion_tokens': 2048,
          'reasoning_effort': 'low',
        } else ...{
          'max_tokens': 2048,
        },
        if (!omitTemperature) 'temperature': 0.7,
      };
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      if (response.body.trim().isEmpty) {
        return const ApiKeyTestResult(
          success: false,
          message:
              'OpenAI returned an empty response. Try increasing your token limits or check your request.',
        );
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'] ?? '';
        if (content.isEmpty) {
          debugPrint(
            'OpenAI API returned an empty response for model $model with API key $apiKey, Response: ${response.body}',
          );
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
          debugPrint(
            'OpenAI API error: ${errorData['error']?['message']}, '
            'status code: ${response.statusCode}',
          );
        } catch (_) {}
        if (response.statusCode == 400) {
          errorMessage =
              'Invalid request. Please check the model and parameters used.';
        } else if (response.statusCode == 401) {
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

  Future<String> sendMessage(
    String message, {
    String? imageUrl,
    bool isHighDetail = false,
  }) async {
    final apiKey = await _getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OpenAI API key not configured');
    }

    // Clean the API key of any unwanted characters
    final cleanedApiKey = apiKey.trim().replaceAll(
      RegExp(r'[\x00-\x1F\x7F]'),
      '',
    );

    final model = await getSelectedModel();
    final baseUrl = await _getBaseUrl();
    final url = Uri.parse('$baseUrl/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $cleanedApiKey',
    };

    const systemPrompt =
        'You are a helpful nutrition and fitness assistant for PlatePal Tracker app.';
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
          'imageDataUrl (first 100 chars): ${imageDataUrl.substring(0, imageDataUrl.length > 100 ? 100 : imageDataUrl.length)}',
        );
      } catch (e) {
        throw Exception('Failed to process image file: $e');
      }
      requestMessages = [
        {'role': 'system', 'content': systemPrompt},
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': message},
            {
              'type': 'image_url',
              'image_url': {
                'url': imageDataUrl,
                'detail': isHighDetail ? 'high' : 'low',
              },
            },
          ],
        },
      ];
    } else {
      requestMessages = [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': message},
      ];
    }
    final bool useCompletionTokens = _useCompletionTokens(model);
    final bool omitTemperature = _omitTemperature(model);
    final body = {
      'model': model,
      'messages': requestMessages,
      if (useCompletionTokens) ...{
        'max_completion_tokens': 2048,
        'reasoning_effort': 'low',
      } else ...{
        'max_tokens': 2048,
      },
      if (!omitTemperature) 'temperature': 0.7,
    };
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      if (response.body.trim().isEmpty) {
        throw Exception(
          'OpenAI returned an empty response. Try increasing your token limits or check your request.',
        );
      }
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

  Future<List<OpenAIModel>> getAvailableModels(
    String apiKey, {
    String? customBaseUrl,
  }) async {
    try {
      // Clean the API key of any unwanted characters
      final cleanedApiKey = apiKey.trim().replaceAll(
        RegExp(r'[\x00-\x1F\x7F]'),
        '',
      );

      final baseUrl = customBaseUrl ?? 'https://api.openai.com/v1';
      final url = Uri.parse('$baseUrl/models');
      final headers = {'Authorization': 'Bearer $cleanedApiKey'};
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

  Future<ChatCompletionResponse> sendChatRequest({
    required List<Map<String, dynamic>> messages,
    double temperature = 0.7,
    int? maxTokens,
    Map<String, dynamic>? responseFormat,
    String? imageUri,

    /// OpenAI tool definitions. When provided, the model can call these tools.
    List<Map<String, dynamic>>? tools,

    /// Force the model to call a specific tool or 'auto'/'required'.
    /// Pass a map like {'type': 'function', 'function': {'name': 'tool_name'}}
    /// to force a specific tool, or use the string 'required' / 'auto'.
    dynamic toolChoice,
  }) async {
    final apiKey = await _getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OpenAI API key not configured');
    }

    // Clean the API key of any unwanted characters
    final cleanedApiKey = apiKey.trim().replaceAll(
      RegExp(r'[\x00-\x1F\x7F]'),
      '',
    );

    final model = await getSelectedModel();
    final baseUrl = await _getBaseUrl();
    final url = Uri.parse('$baseUrl/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $cleanedApiKey',
    };
    final bool useCompletionTokens = _useCompletionTokens(model);
    final bool omitTemperature = _omitTemperature(model);
    // If an image URI was provided but the messages don't already include an image,
    // load and embed the image as a data URL into the messages so vision-capable
    // models will actually receive the pixels (not just a string URI).
    if (imageUri != null) {
      try {
        bool hasImageAlready = false;
        for (final m in messages) {
          final content = m['content'];
          if (content is List) {
            for (final item in content) {
              if (item is Map && item['type'] == 'image_url') {
                hasImageAlready = true;
                break;
              }
            }
            if (hasImageAlready) break;
          } else if (content is String && content.contains('data:image')) {
            hasImageAlready = true;
            break;
          }
        }

        if (!hasImageAlready) {
          // Resize/encode the image and create a data URL
          final base64String = await ImageUtils.resizeAndEncodeImage(
            imageUri,
            isHighDetail: false,
          );
          final imageDataUrl = ImageUtils.createImageDataUrl(
            base64String,
            imagePath: imageUri,
          );

          // Append as a user message with structured content (text + image)
          messages.add({
            'role': 'user',
            'content': [
              {'type': 'text', 'text': 'User uploaded an image'},
              {
                'type': 'image_url',
                'image_url': {'url': imageDataUrl},
              },
            ],
          });
        }
      } catch (e) {
        // If image processing fails, continue without blocking the request.
        debugPrint('OpenAIService: Failed to attach image to messages: $e');
      }
    }
    final body = <String, dynamic>{
      'model': model,
      'messages': messages,
      if (useCompletionTokens) ...{
        'max_completion_tokens': maxTokens ?? 2048,
        'reasoning_effort': 'low',
      } else if (maxTokens != null) ...{
        'max_tokens': maxTokens,
      },
      if (!omitTemperature) 'temperature': temperature,
    };
    if (responseFormat != null) {
      body['response_format'] = responseFormat;
    }
    if (tools != null && tools.isNotEmpty) {
      body['tools'] = tools;
      if (toolChoice != null) {
        body['tool_choice'] = toolChoice;
      }
    }
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      if (response.body.trim().isEmpty) {
        throw Exception(
          'OpenAI returned an empty response. Try increasing your token limits or check your request.',
        );
      }
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
