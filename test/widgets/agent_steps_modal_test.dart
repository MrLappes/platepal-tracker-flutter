import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/components/chat/agent_steps_modal.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';

void main() {
  testWidgets('agent statuses and modification labels follow German locale', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AgentStepsModal(
          metadata: {
            'stepResults': [
              {
                'stepName': 'skipped_step',
                'success': true,
                'data': <String, dynamic>{'skipped': true},
              },
              {
                'stepName': 'error_handling',
                'success': true,
                'data': <String, dynamic>{},
              },
            ],
            'pipelineModifications': {
              'summary': {'totalModifications': 1, 'hasAutomaticFixes': true},
              'modifications': [
                {
                  'id': 'fix-1',
                  'type': 'automaticFix',
                  'severity': 'low',
                  'stepName': 'skipped_step',
                  'description': 'Korrektur',
                  'technicalDetails': 'Details',
                  'wasSuccessful': false,
                  'beforeData': {'value': 1},
                  'afterData': {'value': 2},
                },
              ],
            },
          },
        ),
      ),
    );

    expect(find.text('Übersprungen'), findsOneWidget);
    expect(find.text('Fehler behoben'), findsOneWidget);
    expect(find.text('Gesamtänderungen: 1'), findsOneWidget);
    expect(find.text('Automatische Korrekturen'), findsWidgets);

    await tester.ensureVisible(find.text('Korrektur'));
    await tester.tap(find.text('Korrektur'));
    await tester.pumpAndSettle();

    expect(find.text('FEHLGESCHLAGEN'), findsOneWidget);
    expect(find.text('skipped_step • NIEDRIG'), findsOneWidget);
    expect(find.text('Technische Details'), findsOneWidget);
    expect(find.text('Datenänderungen'), findsOneWidget);
    expect(find.text('Vorher'), findsOneWidget);
    expect(find.text('Nachher'), findsOneWidget);
  });

  testWidgets('agent fallback summaries follow German locale', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AgentStepsModal(
          metadata: {
            'stepResults': [
              {
                'success': true,
                'data': <String, dynamic>{'skipped': true},
              },
              {
                'stepName': 'ingredients',
                'success': true,
                'data': <String, dynamic>{
                  'items': [1, 2],
                  'settings': {'count': 1},
                  'valid': true,
                  'extra': 'unused',
                  'modifications': <String, dynamic>{
                    'modifications': [
                      {'severity': 'low'},
                    ],
                  },
                },
              },
            ],
          },
        ),
      ),
    );

    expect(find.text('Unbekannter Schritt'), findsOneWidget);
    expect(find.text('Assistent'), findsOneWidget);
    await tester.ensureVisible(find.text('Unbekannter Schritt'));
    await tester.tap(find.text('Unbekannter Schritt'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Kein Grund angegeben'), findsWidgets);

    await tester.ensureVisible(find.text('ingredients'));
    await tester.tap(find.text('ingredients'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Listeneinträge: 2'), findsWidgets);
    expect(find.textContaining('Zuordnungseinträge: 1'), findsWidgets);
    expect(find.textContaining('Weitere Einträge: 2'), findsWidgets);
    expect(
      find.text('Zusammenfassung: Keine Zusammenfassung verfügbar'),
      findsOneWidget,
    );
  });

  testWidgets(
    'unencodable agent data shows raw values without English labels',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('de'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AgentStepsModal(
            metadata: {
              'stepResults': [
                {
                  'stepName': 'invalid_data',
                  'success': true,
                  'data': {'value': _BrokenChatStepVerificationResult()},
                },
              ],
            },
          ),
        ),
      );

      await tester.tap(find.text('invalid_data'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Error serializing data'), findsNothing);
      expect(find.textContaining('value: invalid-json'), findsWidgets);
    },
  );
}

class _BrokenChatStepVerificationResult {
  Object toJson() => Object();

  @override
  String toString() => 'invalid-json';
}
