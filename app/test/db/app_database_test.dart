import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/drift.dart'
    show
        QueryExecutor,
        QueryExecutorUser,
        BatchedStatements,
        SqlDialect,
        TransactionExecutor;
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:trale/core/db/app_database.dart';

void main() {
  final bool hasSqlite = (() {
    try {
      // Accessing sqlite3.sqlite3 loads the native library; wrap in try/catch
      sqlite3.sqlite3;
      return true;
    } catch (e) {
      return false;
    }
  })();

  group('AppDatabase - basic CRUD', () {
    late AppDatabase db;

    setUp(() {
      if (!hasSqlite) return;
      db = AppDatabase.connect(NativeDatabase.memory());
    });

    tearDown(() async {
      if (!hasSqlite) return;
      await db.close();
    });

    test('insert and read check_in', () async {
      if (!hasSqlite) return;
      const String date = '2026-01-11';
      await db.insertCheckIn(
        CheckInsCompanion.insert(checkInDate: date, weight: const drift.Value(72.5)),
      );

      final CheckIn? c = await db.getCheckInByDate(date);
      expect(c, isNotNull);
      expect(c!.weight, 72.5);
    }, skip: !hasSqlite);

    test('insert workout tag and link to workout', () async {
      if (!hasSqlite) return;
      const String date = '2026-01-11';
      await db.insertCheckIn(CheckInsCompanion.insert(checkInDate: date));

      final int tagId = await db
          .into(db.workoutTags)
          .insert(WorkoutTagsCompanion.insert(tag: 'cardio'));
      await db
          .into(db.workouts)
          .insert(
            WorkoutsCompanion.insert(
              checkInDate: date,
              description: const drift.Value('pm run'),
            ),
          );
      await db
          .into(db.workoutWorkoutTags)
          .insert(
            WorkoutWorkoutTagsCompanion.insert(
              checkInDate: date,
              workoutTagId: tagId,
            ),
          );

      final List<WorkoutTag> tags = await db.select(db.workoutTags).get();
      expect(tags.any((WorkoutTag t) => t.id == tagId && t.tag == 'cardio'), isTrue);
    }, skip: !hasSqlite);
  });

  group('AppDatabase - migrations', () {
    test(
      'remove legacy target_weight column if present (pure function)',
      () async {
        final List<String> executed = <String>[];

        Future<bool> Function(String table, String column) Future<bool> Future<bool> hasColumnStub(String table, String column) async => true;
        Future<void> Function(String sql) Future<void> Future<void> runSqlStub(String sql) async => executed.add(sql);

        await removeLegacyTargetWeightIfPresentFn(hasColumnStub, runSqlStub);

        expect(
          executed.any((String s) => s.contains('PRAGMA foreign_keys = OFF')),
          isTrue,
        );
        expect(
          executed.any(
            (String s) => s.contains(
              'CREATE TABLE IF NOT EXISTS measurements_new AS SELECT id, date, weight, height, notes FROM measurements',
            ),
          ),
          isTrue,
        );
        expect(
          executed.any(
            (String s) => s.contains(
              'ALTER TABLE measurements_new RENAME TO measurements',
            ),
          ),
          isTrue,
        );
      },
    );
  });
}
