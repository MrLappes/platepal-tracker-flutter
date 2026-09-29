import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/models/chat_message.dart';
import 'package:platepal_tracker/models/user_ingredient.dart';
import 'package:platepal_tracker/providers/chat_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
}
