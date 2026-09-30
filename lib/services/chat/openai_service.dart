import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/image_utils.dart'; // Adjust the import based on your project structure
import '../secure_key_store.dart';

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

enum OpenAIFailure {
  /// Custom base URL is not an absolute https URL (http only for localhost).
  invalidBaseUrl,
  network,
  server,

  /// 401/403: the provider rejected the API key.
  auth,

  /// 429: rate limit or exhausted quota/credit.
  rateLimit,
}

/// What the user should do about a failed chat request; persisted by [name].
enum ChatErrorKind { auth, rateLimit, network, server, keyUnreadable, unknown }

class OpenAIServiceException implements Exception {
  final OpenAIFailure failure;
  final int? statusCode;

  /// Provider error message with secrets already redacted.
  final String? detail;

  const OpenAIServiceException(this.failure, {this.statusCode, this.detail});

  static OpenAIFailure failureForStatus(int statusCode) => switch (statusCode) {
    401 || 403 => OpenAIFailure.auth,
    429 => OpenAIFailure.rateLimit,
    _ => OpenAIFailure.server,
  };

  @override
  String toString() =>
      'OpenAIServiceException: API ${failure.name}'
      '${statusCode != null ? ' ($statusCode)' : ''}'
      '${detail != null ? ': $detail' : ''}';
}

class ApiKeyTestResult {
  final bool success;
  final String message;
  final bool isAuthError;
  final OpenAIFailure? failure;

  const ApiKeyTestResult({
    required this.success,
    required this.message,
    this.isAuthError = false,
    this.failure,
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

  static const Duration chatRequestTimeout = Duration(seconds: 60);
  static const Duration visionRequestTimeout = Duration(seconds: 120);
  static const Duration _apiKeyTestTimeout = Duration(seconds: 30);
  static const Duration _modelListTimeout = Duration(seconds: 20);

  static const String _defaultBaseUrl = 'https://api.openai.com/v1';
  static const Set<String> _localHosts = {
    'localhost',
    '127.0.0.1',
    '10.0.2.2', // Android emulator's alias for the host machine
    '::1',
  };

  /// Resolves the API base URL (appending `/v1` like all request paths expect)
  /// and rejects URLs the bearer key must not be sent to.
  static Uri normalizeBaseUrl(String? customBaseUrl) {
    final raw = (customBaseUrl ?? '').trim();
    if (raw.isEmpty) return Uri.parse(_defaultBaseUrl);
    final stripped = raw.replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.tryParse(
      stripped.endsWith('/v1') ? stripped : '$stripped/v1',
    );
    final isHttps = uri?.scheme == 'https';
    final isLocalHttp =
        uri?.scheme == 'http' && _localHosts.contains(uri?.host);
    if (uri == null ||
        !uri.isAbsolute ||
        uri.host.isEmpty ||
        !(isHttps || isLocalHttp)) {
      throw const OpenAIServiceException(OpenAIFailure.invalidBaseUrl);
    }
    return uri;
  }

  static final RegExp _secretTokenPattern = RegExp(
    r'(?<![A-Za-z0-9])sk-[A-Za-z0-9_*\-]{4,}',
  );

  /// Removes [apiKey] and anything shaped like an `sk-` key from [text].
  static String redactSecrets(String text, [String? apiKey]) {
    var result = text;
    if (apiKey != null && apiKey.isNotEmpty) {
      result = result.replaceAll(apiKey, '[redacted]');
    }
    return result.replaceAll(_secretTokenPattern, '[redacted]');
  }

  /// Maps an error thrown by [sendMessage] or [sendChatRequest] to a [ChatErrorKind].
  static ChatErrorKind errorKindOf(Object error) {
    if (error is TimeoutException || error is http.ClientException) {
      return ChatErrorKind.network;
    }
    if (error is! OpenAIServiceException) return ChatErrorKind.unknown;
    return switch (error.failure) {
      OpenAIFailure.auth => ChatErrorKind.auth,
      OpenAIFailure.rateLimit => ChatErrorKind.rateLimit,
      OpenAIFailure.network => ChatErrorKind.network,
      OpenAIFailure.server =>
        (error.statusCode ?? 500) >= 500
            ? ChatErrorKind.server
            : ChatErrorKind.unknown,
      OpenAIFailure.invalidBaseUrl => ChatErrorKind.unknown,
    };
  }

  /// Kind of the latest failed chat request, even if a caller swallowed it.
  ChatErrorKind? lastErrorKind;

  final http.Client? _httpClient;

  /// [httpClient] is optional; by default a short-lived client is used per request.
  OpenAIService({http.Client? httpClient}) : _httpClient = httpClient;

  /// Get the currently selected model
  String get selectedModel => _selectedModelCache ?? 'gpt-4o';
  String? _selectedModelCache;

  Future<http.Response> _post(
    Uri url,
    Map<String, String> headers,
    Object body,
    Duration timeout,
  ) {
    final client = _httpClient;
    final request =
        client != null
            ? client.post(url, headers: headers, body: body)
            : http.post(url, headers: headers, body: body);
    return request.timeout(
      timeout,
      onTimeout:
          () =>
              throw TimeoutException(
                'OpenAI request timed out after ${timeout.inSeconds}s',
                timeout,
              ),
    );
  }

  Future<String?> _getApiKey() => SecureKeyStore.readApiKey();

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

  Future<Uri> _getBaseUrl() async {
    final isCompatibility = await getIsCompatibilityMode();
    return normalizeBaseUrl(isCompatibility ? await getCustomBaseUrl() : null);
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
    // Clean the API key of any unwanted characters
    final cleanedApiKey = apiKey.trim().replaceAll(
      RegExp(r'[\x00-\x1F\x7F]'),
      '',
    );
    final Uri baseUrl;
    try {
      baseUrl = normalizeBaseUrl(customBaseUrl);
    } on OpenAIServiceException catch (e) {
      return ApiKeyTestResult(
        success: false,
        message: 'Invalid base URL. Use an https:// address.',
        failure: e.failure,
      );
    }
    try {
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
      final response = await _post(
        url,
        headers,
        jsonEncode(body),
        _apiKeyTestTimeout,
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
            'OpenAI API returned empty content for model $model '
            '(status ${response.statusCode}, ${response.body.length} bytes)',
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
          errorMessage = redactSecrets(
            errorData['error']?['message'] ?? errorMessage,
            cleanedApiKey,
          );
        } catch (_) {}
        // The error message can echo parts of the key, so only log metadata.
        debugPrint(
          'OpenAI API key test failed: status ${response.statusCode}, '
          '${response.body.length} bytes',
        );
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
          failure: OpenAIFailure.server,
        );
      }
    } catch (e) {
      return ApiKeyTestResult(
        success: false,
        message: redactSecrets('Failed to test API key: $e', cleanedApiKey),
        failure: OpenAIFailure.network,
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
        debugPrint('Encoded image data URL: ${imageDataUrl.length} chars');
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
      final response = await _post(
        url,
        headers,
        jsonEncode(body),
        imageUrl != null ? visionRequestTimeout : chatRequestTimeout,
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
        throw _httpFailure(response, cleanedApiKey);
      }
    } catch (e) {
      lastErrorKind = errorKindOf(e);
      if (e is TimeoutException || e is OpenAIServiceException) rethrow;
      if (e is http.ClientException) {
        throw const OpenAIServiceException(OpenAIFailure.network);
      }
      throw Exception(
        redactSecrets('Failed to send message: $e', cleanedApiKey),
      );
    }
  }

  static OpenAIServiceException _httpFailure(
    http.Response response,
    String apiKey,
  ) {
    String? message;
    try {
      message = jsonDecode(response.body)['error']?['message'] as String?;
    } catch (_) {}
    return OpenAIServiceException(
      OpenAIServiceException.failureForStatus(response.statusCode),
      statusCode: response.statusCode,
      detail: message == null ? null : redactSecrets(message, apiKey),
    );
  }

  Future<List<OpenAIModel>> getAvailableModels(
    String apiKey, {
    String? customBaseUrl,
  }) async {
    // Clean the API key of any unwanted characters
    final cleanedApiKey = apiKey.trim().replaceAll(
      RegExp(r'[\x00-\x1F\x7F]'),
      '',
    );
    if (cleanedApiKey.isEmpty) return _defaultModels;

    final url = Uri.parse('${normalizeBaseUrl(customBaseUrl)}/models');
    final headers = {'Authorization': 'Bearer $cleanedApiKey'};
    final client = _httpClient;
    final http.Response response;
    try {
      response = await (client != null
              ? client.get(url, headers: headers)
              : http.get(url, headers: headers))
          .timeout(_modelListTimeout);
    } catch (_) {
      throw const OpenAIServiceException(OpenAIFailure.network);
    }
    if (response.statusCode != 200) {
      throw OpenAIServiceException(
        OpenAIFailure.server,
        statusCode: response.statusCode,
      );
    }
    try {
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
                  displayName: OpenAIModel._formatModelDisplayName(model['id']),
                ),
              )
              .toList();
      filteredModels.sort((a, b) {
        if (a.id.contains('gpt-4') && !b.id.contains('gpt-4')) return -1;
        if (!a.id.contains('gpt-4') && b.id.contains('gpt-4')) return 1;
        return a.displayName.compareTo(b.displayName);
      });
      return filteredModels.isEmpty ? _defaultModels : filteredModels;
    } catch (_) {
      throw const OpenAIServiceException(OpenAIFailure.server, statusCode: 200);
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
    final hasImage = messages.any((m) {
      final content = m['content'];
      return (content is List &&
              content.any((i) => i is Map && i['type'] == 'image_url')) ||
          (content is String && content.contains('data:image'));
    });
    try {
      final response = await _post(
        url,
        headers,
        jsonEncode(body),
        hasImage ? visionRequestTimeout : chatRequestTimeout,
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
        throw _httpFailure(response, cleanedApiKey);
      }
    } catch (e) {
      lastErrorKind = errorKindOf(e);
      if (e is TimeoutException || e is OpenAIServiceException) rethrow;
      if (e is http.ClientException) {
        throw const OpenAIServiceException(OpenAIFailure.network);
      }
      throw Exception(
        redactSecrets('Failed to send chat request: $e', cleanedApiKey),
      );
    }
  }
}
