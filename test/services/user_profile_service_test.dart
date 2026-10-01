import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/models/user_profile.dart';
import 'package:platepal_tracker/services/storage/database_service.dart';
import 'package:platepal_tracker/services/storage/user_profile_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

UserProfile _profile({double weight = 70, double height = 175}) {
  final now = DateTime(2026, 1, 1);
  return UserProfile(
    id: 'u1',
    name: 'Test',
    email: 'test@example.com',
    age: 30,
    gender: 'other',
    height: height,
    weight: weight,
    activityLevel: 'moderately_active',
    goals: const FitnessGoals(
      goal: 'maintain_weight',
      targetWeight: 70,
      targetCalories: 2000,
      targetProtein: 150,
      targetCarbs: 200,
      targetFat: 67,
      targetFiber: 28,
    ),
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late UserProfileService service;

  setUp(() async {
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
    service = UserProfileService();
  });

  Future<List<Map<String, dynamic>>> history() =>
      service.getUserMetricsHistory('u1');

  test('first save records the initial measurements once', () async {
    await service.saveUserProfile(_profile());

    final rows = await history();
    expect(rows, hasLength(1));
    expect(rows.single['weight'], 70);
    expect(rows.single['height'], 175);
  });

  test('saving unchanged measurements adds no history row', () async {
    await service.saveUserProfile(_profile());
    await service.saveUserProfile(_profile());
    await service.saveUserProfile(_profile(), bodyFat: null);

    expect(await history(), hasLength(1));
  });

  test('a weight or height change adds exactly one row', () async {
    await service.saveUserProfile(_profile());
    await service.saveUserProfile(_profile(weight: 71.5));
    await service.saveUserProfile(_profile(weight: 71.5, height: 176));

    final rows = await history();
    expect(rows, hasLength(3));
    expect(rows[1]['weight'], 71.5);
    expect(rows[2]['height'], 176);
  });

  test('body fat is recorded only when it changes', () async {
    await service.saveUserProfile(_profile());
    await service.saveUserProfile(_profile(), bodyFat: 20);
    await service.saveUserProfile(_profile(), bodyFat: 20);
    await service.saveUserProfile(_profile(weight: 72), bodyFat: 20);
    await service.saveUserProfile(_profile(weight: 72), bodyFat: 20);
    await service.saveUserProfile(_profile(weight: 72), bodyFat: 19.5);

    final rows = await history();
    expect(rows.map((r) => r['body_fat']).toList(), [null, 20, 20, 19.5]);
    expect(rows.map((r) => r['weight']).toList(), [70, 70, 72, 72]);
  });
}
