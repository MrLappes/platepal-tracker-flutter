import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/screens/settings/contributors_screen.dart';

void main() {
  testWidgets('German contributor link and back buttons have tooltips', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ContributorsScreen(),
      ),
    );

    final github = find.byTooltip('GitHub-Profil von MrLappes öffnen');
    expect(github, findsOneWidget);
    expect(tester.getSize(github).shortestSide, greaterThanOrEqualTo(48));
    final context = tester.element(find.byType(ContributorsScreen));
    expect(
      find.byTooltip(MaterialLocalizations.of(context).backButtonTooltip),
      findsOneWidget,
    );
  });
}