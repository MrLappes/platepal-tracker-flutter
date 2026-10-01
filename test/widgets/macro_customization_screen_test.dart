import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/models/user_profile.dart';
import 'package:platepal_tracker/screens/settings/macro_customization_screen.dart';
import 'package:platepal_tracker/services/storage/storage_service_provider.dart';
import 'package:platepal_tracker/services/storage/user_profile_service.dart';
import 'package:platepal_tracker/themes/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Profiles extends UserProfileService {
  @override
  Future<UserProfile?> getUserProfile(String userId) async => UserProfile(
    id: userId,
    name: 'Test',
    email: 'test@example.com',
    age: 30,
    gender: 'other',
    height: 170,
    weight: 70,
    activityLevel: 'moderately_active',
    goals: const FitnessGoals(
      goal: 'maintain_weight',
      targetWeight: 70,
      targetCalories: 2000,
      targetProtein: 200,
      targetCarbs: 150,
      targetFat: 600 / 9,
      targetFiber: 30,
    ),
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

void main() {
  testWidgets('trailing pin announces its state and locks the slider', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    SharedPreferences.setMockInitialValues({});
    final storage = StorageServiceProvider()..userProfileService = _Profiles();
    await tester.pumpWidget(
      ChangeNotifierProvider<StorageServiceProvider>.value(
        value: storage,
        child: MaterialApp(
          theme: AppThemes.dark.materialTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MacroCustomizationScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final pin = find.byTooltip('Pin Protein');
    expect(pin, findsOneWidget);
    expect(tester.getSize(pin).width, greaterThanOrEqualTo(48));
    expect(tester.getSize(pin).height, greaterThanOrEqualTo(48));
    expect(
      tester.getCenter(pin).dx,
      greaterThan(tester.getCenter(find.textContaining('40.0%')).dx),
    );
    expect(
      tester.getSemantics(pin).flagsCollection.isToggled,
      Tristate.isFalse,
    );

    await tester.tap(pin);
    await tester.pump();
    final unpin = find.byTooltip('Unpin Protein');
    expect(unpin, findsOneWidget);
    expect(find.byIcon(Icons.push_pin), findsOneWidget);
    expect(
      tester.getSemantics(unpin).flagsCollection.isToggled,
      Tristate.isTrue,
    );
    expect(tester.widget<Slider>(find.byType(Slider).first).onChanged, isNull);

    await tester.tap(unpin);
    await tester.pump();
    expect(find.byTooltip('Pin Protein'), findsOneWidget);
    expect(
      tester.getSemantics(pin).flagsCollection.isToggled,
      Tristate.isFalse,
    );
    expect(
      tester.widget<Slider>(find.byType(Slider).first).onChanged,
      isNotNull,
    );
    semantics.dispose();
  });

  testWidgets('German macro ratios use commas in text and slider semantics', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageServiceProvider()..userProfileService = _Profiles();
    await tester.pumpWidget(
      ChangeNotifierProvider<StorageServiceProvider>.value(
        value: storage,
        child: MaterialApp(
          locale: const Locale('de'),
          theme: AppThemes.dark.materialTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MacroCustomizationScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gesamt: 100,0 %'), findsOneWidget);
    expect(find.textContaining('40,0%'), findsOneWidget);
    expect(
      tester
          .widget<Slider>(find.byType(Slider).first)
          .semanticFormatterCallback!(26.1),
      '26,1%',
    );
  });
}
