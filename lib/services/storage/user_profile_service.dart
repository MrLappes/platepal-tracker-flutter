import 'package:sqflite/sqflite.dart';
import '../../models/user_profile.dart';
import 'database_service.dart';

class UserProfileService {
  final DatabaseService _databaseService = DatabaseService.instance;

  // Get user profile
  Future<UserProfile?> getUserProfile(String userId) async {
    final db = await _databaseService.database;

    // Get the user profile data
    final List<Map<String, dynamic>> userMaps = await db.query(
      'user_profiles',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (userMaps.isEmpty) {
      return null;
    }

    // Get the fitness goals
    final List<Map<String, dynamic>> goalsMaps = await db.query(
      'fitness_goals',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: 1,
    ); // Get the dietary preferences
    final List<Map<String, dynamic>> prefMaps = await db.query(
      'dietary_preferences',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    // If there are no fitness goals, return null (essential data missing)
    if (goalsMaps.isEmpty) {
      return null;
    }

    // Construct fitness goals (always required)
    final FitnessGoals goals = FitnessGoals(
      goal: goalsMaps.first['goal'] as String,
      targetWeight: goalsMaps.first['target_weight'] as double,
      targetCalories: goalsMaps.first['target_calories'] as double,
      targetProtein: goalsMaps.first['target_protein'] as double,
      targetCarbs: goalsMaps.first['target_carbs'] as double,
      targetFat: goalsMaps.first['target_fat'] as double,
    );

    // Construct dietary preferences (optional)
    DietaryPreferences? preferences;
    if (prefMaps.isNotEmpty) {
      final int prefId = prefMaps.first['id'] as int;

      // Get allergies
      final List<Map<String, dynamic>> allergiesMaps = await db.query(
        'allergies',
        where: 'preference_id = ?',
        whereArgs: [prefId],
      );
      final List<String> allergies =
          allergiesMaps.map((map) => map['allergy'] as String).toList();

      // Get dislikes
      final List<Map<String, dynamic>> dislikesMaps = await db.query(
        'dislikes',
        where: 'preference_id = ?',
        whereArgs: [prefId],
      );
      final List<String> dislikes =
          dislikesMaps.map((map) => map['dislike'] as String).toList();

      // Get cuisine preferences
      final List<Map<String, dynamic>> cuisineMaps = await db.query(
        'cuisine_preferences',
        where: 'preference_id = ?',
        whereArgs: [prefId],
      );
      final List<String> cuisinePreferences =
          cuisineMaps.map((map) => map['cuisine'] as String).toList();

      preferences = DietaryPreferences(
        allergies: allergies,
        dislikes: dislikes,
        dietType: prefMaps.first['diet_type'] as String,
        preferOrganic: (prefMaps.first['prefer_organic'] as int) == 1,
        cuisinePreferences: cuisinePreferences,
      );
    }

    // Construct and return the full user profile
    return UserProfile(
      id: userMaps.first['id'] as String,
      name: userMaps.first['name'] as String,
      email: userMaps.first['email'] as String,
      age: userMaps.first['age'] as int,
      gender: userMaps.first['gender'] as String,
      height: userMaps.first['height'] as double,
      weight: userMaps.first['weight'] as double,
      activityLevel: userMaps.first['activity_level'] as String,
      goals: goals,
      preferences: preferences,
      preferredUnit: userMaps.first['preferred_unit'] as String,
      createdAt: DateTime.parse(userMaps.first['created_at'] as String),
      updatedAt: DateTime.parse(userMaps.first['updated_at'] as String),
    );
  }

  // Save or update user profile
  Future<UserProfile> saveUserProfile(UserProfile userProfile) async {
    final db = await _databaseService.database;

    await db.transaction((txn) async {
      // Save user profile
      await txn.insert('user_profiles', {
        'id': userProfile.id,
        'name': userProfile.name,
        'email': userProfile.email,
        'age': userProfile.age,
        'gender': userProfile.gender,
        'height': userProfile.height,
        'weight': userProfile.weight,
        'activity_level': userProfile.activityLevel,
        'preferred_unit': userProfile.preferredUnit,
        'created_at': userProfile.createdAt.toIso8601String(),
        'updated_at': userProfile.updatedAt.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      // Add to metrics history
      await txn.insert('user_metrics_history', {
        'user_id': userProfile.id,
        'weight': userProfile.weight,
        'height': userProfile.height,
        'recorded_date': DateTime.now().toIso8601String(),
      });

      // Save fitness goals
      await txn.insert('fitness_goals', {
        'user_id': userProfile.id,
        'goal': userProfile.goals.goal,
        'target_weight': userProfile.goals.targetWeight,
        'target_calories': userProfile.goals.targetCalories,
        'target_protein': userProfile.goals.targetProtein,
        'target_carbs': userProfile.goals.targetCarbs,
        'target_fat': userProfile.goals.targetFat,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Save dietary preferences (only if they exist)
      if (userProfile.preferences != null) {
        final prefsId = await txn.insert('dietary_preferences', {
          'user_id': userProfile.id,
          'diet_type': userProfile.preferences!.dietType,
          'prefer_organic': userProfile.preferences!.preferOrganic ? 1 : 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        // Save allergies
        for (final allergy in userProfile.preferences!.allergies) {
          await txn.insert('allergies', {
            'preference_id': prefsId,
            'allergy': allergy,
          });
        }

        // Save dislikes
        for (final dislike in userProfile.preferences!.dislikes) {
          await txn.insert('dislikes', {
            'preference_id': prefsId,
            'dislike': dislike,
          });
        }

        // Save cuisine preferences
        for (final cuisine in userProfile.preferences!.cuisinePreferences) {
          await txn.insert('cuisine_preferences', {
            'preference_id': prefsId,
            'cuisine': cuisine,
          });
        }
      }
    });

    return userProfile;
  }

  // Update user metrics and store history
  Future<void> updateUserMetrics({
    required String userId,
    double? weight,
    double? height,
    double? bodyFat,
    double? dailyCalories,
  }) async {
    final db = await _databaseService.database;

    // Store in history table
    await db.insert('user_metrics_history', {
      'user_id': userId,
      'weight': weight,
      'height': height,
      'body_fat': bodyFat,
      'daily_calories': dailyCalories,
      'recorded_date': DateTime.now().toIso8601String(),
    });

    // Update current user profile if needed
    final Map<String, dynamic> updates = {};

    if (weight != null) {
      updates['weight'] = weight;
    }

    if (height != null) {
      updates['height'] = height;
    }

    if (updates.isNotEmpty) {
      updates['updated_at'] = DateTime.now().toIso8601String();

      await db.update(
        'user_profiles',
        updates,
        where: 'id = ?',
        whereArgs: [userId],
      );
    }
  }

  // Get user metrics history
  Future<List<Map<String, dynamic>>> getUserMetricsHistory(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _databaseService.database;

    String whereClause = 'user_id = ?';
    List<dynamic> whereArgs = [userId];

    if (startDate != null) {
      whereClause += ' AND recorded_date >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClause += ' AND recorded_date <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    return await db.query(
      'user_metrics_history',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'recorded_date ASC',
    );
  }

  // Delete user profile and all related data
  Future<void> deleteUserProfile(String userId) async {
    final db = await _databaseService.database;

    await db.transaction((txn) async {
      // Delete user metrics history
      await txn.delete(
        'user_metrics_history',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      // Get dietary preference IDs to delete related records
      final List<Map<String, dynamic>> prefMaps = await txn.query(
        'dietary_preferences',
        columns: ['id'],
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      for (final prefMap in prefMaps) {
        final int prefId = prefMap['id'] as int;

        // Delete allergies
        await txn.delete(
          'allergies',
          where: 'preference_id = ?',
          whereArgs: [prefId],
        );

        // Delete dislikes
        await txn.delete(
          'dislikes',
          where: 'preference_id = ?',
          whereArgs: [prefId],
        );

        // Delete cuisine preferences
        await txn.delete(
          'cuisine_preferences',
          where: 'preference_id = ?',
          whereArgs: [prefId],
        );
      }

      // Delete dietary preferences
      await txn.delete(
        'dietary_preferences',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      // Delete fitness goals
      await txn.delete(
        'fitness_goals',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      // Delete meal logs
      await txn.delete('meal_logs', where: 'user_id = ?', whereArgs: [userId]);

      // Delete user profile
      await txn.delete('user_profiles', where: 'id = ?', whereArgs: [userId]);
    });
  }
}
