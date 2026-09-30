import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/screens/settings/api_key_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Spanish API key visibility and removal controls have tooltips', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ApiKeySettingsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final showKey = find.byTooltip('Mostrar clave API');
    expect(showKey, findsOneWidget);
    expect(tester.getSize(showKey).shortestSide, greaterThanOrEqualTo(48));
    await tester.tap(showKey);
    await tester.pump();
    expect(find.byTooltip('Ocultar clave API'), findsOneWidget);
  });

  testWidgets(
    'compatibility settings labels and required errors follow Spanish locale',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ApiKeySettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Modo de API'), findsOneWidget);
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      expect(find.text('URL base'), findsOneWidget);
      expect(find.text('Nombre del modelo'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Probar y Guardar Clave API'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Probar y Guardar Clave API'));
      await tester.pumpAndSettle();
      expect(
        find.text('La URL base es obligatoria en modo compatible'),
        findsOneWidget,
      );
      expect(
        find.text('El nombre del modelo es obligatorio en modo compatible'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'compatibility mode requires a key without the OpenAI sk-prefix error',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ApiKeySettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'https://api.example.com/v1',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'custom-model');
      await tester.scrollUntilVisible(
        find.text('Probar y Guardar Clave API'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Probar y Guardar Clave API'));
      await tester.pumpAndSettle();

      expect(
        find.text('La clave de API es obligatoria en modo compatible'),
        findsOneWidget,
      );
      expect(find.text('La clave API debe comenzar con "sk-"'), findsNothing);
    },
  );
}
