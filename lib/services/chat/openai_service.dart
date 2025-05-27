import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/nutrition_analysis.dart';

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

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _apiKeyKey = 'openai_api_key';
  static const String _selectedModelKey = 'openai_selected_model';

  // Default models to show before fetching from API
  static const List<OpenAIModel> _defaultModels = [
    OpenAIModel(id: 'gpt-4o', displayName: 'GPT-4O'),
    OpenAIModel(id: 'gpt-4', displayName: 'GPT-4'),
    OpenAIModel(id: 'gpt-3.5-turbo', displayName: 'GPT-3.5 Turbo'),
    OpenAIModel(id: 'gpt-4o-mini', displayName: 'GPT-4O Mini'),
  ];

  Future<String?> _getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }

  Future<String> getSelectedModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedModelKey) ?? 'gpt-4o';
  }

  Future<void> setSelectedModel(String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedModelKey, model);
  }

  Future<bool> isConfigured() async {
    final apiKey = await _getApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }

  Future<ApiKeyTestResult> testApiKey(String apiKey, String model) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
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
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'] as String?;

        if (content == null || content.isEmpty) {
          return const ApiKeyTestResult(
            success: false,
            message:
                'Received empty response from OpenAI. The API key might be valid but the model may not be available.',
          );
        }

        return ApiKeyTestResult(success: true, message: content);
      } else {
        final error = json.decode(response.body);
        String errorMessage =
            'Network error occurred while testing the API key.';
        bool isAuthError = false;

        switch (response.statusCode) {
          case 401:
            errorMessage =
                'Invalid API key. Please check your key and try again.';
            isAuthError = true;
            break;
          case 403:
            errorMessage =
                'Access denied. Your account may not have permission to use this service.';
            isAuthError = true;
            break;
          case 429:
            errorMessage =
                'Rate limit exceeded or insufficient quota. Please check your plan and billing details.';
            break;
          case 404:
            errorMessage =
                'The model "$model" was not found or is not available for your account.';
            break;
          default:
            if (error['error'] != null && error['error']['message'] != null) {
              errorMessage = error['error']['message'];
              if (errorMessage.toLowerCase().contains('model') &&
                  (errorMessage.toLowerCase().contains('does not exist') ||
                      errorMessage.toLowerCase().contains('not found') ||
                      errorMessage.toLowerCase().contains('not available'))) {
                errorMessage =
                    'The model "$model" is not available for your account. Try a different model.';
              }
            }
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
      final response = await http.get(
        Uri.parse('$_baseUrl/models'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final models =
            (data['data'] as List)
                .where(
                  (model) =>
                      model['id'].toString().startsWith('gpt-') &&
                      !model['id'].toString().contains('instruct') &&
                      model['id'].toString() != 'gpt',
                )
                .map((model) => OpenAIModel.fromJson(model))
                .toList();

        // Sort GPT-4 models first, then others
        models.sort((a, b) {
          if (a.id.contains('gpt-4') && !b.id.contains('gpt-4')) return -1;
          if (!a.id.contains('gpt-4') && b.id.contains('gpt-4')) return 1;
          return a.displayName.compareTo(b.displayName);
        });

        return models.isEmpty ? _defaultModels : models;
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

  Future<String> sendMessage(String message, {String? imageUrl}) async {
    final apiKey = await _getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OpenAI API key not configured');
    }

    final selectedModel = await getSelectedModel();
    final messages = <Map<String, dynamic>>[
      {
        'role': 'system',
        'content':
            '''You are a helpful nutrition and fitness assistant for PlatePal Tracker app. 
You help users with meal planning, nutrition analysis, and fitness goals. 
Be friendly, informative, and provide practical advice. 
Keep responses concise but helpful.''',
      },
    ];

    if (imageUrl != null) {
      messages.add({
        'role': 'user',
        'content': [
          {'type': 'text', 'text': message},
          {
            'type': 'image_url',
            'image_url': {'url': imageUrl},
          },
        ],
      });
    } else {
      messages.add({'role': 'user', 'content': message});
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': imageUrl != null ? 'gpt-4-vision-preview' : selectedModel,
          'messages': messages,
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        return content.trim();
      } else {
        final error = json.decode(response.body);
        throw Exception('OpenAI API error: ${error['error']['message']}');
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<NutritionAnalysis?> analyzeNutrition(
    String description, {
    String? imageUrl,
  }) async {
    final apiKey = await _getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OpenAI API key not configured');
    }

    final selectedModel = await getSelectedModel();
    final prompt = '''
Analyze the nutrition of this food item and return ONLY a JSON object with this exact structure:
{
  "dishName": "name of the dish",
  "ingredients": ["ingredient1", "ingredient2", "..."],
  "nutritionInfo": {
    "calories": 0,
    "protein": 0,
    "carbs": 0,
    "fat": 0,
    "fiber": 0,
    "sugar": 0,
    "sodium": 0
  },
  "servingSize": "serving size description",
  "cookingInstructions": "brief cooking instructions if applicable",
  "mealType": "breakfast/lunch/dinner/snack",
  "confidence": 0.95
}

Food description: $description
''';

    final messages = <Map<String, dynamic>>[
      {
        'role': 'system',
        'content':
            'You are a nutrition analysis expert. Return only valid JSON with nutrition data.',
      },
    ];

    if (imageUrl != null) {
      messages.add({
        'role': 'user',
        'content': [
          {'type': 'text', 'text': prompt},
          {
            'type': 'image_url',
            'image_url': {'url': imageUrl},
          },
        ],
      });
    } else {
      messages.add({'role': 'user', 'content': prompt});
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': imageUrl != null ? 'gpt-4-vision-preview' : selectedModel,
          'messages': messages,
          'max_tokens': 1000,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'] as String;

        // Try to parse the JSON response
        try {
          final jsonData = json.decode(content.trim());
          return NutritionAnalysis.fromJson(jsonData);
        } catch (parseError) {
          throw Exception('Failed to parse nutrition analysis: $parseError');
        }
      } else {
        final error = json.decode(response.body);
        throw Exception('OpenAI API error: ${error['error']['message']}');
      }
    } catch (e) {
      throw Exception('Failed to analyze nutrition: $e');
    }
  }
}
