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
  final hasSqlite = (() {
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
      final date = '2026-01-11';
      await db.insertCheckIn(
        CheckInsCompanion.insert(date: date, weight: drift.Value(72.5)),
      );

      final c = await db.getCheckInByDate(date);
      expect(c, isNotNull);
      expect(c!.weight, 72.5);
    }, skip: !hasSqlite);

    test('insert workout tag and link to workout', () async {
      if (!hasSqlite) return;
      final date = '2026-01-11';
      await db.insertCheckIn(CheckInsCompanion.insert(date: date));

      final tagId = await db
          .into(db.workoutTags)
          .insert(WorkoutTagsCompanion.insert(tag: 'cardio'));
      await db
          .into(db.workouts)
          .insert(
            WorkoutsCompanion.insert(
              checkInDate: date,
              description: drift.Value('pm run'),
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

      final tags = await (db.select(db.workoutTags)).get();
      expect(tags.any((t) => t.id == tagId && t.tag == 'cardio'), isTrue);
    }, skip: !hasSqlite);
  });

  group('AppDatabase - migrations', () {
    test(
      'remove legacy target_weight column if present (pure function)',
      () async {
        final executed = <String>[];

        final hasColumnStub = (String table, String column) async => true;
        final runSqlStub = (String sql) async => executed.add(sql);

        await removeLegacyTargetWeightIfPresentFn(hasColumnStub, runSqlStub);

        expect(
          executed.any((s) => s.contains('PRAGMA foreign_keys = OFF')),
          isTrue,
        );
        expect(
          executed.any(
            (s) => s.contains(
              'CREATE TABLE IF NOT EXISTS measurements_new AS SELECT id, date, weight, height, notes FROM measurements',
            ),
          ),
          isTrue,
        );
        expect(
          executed.any(
            (s) => s.contains(
              'ALTER TABLE measurements_new RENAME TO measurements',
            ),
          ),
          isTrue,
        );
      },
    );
  });
}
