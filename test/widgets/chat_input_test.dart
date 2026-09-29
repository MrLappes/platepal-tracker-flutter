import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/components/chat/chat_input.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';

void main() {
  testWidgets('attachment control has a localized 48dp tap target', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ChatInput(onSendMessage: (message, {imageUrl, ingredients}) {}),
        ),
      ),
    );

    final attach = find.byTooltip('Añadir archivos adjuntos');
    expect(attach, findsOneWidget);
    expect(tester.getSize(attach).width, greaterThanOrEqualTo(48));
    expect(tester.getSize(attach).height, greaterThanOrEqualTo(48));
  });
}
