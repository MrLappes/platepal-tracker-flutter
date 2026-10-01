import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/components/calendar/macro_summary.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';

Widget _app(Widget child, {Locale locale = const Locale('es')}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  for (final (locale, amount, status) in [
    (const Locale('de'), '26,1g / 20g', '6,1 g über dem Ziel'),
    (const Locale('en'), '26.1g / 20g', 'Over goal by 6.1 g'),
  ]) {
    testWidgets(
      '${locale.languageCode} macro decimals match visible text and semantics',
      (tester) async {
        await tester.pumpWidget(
          _app(
            const MacroSummary(
              calories: 800,
              protein: 26.1,
              carbs: 70,
              fat: 20,
              proteinTarget: 20,
            ),
            locale: locale,
          ),
        );

        expect(find.text(amount), findsOneWidget);
        expect(find.text(status), findsOneWidget);
        final values =
            tester
                .widgetList<Semantics>(find.byType(Semantics))
                .map((widget) => widget.properties.value ?? '')
                .toList();
        expect(values, contains(status));
      },
    );
  }

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

  testWidgets('AI tip shares the expanded summary header without collapsing', (
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
          isCollapsible: true,
          onAiTipPressed: () => pressed = true,
        ),
      ),
    );

    final title = find.text('Resumen Nutricional');
    final tip = find.bySemanticsLabel('Obtener Consejo IA');
    final chevron = find.byIcon(Icons.keyboard_arrow_up);
    expect(tip, findsOneWidget);
    expect(tester.getSize(tip).height, greaterThanOrEqualTo(48));
    expect(
      (tester.getCenter(tip).dy - tester.getCenter(title).dy).abs(),
      lessThan(12),
    );
    expect(
      (tester.getCenter(tip).dy - tester.getCenter(chevron).dy).abs(),
      lessThan(12),
    );

    await tester.tap(tip);
    await tester.pump();
    expect(pressed, isTrue);
    expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
  });

  testWidgets('English phone-width header has an accessible AI tip fallback', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MacroSummary(
            calories: 800,
            protein: 30,
            carbs: 70,
            fat: 20,
            isCollapsible: true,
            onAiTipPressed: () {},
          ),
        ),
      ),
    );

    final tip = find.byTooltip('Get AI Tip');
    expect(tip, findsOneWidget);
    expect(tester.getSize(tip).height, greaterThanOrEqualTo(48));
    expect(tester.takeException(), isNull);
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

    final tip = find.byTooltip('Obtener Consejo IA');
    expect(tip, findsOneWidget);
    expect(tester.getSize(tip).height, greaterThanOrEqualTo(48));
    expect(tester.takeException(), isNull);
    await tester.tap(tip);
    await tester.pump();
    expect(pressed, isTrue);
    expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
  });
}
