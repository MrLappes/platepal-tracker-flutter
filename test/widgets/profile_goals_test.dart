import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/models/user_profile.dart';
import 'package:platepal_tracker/screens/settings/macro_customization_screen.dart';
import 'package:platepal_tracker/screens/settings/profile_settings_screen.dart';
import 'package:platepal_tracker/services/storage/storage_service_provider.dart';
import 'package:platepal_tracker/services/storage/user_profile_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeProfiles extends UserProfileService {
  final saved = <UserProfile>[];
  double? savedBodyFat;
  UserProfile? profile;

  @override
  Future<UserProfile?> getUserProfile(String userId) async =>
      profile ??
      UserProfile(
        id: userId,
        name: 'Tester',
        email: 'user@platepal.app',
        age: 30,
        gender: 'other',
        height: 170,
        weight: 70,
        activityLevel: 'moderately_active',
        goals: FitnessGoals(
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

  @override
  Future<List<Map<String, dynamic>>> getUserMetricsHistory(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async => [];

  @override
  Future<UserProfile> saveUserProfile(
    UserProfile profile, {
    double? bodyFat,
  }) async {
    saved.add(profile);
    savedBodyFat = bodyFat;
    return profile;
  }

  @override
  Future<void> updateUserMetrics({
    required String userId,
    double? weight,
    double? height,
    double? bodyFat,
    double? dailyCalories,
  }) async {}
}

class _SlowProfiles extends _FakeProfiles {
  final pendingProfile = Completer<UserProfile?>();

  @override
  Future<UserProfile?> getUserProfile(String userId) => pendingProfile.future;
}

class _MissingProfiles extends _FakeProfiles {
  @override
  Future<UserProfile?> getUserProfile(String userId) async => null;
}

void main() {
  Future<_FakeProfiles> pumpSettingsScreen(
    WidgetTester tester,
    Widget screen, {
    _FakeProfiles? fakeProfiles,
    Locale locale = const Locale('en'),
  }) async {
    SharedPreferences.setMockInitialValues({});
    final profiles = fakeProfiles ?? _FakeProfiles();
    final storage = StorageServiceProvider()..userProfileService = profiles;
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      ChangeNotifierProvider<StorageServiceProvider>.value(
        value: storage,
        child: MaterialApp(
          navigatorKey: navigatorKey,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(),
        ),
      ),
    );
    navigatorKey.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
    await tester.pumpAndSettle();
    return profiles;
  }

  for (final screen in [
    const ProfileSettingsScreen(),
    const MacroCustomizationScreen(),
  ]) {
    testWidgets(
      'closing $screen while loading does not update disposed state',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final profiles = _SlowProfiles();
        final storage = StorageServiceProvider()..userProfileService = profiles;
        final navigatorKey = GlobalKey<NavigatorState>();
        await tester.pumpWidget(
          ChangeNotifierProvider<StorageServiceProvider>.value(
            value: storage,
            child: MaterialApp(
              navigatorKey: navigatorKey,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const Scaffold(),
            ),
          ),
        );
        navigatorKey.currentState!.push(
          MaterialPageRoute<void>(builder: (_) => screen),
        );
        await tester.pump();
        await tester.pump();
        navigatorKey.currentState!.pop();
        await tester.pump(const Duration(milliseconds: 500));
        profiles.pendingProfile.complete(null);
        await tester.pump();

        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('discarding edited profile from back closes the screen', (
    tester,
  ) async {
    final profiles = await pumpSettingsScreen(
      tester,
      const ProfileSettingsScreen(),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tester'),
      'Tester 2',
    );
    await tester.pump();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Discard Changes'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ProfileSettingsScreen), findsNothing);
    expect(profiles.saved, isEmpty);
  });

  testWidgets('discarding macro changes from back exits without saving', (
    tester,
  ) async {
    final profiles = await pumpSettingsScreen(
      tester,
      const MacroCustomizationScreen(),
    );

    tester.widget<Slider>(find.byType(Slider).first).onChanged!(45);
    await tester.pump();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Discard Changes'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MacroCustomizationScreen), findsNothing);
    expect(profiles.saved, isEmpty);
  });

  testWidgets('moving protein cannot change pinned carbs or starve fat', (
    tester,
  ) async {
    final profiles = _FakeProfiles();
    profiles.profile = (await profiles.getUserProfile('default'))!.copyWith(
      goals: FitnessGoals(
        goal: 'maintain_weight',
        targetWeight: 70,
        targetCalories: 2000,
        targetProtein: 150,
        targetCarbs: 250,
        targetFat: 400 / 9,
        targetFiber: 30,
      ),
    );
    await pumpSettingsScreen(
      tester,
      const MacroCustomizationScreen(),
      fakeProfiles: profiles,
    );

    await tester.tap(find.byIcon(Icons.push_pin_outlined).at(1));
    await tester.pump();
    tester.widget<Slider>(find.byType(Slider).first).onChanged!(50);
    await tester.pump();

    final sliders = tester.widgetList<Slider>(find.byType(Slider)).toList();
    expect(sliders[0].value, 40);
    expect(sliders[1].value, 50);
    expect(sliders[2].value, 10);
  });

  testWidgets('macro sliders announce macro names and percentage values', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpSettingsScreen(tester, const MacroCustomizationScreen());

    final protein = tester.getSemantics(find.bySemanticsLabel('Protein'));
    expect(protein.label, contains('Protein'));
    expect(protein.value, contains('40.0%'));
    semantics.dispose();
  });

  testWidgets('fiber slider announces grams per 1000 calories', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpSettingsScreen(
      tester,
      const MacroCustomizationScreen(),
      locale: const Locale('de'),
    );

    final fiber = tester.getSemantics(find.bySemanticsLabel('Ballaststoffe'));
    expect(fiber.value, contains('15,0 g pro 1000 Kalorien'));
    semantics.dispose();
  });

  testWidgets('pin buttons have localized labels and full touch targets', (
    tester,
  ) async {
    await pumpSettingsScreen(
      tester,
      const MacroCustomizationScreen(),
      locale: const Locale('de'),
    );

    final pin = find.byTooltip('Kohlenhydrate fixieren');
    expect(pin, findsOneWidget);
    expect(tester.getSize(pin).width, greaterThanOrEqualTo(48));
    expect(tester.getSize(pin).height, greaterThanOrEqualTo(48));
    await tester.tap(pin);
    await tester.pump();
    expect(find.byTooltip('Fixierung aufheben: Kohlenhydrate'), findsOneWidget);
  });

  testWidgets('translated macro controls fit on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpSettingsScreen(
      tester,
      const MacroCustomizationScreen(),
      locale: const Locale('de'),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('changing a name keeps fractional measures and build muscle', (
    tester,
  ) async {
    final profiles = _FakeProfiles();
    final original = (await profiles.getUserProfile('default'))!;
    profiles.profile = original.copyWith(
      height: 170.6,
      weight: 70.4,
      goals: FitnessGoals(
        goal: 'build_muscle',
        targetWeight: 75.8,
        targetCalories: original.goals.targetCalories,
        targetProtein: original.goals.targetProtein,
        targetCarbs: original.goals.targetCarbs,
        targetFat: original.goals.targetFat,
        targetFiber: original.goals.targetFiber,
      ),
    );
    await pumpSettingsScreen(
      tester,
      const ProfileSettingsScreen(),
      fakeProfiles: profiles,
    );

    final values = tester
        .widgetList<TextFormField>(find.byType(TextFormField))
        .map((field) => field.controller!.text);
    expect(values, containsAll(['170.6', '70.4', '75.8']));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tester'),
      'Tester 2',
    );
    await tester.pump();
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    expect(profiles.saved, hasLength(1));
    expect(profiles.saved.single.height, 170.6);
    expect(profiles.saved.single.weight, 70.4);
    expect(profiles.saved.single.goals.targetWeight, 75.8);
    expect(profiles.saved.single.goals.goal, 'build_muscle');
  });

  testWidgets('changing weights does not replace a build muscle goal', (
    tester,
  ) async {
    final profiles = _FakeProfiles();
    final original = (await profiles.getUserProfile('default'))!;
    profiles.profile = original.copyWith(
      goals: FitnessGoals(
        goal: 'build_muscle',
        targetWeight: 75,
        targetCalories: original.goals.targetCalories,
        targetProtein: original.goals.targetProtein,
        targetCarbs: original.goals.targetCarbs,
        targetFat: original.goals.targetFat,
        targetFiber: original.goals.targetFiber,
      ),
    );
    await pumpSettingsScreen(
      tester,
      const ProfileSettingsScreen(),
      fakeProfiles: profiles,
    );

    await tester.enterText(find.byType(TextFormField).at(3), '72');
    await tester.enterText(find.byType(TextFormField).at(5), '80');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    expect(profiles.saved, hasLength(1));
    expect(profiles.saved.single.goals.goal, 'build_muscle');
    expect(profiles.saved.single.goals.targetWeight, 80);
  });

  testWidgets('new profile has a translated name hint, not a fabricated name', (
    tester,
  ) async {
    final profiles = _MissingProfiles();
    await pumpSettingsScreen(
      tester,
      const ProfileSettingsScreen(),
      fakeProfiles: profiles,
      locale: const Locale('es'),
    );

    final nameField = tester.widget<TextFormField>(
      find.byType(TextFormField).first,
    );
    final nameInput = tester.widget<TextField>(find.byType(TextField).first);
    expect(nameField.controller!.text, isEmpty);
    expect(nameInput.decoration!.hintText, 'Introduce tu nombre');
    expect(profiles.saved.single.name, isEmpty);
  });

  testWidgets('BMI categories in profile follow the selected locale', (
    tester,
  ) async {
    final profiles = _FakeProfiles();
    profiles.profile = (await profiles.getUserProfile(
      'default',
    ))!.copyWith(weight: 86);
    await pumpSettingsScreen(
      tester,
      const ProfileSettingsScreen(),
      fakeProfiles: profiles,
      locale: const Locale('de'),
    );

    expect(find.text('Übergewicht'), findsOneWidget);
    expect(find.text('Körperdaten'), findsOneWidget);
  });

  testWidgets('toggling units preserves measures and accepts decimal commas', (
    tester,
  ) async {
    final profiles = _FakeProfiles();
    final original = (await profiles.getUserProfile('default'))!;
    profiles.profile = original.copyWith(height: 170.6, weight: 70.4);
    await pumpSettingsScreen(
      tester,
      const ProfileSettingsScreen(),
      fakeProfiles: profiles,
    );

    final unitDropdown = find.byType(DropdownButtonFormField<String>).last;
    await tester.ensureVisible(unitDropdown);
    await tester.tap(unitDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Imperial (lb, ft)').last);
    await tester.pumpAndSettle();
    await tester.tap(unitDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Metric (kg, cm)').last);
    await tester.pumpAndSettle();

    final values = tester
        .widgetList<TextFormField>(find.byType(TextFormField))
        .map((field) => field.controller!.text);
    expect(values, containsAll(['170.6', '70.4']));
    await tester.enterText(find.byType(TextFormField).at(2), '170,6');
    await tester.enterText(find.byType(TextFormField).at(3), '70,4');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    expect(profiles.saved, hasLength(1));
    expect(profiles.saved.single.height, 170.6);
    expect(profiles.saved.single.weight, 70.4);
  });

  testWidgets('saving an imperial profile does not round stored measurements', (
    tester,
  ) async {
    final profiles = _FakeProfiles();
    profiles.profile = (await profiles.getUserProfile(
      'default',
    ))!.copyWith(height: 170.6, weight: 70.4, preferredUnit: 'imperial');
    await pumpSettingsScreen(
      tester,
      const ProfileSettingsScreen(),
      fakeProfiles: profiles,
    );

    await tester.enterText(find.byType(TextFormField).first, 'New name');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    expect(profiles.saved.single.height, 170.6);
    expect(profiles.saved.single.weight, 70.4);
  });

  testWidgets('body fat accepts a decimal comma', (tester) async {
    final profiles = await pumpSettingsScreen(
      tester,
      const ProfileSettingsScreen(),
    );

    await tester.enterText(find.byType(TextFormField).at(4), '22,5');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    expect(profiles.savedBodyFat, 22.5);
  });
}
