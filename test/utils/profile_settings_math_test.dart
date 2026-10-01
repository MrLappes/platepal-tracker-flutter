import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/models/user_profile.dart';
import 'package:platepal_tracker/screens/settings/profile_settings_screen.dart';
import 'package:platepal_tracker/services/storage/storage_service_provider.dart';
import 'package:platepal_tracker/services/storage/user_profile_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeProfiles extends UserProfileService {
  _FakeProfiles(this.profile);

  UserProfile profile;
  final saved = <UserProfile>[];
  final savedBodyFat = <double?>[];
  int metricsUpdates = 0;

  @override
  Future<UserProfile?> getUserProfile(String userId) async => profile;

  @override
  Future<List<Map<String, dynamic>>> getUserMetricsHistory(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async => [];

  @override
  Future<UserProfile> saveUserProfile(
    UserProfile userProfile, {
    double? bodyFat,
  }) async {
    saved.add(userProfile);
    savedBodyFat.add(bodyFat);
    return userProfile;
  }

  @override
  Future<void> updateUserMetrics({
    required String userId,
    double? weight,
    double? height,
    double? bodyFat,
    double? dailyCalories,
  }) async {
    metricsUpdates++;
  }
}

UserProfile _profile({
  double protein = 100,
  double carbs = 250,
  double fat = 60,
}) {
  final now = DateTime(2026, 1, 1);
  return UserProfile(
    id: 'default',
    name: 'Tester',
    email: 'user@platepal.app',
    age: 30,
    gender: 'other',
    height: 170,
    weight: 70,
    activityLevel: 'moderately_active',
    // Default customized split: 400 / 1000 / 540 kcal of 1940.
    goals: FitnessGoals(
      goal: 'maintain_weight',
      targetWeight: 70,
      targetCalories: 2000,
      targetProtein: protein,
      targetCarbs: carbs,
      targetFat: fat,
      targetFiber: 30,
    ),
    createdAt: now,
    updatedAt: now,
  );
}

Future<_FakeProfiles> _pumpScreen(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final profiles = _FakeProfiles(_profile());
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
    MaterialPageRoute<void>(builder: (_) => const ProfileSettingsScreen()),
  );
  await tester.pumpAndSettle();
  return profiles;
}

void main() {
  testWidgets('a profile with gender "other" opens without an assertion', (
    tester,
  ) async {
    await _pumpScreen(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Other'), findsOneWidget);
  });

  testWidgets('saving keeps the custom macro split and saves once', (
    tester,
  ) async {
    final profiles = await _pumpScreen(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tester'),
      'Tester 2',
    );
    await tester.pump();
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    expect(profiles.saved, hasLength(1));
    expect(profiles.savedBodyFat.single, isNull);
    expect(profiles.metricsUpdates, 0);

    final goals = profiles.saved.single.goals;
    // Mifflin-St Jeor, other: 700 + 1062.5 - 150 - 78 = 1534.5; x1.55.
    const calories = 1534.5 * 1.55;
    expect(goals.targetCalories, closeTo(calories, 1e-6));
    expect(goals.targetProtein, closeTo(calories * 400 / 1940 / 4, 1e-6));
    expect(goals.targetCarbs, closeTo(calories * 1000 / 1940 / 4, 1e-6));
    expect(goals.targetFat, closeTo(calories * 540 / 1940 / 9, 1e-6));
    expect(goals.targetFiber, closeTo(calories / 1000 * 14, 1e-6));
    expect(profiles.saved.single.gender, 'other');
  });

  testWidgets('saving uses a split customized after the screen loaded', (
    tester,
  ) async {
    final profiles = await _pumpScreen(tester);
    // Macro customization saved 25/50/25 (by energy) in the meantime.
    profiles.profile = _profile(protein: 125, carbs: 250, fat: 500 / 9);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tester'),
      'Tester 2',
    );
    await tester.pump();
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    final goals = profiles.saved.single.goals;
    const calories = 1534.5 * 1.55;
    expect(goals.targetProtein, closeTo(calories * 0.25 / 4, 1e-6));
    expect(goals.targetCarbs, closeTo(calories * 0.50 / 4, 1e-6));
    expect(goals.targetFat, closeTo(calories * 0.25 / 9, 1e-6));
  });
}
