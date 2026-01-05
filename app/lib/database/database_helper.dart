import 'dart:io';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/daily_entry.dart';
import '../models/user_profile.dart';

class DatabaseHelper {

  DatabaseHelper._init();
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // Database version: increment when schema changes
  // v1: Initial SQLite schema (replaced Hive)
  // v2: Emotional check-ins (emotions -> emotional_checkins), added is_immutable
  static const int NEW_VERSION_NUMBER = 2; 

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('trale_fitness.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, filePath);

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
      emotional_checkins TEXT,
      timestamp TEXT NOT NULL,
      is_immutable INTEGER DEFAULT 0
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
    // Migration from v1 to v2: Emotional check-ins refactor
    if (oldVersion < 2 && newVersion >= 2) {
      // Add new columns
      await db.execute('ALTER TABLE daily_entries ADD COLUMN emotional_checkins TEXT');
      await db.execute('ALTER TABLE daily_entries ADD COLUMN is_immutable INTEGER DEFAULT 0');
      
      // Migrate old emotions field to new emotional_checkins format
      final List<Map<String, Object?>> entries = await db.query('daily_entries');
      for (Map<String, Object?> entry in entries) {
        final String? oldEmotions = entry['emotions'] as String?;
        if (oldEmotions != null && oldEmotions.isNotEmpty && oldEmotions != '[]') {
          // Convert old emotions array to single emotional check-in
          final List<dynamic> emotionsList = jsonDecode(oldEmotions);
          if (emotionsList.isNotEmpty) {
            final String timestamp = entry['timestamp'] as String;
            final Map<String, Object> checkIn = <String, Object>{
              'timestamp': timestamp,
              'emotions': emotionsList,
              'text': '', // Old entries didn't have text
            };
            await db.update(
              'daily_entries',
              <String, Object?>{'emotional_checkins': jsonEncode(<Map<String, Object>>[checkIn])},
              where: 'date = ?',
              whereArgs: <Object?>[entry['date']],
            );
          }
        }
      }
      
      // Note: We keep the emotions column for now to avoid data loss
      // It can be dropped in a future version after migration is confirmed
    }
  }

  Future<void> close() async {
    final Database? db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  // Insert or update daily entry
  Future<void> saveDailyEntry(DailyEntry entry) async {
    final Database db = await database;
    await db.insert(
      'daily_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get entry by date
  Future<DailyEntry?> getDailyEntry(DateTime date) async {
    final Database db = await database;
    final String dateStr = date.toIso8601String().split('T')[0];
    final List<Map<String, Object?>> results = await db.query(
      'daily_entries',
      where: 'date = ?',
      whereArgs: <Object?>[dateStr],
    );
    
    if (results.isEmpty) return null;
    return DailyEntry.fromMap(results.first);
  }

  // Get all entries (ordered by date descending)
  Future<List<DailyEntry>> getAllEntries() async {
    final Database db = await database;
    final List<Map<String, Object?>> results = await db.query(
      'daily_entries',
      orderBy: 'date DESC',
    );
    
    return results.map((Map<String, Object?> map) => DailyEntry.fromMap(map)).toList();
  }

  // Delete entry
  Future<void> deleteEntry(DateTime date) async {
    // Get entry first to access photo paths
    final DailyEntry? entry = await getDailyEntry(date);
    
    // Delete photos from disk
    if (entry != null && entry.photoPaths.isNotEmpty) {
      for (final String photoPath in entry.photoPaths) {
        try {
          final File file = File(photoPath);
          if (await file.exists()) {
            await file.delete();
            // Also delete thumbnail if exists
            final String thumbPath = photoPath.replaceAll('.jpg', '_thumb.jpg');
            final File thumbFile = File(thumbPath);
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
    final Database db = await database;
    final String dateStr = date.toIso8601String().split('T')[0];
    await db.delete(
      'daily_entries',
      where: 'date = ?',
      whereArgs: <Object?>[dateStr],
    );
  }

  // User Profile methods
  Future<void> saveUserProfile(UserProfile profile) async {
    final Database db = await database;
    await db.insert(
      'user_profile',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserProfile?> getUserProfile() async {
    final Database db = await database;
    final List<Map<String, Object?>> results = await db.query('user_profile', where: 'id = 1');
    
    if (results.isEmpty) return null;
    return UserProfile.fromMap(results.first);
  }

  // Workout tags methods
  Future<void> saveWorkoutTag(String tag, String color) async {
    final Database db = await database;
    await db.insert(
      'workout_tags',
      <String, Object?>{'tag': tag, 'color': color, 'use_count': 1},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> incrementTagUseCount(String tag) async {
    final Database db = await database;
    await db.rawUpdate(
      'UPDATE workout_tags SET use_count = use_count + 1 WHERE tag = ?',
      <Object?>[tag],
    );
  }

  Future<List<String>> getAllWorkoutTags() async {
    final Database db = await database;
    final List<Map<String, Object?>> results = await db.query(
      'workout_tags',
      orderBy: 'use_count DESC',
    );
    
    return results.map((Map<String, Object?> row) => row['tag'] as String).toList();
  }


}
