import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/screens/dish_create_screen.dart';
import 'package:platepal_tracker/screens/platepal_import_screen.dart';
import 'package:platepal_tracker/services/data/platepal_dish_import.dart';

String _encode(Object? json) =>
    base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');

Map<String, dynamic> _valid([Map<String, dynamic> overrides = const {}]) => {
  'v': 1,
  'source': 'platepal',
  'name': '  Grandma\'s Lasagne ',
  'description': 'Layered,\nbaked for 45 min.',
  'ingredients': ['Pasta sheets', ' Minced beef', 'Tomatoes'],
  'servings': 6,
  ...overrides,
};

PlatePalImportError? _errorOf(String? payload) {
  try {
    decodePlatePalDish(payload);
    return null;
  } on PlatePalImportException catch (e) {
    return e.error;
  }
}

void main() {
  group('decodePlatePalDish', () {
    test('reads a valid version 1 payload', () {
      final draft = decodePlatePalDish(_encode(_valid()));
      expect(draft.name, "Grandma's Lasagne");
      expect(draft.description, 'Layered,\nbaked for 45 min.');
      expect(draft.ingredients, ['Pasta sheets', 'Minced beef', 'Tomatoes']);
      expect(draft.servings, 6);
    });

    test('optional fields may be missing and unknown keys are ignored', () {
      final draft = decodePlatePalDish(
        _encode({
          'v': 1,
          'source': 'platepal',
          'name': 'Toast',
          'ingredients': <String>[],
          'extra': {'future': true},
        }),
      );
      expect(draft.description, isNull);
      expect(draft.servings, isNull);
      expect(draft.ingredients, isEmpty);
    });

    test('limits are inclusive', () {
      final draft = decodePlatePalDish(
        _encode(
          _valid({
            'name': 'n' * 100,
            'description': 'd' * 500,
            'ingredients': List.filled(50, 'i' * 100),
            'servings': 100,
          }),
        ),
      );
      expect(draft.ingredients, hasLength(50));
      expect(decodePlatePalDish(_encode(_valid({'servings': 1}))).servings, 1);
    });

    test('padded base64 and non-ASCII text decode', () {
      final payload = base64Url.encode(
        utf8.encode(jsonEncode(_valid({'name': 'Käsespätzle 🧀'}))),
      );
      expect(decodePlatePalDish(payload).name, 'Käsespätzle 🧀');
    });

    test('rejects malformed, oversized and invalid payloads', () {
      final cases = <String?, PlatePalImportError>{
        null: PlatePalImportError.missing,
        '': PlatePalImportError.missing,
        'A' * 21847: PlatePalImportError.tooLarge,
        'not base64!': PlatePalImportError.malformed,
        'abcde': PlatePalImportError.malformed,
        base64Url.encode([0xff, 0xfe, 0xfd]): PlatePalImportError.malformed,
        _encode('just a string'): PlatePalImportError.malformed,
        _encode([1, 2]): PlatePalImportError.malformed,
        _encode(_valid({'v': '1'})): PlatePalImportError.malformed,
        _encode(_valid({'v': 2})): PlatePalImportError.unsupportedVersion,
        _encode(_valid({'source': 'other'})): PlatePalImportError.invalidContent,
        _encode(_valid({'name': '   '})): PlatePalImportError.invalidContent,
        _encode(_valid({'name': 'n' * 101})): PlatePalImportError.invalidContent,
        _encode(_valid({'name': 'Tab\there'})):
            PlatePalImportError.invalidContent,
        _encode(_valid({'name': 42})): PlatePalImportError.invalidContent,
        _encode(_valid({'description': 'd' * 501})):
            PlatePalImportError.invalidContent,
        _encode(_valid({'description': 'bell\u0007'})):
            PlatePalImportError.invalidContent,
        _encode(_valid({'ingredients': 'Pasta'})):
            PlatePalImportError.invalidContent,
        _encode(_valid({'ingredients': null})):
            PlatePalImportError.invalidContent,
        _encode(_valid({'ingredients': List.filled(51, 'x')})):
            PlatePalImportError.invalidContent,
        _encode(_valid({'ingredients': ['x' * 101]})):
            PlatePalImportError.invalidContent,
        _encode(_valid({'ingredients': ['ok', 3]})):
            PlatePalImportError.invalidContent,
        _encode(_valid({'ingredients': ['']})):
            PlatePalImportError.invalidContent,
        _encode(_valid({'servings': 0})): PlatePalImportError.invalidContent,
        _encode(_valid({'servings': 101})): PlatePalImportError.invalidContent,
        _encode(_valid({'servings': 2.5})): PlatePalImportError.invalidContent,
        _encode(_valid({'servings': '4'})): PlatePalImportError.invalidContent,
      };
      for (final MapEntry(key: payload, value: error) in cases.entries) {
        expect(_errorOf(payload), error, reason: '$error');
      }
    });

    test('a payload over 16 KB is rejected after decoding', () {
      final big = _encode(_valid({'description': 'x' * 20000}));
      expect(_errorOf(big), PlatePalImportError.tooLarge);
    });
  });

  group('platePalImportRedirect', () {
    test('maps the import link to the in-app route', () {
      expect(
        platePalImportRedirect(Uri.parse('platepaltracker://import-dish?d=abc_-')),
        '/import-dish?d=abc_-',
      );
      expect(
        platePalImportRedirect(Uri.parse('PlatePalTracker://IMPORT-DISH')),
        '/import-dish',
      );
    });

    test('leaves every other location alone', () {
      for (final location in [
        '/',
        '/import-dish?d=abc',
        '/settings/backup',
        'platepaltracker://other?d=abc',
        'https://import-dish/?d=abc',
      ]) {
        expect(platePalImportRedirect(Uri.parse(location)), isNull);
      }
    });
  });

  group('import route', () {
    Future<GoRouter> pumpRouter(WidgetTester tester) async {
      final router = GoRouter(
        redirect: (context, state) => platePalImportRedirect(state.uri),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: Text('home')),
            routes: [
              GoRoute(
                path: platePalImportRoute.substring(1),
                builder:
                    (context, state) => PlatePalImportScreen(
                      payload: state.uri.queryParameters['d'],
                    ),
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();
      return router;
    }

    testWidgets('a link opens the prefilled, unsaved dish form', (
      tester,
    ) async {
      final router = await pumpRouter(tester);
      router.go('platepaltracker://import-dish?d=${_encode(_valid())}');
      await tester.pumpAndSettle();

      final form = tester.widget<DishCreateScreenAdvanced>(
        find.byType(DishCreateScreenAdvanced),
      );
      expect(form.dish, isNull);
      expect(form.importedDraft!.name, "Grandma's Lasagne");
      expect(
        find.text('Imported from PlatePal – check the ingredients and amounts'),
        findsOneWidget,
      );
      expect(find.text("Grandma's Lasagne"), findsOneWidget);
      expect(
        tester
            .widget<TextField>(
              find.byKey(const ValueKey('dish-create-servings')),
            )
            .controller!
            .text,
        '6',
      );
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -1500),
      );
      await tester.pumpAndSettle();
      expect(find.text('Minced beef'), findsOneWidget);
      expect(find.text('Add amount and nutrition'), findsNWidgets(3));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Complete or remove the ingredients marked in red before saving.',
        ),
        findsOneWidget,
      );
      expect(find.byType(DishCreateScreenAdvanced), findsOneWidget);
    });

    testWidgets('an invalid link shows an error instead of a form', (
      tester,
    ) async {
      final router = await pumpRouter(tester);
      router.go('platepaltracker://import-dish?d=bogus!');
      await tester.pumpAndSettle();
      expect(find.byType(DishCreateScreenAdvanced), findsNothing);
      expect(
        find.text(
          'This PlatePal link is invalid or incomplete. Share the dish again from PlatePal.',
        ),
        findsOneWidget,
      );

      router.go(
        'platepaltracker://import-dish?d=${_encode(_valid({'v': 2}))}',
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('newer version of PlatePal'),
        findsOneWidget,
      );
    });
  });
}
