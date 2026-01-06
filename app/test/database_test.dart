import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trale/database/database_helper.dart';
import 'package:trale/models/daily_entry.dart';
import 'package:trale/models/emotional_checkin.dart';
import 'package:trale/models/user_profile.dart';

void main() {
  // Initialize FFI
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Database Tests', () {
    setUp(() async {
      // Ensure database is initialized and clear tables
      final Database db = await DatabaseHelper.instance.database;
      await db.delete('daily_entries');
      await db.delete('user_profile');
      await db.delete('workout_tags');
    });

    tearDown(() async {
      await DatabaseHelper.instance.close();
    });

    test('DailyEntry CRUD', () async {
      final EmotionalCheckIn checkIn1 = EmotionalCheckIn(
        timestamp: DateTime(2023, 1, 1, 10, 30),
        emotions: <String>['😊', '💪'],
        text: 'Feeling great after workout!',
      );
      
      final EmotionalCheckIn checkIn2 = EmotionalCheckIn(
        timestamp: DateTime(2023, 1, 1, 14, 15),
        emotions: <String>['😨'],
        text: 'A bit anxious about the meeting',
      );
      
      final DailyEntry entry = DailyEntry(
        date: DateTime(2023, 1, 1),
        weight: 70.0,
        height: 175.0,
        workoutText: 'Run',
        workoutTags: <String>['Cardio'],
        thoughts: 'Good run',
        emotionalCheckIns: <EmotionalCheckIn>[checkIn1, checkIn2],
      );

      await DatabaseHelper.instance.saveDailyEntry(entry);

      final DailyEntry? retrieved = await DatabaseHelper.instance.getDailyEntry(DateTime(2023, 1, 1));
      expect(retrieved, isNotNull);
      expect(retrieved!.weight, 70.0);
      expect(retrieved.workoutText, 'Run');
      expect(retrieved.workoutTags, contains('Cardio'));
      expect(retrieved.emotionalCheckIns.length, 2);
      expect(retrieved.emotionalCheckIns[0].emotions, contains('😊'));
      expect(retrieved.emotionalCheckIns[1].text, 'A bit anxious about the meeting');
      
      // Update
      final DailyEntry updatedEntry = DailyEntry(
        date: DateTime(2023, 1, 1),
        weight: 69.5,
        workoutText: 'Run + Swim',
        emotionalCheckIns: <EmotionalCheckIn>[checkIn1, checkIn2],
      );
      await DatabaseHelper.instance.saveDailyEntry(updatedEntry);
      
      final DailyEntry? retrievedUpdated = await DatabaseHelper.instance.getDailyEntry(DateTime(2023, 1, 1));
      expect(retrievedUpdated!.weight, 69.5);
      expect(retrievedUpdated.workoutText, 'Run + Swim');
      // Verify omitted fields behavior
      expect(retrievedUpdated.height, isNull); // height was not in update
      expect(retrievedUpdated.workoutTags, isEmpty); // tags were not in update
      expect(retrievedUpdated.thoughts, isNull); // thoughts were not in update
      expect(retrievedUpdated.emotionalCheckIns.length, 2); // checkIns were included
      
      // Delete
      await DatabaseHelper.instance.deleteEntry(DateTime(2023, 1, 1));
      final DailyEntry? deleted = await DatabaseHelper.instance.getDailyEntry(DateTime(2023, 1, 1));
      expect(deleted, isNull);
    });

    test('UserProfile CRUD', () async {
      final UserProfile profile = UserProfile(
        initialHeight: 180.0,
        preferredUnits: UnitSystem.imperial,
      );
      
      await DatabaseHelper.instance.saveUserProfile(profile);
      
      final UserProfile? retrieved = await DatabaseHelper.instance.getUserProfile();
      expect(retrieved, isNotNull);
      expect(retrieved!.initialHeight, 180.0);
      expect(retrieved.preferredUnits, UnitSystem.imperial);
    });

    test('Workout Tags', () async {
      await DatabaseHelper.instance.saveWorkoutTag('Running', '#FF0000');
      await DatabaseHelper.instance.saveWorkoutTag('Swimming', '#00FF00');
      
      List<String> tags = await DatabaseHelper.instance.getAllWorkoutTags();
      expect(tags, containsAll(<dynamic>['Running', 'Swimming']));
      
      await DatabaseHelper.instance.incrementTagUseCount('Running');
      
      // Let's add another tag and not increment it.
      await DatabaseHelper.instance.saveWorkoutTag('Cycling', '#0000FF');
      
      tags = await DatabaseHelper.instance.getAllWorkoutTags();
      // Running should be first (count 2: 1 initial + 1 increment)
      
      expect(tags.first, 'Running');
    });
  });
}
