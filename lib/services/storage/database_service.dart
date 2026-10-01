import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Owns the app's SQLite database.
///
/// Foreign-key enforcement is intentionally left OFF (SQLite default): the
/// declared cascades are not relied on, child rows are cleaned up explicitly,
/// and `dish_logs` is a self-contained ledger that must outlive its dish.
class DatabaseService {
  static const String _databaseName = 'platepal.db';
  static const int _databaseVersion = 5;

  // Private constructor for singleton pattern
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  static Database? _database;
  static DatabaseFactory? _testFactory;
  static String? _testPath;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Makes [database] open [path] through [factory] (e.g. sqflite ffi).
  @visibleForTesting
  static Future<void> useFactoryForTesting(
    DatabaseFactory factory, {
    String path = inMemoryDatabasePath,
  }) async {
    await _database?.close();
    _database = null;
    _testFactory = factory;
    _testPath = path;
  }

  Future<Database> _initDatabase() async {
    final options = OpenDatabaseOptions(
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    final testFactory = _testFactory;
    if (testFactory != null) {
      return testFactory.openDatabase(_testPath!, options: options);
    }

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);
    return databaseFactory.openDatabase(path, options: options);
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
    '''); // Fitness goals table
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
        target_fiber REAL NOT NULL DEFAULT 25.0,
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
        updated_at TEXT NOT NULL,
        servings REAL NOT NULL DEFAULT 1
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

    // Canonical meal-log ledger (meal_logs above is legacy, kept for rollback)
    await db.execute(_createDishLogsV4Sql('dish_logs'));

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

    if (oldVersion < 3) {
      // Add target_fiber column to fitness_goals table
      await db.execute('''
        ALTER TABLE fitness_goals 
        ADD COLUMN target_fiber REAL NOT NULL DEFAULT 25.0
      ''');
    }

    if (oldVersion < 4) {
      await _migrateToV4(db);
    }

    if (oldVersion < 5) {
      // Recipe yield; existing dishes keep their nutrition as one serving.
      await db.execute(
        'ALTER TABLE dishes ADD COLUMN servings REAL NOT NULL DEFAULT 1',
      );
    }
  }

  /// v4 dish_logs: name/notes snapshot and no FK to dishes, so a log keeps
  /// its values after the dish is edited or deleted.
  static String _createDishLogsV4Sql(String table) => '''
      CREATE TABLE $table (
        id TEXT PRIMARY KEY,
        dish_id TEXT NOT NULL,
        dish_name TEXT,
        logged_at TEXT NOT NULL,
        meal_type TEXT NOT NULL,
        serving_size REAL NOT NULL,
        calories REAL NOT NULL,
        protein REAL NOT NULL,
        carbs REAL NOT NULL,
        fat REAL NOT NULL,
        fiber REAL NOT NULL DEFAULT 0,
        notes TEXT
      )
    ''';

  Future<void> _migrateToV4(Database db) async {
    // 1. Rebuild dish_logs without the FK and with the snapshot columns.
    await db.execute(_createDishLogsV4Sql('dish_logs_v4'));
    await db.execute('''
      INSERT INTO dish_logs_v4 (id, dish_id, dish_name, logged_at, meal_type,
        serving_size, calories, protein, carbs, fat, fiber, notes)
      SELECT dl.id, dl.dish_id, d.name, dl.logged_at, dl.meal_type,
        dl.serving_size, dl.calories, dl.protein, dl.carbs, dl.fat, dl.fiber,
        NULL
      FROM dish_logs dl LEFT JOIN dishes d ON d.id = dl.dish_id
    ''');
    await db.execute('DROP TABLE dish_logs');
    await db.execute('ALTER TABLE dish_logs_v4 RENAME TO dish_logs');
    await db.execute(
      'CREATE INDEX idx_dish_logs_logged_at ON dish_logs (logged_at)',
    );
    await db.execute(
      'CREATE INDEX idx_dish_logs_dish_id ON dish_logs (dish_id)',
    );

    // 2. Copy legacy meal_logs into the ledger. Import wrote each entry to
    // both tables, so rows already present in dish_logs are skipped. Rows
    // whose dish is gone are skipped too: without a dish there is no
    // snapshot, and they remain in meal_logs.
    await db.execute('''
      INSERT INTO dish_logs (id, dish_id, dish_name, logged_at, meal_type,
        serving_size, calories, protein, carbs, fat, fiber, notes)
      SELECT 'meal_log_' || ml.id, ml.dish_id, d.name, ml.logged_at,
        ml.meal_type, ml.serving_size,
        COALESCE(n.calories, 0) * ml.serving_size,
        COALESCE(n.protein, 0) * ml.serving_size,
        COALESCE(n.carbs, 0) * ml.serving_size,
        COALESCE(n.fat, 0) * ml.serving_size,
        COALESCE(n.fiber, 0) * ml.serving_size,
        NULL
      FROM meal_logs ml
      JOIN dishes d ON d.id = ml.dish_id
      LEFT JOIN dish_nutrition n ON n.dish_id = ml.dish_id
      WHERE NOT EXISTS (
        SELECT 1 FROM dish_logs dl
        WHERE dl.dish_id = ml.dish_id
          AND dl.logged_at = ml.logged_at
          AND dl.meal_type = ml.meal_type
      )
    ''');

    // 3. Imported rows were stored as UTC ('...Z'); the day-range queries
    // compare against local ISO strings, so store every row as local time.
    final utcRows = await db.rawQuery(
      "SELECT id, logged_at FROM dish_logs WHERE logged_at LIKE '%Z'",
    );
    final batch = db.batch();
    for (final row in utcRows) {
      final parsed = DateTime.tryParse(row['logged_at'] as String);
      if (parsed == null) continue;
      batch.update(
        'dish_logs',
        {'logged_at': parsed.toLocal().toIso8601String()},
        where: 'id = ?',
        whereArgs: [row['id']],
      );
    }
    await batch.commit(noResult: true);

    // 4. Remove ingredient links duplicated by the old saveDish (F4-01).
    await db.execute('''
      DELETE FROM dish_ingredients
      WHERE id NOT IN (
        SELECT MIN(id) FROM dish_ingredients
        GROUP BY dish_id, ingredient_id, amount, unit
      )
    ''');
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

      // Stay on the default (OFF); see class doc.
      await db.execute('PRAGMA foreign_keys = OFF');
    } catch (e) {
      throw Exception('Failed to clear database data: $e');
    }
  }
}
