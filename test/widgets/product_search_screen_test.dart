import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/components/scanner/product_search_screen.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/providers/locale_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
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
}
