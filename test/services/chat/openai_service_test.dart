import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:platepal_tracker/services/chat/openai_service.dart';
import 'package:platepal_tracker/services/secure_key_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SecureKeyStore.resetForTesting();
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('testApiKey never logs the API key or the raw response body', () async {
    const key = 'sk-secret-123';
    final logs = <String>[];
    final originalDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) logs.add(message);
    };
    addTearDown(() => debugPrint = originalDebugPrint);

    final responses = [
      http.Response(
        jsonEncode({
          'choices': [
            {
              'message': {'content': ''},
            },
          ],
          'marker': 'RAW-BODY-MARKER',
        }),
        200,
      ),
      http.Response(
        jsonEncode({
          'error': {'message': 'Incorrect API key provided: $key'},
          'marker': 'RAW-BODY-MARKER',
        }),
        401,
      ),
    ];

    for (final response in responses) {
      String? authHeader;
      final service = OpenAIService(
        httpClient: MockClient((request) async {
          authHeader = request.headers['Authorization'];
          return response;
        }),
      );
      final result = await service.testApiKey(key, 'gpt-4o');
      expect(result.success, isFalse);
      expect(authHeader, 'Bearer $key');
    }

    final allLogs = logs.join('\n');
    expect(allLogs, isNot(contains(key)));
    expect(allLogs, isNot(contains('RAW-BODY-MARKER')));
  });

  testWidgets(
    'sendChatRequest throws a TimeoutException when the server hangs',
    (tester) async {
      SharedPreferences.setMockInitialValues({'openai_api_key': 'sk-test'});
      final service = OpenAIService(
        httpClient: MockClient((_) => Completer<http.Response>().future),
      );

      Object? error;
      var finished = false;
      unawaited(
        service
            .sendChatRequest(
              messages: [
                {'role': 'user', 'content': 'hi'},
              ],
            )
            .then<void>((_) {}, onError: (Object e) => error = e)
            .whenComplete(() => finished = true),
      );

      await tester.pump();
      expect(finished, isFalse);
      await tester.pump(OpenAIService.chatRequestTimeout);
      await tester.pump(const Duration(seconds: 1));

      expect(finished, isTrue);
      expect(error, isA<TimeoutException>());
    },
  );

  group('normalizeBaseUrl', () {
    String normalized(String? url) =>
        OpenAIService.normalizeBaseUrl(url).toString();

    test('defaults to OpenAI and appends /v1 like chat requests do', () {
      expect(normalized(null), 'https://api.openai.com/v1');
      expect(normalized('  '), 'https://api.openai.com/v1');
      expect(
        normalized('https://llm.example.com'),
        'https://llm.example.com/v1',
      );
      expect(
        normalized('https://llm.example.com/'),
        'https://llm.example.com/v1',
      );
      expect(
        normalized('https://llm.example.com/v1/'),
        'https://llm.example.com/v1',
      );
      expect(
        normalized('https://openrouter.ai/api/v1'),
        'https://openrouter.ai/api/v1',
      );
    });

    test('allows plain http only for local servers', () {
      expect(normalized('http://localhost:1234'), 'http://localhost:1234/v1');
      expect(
        normalized('http://127.0.0.1:8080/v1'),
        'http://127.0.0.1:8080/v1',
      );
      expect(normalized('http://10.0.2.2:11434'), 'http://10.0.2.2:11434/v1');
    });

    test('rejects URLs the key must not be sent to', () {
      for (final url in [
        'http://llm.example.com',
        'http://192.168.1.10:1234',
        'ftp://llm.example.com',
        'llm.example.com',
        '/v1',
        'https://',
        'not a url',
      ]) {
        expect(
          () => OpenAIService.normalizeBaseUrl(url),
          throwsA(
            isA<OpenAIServiceException>().having(
              (e) => e.failure,
              'failure',
              OpenAIFailure.invalidBaseUrl,
            ),
          ),
          reason: url,
        );
      }
    });
  });

  group('custom base URL', () {
    test('testApiKey and getAvailableModels use the normalized URL', () async {
      final urls = <Uri>[];
      final service = OpenAIService(
        httpClient: MockClient((request) async {
          urls.add(request.url);
          if (request.url.path.endsWith('/models')) {
            return http.Response(
              jsonEncode({
                'data': [
                  {'id': 'gpt-4o'},
                ],
              }),
              200,
            );
          }
          return http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {'content': 'Hello'},
                },
              ],
            }),
            200,
          );
        }),
      );

      final result = await service.testApiKey(
        'sk-test',
        'local-model',
        customBaseUrl: 'https://llm.example.com/',
      );
      await service.getAvailableModels(
        'sk-test',
        customBaseUrl: 'https://llm.example.com',
      );

      expect(result.success, isTrue);
      expect(urls.map((u) => u.toString()), [
        'https://llm.example.com/v1/chat/completions',
        'https://llm.example.com/v1/models',
      ]);
    });

    test('an invalid URL never receives the key', () async {
      var requests = 0;
      final service = OpenAIService(
        httpClient: MockClient((_) async {
          requests++;
          return http.Response('{}', 200);
        }),
      );

      final result = await service.testApiKey(
        'sk-test',
        'm',
        customBaseUrl: 'http://evil.example.com',
      );
      expect(result.success, isFalse);
      expect(result.failure, OpenAIFailure.invalidBaseUrl);

      await expectLater(
        service.getAvailableModels(
          'sk-test',
          customBaseUrl: 'http://evil.example.com',
        ),
        throwsA(isA<OpenAIServiceException>()),
      );

      SharedPreferences.setMockInitialValues({
        'openai_api_key': 'sk-test',
        'openai_compatibility_mode': true,
        'openai_custom_base_url': 'http://evil.example.com',
        'openai_custom_model': 'm',
      });
      await expectLater(
        service.sendChatRequest(
          messages: [
            {'role': 'user', 'content': 'hi'},
          ],
        ),
        throwsA(
          isA<OpenAIServiceException>().having(
            (e) => e.failure,
            'failure',
            OpenAIFailure.invalidBaseUrl,
          ),
        ),
      );
      expect(requests, 0);
    });
  });

  group('getAvailableModels', () {
    test('returns defaults without a key and makes no request', () async {
      var requests = 0;
      final service = OpenAIService(
        httpClient: MockClient((_) async {
          requests++;
          return http.Response('{}', 200);
        }),
      );

      expect(
        await service.getAvailableModels('  '),
        service.getDefaultModels(),
      );
      expect(requests, 0);
    });

    test('surfaces HTTP errors instead of returning defaults', () async {
      final service = OpenAIService(
        httpClient: MockClient((_) async => http.Response('nope', 500)),
      );

      await expectLater(
        service.getAvailableModels('sk-test'),
        throwsA(
          isA<OpenAIServiceException>()
              .having((e) => e.failure, 'failure', OpenAIFailure.server)
              .having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });

    test('surfaces network errors instead of returning defaults', () async {
      final service = OpenAIService(
        httpClient: MockClient(
          (_) async => throw http.ClientException('no route'),
        ),
      );

      await expectLater(
        service.getAvailableModels('sk-test'),
        throwsA(
          isA<OpenAIServiceException>().having(
            (e) => e.failure,
            'failure',
            OpenAIFailure.network,
          ),
        ),
      );
    });
  });

  group('server error messages are redacted', () {
    const key = 'sk-proj-SuperSecretKey1234567890';
    const otherKey = 'sk-other-abcdefghij';
    final errorBody = jsonEncode({
      'error': {
        'message': 'Bad key $key (also tried $otherKey, sk-proj-****7890)',
      },
    });

    test('testApiKey', () async {
      final service = OpenAIService(
        httpClient: MockClient((_) async => http.Response(errorBody, 500)),
      );

      final result = await service.testApiKey(key, 'gpt-4o');

      expect(result.success, isFalse);
      expect(result.message, contains('[redacted]'));
      expect(result.message, isNot(contains('SuperSecret')));
      expect(result.message, isNot(contains(otherKey)));
      expect(result.message, isNot(contains('****7890')));
    });

    test('sendChatRequest', () async {
      SharedPreferences.setMockInitialValues({'openai_api_key': key});
      final service = OpenAIService(
        httpClient: MockClient((_) async => http.Response(errorBody, 500)),
      );

      Object? error;
      try {
        await service.sendChatRequest(
          messages: [
            {'role': 'user', 'content': 'hi'},
          ],
        );
      } catch (e) {
        error = e;
      }

      expect(error.toString(), contains('[redacted]'));
      expect(error.toString(), isNot(contains('SuperSecret')));
      expect(error.toString(), isNot(contains(otherKey)));
    });
  });

  group('chat request errors are typed', () {
    Future<Object?> failSend(MockClient client, {bool plain = false}) async {
      SharedPreferences.setMockInitialValues({'openai_api_key': 'sk-test'});
      final service = OpenAIService(httpClient: client);
      try {
        if (plain) {
          await service.sendMessage('hi');
        } else {
          await service.sendChatRequest(
            messages: [
              {'role': 'user', 'content': 'hi'},
            ],
          );
        }
      } catch (e) {
        expect(service.lastErrorKind, OpenAIService.errorKindOf(e));
        return e;
      }
      fail('request should have failed');
    }

    for (final (status, kind) in [
      (401, ChatErrorKind.auth),
      (403, ChatErrorKind.auth),
      (429, ChatErrorKind.rateLimit),
      (500, ChatErrorKind.server),
      (503, ChatErrorKind.server),
      (400, ChatErrorKind.unknown),
    ]) {
      for (final plain in [false, true]) {
        test('HTTP $status is $kind (plain: $plain)', () async {
          final error = await failSend(
            MockClient(
              (_) async => http.Response(
                jsonEncode({
                  'error': {'message': 'nope'},
                }),
                status,
              ),
            ),
            plain: plain,
          );
          expect(
            error,
            isA<OpenAIServiceException>().having(
              (e) => e.statusCode,
              'statusCode',
              status,
            ),
          );
          expect(OpenAIService.errorKindOf(error!), kind);
        });
      }
    }

    test('connection failures are network errors', () async {
      final error = await failSend(
        MockClient((_) async => throw http.ClientException('offline')),
      );
      expect(
        error,
        isA<OpenAIServiceException>().having(
          (e) => e.failure,
          'failure',
          OpenAIFailure.network,
        ),
      );
      expect(OpenAIService.errorKindOf(error!), ChatErrorKind.network);
    });

    test('timeouts are network errors', () {
      expect(
        OpenAIService.errorKindOf(TimeoutException('slow')),
        ChatErrorKind.network,
      );
      expect(OpenAIService.errorKindOf(Exception('x')), ChatErrorKind.unknown);
    });
  });

  test('reads a migrated legacy key from secure storage', () async {
    SharedPreferences.setMockInitialValues({'openai_api_key': 'sk-legacy'});
    String? authHeader;
    final service = OpenAIService(
      httpClient: MockClient((request) async {
        authHeader = request.headers['Authorization'];
        return http.Response(
          jsonEncode({
            'id': 'x',
            'object': 'chat.completion',
            'created': 0,
            'model': 'gpt-4o',
            'choices': [
              {
                'index': 0,
                'message': {'role': 'assistant', 'content': 'ok'},
                'finish_reason': 'stop',
              },
            ],
          }),
          200,
        );
      }),
    );

    expect(await service.isConfigured(), isTrue);
    await service.sendChatRequest(
      messages: [
        {'role': 'user', 'content': 'hi'},
      ],
    );

    expect(authHeader, 'Bearer sk-legacy');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('openai_api_key'), isNull);
  });
}
