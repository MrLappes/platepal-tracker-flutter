import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/components/calendar/macro_summary.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';

Widget _app(Widget child) => MaterialApp(
  locale: const Locale('es'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  testWidgets(
    'Spanish macro bars state under and over goal in text and semantics',
    (tester) async {
      await tester.pumpWidget(
        _app(
          const MacroSummary(
            calories: 2120,
            protein: 85,
            carbs: 180,
            fat: 60,
            calorieTarget: 2000,
            proteinTarget: 100,
          ),
        ),
      );

      expect(find.text('Por encima del objetivo en 120 kcal'), findsOneWidget);
      expect(find.text('85 % del objetivo'), findsOneWidget);
      final values =
          tester
              .widgetList<Semantics>(find.byType(Semantics))
              .map((widget) => widget.properties.value ?? '')
              .toList();
      expect(values, contains(contains('120 kcal')));
      expect(values, contains(contains('85 % del objetivo')));
    },
  );

  testWidgets('collapsed macro bar and AI tip are readable and actionable', (
    tester,
  ) async {
    var pressed = false;
    await tester.pumpWidget(
      _app(
        MacroSummary(
          calories: 800,
          protein: 30,
          carbs: 70,
          fat: 20,
          calorieTarget: 1000,
          isCollapsible: true,
          initiallyExpanded: false,
          onAiTipPressed: () => pressed = true,
        ),
      ),
    );

    expect(find.text('80%'), findsOneWidget);
    final tip = find.bySemanticsLabel('Obtener Consejo IA');
    expect(tip, findsOneWidget);
    expect(tester.getSize(tip).height, greaterThanOrEqualTo(48));
    await tester.tap(tip);
    expect(pressed, isTrue);
  });

  testWidgets('compact calorie overage is announced in kcal', (tester) async {
    await tester.pumpWidget(
      _app(
        const MacroSummary(
          calories: 1120,
          protein: 30,
          carbs: 70,
          fat: 20,
          calorieTarget: 1000,
          isCollapsible: true,
          initiallyExpanded: false,
        ),
      ),
    );

    final values =
        tester
            .widgetList<Semantics>(find.byType(Semantics))
            .map((widget) => widget.properties.value ?? '')
            .toList();
    expect(values, contains(contains('120 kcal')));
  });

  testWidgets('Spanish compact header fits a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _app(
        MacroSummary(
          calories: 800,
          protein: 30,
          carbs: 70,
          fat: 20,
          calorieTarget: 1000,
          isCollapsible: true,
          initiallyExpanded: false,
          onAiTipPressed: () {},
        ),
      ),
    );
  });
}
