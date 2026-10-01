import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/models/user_profile.dart';
import 'package:platepal_tracker/screens/settings/profile_settings_screen.dart';
import 'package:platepal_tracker/services/storage/storage_service_provider.dart';
import 'package:platepal_tracker/services/storage/user_profile_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Profiles extends UserProfileService {
  _Profiles({
    this.weight = 70,
    this.height = 170,
    this.age = 30,
    this.gender = 'other',
    this.activityLevel = 'moderately_active',
    this.goal = 'maintain_weight',
    this.targetWeight = 70,
  });

  final double weight;
  final double height;
  final int age;
  final String gender;
  final String activityLevel;
  final String goal;
  final double targetWeight;
  final saved = <UserProfile>[];

  @override
  Future<UserProfile?> getUserProfile(String userId) async => UserProfile(
    id: userId,
    name: 'Tester',
    email: 'user@platepal.app',
    age: age,
    gender: gender,
    height: height,
    weight: weight,
    activityLevel: activityLevel,
    goals: FitnessGoals(
      goal: goal,
      targetWeight: targetWeight,
      targetCalories: 2000,
      targetProtein: 140,
      targetCarbs: 275,
      targetFat: 75,
      targetFiber: 25,
    ),
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  @override
  Future<UserProfile> saveUserProfile(
    UserProfile userProfile, {
    double? bodyFat,
  }) async {
    saved.add(userProfile);
    return userProfile;
  }

  @override
  Future<List<Map<String, dynamic>>> getUserMetricsHistory(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async => [];
}

void main() {
  Future<void> pumpProfile(
    WidgetTester tester,
    String language, {
    double weight = 70,
  }) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    final storage = StorageServiceProvider()
      ..userProfileService = _Profiles(weight: weight);
    await tester.pumpWidget(
      ChangeNotifierProvider<StorageServiceProvider>.value(
        value: storage,
        child: MaterialApp(
          locale: Locale(language),
          theme: ThemeData.dark(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder:
              (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1)),
                child: child!,
              ),
          home: const ProfileSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  const labels = {
    'en': (
      'Physical Stats',
      'Body Fat (%)',
      'Activity Level',
      'Moderately Active',
      'Gender',
      'Other',
      'Fitness Goal',
      'Maintain Weight',
      'Target Weight (kg)',
      'Height (cm)',
      'Weight (kg)',
      'Optional',
    ),
    'de': (
      'Körperdaten',
      'Körperfett (%)',
      'Aktivitätslevel',
      'Mäßig aktiv',
      'Geschlecht',
      'Andere',
      'Fitnessziel',
      'Gewicht halten',
      'Zielgewicht (kg)',
      'Größe (cm)',
      'Gewicht (kg)',
      'Optional',
    ),
    'es': (
      'Datos físicos',
      'Grasa Corporal (%)',
      'Nivel de Actividad',
      'Moderadamente Activo',
      'Género',
      'Otro',
      'Objetivo de Fitness',
      'Mantener Peso',
      'Peso Objetivo (kg)',
      'Altura (cm)',
      'Peso (kg)',
      'Opcional',
    ),
  };

  for (final (language, weightLabel, expectedWeight, expectedBmi) in [
    ('de', 'Gewicht (kg)', '70,5', '24,4'),
    ('en', 'Weight (kg)', '70.5', '24.4'),
  ]) {
    testWidgets('$language profile decimals follow the selected locale', (
      tester,
    ) async {
      await pumpProfile(tester, language, weight: 70.5);

      final weightField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == weightLabel,
      );
      expect(
        tester.widget<TextField>(weightField).controller!.text,
        expectedWeight,
      );
      expect(find.text(expectedBmi), findsOneWidget);
    });
  }

  for (final entry in labels.entries) {
    testWidgets(
      '${entry.key} empty body fat keeps its optional label visible',
      (tester) async {
        await pumpProfile(tester, entry.key);
        await tester.ensureVisible(find.text(entry.value.$1));
        await tester.pumpAndSettle();

        final bodyFatField = find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              widget.decoration?.labelText == entry.value.$2,
        );
        expect(bodyFatField, findsOneWidget);
        final bodyFatInput = tester.widget<TextField>(bodyFatField);
        expect(bodyFatInput.controller!.text, isEmpty);
        expect(bodyFatInput.decoration!.helperText, entry.value.$12);
        expect(
          bodyFatInput.decoration!.floatingLabelBehavior,
          FloatingLabelBehavior.always,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('${entry.key} selected activity fits at 360dp', (tester) async {
      await pumpProfile(tester, entry.key);
      final activityField = find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButtonFormField<String> &&
            widget.decoration.labelText == entry.value.$3,
      );
      await tester.ensureVisible(activityField);
      await tester.pumpAndSettle();

      final selectedText = find.descendant(
        of: activityField,
        matching: find.text(entry.value.$4),
      );
      expect(selectedText, findsOneWidget);
      final paragraph = tester.renderObject<RenderParagraph>(selectedText);
      expect(paragraph.didExceedMaxLines, isFalse);
      final textBounds = tester.getRect(selectedText);
      final fieldBounds = tester.getRect(activityField);
      expect(textBounds.left, greaterThanOrEqualTo(fieldBounds.left));
      expect(textBounds.right, lessThanOrEqualTo(fieldBounds.right));
      expect(textBounds.bottom, lessThanOrEqualTo(fieldBounds.bottom));
      expect(tester.takeException(), isNull);
    });

    testWidgets('${entry.key} remaining form labels and choices fit at 360dp', (
      tester,
    ) async {
      await pumpProfile(tester, entry.key);

      for (final (label, selected) in [
        (entry.value.$5, entry.value.$6),
        (entry.value.$7, entry.value.$8),
      ]) {
        final dropdown = find.byWidgetPredicate(
          (widget) =>
              widget is DropdownButtonFormField<String> &&
              widget.decoration.labelText == label,
        );
        await tester.ensureVisible(dropdown);
        await tester.pumpAndSettle();
        final selectedText = find.descendant(
          of: dropdown,
          matching: find.text(selected),
        );
        expect(selectedText, findsOneWidget);
        final paragraph = tester.renderObject<RenderParagraph>(selectedText);
        expect(paragraph.didExceedMaxLines, isFalse);
        expect(
          tester.getRect(selectedText).right,
          lessThanOrEqualTo(tester.getRect(dropdown).right),
        );
      }

      for (final label in [
        entry.value.$2,
        entry.value.$9,
        entry.value.$10,
        entry.value.$11,
      ]) {
        final input = find.byWidgetPredicate(
          (widget) =>
              widget is TextField && widget.decoration?.labelText == label,
        );
        await tester.ensureVisible(input);
        await tester.pumpAndSettle();
        final renderedLabel = find.descendant(
          of: input,
          matching: find.text(label),
        );
        expect(renderedLabel, findsOneWidget);
        final paragraph = tester.renderObject<RenderParagraph>(renderedLabel);
        expect(
          paragraph.didExceedMaxLines,
          isFalse,
          reason:
              '$label is clipped: text width ${paragraph.size.width}, '
              'intrinsic ${paragraph.getMaxIntrinsicWidth(double.infinity)}, '
              'field width ${tester.getSize(input).width}',
        );
        expect(
          tester.getRect(renderedLabel).right,
          lessThanOrEqualTo(tester.getRect(input).right),
        );
      }
      expect(tester.takeException(), isNull);
    });
  }

  group('calorie target', () {
    const warningTitle = 'Very low calorie target';
    const invalidTargetMessage = 'check your weight, height and age';

    Finder field(String label) => find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.labelText == label,
    );

    Finder warning() => find.text(warningTitle, skipOffstage: false);

    Future<void> enter(WidgetTester tester, String label, String text) async {
      await tester.ensureVisible(field(label));
      await tester.enterText(field(label), text);
      await tester.pumpAndSettle();
    }

    // Pushed on top of a home route so the screen can pop after saving.
    Future<void> pumpPushed(WidgetTester tester, _Profiles profiles) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});

      final navigatorKey = GlobalKey<NavigatorState>();
      final storage = StorageServiceProvider()..userProfileService = profiles;
      await tester.pumpWidget(
        ChangeNotifierProvider<StorageServiceProvider>.value(
          value: storage,
          child: MaterialApp(
            navigatorKey: navigatorKey,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: Text('home')),
          ),
        ),
      );
      navigatorKey.currentState!.push(
        MaterialPageRoute<void>(builder: (_) => const ProfileSettingsScreen()),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    // Female, 45 kg, 150 cm, sedentary: 1291.8 kcal at 30, 1111.8 kcal at 60.
    _Profiles lowProfile({int age = 30}) => _Profiles(
      weight: 45,
      height: 150,
      age: age,
      gender: 'female',
      activityLevel: 'sedentary',
      targetWeight: 45,
    );

    testWidgets('warns only while the entered values give < 1200 kcal', (
      tester,
    ) async {
      await pumpPushed(tester, lowProfile());
      expect(warning(), findsNothing);

      await enter(tester, 'Age', '60');
      expect(warning(), findsOneWidget);

      await enter(tester, 'Age', '30');
      expect(warning(), findsNothing);
    });

    testWidgets('ignores partially typed values in the live stats', (
      tester,
    ) async {
      await pumpPushed(tester, _Profiles());
      expect(find.text('24.2', skipOffstage: false), findsOneWidget);

      await enter(tester, 'Height (cm)', '1');
      await enter(tester, 'Weight (kg)', '7');
      await enter(tester, 'Age', '1');
      expect(find.text('24.2', skipOffstage: false), findsOneWidget);
      expect(warning(), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('saves a positive target below 1200 kcal unchanged', (
      tester,
    ) async {
      final profiles = lowProfile(age: 60);
      await pumpPushed(tester, profiles);
      expect(warning(), findsOneWidget);

      await enter(tester, 'Name', 'Tester 2');
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      final goals = profiles.saved.single.goals;
      expect(goals.targetCalories, closeTo(1111.8, 1e-9));
      expect(goals.targetProtein, greaterThan(0));
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('does not save a 0 kcal target and explains why', (
      tester,
    ) async {
      final profiles = _Profiles(
        weight: 30,
        height: 100,
        age: 120,
        gender: 'female',
        activityLevel: 'sedentary',
        goal: 'lose_weight',
        targetWeight: 30,
      );
      await pumpPushed(tester, profiles);

      await enter(tester, 'Name', 'Tester 2');
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      expect(profiles.saved, isEmpty);
      expect(find.textContaining(invalidTargetMessage), findsOneWidget);
      expect(find.byType(ProfileSettingsScreen), findsOneWidget);
    });
  });
}
