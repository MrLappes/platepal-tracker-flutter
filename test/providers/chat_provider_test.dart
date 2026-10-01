import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/models/chat_message.dart';
import 'package:platepal_tracker/models/user_ingredient.dart';
import 'package:platepal_tracker/providers/chat_provider.dart';
import 'package:platepal_tracker/services/chat/openai_service.dart';
import 'package:platepal_tracker/services/secure_key_store.dart';
import 'package:platepal_tracker/services/storage/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  test('a logged meal proposal stays logged after reloading', () async {
    final stored = ChatMessage(
      id: 'bot-1',
      content: 'Confirm the entry below.',
      sender: MessageSender.assistant,
      timestamp: DateTime(2026, 9, 20),
      metadata: const {
        'mealLogProposals': [
          {'dishId': 'pasta'},
        ],
      },
    );
    SecureKeyStore.resetForTesting();
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({
      'chat_messages': [jsonEncode(stored.toJson())],
    });
    final provider = ChatProvider();
    addTearDown(provider.dispose);
    await pumpEventQueue(times: 200);
    expect(provider.messages, hasLength(1));

    await provider.setMealLogProposalStatus('bot-1', 0, 'logged');

    final prefs = await SharedPreferences.getInstance();
    final saved = ChatMessage.fromJson(
      jsonDecode(prefs.getStringList('chat_messages')!.single),
    );
    expect(saved.metadata!['mealLogProposalStatus'], {'0': 'logged'});
    expect(saved.metadata!['mealLogProposals'], hasLength(1));
    expect(
      provider.messages.single.metadata!['mealLogProposalStatus'],
      {'0': 'logged'},
    );
  });

  testWidgets('concurrent sends add only one user message', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = ChatProvider();
    addTearDown(provider.dispose);
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final firstSend = provider.sendMessage('First message');
      expect(provider.isLoading, isTrue);
      final secondSend = provider.sendMessage('Second message');
      await Future.wait([firstSend, secondSend]);
    });

    expect(
      provider.messages.where(
        (message) => message.sender == MessageSender.user,
      ),
      hasLength(1),
    );
  });

  testWidgets(
    'ingredient-only send keeps ingredients and uses localized prompt',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final provider = ChatProvider();
      addTearDown(provider.dispose);
      late BuildContext chatContext;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              chatContext = context;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.runAsync(() async {
        await provider.sendMessage(
          '',
          context: chatContext,
          userIngredients: const [
            UserIngredient(id: 'rice', name: 'Arroz', quantity: 100, unit: 'g'),
          ],
        );
      });

      final userMessages = provider.messages.where(
        (message) => message.sender == MessageSender.user,
      );
      expect(userMessages, hasLength(1));
      expect(
        userMessages.single.content,
        '¿Qué puedo preparar con estos ingredientes?',
      );
      expect(
        (userMessages.single.metadata?['userIngredients'] as List)
            .single['name'],
        'Arroz',
      );
    },
  );

  group('failures', () {
    const plainSystemPrompt =
        'You are a helpful nutrition and fitness assistant for PlatePal Tracker app.';

    setUp(() async {
      SecureKeyStore.resetForTesting();
      FlutterSecureStorage.setMockInitialValues({});
      await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
    });

    /// Runs [body] with every `http` call answered by [handler].
    Future<void> withHttp(
      Future<http.Response> Function(Map<String, dynamic> body) handler,
      Future<void> Function() body,
    ) => http.runWithClient(
      body,
      () => MockClient(
        (request) => handler(jsonDecode(request.body) as Map<String, dynamic>),
      ),
    );

    Future<ChatProvider> readyProvider() async {
      final provider = ChatProvider();
      addTearDown(provider.dispose);
      await pumpEventQueue(times: 200);
      await provider.refreshApiKeyConfiguration();
      return provider;
    }

    String systemPrompt(Map<String, dynamic> body) =>
        ((body['messages'] as List).first as Map)['content'].toString();

    ChatMessage onlyUserMessage(ChatProvider provider) =>
        provider.messages.singleWhere((m) => m.isFromUser);

    test('a rejected key fails the message with a persisted kind; retry recovers', () async {
      SharedPreferences.setMockInitialValues({'openai_api_key': 'sk-test'});
      var status = 401;
      await withHttp(
        (_) async => http.Response(
          jsonEncode(
            status == 200
                ? {
                  'choices': [
                    {
                      'message': {'content': 'Hello again'},
                    },
                  ],
                }
                : {
                  'error': {'message': 'bad key'},
                },
          ),
          status,
        ),
        () async {
          final provider = await readyProvider();
          await provider.sendMessage('Hi');

          final failed = onlyUserMessage(provider);
          expect(failed.hasFailed, isTrue);
          expect(failed.metadata?['errorKind'], ChatErrorKind.auth.name);
          final prefs = await SharedPreferences.getInstance();
          final stored = prefs.getStringList('chat_messages')!;
          expect(jsonDecode(stored.single)['metadata']['errorKind'], 'auth');

          status = 200;
          await provider.retryMessage(failed.id);
          final retried = onlyUserMessage(provider);
          expect(retried.hasFailed, isFalse);
          expect(retried.metadata?.containsKey('errorKind'), isFalse);
          expect(provider.messages.last.content, 'Hello again');
        },
      );
    });

    for (final (status, kind, fallsBack) in [
      (401, ChatErrorKind.auth, false),
      (429, ChatErrorKind.rateLimit, false),
      (503, ChatErrorKind.server, true),
    ]) {
      test('agent pipeline HTTP $status -> $kind, fallback: $fallsBack', () async {
        SharedPreferences.setMockInitialValues({
          'openai_api_key': 'sk-test',
          'agent_mode_enabled': true,
          'app_locale': 'en',
        });
        final bodies = <Map<String, dynamic>>[];
        await withHttp(
          (body) async {
            bodies.add(body);
            return http.Response('{"error": {"message": "x"}}', status);
          },
          () async {
            final provider = await readyProvider();
            await provider.sendMessage('Suggest a breakfast');

            final failed = onlyUserMessage(provider);
            expect(failed.hasFailed, isTrue);
            expect(failed.metadata?['errorKind'], kind.name);
            expect(
              bodies.any((b) => systemPrompt(b) == plainSystemPrompt),
              fallsBack,
            );
          },
        );
      });
    }

    test('unreadable history entries are skipped and reported once', () async {
      final valid = ChatMessage(
        id: 'ok',
        content: 'Kept',
        sender: MessageSender.user,
        timestamp: DateTime(2026, 9, 1),
      );
      SharedPreferences.setMockInitialValues({
        'chat_messages': [
          jsonEncode(valid.toJson()),
          'not json',
          jsonEncode({'id': 1}),
        ],
      });

      final provider = await readyProvider();

      expect(provider.messages.map((m) => m.content), ['Kept']);
      expect(provider.takeNotices(), [ChatNotice.historyLoadFailed]);
      expect(provider.takeNotices(), isEmpty);
    });
  });

  test('response notes come from failed context and image steps', () {
    expect(ChatProvider.responseNotes(null), isEmpty);
    expect(
      ChatProvider.responseNotes({
        'stepResults': [
          {
            'stepName': 'context_gathering',
            'data': {
              'failedContextParts': ['userProfile'],
            },
          },
          {
            'stepName': 'response_generation',
            'data': {'imageAnalysisFailed': true},
          },
        ],
      }),
      ['contextIncomplete', 'imageNotAnalyzed'],
    );
    expect(
      ChatProvider.responseNotes({
        'stepResults': [
          {
            'stepName': 'context_gathering',
            'data': {'contextGatheringResult': {}},
          },
        ],
      }),
      isEmpty,
    );
  });
}
