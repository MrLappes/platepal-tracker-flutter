import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:platepal_tracker/models/chat_types.dart';
import 'package:platepal_tracker/repositories/dish_repository.dart';
import 'package:platepal_tracker/repositories/meal_repository.dart';
import 'package:platepal_tracker/repositories/user_profile_repository.dart';
import 'package:platepal_tracker/services/chat/chat_agent_service.dart';
import 'package:platepal_tracker/services/chat/openai_service.dart';
import 'package:platepal_tracker/services/chat/system_prompts.dart';
import 'package:platepal_tracker/services/storage/database_service.dart';
import 'package:platepal_tracker/services/storage/dish_service.dart';
import 'package:platepal_tracker/services/user_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Text that ContextGatheringStep puts into the enhanced system prompt when
/// the thinking step asks for nutrition advice.
const _contextMarker =
    'General nutrition advice may be relevant to this user request.';

const _bot = BotConfiguration(
  type: 'nutritionist',
  name: 'PlatePal',
  behaviorType: 'helpful',
);

http.Response _completion(
  Map<String, dynamic> message, {
  String finishReason = 'stop',
}) {
  return http.Response(
    jsonEncode({
      'id': 'cmpl-1',
      'object': 'chat.completion',
      'created': 0,
      'model': 'gpt-4o',
      'choices': [
        {'index': 0, 'finish_reason': finishReason, 'message': message},
      ],
    }),
    200,
  );
}

/// Fake OpenAI endpoint that routes by request shape and records every body.
class _FakeOpenAI {
  final requests = <Map<String, dynamic>>[];

  /// Only response generation sends tool definitions.
  List<Map<String, dynamic>> get responseRequests =>
      requests.where((r) => r['tools'] != null).toList();

  late final client = MockClient((request) async {
    final body = jsonDecode(request.body) as Map<String, dynamic>;
    requests.add(body);
    final messages = body['messages'] as List<dynamic>;
    final system = (messages.first as Map)['content'];

    if (body['tools'] != null) {
      return _completion({
        'role': 'assistant',
        'content': null,
        'tool_calls': [
          {
            'id': 'call_1',
            'type': 'function',
            'function': {
              'name': 'create_new_dish',
              'arguments': jsonEncode({
                'name': 'Protein Oats',
                'reply_text': 'Here is a high-protein breakfast.',
                'ingredients': [
                  {
                    'name': 'Oats',
                    'quantity': 50,
                    'unit': 'g',
                    'calories_per_100': 380,
                    'protein_per_100': 13,
                    'carbs_per_100': 60,
                    'fat_per_100': 7,
                  },
                ],
              }),
            },
          },
        ],
      }, finishReason: 'tool_calls');
    }

    if (system is String &&
        system.startsWith(SystemPrompts.analysisPrompt.substring(0, 60))) {
      return _completion({
        'role': 'assistant',
        'content': jsonEncode({
          'userIntent': 'User wants a high-protein breakfast',
          'contextRequirements': {
            'needsNutritionAdvice': true,
            'needsConversationHistory': false,
          },
          'responseRequirements': ['dish_creation'],
        }),
      });
    }

    return _completion({
      'role': 'assistant',
      'content': jsonEncode({
        'decision': 'continueNormally',
        'confidence': 0.95,
        'reasoning': 'Context is sufficient.',
      }),
    });
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late _FakeOpenAI fake;

  Future<ChatAgentService> buildService({required bool deepSearch}) async {
    SharedPreferences.setMockInitialValues({
      'openai_api_key': 'sk-test',
      'deep_search_enabled': deepSearch,
      'app_locale': 'en',
    });
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
    final prefs = await SharedPreferences.getInstance();
    final session = UserSessionService(prefs);
    fake = _FakeOpenAI();
    return ChatAgentService(
      openaiService: OpenAIService(httpClient: fake.client),
      dishRepository: DishRepository(),
      mealRepository: MealRepository(userSessionService: session),
      userProfileRepository: UserProfileRepository(userSessionService: session),
      dishService: DishService(),
    );
  }

  String responseSystemPrompt() {
    final messages = fake.responseRequests.single['messages'] as List<dynamic>;
    return (messages.first as Map)['content'] as String;
  }

  /// MessageBubble renders dish cards from metadata['dishesProcessed'].
  List<Object?> dishCardNames(ChatResponse response) {
    final processed =
        response.metadata!['dishesProcessed'] as Map<String, dynamic>;
    return (processed['validatedDishes'] as List)
        .map((d) => (d as Map)['name'])
        .toList();
  }

  group('default pipeline', () {
    test('runs response generation once and keeps tool-call dishes', () async {
      final service = await buildService(deepSearch: false);

      final response = await service.processMessage(
        userMessage: 'Suggest a high-protein breakfast',
        conversationHistory: const [],
        botConfig: _bot,
      );

      expect(fake.responseRequests, hasLength(1));
      expect(response.replyText, 'Here is a high-protein breakfast.');
      expect(dishCardNames(response), ['Protein Oats']);
      expect(responseSystemPrompt(), contains(_contextMarker));
    });
  });

  group('deep search pipeline', () {
    test('passes gathered context to response generation', () async {
      final service = await buildService(deepSearch: true);

      final response = await service.processMessage(
        userMessage: 'Suggest a high-protein breakfast',
        conversationHistory: const [],
        botConfig: _bot,
      );

      expect(fake.responseRequests, hasLength(1));
      expect(responseSystemPrompt(), contains(_contextMarker));
      expect(dishCardNames(response), ['Protein Oats']);
    });
  });

  group('resolveLanguageCode', () {
    test('uses a supported saved preference', () {
      expect(
        ChatAgentService.resolveLanguageCode('de', const Locale('en')),
        'de',
      );
    });

    test('falls back to a supported device locale', () {
      expect(
        ChatAgentService.resolveLanguageCode(null, const Locale('es', 'ES')),
        'es',
      );
      expect(
        ChatAgentService.resolveLanguageCode('fr', const Locale('de')),
        'de',
      );
    });

    test('falls back to English for unsupported device locales', () {
      expect(
        ChatAgentService.resolveLanguageCode(null, const Locale('fr')),
        'en',
      );
    });
  });
}
