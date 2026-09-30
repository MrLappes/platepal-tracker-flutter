import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:platepal_tracker/components/chat/chat_welcome.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/screens/chat_screen.dart';
import 'package:platepal_tracker/services/secure_key_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('unreadable chat history is reported with a snackbar', (
    tester,
  ) async {
    SecureKeyStore.resetForTesting();
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({
      'openai_api_key': 'sk-test',
      'chat_messages': ['not json'],
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ChatScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.text("Some of your chat history couldn't be loaded."),
      findsOneWidget,
    );
  });

  testWidgets('chat without a key only offers configuration', (tester) async {
    SecureKeyStore.resetForTesting();
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ChatScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(ElevatedButton, 'Configure API Key'),
      findsOneWidget,
    );
    expect(find.text('Reload API Key'), findsNothing);
  });

  testWidgets('chat refreshes API key after returning from settings', (
    tester,
  ) async {
    SecureKeyStore.resetForTesting();
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const ChatScreen()),
        GoRoute(
          path: '/settings/api-key',
          builder:
              (context, state) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    await SecureKeyStore.writeApiKey('sk-test');
                    if (context.mounted) context.pop();
                  },
                  child: const Text('Save test key'),
                ),
              ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Configure API Key'), findsOneWidget);

    await tester.tap(find.text('Configure API Key'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save test key'));
    await tester.pumpAndSettle();

    expect(find.byType(ChatWelcome), findsOneWidget);
    expect(find.text('Configure API Key'), findsNothing);
  });

  testWidgets('chat refreshes API key when the app resumes', (tester) async {
    SecureKeyStore.resetForTesting();
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ChatScreen(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Configure API Key'), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await SecureKeyStore.writeApiKey('sk-test');
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(find.byType(ChatWelcome), findsOneWidget);
    expect(find.text('Configure API Key'), findsNothing);
  });
}
