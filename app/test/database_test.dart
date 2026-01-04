import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trale/database/database_helper.dart';
import 'package:trale/models/daily_entry.dart';
import 'package:trale/models/user_profile.dart';

void main() {
  // Initialize FFI
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Database Tests', () {
    setUp(() async {
      // Ensure database is initialized and clear tables
      final db = await DatabaseHelper.instance.database;
      await db.delete('daily_entries');
      await db.delete('user_profile');
      await db.delete('workout_tags');
    });

    tearDown(() async {
      await DatabaseHelper.instance.close();
    });

    test('DailyEntry CRUD', () async {
      final entry = DailyEntry(
        date: DateTime(2023, 1, 1),
        weight: 70.0,
        height: 175.0,
        workoutText: 'Run',
        workoutTags: ['Cardio'],
        thoughts: 'Good run',
        emotions: ['Happy'],
      );

      await DatabaseHelper.instance.saveDailyEntry(entry);

      final retrieved = await DatabaseHelper.instance.getDailyEntry(DateTime(2023, 1, 1));
      expect(retrieved, isNotNull);
      expect(retrieved!.weight, 70.0);
      expect(retrieved.workoutText, 'Run');
      expect(retrieved.workoutTags, contains('Cardio'));
      
      // Update
      final updatedEntry = DailyEntry(
        date: DateTime(2023, 1, 1),
        weight: 69.5,
        workoutText: 'Run + Swim',
      );
      await DatabaseHelper.instance.saveDailyEntry(updatedEntry);
      
      final retrievedUpdated = await DatabaseHelper.instance.getDailyEntry(DateTime(2023, 1, 1));
      expect(retrievedUpdated!.weight, 69.5);
      expect(retrievedUpdated.workoutText, 'Run + Swim');
      
      // Delete
      await DatabaseHelper.instance.deleteEntry(DateTime(2023, 1, 1));
      final deleted = await DatabaseHelper.instance.getDailyEntry(DateTime(2023, 1, 1));
      expect(deleted, isNull);
    });

    test('UserProfile CRUD', () async {
      final profile = UserProfile(
        initialHeight: 180.0,
        preferredUnits: 'imperial',
      );
      
      await DatabaseHelper.instance.saveUserProfile(profile);
      
      final retrieved = await DatabaseHelper.instance.getUserProfile();
      expect(retrieved, isNotNull);
      expect(retrieved!.initialHeight, 180.0);
      expect(retrieved.preferredUnits, 'imperial');
    });

    test('Workout Tags', () async {
      await DatabaseHelper.instance.saveWorkoutTag('Running', '#FF0000');
      await DatabaseHelper.instance.saveWorkoutTag('Swimming', '#00FF00');
      
      var tags = await DatabaseHelper.instance.getAllWorkoutTags();
      expect(tags, containsAll(['Running', 'Swimming']));
      
      await DatabaseHelper.instance.incrementTagUseCount('Running');
      
      // Let's add another tag and not increment it.
      await DatabaseHelper.instance.saveWorkoutTag('Cycling', '#0000FF');
      
      tags = await DatabaseHelper.instance.getAllWorkoutTags();
      // Running should be first (count 2: 1 initial + 1 increment)
      
      expect(tags.first, 'Running');
    });
  });
}
