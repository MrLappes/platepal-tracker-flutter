import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:platepal_tracker/services/chat/openai_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
}
