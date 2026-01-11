import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

part 'app_database.g.dart';

// Tables
class CheckIns extends Table {
  @override
  String get tableName => 'check_in';

  TextColumn get date => text()(); // ISO-8601 YYYY-MM-DD
  RealColumn get weight => real().nullable()();
  RealColumn get height => real().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {date};
}

class WorkoutTags extends Table {
  @override
  String get tableName => 'workout_tag';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get tag => text().withLength(min: 1, max: 256)();

  @override
  List<String> get customConstraints => ['UNIQUE(tag)'];
}

class Workouts extends Table {
  @override
  String get tableName => 'workout';

  TextColumn get checkInDate => text()(); // FK -> check_in.date
  TextColumn get description => text().nullable()();

  @override
  Set<Column> get primaryKey => {checkInDate};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (check_in_date) REFERENCES check_in(date) ON DELETE CASCADE',
  ];
}

class WorkoutWorkoutTags extends Table {
  @override
  String get tableName => 'workout_workout_tag';

  TextColumn get checkInDate => text()();
  IntColumn get workoutTagId => integer()();

  @override
  Set<Column> get primaryKey => {checkInDate, workoutTagId};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (check_in_date) REFERENCES workout(check_in_date) ON DELETE CASCADE',
    'FOREIGN KEY (workout_tag_id) REFERENCES workout_tag(id) ON DELETE CASCADE',
  ];
}

class CheckInColor extends Table {
  @override
  String get tableName => 'check_in_color';

  TextColumn get checkInDate => text()();
  IntColumn get ts => integer()(); // Unix timestamp
  IntColumn get colorRgb => integer()();
  TextColumn get message => text().nullable()();
  BoolColumn get isImmutable => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {checkInDate, ts};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (check_in_date) REFERENCES check_in(date) ON DELETE CASCADE',
  ];
}

class CheckInPhoto extends Table {
  @override
  String get tableName => 'check_in_photo';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get checkInDate => text()();
  TextColumn get filePath => text()();
  IntColumn get ts => integer()();
  BoolColumn get fw => boolean().withDefault(const Constant(false))();

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (check_in_date) REFERENCES check_in(date) ON DELETE CASCADE',
  ];
}

@DriftDatabase(
  tables: [
    CheckIns,
    WorkoutTags,
    Workouts,
    WorkoutWorkoutTags,
    CheckInColor,
    CheckInPhoto,
  ],
)
class AppDatabase extends _$AppDatabase {
  // For production, pass a LazyDatabase that opens the native database
  AppDatabase() : super(_openConnection());

  // For tests: allow passing a QueryExecutor (e.g., an in-memory NativeDatabase)
  AppDatabase.connect(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      // Create indexes matching the spec
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_workout_checkin ON workout(check_in_date)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_workout_workout_tag_tag ON workout_workout_tag(workout_tag_id)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_color_date_ts ON check_in_color(check_in_date, ts)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_photo_date ON check_in_photo(check_in_date)',
      );

      // Prevent updates/deletes on past check-ins (immutability by date)
      await customStatement('''
        CREATE TRIGGER IF NOT EXISTS prevent_update_old_checkin
        BEFORE UPDATE ON check_in
        WHEN date < date('now','localtime')
        BEGIN
          SELECT RAISE(ABORT, 'check-in is immutable by date');
        END;
      ''');
      await customStatement('''
        CREATE TRIGGER IF NOT EXISTS prevent_delete_old_checkin
        BEFORE DELETE ON check_in
        WHEN date < date('now','localtime')
        BEGIN
          SELECT RAISE(ABORT, 'check-in is immutable by date');
        END;
      ''');

      // Prevent updates/deletes of emotional check-ins when they are marked immutable
      await customStatement('''
        CREATE TRIGGER IF NOT EXISTS prevent_update_immutable_checkin_color
        BEFORE UPDATE ON check_in_color
        WHEN OLD.isImmutable = 1
        BEGIN
          SELECT RAISE(ABORT, 'emotional check-in is immutable');
        END;
      ''');
      await customStatement('''
        CREATE TRIGGER IF NOT EXISTS prevent_delete_immutable_checkin_color
        BEFORE DELETE ON check_in_color
        WHEN OLD.isImmutable = 1
        BEGIN
          SELECT RAISE(ABORT, 'emotional check-in is immutable');
        END;
      ''');
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Delegate to a testable method which is idempotent
      await removeLegacyTargetWeightIfPresent();
    },
  );

  /// Public helper so tests can invoke and/or override the SQL used in the migration
  Future<void> removeLegacyTargetWeightIfPresent() async {
    await removeLegacyTargetWeightIfPresentFn(hasColumn, runSql);
  }

  /// Helper: detect whether a column exists in a table (public for testing)
  Future<bool> hasColumn(String table, String column) async {
    try {
      final result = await customSelect('PRAGMA table_info(${table})').get();
      for (final row in result) {
        if (row.data['name'] == column) return true;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error while checking columns: $e');
    }
    return false;
  }

  /// Wrapper for executing migration SQL, extracted for testability
  Future<void> runSql(String sql) async {
    await customStatement(sql);
  }

  // Basic CRUD examples (expand as needed)
  Future<int> insertCheckIn(Insertable<CheckIn> row) =>
      into(checkIns).insert(row);

  Future<CheckIn?> getCheckInByDate(String date) async {
    return (select(
      checkIns,
    )..where((t) => t.date.equals(date))).getSingleOrNull();
  }

  Future<List<CheckInPhotoData>> photosForDate(String date) =>
      (select(checkInPhoto)..where((p) => p.checkInDate.equals(date))).get();

  /// Insert a photo record for a given check-in date
  Future<int> insertPhoto(
    String date,
    String filePath,
    int ts, {
    bool fw = false,
  }) {
    return into(checkInPhoto).insert(
      CheckInPhotoCompanion.insert(
        checkInDate: date,
        filePath: filePath,
        ts: ts,
        fw: Value(fw),
      ),
    );
  }

  /// Returns whether the check-in for [dateStr] may be edited.
  /// A check-in is immutable if it's older than today, or if an emotional
  /// check-in for that date was stored with isImmutable = true.
  Future<bool> isCheckInMutable(String dateStr) async {
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return false;
      final d = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      if (d.isBefore(today)) return false;

      final imm =
          await (select(checkInColor)..where(
                (c) =>
                    c.checkInDate.equals(dateStr) & c.isImmutable.equals(true),
              ))
              .get();
      return imm.isEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Insert an emotional color for a check-in date
  Future<int> insertColor(
    String date,
    int ts,
    int colorRgb, {
    String? message,
    bool isImmutable = true,
  }) {
    return into(checkInColor).insert(
      CheckInColorCompanion.insert(
        checkInDate: date,
        ts: ts,
        colorRgb: colorRgb,
        message: Value(message),
        isImmutable: Value(isImmutable),
      ),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final file = File('trale_app_db.sqlite');
    return NativeDatabase(file);
  });
}

/// Pure migration function extracted for testing
Future<void> removeLegacyTargetWeightIfPresentFn(
  Future<bool> Function(String table, String column) hasColumnFn,
  Future<void> Function(String sql) runSqlFn,
) async {
  final hasTargetColumn = await hasColumnFn('measurements', 'target_weight');
  if (hasTargetColumn) {
    // safe migration: copy, drop, rename
    await runSqlFn('PRAGMA foreign_keys = OFF');
    await runSqlFn('BEGIN TRANSACTION');
    await runSqlFn(
      'CREATE TABLE IF NOT EXISTS measurements_new AS SELECT id, date, weight, height, notes FROM measurements',
    );
    await runSqlFn('DROP TABLE measurements');
    await runSqlFn('ALTER TABLE measurements_new RENAME TO measurements');
    await runSqlFn('COMMIT');
    await runSqlFn('PRAGMA foreign_keys = ON');
  }
}
