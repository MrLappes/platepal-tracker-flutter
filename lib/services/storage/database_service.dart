import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/dish.dart';
import '../../models/user_profile.dart';
import '../../models/nutrition_analysis.dart';
import '../../models/supplement.dart';

class DatabaseService {
  static const String _databaseName = 'platepal.db';
  static const int _databaseVersion = 2;

  // Private constructor for singleton pattern
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // User profile table
    await db.execute('''
      CREATE TABLE user_profiles (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        height REAL NOT NULL,
        weight REAL NOT NULL,
        activity_level TEXT NOT NULL,
        preferred_unit TEXT DEFAULT 'metric',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Historical user metrics table
    await db.execute('''
      CREATE TABLE user_metrics_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        weight REAL,
        height REAL,
        body_fat REAL,
        daily_calories REAL,
        recorded_date TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES user_profiles (id)
      )
    ''');

    // Fitness goals table
    await db.execute('''
      CREATE TABLE fitness_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        goal TEXT NOT NULL,
        target_weight REAL NOT NULL,
        target_calories REAL NOT NULL,
        target_protein REAL NOT NULL,
        target_carbs REAL NOT NULL,
        target_fat REAL NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES user_profiles (id)
      )
    ''');

    // Dietary preferences table
    await db.execute('''
      CREATE TABLE dietary_preferences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        diet_type TEXT NOT NULL,
        prefer_organic INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES user_profiles (id)
      )
    ''');

    // Allergies table
    await db.execute('''
      CREATE TABLE allergies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        preference_id INTEGER NOT NULL,
        allergy TEXT NOT NULL,
        FOREIGN KEY (preference_id) REFERENCES dietary_preferences (id) ON DELETE CASCADE
      )
    ''');

    // Dislikes table
    await db.execute('''
      CREATE TABLE dislikes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        preference_id INTEGER NOT NULL,
        dislike TEXT NOT NULL,
        FOREIGN KEY (preference_id) REFERENCES dietary_preferences (id) ON DELETE CASCADE
      )
    ''');

    // Cuisine preferences table
    await db.execute('''
      CREATE TABLE cuisine_preferences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        preference_id INTEGER NOT NULL,
        cuisine TEXT NOT NULL,
        FOREIGN KEY (preference_id) REFERENCES dietary_preferences (id) ON DELETE CASCADE
      )
    ''');

    // Dishes table
    await db.execute('''
      CREATE TABLE dishes (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        image_url TEXT,
        category TEXT,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Ingredients table
    await db.execute('''
      CREATE TABLE ingredients (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        barcode TEXT
      )
    ''');

    // Dish ingredients (many-to-many relationship)
    await db.execute('''
      CREATE TABLE dish_ingredients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dish_id TEXT NOT NULL,
        ingredient_id TEXT NOT NULL,
        amount REAL NOT NULL,
        unit TEXT NOT NULL,
        FOREIGN KEY (dish_id) REFERENCES dishes (id) ON DELETE CASCADE,
        FOREIGN KEY (ingredient_id) REFERENCES ingredients (id)
      )
    ''');

    // Nutrition info table for dishes
    await db.execute('''
      CREATE TABLE dish_nutrition (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dish_id TEXT UNIQUE NOT NULL,
        calories REAL NOT NULL,
        protein REAL NOT NULL,
        carbs REAL NOT NULL,
        fat REAL NOT NULL,
        fiber REAL NOT NULL DEFAULT 0,
        FOREIGN KEY (dish_id) REFERENCES dishes (id) ON DELETE CASCADE
      )
    ''');

    // Nutrition info table for ingredients
    await db.execute('''
      CREATE TABLE ingredient_nutrition (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ingredient_id TEXT UNIQUE NOT NULL,
        calories REAL NOT NULL,
        protein REAL NOT NULL,
        carbs REAL NOT NULL,
        fat REAL NOT NULL,
        fiber REAL NOT NULL DEFAULT 0,
        FOREIGN KEY (ingredient_id) REFERENCES ingredients (id) ON DELETE CASCADE
      )
    ''');

    // Meal logs table
    await db.execute('''
      CREATE TABLE meal_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        dish_id TEXT NOT NULL,
        serving_size REAL NOT NULL DEFAULT 1,
        meal_type TEXT NOT NULL,
        logged_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES user_profiles (id),
        FOREIGN KEY (dish_id) REFERENCES dishes (id)
      )
    ''');

    // Dish logs table for calendar tracking
    await db.execute('''
      CREATE TABLE dish_logs (
        id TEXT PRIMARY KEY,
        dish_id TEXT NOT NULL,
        logged_at TEXT NOT NULL,
        meal_type TEXT NOT NULL,
        serving_size REAL NOT NULL,
        calories REAL NOT NULL,
        protein REAL NOT NULL,
        carbs REAL NOT NULL,
        fat REAL NOT NULL,
        fiber REAL NOT NULL DEFAULT 0,
        FOREIGN KEY (dish_id) REFERENCES dishes (id)
      )
    ''');

    // Create indexes for better query performance
    await db.execute(
      'CREATE INDEX idx_user_metrics_user_id ON user_metrics_history (user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_dish_ingredients_dish_id ON dish_ingredients (dish_id)',
    );
    await db.execute(
      'CREATE INDEX idx_meal_logs_user_id ON meal_logs (user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_meal_logs_logged_at ON meal_logs (logged_at)',
    );
    await db.execute(
      'CREATE INDEX idx_dish_logs_logged_at ON dish_logs (logged_at)',
    );
    await db.execute(
      'CREATE INDEX idx_dish_logs_dish_id ON dish_logs (dish_id)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < 2) {
      // Add dish_logs table
      await db.execute('''
        CREATE TABLE dish_logs (
          id TEXT PRIMARY KEY,
          dish_id TEXT NOT NULL,
          logged_at TEXT NOT NULL,
          meal_type TEXT NOT NULL,
          serving_size REAL NOT NULL,
          calories REAL NOT NULL,
          protein REAL NOT NULL,
          carbs REAL NOT NULL,
          fat REAL NOT NULL,
          fiber REAL NOT NULL DEFAULT 0,
          FOREIGN KEY (dish_id) REFERENCES dishes (id)
        )
      ''');

      // Add indexes for dish_logs
      await db.execute(
        'CREATE INDEX idx_dish_logs_logged_at ON dish_logs (logged_at)',
      );
      await db.execute(
        'CREATE INDEX idx_dish_logs_dish_id ON dish_logs (dish_id)',
      );
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  /// Completely resets the database by deleting it and recreating it
  Future<void> resetDatabase() async {
    try {
      // Close the current database connection
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      // Get database path and delete the database file
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, _databaseName);

      // Delete the database file
      await deleteDatabase(path);

      // Reinitialize the database
      _database = await _initDatabase();
    } catch (e) {
      throw Exception('Failed to reset database: $e');
    }
  }

  /// Clears all data from all tables but keeps the structure
  Future<void> clearAllData() async {
    try {
      final db = await database;

      // Disable foreign key constraints temporarily
      await db.execute('PRAGMA foreign_keys = OFF');

      // Get all table names
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      );

      // Clear all tables
      for (final table in tables) {
        final tableName = table['name'] as String;
        await db.delete(tableName);
      }

      // Re-enable foreign key constraints
      await db.execute('PRAGMA foreign_keys = ON');
    } catch (e) {
      throw Exception('Failed to clear database data: $e');
    }
  }
}
