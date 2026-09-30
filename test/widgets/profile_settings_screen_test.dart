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
  @override
  Future<UserProfile?> getUserProfile(String userId) async => UserProfile(
    id: userId,
    name: 'Tester',
    email: 'user@platepal.app',
    age: 30,
    gender: 'other',
    height: 170,
    weight: 70,
    activityLevel: 'moderately_active',
    goals: const FitnessGoals(
      goal: 'maintain_weight',
      targetWeight: 70,
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
  Future<List<Map<String, dynamic>>> getUserMetricsHistory(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async => [];
}

void main() {
  Future<void> pumpProfile(WidgetTester tester, String language) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    final storage = StorageServiceProvider()..userProfileService = _Profiles();
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
}
