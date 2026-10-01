import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/components/ui/low_calorie_target_warning.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/models/user_profile.dart';
import 'package:platepal_tracker/screens/settings/macro_customization_screen.dart';
import 'package:platepal_tracker/services/storage/storage_service_provider.dart';
import 'package:platepal_tracker/services/storage/user_profile_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Profiles extends UserProfileService {
  final double targetCalories;

  _Profiles(this.targetCalories);

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
    goals: FitnessGoals(
      goal: 'lose_weight',
      targetWeight: 65,
      targetCalories: targetCalories,
      targetProtein: targetCalories * 0.3 / 4,
      targetCarbs: targetCalories * 0.4 / 4,
      targetFat: targetCalories * 0.3 / 9,
      targetFiber: 25,
    ),
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

Widget _app(Widget home, {Locale locale = const Locale('en')}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: home),
);

void main() {
  const title = 'Very low calorie target';

  testWidgets('shows a warning below 1200 kcal', (tester) async {
    for (final calories in [1199.0, 1000.0, 0.0]) {
      await tester.pumpWidget(
        _app(LowCalorieTargetWarning(calories: calories)),
      );
      expect(find.text(title), findsOneWidget, reason: '$calories');
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    }
    expect(find.textContaining('1200 kcal'), findsOneWidget);
    expect(find.textContaining('medical supervision'), findsOneWidget);
  });

  testWidgets('renders nothing at or above 1200 kcal', (tester) async {
    for (final calories in [1200.0, 1200.4, 2500.0]) {
      await tester.pumpWidget(
        _app(LowCalorieTargetWarning(calories: calories)),
      );
      expect(find.text(title), findsNothing, reason: '$calories');
      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
    }
  });

  testWidgets('is translated', (tester) async {
    await tester.pumpWidget(
      _app(
        const LowCalorieTargetWarning(calories: 900),
        locale: const Locale('de'),
      ),
    );
    expect(find.text('Sehr niedriges Kalorienziel'), findsOneWidget);

    await tester.pumpWidget(
      _app(
        const LowCalorieTargetWarning(calories: 900),
        locale: const Locale('es'),
      ),
    );
    expect(find.text('Objetivo calórico muy bajo'), findsOneWidget);
  });

  testWidgets('lays out inside an AlertDialog', (tester) async {
    await tester.pumpWidget(
      _app(
        const AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Suggested target: 1100 kcal'),
                LowCalorieTargetWarning(
                  calories: 1100,
                  padding: EdgeInsets.only(top: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text(title), findsOneWidget);
  });

  group('macro customization screen', () {
    Future<void> pumpScreen(WidgetTester tester, double calories) async {
      SharedPreferences.setMockInitialValues({});
      final storage =
          StorageServiceProvider()..userProfileService = _Profiles(calories);
      await tester.pumpWidget(
        ChangeNotifierProvider<StorageServiceProvider>.value(
          value: storage,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MacroCustomizationScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('warns about a 1000 kcal target', (tester) async {
      await pumpScreen(tester, 1000);
      expect(find.text(title), findsOneWidget);
    });

    testWidgets('does not warn about a 1200 kcal target', (tester) async {
      await pumpScreen(tester, 1200);
      expect(find.text(title), findsNothing);
    });
  });
}
