import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:platepal_tracker/components/scanner/product_search_screen.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/providers/locale_provider.dart';
import 'package:platepal_tracker/services/open_food_facts_service.dart';
import 'package:platepal_tracker/services/storage/database_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  testWidgets('product categories have full-size selected button semantics', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(prefs: prefs),
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ProductSearchScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final all = find.byWidgetPredicate(
      (widget) => widget is Semantics && widget.properties.label == 'All',
    );
    expect(all, findsOneWidget);
    expect(tester.getSize(all).height, greaterThanOrEqualTo(48));
    expect(tester.getSemantics(all).flagsCollection.isButton, isTrue);
    expect(tester.getSemantics(all).flagsCollection.isSelected, Tristate.isTrue);

    final fruits = find.byWidgetPredicate(
      (widget) => widget is Semantics && widget.properties.label == 'Fruits',
    );
    expect(fruits, findsOneWidget);
    expect(tester.getSize(fruits).height, greaterThanOrEqualTo(48));
    await tester.tap(fruits);
    await tester.pump();
    expect(
      tester.getSemantics(fruits).flagsCollection.isSelected,
      Tristate.isTrue,
    );
    expect(tester.getSemantics(all).flagsCollection.isSelected, Tristate.isFalse);
    semantics.dispose();
  });

  testWidgets('product grade and sort options announce their selection', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(prefs: prefs),
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ProductSearchScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Filters & Sort'));
    await tester.pumpAndSettle();

    Finder option(String label) => find.byWidgetPredicate(
      (widget) => widget is Semantics && widget.properties.label == label,
    );

    expect(
      tester.getSemantics(option('Any')).flagsCollection.isSelected,
      Tristate.isTrue,
    );
    await tester.tap(option('A'));
    await tester.pump();
    expect(
      tester.getSemantics(option('A')).flagsCollection.isSelected,
      Tristate.isTrue,
    );
    expect(
      tester.getSemantics(option('Any')).flagsCollection.isSelected,
      Tristate.isFalse,
    );
    expect(
      tester
          .getSemantics(option('Most Popular'))
            .flagsCollection.isSelected,
          Tristate.isTrue,
    );
    await tester.tap(option('Name A–Z'));
    await tester.pump();
    expect(
      tester.getSemantics(option('Name A–Z')).flagsCollection.isSelected,
      Tristate.isTrue,
    );
    semantics.dispose();
  });

  for (final (name, error, message) in [
    (
      'offline',
      const SocketException('Failed host lookup'),
      "You're offline. Check your connection and try again.",
    ),
    (
      'timeout',
      TimeoutException('stalled'),
      'Open Food Facts took too long to respond. Try again.',
    ),
  ]) {
    testWidgets('$name browse failure shows a mapped message and retries', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      var fail = true;
      var requests = 0;
      final client = MockClient((request) async {
        requests++;
        if (fail) throw error;
        return http.Response(
          jsonEncode({
            'products': [
              {
                'code': '42',
                'product_name': 'Oat Drink',
                'nutriments': {'energy-kcal_100g': 46},
              },
            ],
          }),
          200,
        );
      });
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(prefs: prefs),
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ProductSearchScreen(
              service: OpenFoodFactsService(client: client),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(message), findsOneWidget);
      expect(find.textContaining('Exception'), findsNothing);
      expect(find.textContaining('stalled'), findsNothing);

      fail = false;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(requests, 2);
      expect(find.text(message), findsNothing);
      expect(find.text('OAT DRINK'), findsOneWidget);
    });
  }

  testWidgets('rate-limited search keeps an inline error with retry', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
    final prefs = await SharedPreferences.getInstance();
    final client = MockClient(
      (request) async =>
          request.url.path.contains('search.pl')
              ? http.Response('Too many requests', 429)
              : http.Response(jsonEncode({'products': []}), 200),
    );
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(prefs: prefs),
        child: MaterialApp(
          locale: const Locale('de'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ProductSearchScreen(
            service: OpenFoodFactsService(client: client),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'hafer');
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Open Food Facts ist ausgelastet oder nicht erreichbar. '
        'Warte kurz und versuche es erneut.',
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });
}
