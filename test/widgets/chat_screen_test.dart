import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
