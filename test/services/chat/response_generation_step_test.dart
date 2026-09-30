import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/models/chat_types.dart';
import 'package:platepal_tracker/services/chat/agent_steps/error_handling_step.dart';
import 'package:platepal_tracker/services/chat/agent_steps/response_generation_step.dart';
import 'package:platepal_tracker/services/chat/agent_steps/thinking_step.dart';
import 'package:platepal_tracker/services/chat/openai_service.dart';
import 'package:platepal_tracker/services/chat/pipeline_modification_tracker.dart';
import 'package:platepal_tracker/services/chat/system_prompts.dart';

/// Records every request and answers with [reply] (an OpenAI message map).
class _FakeOpenAIService extends OpenAIService {
  _FakeOpenAIService({
    this.compat = false,
    this.reply,
    this.finishReason = 'stop',
    this.error,
  });

  final bool compat;
  final Map<String, dynamic>? reply;
  final String finishReason;
  final Object? error;
  final requests = <List<Map<String, dynamic>>>[];
  final toolsSent = <List<Map<String, dynamic>>?>[];

  List<Map<String, dynamic>> get lastMessages => requests.last;
  String get lastSystemPrompt => lastMessages.first['content'] as String;

  @override
  Future<bool> getIsCompatibilityMode() async => compat;

  @override
  Future<ChatCompletionResponse> sendChatRequest({
    required List<Map<String, dynamic>> messages,
    double temperature = 0.7,
    int? maxTokens,
    Map<String, dynamic>? responseFormat,
    String? imageUri,
    List<Map<String, dynamic>>? tools,
    dynamic toolChoice,
  }) async {
    requests.add(messages);
    toolsSent.add(tools);
    if (error != null) throw error!;
    return ChatCompletionResponse.fromJson({
      'id': 'cmpl-1',
      'object': 'chat.completion',
      'created': 0,
      'model': 'gpt-4o',
      'choices': [
        {
          'index': 0,
          'finish_reason': finishReason,
          'message':
              reply ?? {'role': 'assistant', 'content': 'Plain text reply.'},
        },
      ],
    });
  }
}

ChatMessage _msg(String role, String content, {int i = 0}) => ChatMessage(
  id: '$role-$i',
  role: role,
  content: content,
  timestamp: DateTime(2026, 1, 1),
);

List<String> _captureLogs() {
  final logs = <String>[];
  final original = debugPrint;
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message != null) logs.add(message);
  };
  addTearDown(() => debugPrint = original);
  return logs;
}

void main() {
  test('German fallback replaces missing JSON reply text', () async {
    final openai = _FakeOpenAIService(
      compat: true,
      reply: {'role': 'assistant', 'content': '{"dishes": []}'},
    );
    final result = await ResponseGenerationStep(openaiService: openai).execute(
      const ChatStepInput(
        userMessage: 'Hallo',
        metadata: {'languageCode': 'de'},
      ),
    );

    expect(result.success, isTrue);
    final response = ChatResponse.fromJson(
      result.data['chatResponse'] as Map<String, dynamic>,
    );
    expect(response.replyText, 'Kein Antworttext gefunden.');
  });

  test('German formatting issue gives a localized retry reply', () async {
    final openai = _FakeOpenAIService(
      compat: true,
      reply: {'role': 'assistant', 'content': '{"dishes": [}'},
    );
    final result = await ResponseGenerationStep(openaiService: openai).execute(
      const ChatStepInput(userMessage: 'Hallo', metadata: {'languageCode': 'de'}),
    );

    final response = ChatResponse.fromJson(
      result.data['chatResponse'] as Map<String, dynamic>,
    );
    expect(response.replyText,
        'Meine Antwort konnte nicht verarbeitet werden. Bitte versuche es erneut.');
  });

  test('German dish-only tool call uses a localized intro', () async {
    final openai = _FakeOpenAIService(
      finishReason: 'tool_calls',
      reply: {
        'role': 'assistant',
        'content': null,
        'tool_calls': [
          {
            'id': 'call_1',
            'type': 'function',
            'function': {
              'name': 'reference_existing_dish',
              'arguments': jsonEncode({'dish_id': 'oats', 'dish_name': 'Hafer'}),
            },
          },
        ],
      },
    );
    final result = await ResponseGenerationStep(openaiService: openai).execute(
      const ChatStepInput(userMessage: 'Hallo', metadata: {'languageCode': 'de'}),
    );

    final response = ChatResponse.fromJson(
      result.data['chatResponse'] as Map<String, dynamic>,
    );
    expect(response.replyText, 'Hier sind die Gerichte-Informationen:');
  });

  test('German error recovery localizes fallback without provider strings', () async {
    final result = await ErrorHandlingStep().execute(
      const ChatStepInput(
        userMessage: 'Hallo',
        metadata: {
          'languageCode': 'de',
          'failedStep': 'response_generation',
          'originalError': ChatAgentError(
            type: ChatErrorType.criticalError,
            message: 'Internal error',
            retryable: false,
          ),
          'retryCount': 0,
        },
      ),
    );

    expect(result.success, isTrue);
    final recovery = result.data['recoveryResult'] as ErrorRecoveryResult;
    expect(recovery.fallbackResponse?.replyText,
      'Ich erlebe gerade technische Schwierigkeiten. Bitte versuche es in einem Moment erneut.');
  });

  group('logging (F7-02)', () {
    test('response generation never logs prompts, history or tool args', () async {
      final logs = _captureLogs();
      final openai = _FakeOpenAIService(
        finishReason: 'tool_calls',
        reply: {
          'role': 'assistant',
          'content': null,
          'tool_calls': [
            {
              'id': 'call_1',
              'type': 'function',
              'function': {
                'name': 'create_new_dish',
                'arguments': jsonEncode({
                  'name': 'ARGS-MARKER Oats',
                  'reply_text': 'REPLY-MARKER',
                  'ingredients': [
                    {'name': 'Oats', 'quantity': 50, 'unit': 'g'},
                  ],
                }),
              },
            },
          ],
        },
      );

      final result = await ResponseGenerationStep(
        openaiService: openai,
        modificationTracker: PipelineModificationTracker(),
      ).execute(
        ChatStepInput(
          userMessage: 'USER-MARKER breakfast',
          conversationHistory: [
            _msg('user', 'HISTORY-MARKER earlier'),
            _msg('assistant', 'ok'),
          ],
          enhancedSystemPrompt: 'PROFILE-MARKER weight 80kg',
          metadata: {
            'contextSummary': 'MEALS-MARKER pizza yesterday',
            'retryAttempt': true,
            'missingRequirements': ['REQ-MARKER'],
          },
        ),
      );

      expect(result.success, isTrue);
      final allLogs = logs.join('\n');
      for (final marker in [
        'USER-MARKER',
        'HISTORY-MARKER',
        'PROFILE-MARKER',
        'MEALS-MARKER',
        'ARGS-MARKER',
        'REPLY-MARKER',
        'REQ-MARKER',
      ]) {
        expect(allLogs, isNot(contains(marker)), reason: marker);
      }
    });

    test('thinking step never logs the model response', () async {
      final logs = _captureLogs();
      final openai = _FakeOpenAIService(
        reply: {
          'role': 'assistant',
          'content': jsonEncode({
            'userIntent': 'INTENT-MARKER',
            'contextRequirements': {
              'dishSearchTerms': ['TERM-MARKER'],
            },
            'responseRequirements': ['nutrition_information'],
          }),
        },
      );

      final result = await ThinkingStep(
        openaiService: openai,
      ).execute(const ChatStepInput(userMessage: 'USER-MARKER'));

      expect(result.success, isTrue);
      final allLogs = logs.join('\n');
      expect(allLogs, isNot(contains('INTENT-MARKER')));
      expect(allLogs, isNot(contains('TERM-MARKER')));
      expect(allLogs, isNot(contains('USER-MARKER')));
    });
  });

  group('conversation history (F7-08)', () {
    test('does not send the current user message twice', () async {
      final openai = _FakeOpenAIService();
      await ResponseGenerationStep(openaiService: openai).execute(
        ChatStepInput(
          userMessage: 'What should I eat?',
          conversationHistory: [
            _msg('user', 'Hi', i: 1),
            _msg('assistant', 'Hello!', i: 2),
            _msg('user', 'What should I eat?', i: 3),
          ],
        ),
      );

      final sent = openai.lastMessages.skip(1).toList();
      expect(sent.map((m) => m['role']), ['user', 'assistant', 'user']);
      expect(sent.map((m) => m['content']), [
        'Hi',
        'Hello!',
        'What should I eat?',
      ]);
    });

    test('keeps only the most recent turns', () async {
      final openai = _FakeOpenAIService();
      final history = [
        for (var i = 0; i < 50; i++)
          _msg(i.isEven ? 'user' : 'assistant', 'turn $i', i: i),
      ];
      await ResponseGenerationStep(openaiService: openai).execute(
        ChatStepInput(userMessage: 'now', conversationHistory: history),
      );

      final sent = openai.lastMessages.skip(1).toList();
      final historySent = sent.take(sent.length - 1).toList();
      expect(historySent, hasLength(ResponseGenerationStep.maxHistoryMessages));
      expect(historySent.first['content'], 'turn 30');
      expect(historySent.last['content'], 'turn 49');
      expect(sent.last['content'], 'now');
    });

    test('drops the oldest turns once the character budget is used', () async {
      final openai = _FakeOpenAIService();
      const size = 10000;
      final history = [
        for (var i = 0; i < 5; i++)
          _msg(
            i.isEven ? 'user' : 'assistant',
            '$i${'x' * (size - 1)}',
            i: i,
          ),
      ];
      await ResponseGenerationStep(openaiService: openai).execute(
        ChatStepInput(userMessage: 'now', conversationHistory: history),
      );

      final sent = openai.lastMessages.skip(1).toList();
      final historySent = sent.take(sent.length - 1).toList();
      final chars = historySent.fold<int>(
        0,
        (sum, m) => sum + (m['content'] as String).length,
      );
      expect(chars, lessThanOrEqualTo(ResponseGenerationStep.maxHistoryChars));
      expect(historySent, hasLength(2));
      expect((historySent.last['content'] as String)[0], '4');
      expect((historySent.first['content'] as String)[0], '3');
    });
  });

  group('compatibility mode (F7-16)', () {
    test('asks for JSON output and parses JSON dishes', () async {
      final openai = _FakeOpenAIService(
        compat: true,
        reply: {
          'role': 'assistant',
          'content': jsonEncode({
            'replyText': 'Here is a compat breakfast.',
            'recommendation': 'Drink water.',
            'dishes': [
              {
                'name': 'Compat Oats',
                'ingredients': [
                  {
                    'name': 'Oats',
                    'quantity': 50,
                    'unit': 'g',
                    'caloriesPer100': 380,
                    'proteinPer100': 13,
                    'carbsPer100': 60,
                    'fatPer100': 7,
                  },
                ],
              },
              {'id': 'db-dish-1', 'name': 'Saved Bowl', 'reference': true},
            ],
          }),
        },
      );

      final result = await ResponseGenerationStep(openaiService: openai)
          .execute(
            ChatStepInput(
              userMessage: 'Suggest a breakfast',
              // What ContextGatheringStep hands over: the tool-calling base prompt.
              enhancedSystemPrompt: SystemPrompts.buildEnhancedPrompt(
                contextSections: {'ctx': 'CONTEXT-SECTION'},
              ),
            ),
          );

      expect(openai.toolsSent.single, isNull);
      final systemPrompt = openai.lastSystemPrompt;
      expect(systemPrompt, contains('"replyText"'));
      expect(systemPrompt, contains('CONTEXT-SECTION'));
      expect(
        systemPrompt,
        isNot(contains(SystemPrompts.toolCallingBasePrompt)),
      );

      expect(result.success, isTrue);
      final chatResponse = ChatResponse.fromJson(
        result.data['chatResponse'] as Map<String, dynamic>,
      );
      expect(chatResponse.replyText, 'Here is a compat breakfast.');
      expect(chatResponse.recommendation, 'Drink water.');
      expect(chatResponse.dishes!.map((d) => d.name), [
        'Compat Oats',
        'Saved Bowl',
      ]);
      expect(chatResponse.dishes!.first.nutrition.calories, closeTo(190, 0.01));
      // References keep the database id so DishProcessingStep can load them.
      expect(chatResponse.dishes!.last.id, 'db-dish-1');
    });

    test('non-compat mode keeps the tool-calling prompt', () async {
      final openai = _FakeOpenAIService();
      await ResponseGenerationStep(
        openaiService: openai,
      ).execute(const ChatStepInput(userMessage: 'hi'));

      expect(openai.toolsSent.single, isNotNull);
      expect(
        openai.lastSystemPrompt,
        contains(SystemPrompts.toolCallingBasePrompt),
      );
    });
  });

  test('a timeout is classified as a network error', () async {
    final openai = _FakeOpenAIService(
      error: TimeoutException('OpenAI request timed out after 60s'),
    );
    final result = await ResponseGenerationStep(
      openaiService: openai,
    ).execute(const ChatStepInput(userMessage: 'hi'));

    expect(result.success, isFalse);
    expect(result.error!.type, ChatErrorType.networkError);
  });

  test('an unreadable image is flagged instead of silently dropped', () async {
    final openai = _FakeOpenAIService();
    final result = await ResponseGenerationStep(openaiService: openai).execute(
      const ChatStepInput(
        userMessage: 'What is this?',
        imageUri: '/does/not/exist.jpg',
      ),
    );

    expect(result.success, isTrue);
    expect(result.data['imageAnalysisFailed'], isTrue);

    final textOnly = await ResponseGenerationStep(
      openaiService: openai,
    ).execute(const ChatStepInput(userMessage: 'hi'));
    expect(textOnly.data.containsKey('imageAnalysisFailed'), isFalse);
  });
}
