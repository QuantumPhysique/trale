import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;
import 'package:trale/core/db/app_database.dart';

void main() {
  group('AppDatabase - photos & colors', () {
    final hasSqlite = (() {
      try {
        sqlite3
            .sqlite3; // accessing this may throw if native library not available
        return true;
      } catch (e) {
        return false;
      }
    })();

    late AppDatabase db;
    setUp(() {
      if (!hasSqlite) return;
      db = AppDatabase.connect(NativeDatabase.memory());
    });
    tearDown(() async {
      if (!hasSqlite) return;
      await db.close();
    });

    test('insert photo and retrieve', () async {
      if (!hasSqlite) return;
      final date = '2026-01-11';
      await db.insertCheckIn(CheckInsCompanion.insert(date: date));
      final ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final id = await db.insertPhoto(date, '/tmp/photo1.jpg', ts, fw: true);
      final photos = await db.photosForDate(date);
      expect(photos.length, 1);
      expect(photos.first.filePath, '/tmp/photo1.jpg');
      expect(photos.first.fw, isTrue);
    });

    test('insert color and retrieve', () async {
      if (!hasSqlite) return;
      final date = '2026-01-11';
      await db.insertCheckIn(CheckInsCompanion.insert(date: date));
      final ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final color = 0x112233;
      await db.insertColor(date, ts, color, message: 'mood');
      final colors = await (db.select(
        db.checkInColor,
      )..where((c) => c.checkInDate.equals(date))).get();
      expect(colors.length, 1);
      expect(colors.first.colorRgb, color);
      expect(colors.first.message, 'mood');

      // When color is inserted as immutable, updates/deletes should be prevented
      final immTs = ts + 1;
      await db.insertColor(date, immTs, 0x445566, message: 'locked', isImmutable: true);
      final immRows = await (db.select(db.checkInColor)
          ..where((c) => c.checkInDate.equals(date))
          ..where((c) => c.isImmutable.equals(true))).get();
      expect(immRows.length, 1);

      // Attempt to delete immutable emotional check-in should raise
      bool deleteFailed = false;
      try {
        await db.customStatement('DELETE FROM check_in_color WHERE check_in_date = ? AND ts = ?', [date, immTs]);
      } catch (e) {
        deleteFailed = true;
      }
      expect(deleteFailed, isTrue);
    });

    test('past check-in is immutable by date', () async {
      if (!hasSqlite) return;
      final pastDate = DateTime.now().subtract(const Duration(days: 2));
      final dateStr = '${pastDate.year.toString().padLeft(4, '0')}-${pastDate.month.toString().padLeft(2,'0')}-${pastDate.day.toString().padLeft(2,'0')}';
      await db.insertCheckIn(CheckInsCompanion.insert(date: dateStr));

      // Attempt to update past check-in should raise via trigger
      bool updateFailed = false;
      try {
        await db.customStatement('UPDATE check_in SET notes = ? WHERE date = ?', ['x', dateStr]);
      } catch (e) {
        updateFailed = true;
      }
      expect(updateFailed, isTrue);
    });
  });
}
