import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/daily_entry.dart';
import '../models/user_profile.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Since this is a fresh SQLite implementation replacing Hive, we start at version 1.
  static const int NEW_VERSION_NUMBER = 1; 

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('trale_fitness.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: NEW_VERSION_NUMBER,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  static const String CREATE_DAILY_ENTRIES_TABLE = '''
    CREATE TABLE daily_entries (
      date TEXT PRIMARY KEY,
      weight REAL,
      height REAL,
      photo_paths TEXT,
      workout_text TEXT,
      workout_tags TEXT,
      thoughts TEXT,
      emotions TEXT,
      timestamp TEXT NOT NULL
    )
  ''';

  static const String CREATE_USER_PROFILE_TABLE = '''
    CREATE TABLE user_profile (
      id INTEGER PRIMARY KEY CHECK (id = 1),
      initial_height REAL,
      height_history TEXT,
      preferred_units TEXT DEFAULT 'metric'
    )
  ''';

  static const String CREATE_WORKOUT_TAGS_TABLE = '''
    CREATE TABLE workout_tags (
      tag TEXT PRIMARY KEY,
      color TEXT,
      use_count INTEGER DEFAULT 0
    )
  ''';

  Future<void> _createDB(Database db, int version) async {
    await db.execute(CREATE_DAILY_ENTRIES_TABLE);
    await db.execute(CREATE_USER_PROFILE_TABLE);
    await db.execute(CREATE_WORKOUT_TAGS_TABLE);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < NEW_VERSION_NUMBER) {
      // This is where migration logic would go if we were upgrading from an older SQLite version.
      // Since we are migrating from Hive, this might not be triggered for existing users 
      // unless we manually handle the migration elsewhere.
      
      /* 
      // Example migration from hypothetical previous version:
      await db.execute(CREATE_DAILY_ENTRIES_TABLE);
      await db.execute(CREATE_USER_PROFILE_TABLE);
      await db.execute(CREATE_WORKOUT_TAGS_TABLE);
      
      final oldData = await db.query('weight_entries'); 
      
      for (var row in oldData) {
        await db.insert('daily_entries', {
          'date': row['date'],
          'weight': row['weight'],
          'height': null,
          'photo_paths': '[]',
          'workout_text': null,
          'workout_tags': '[]',
          'thoughts': null,
          'emotions': '[]',
          'timestamp': row['date'], 
        });
      }
      */
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  // Insert or update daily entry
  Future<void> saveDailyEntry(DailyEntry entry) async {
    final db = await database;
    await db.insert(
      'daily_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get entry by date
  Future<DailyEntry?> getDailyEntry(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    final results = await db.query(
      'daily_entries',
      where: 'date = ?',
      whereArgs: [dateStr],
    );
    
    if (results.isEmpty) return null;
    return DailyEntry.fromMap(results.first);
  }

  // Get all entries (ordered by date descending)
  Future<List<DailyEntry>> getAllEntries() async {
    final db = await database;
    final results = await db.query(
      'daily_entries',
      orderBy: 'date DESC',
    );
    
    return results.map((map) => DailyEntry.fromMap(map)).toList();
  }

  // Delete entry
  Future<void> deleteEntry(DateTime date) async {
    // Get entry first to access photo paths
    final entry = await getDailyEntry(date);
    
    // Delete photos from disk
    if (entry != null && entry.photoPaths.isNotEmpty) {
      for (final photoPath in entry.photoPaths) {
        try {
          final file = File(photoPath);
          if (await file.exists()) {
            await file.delete();
            // Also delete thumbnail if exists
            final thumbPath = photoPath.replaceAll('.jpg', '_thumb.jpg');
            final thumbFile = File(thumbPath);
            if (await thumbFile.exists()) {
              await thumbFile.delete();
            }
          }
        } catch (e) {
          print('Error deleting photo: $e');
        }
      }
    }
    
    // Delete entry from database
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    await db.delete(
      'daily_entries',
      where: 'date = ?',
      whereArgs: [dateStr],
    );
  }

  // User Profile methods
  Future<void> saveUserProfile(UserProfile profile) async {
    final db = await database;
    await db.insert(
      'user_profile',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserProfile?> getUserProfile() async {
    final db = await database;
    final results = await db.query('user_profile', where: 'id = 1');
    
    if (results.isEmpty) return null;
    return UserProfile.fromMap(results.first);
  }

  // Workout tags methods
  Future<void> saveWorkoutTag(String tag, String color) async {
    final db = await database;
    await db.insert(
      'workout_tags',
      {'tag': tag, 'color': color, 'use_count': 1},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> incrementTagUseCount(String tag) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE workout_tags SET use_count = use_count + 1 WHERE tag = ?',
      [tag],
    );
  }

  Future<List<String>> getAllWorkoutTags() async {
    final db = await database;
    final results = await db.query(
      'workout_tags',
      orderBy: 'use_count DESC',
    );
    
    return results.map((row) => row['tag'] as String).toList();
  }


}
