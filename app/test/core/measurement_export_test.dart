import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurement_database.dart';

void main() {
  group('MeasurementDatabase.forTesting export/import', () {
    late Directory tempDir;
    late Box<Measurement> box;
    late MeasurementDatabase db;

    setUpAll(() async {
      Hive.registerAdapter(MeasurementAdapter());
    });

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('hive_test_');
      Hive.init(tempDir.path);
      box = await Hive.openBox<Measurement>('measurements_test');
      db = MeasurementDatabase.forTesting(box);
      MeasurementDatabase.testInstance = db;
    });

    tearDown(() async {
      await box.close();
      MeasurementDatabase.resetInstance();
      await Hive.deleteFromDisk();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('exportString produces correct header', () async {
      await box.add(Measurement(weight: 75.0, date: DateTime(2024, 1, 1)));
      final String export = db.exportString;
      expect(export, startsWith('# This file was created with trale.\n'));
      expect(export, contains('#Date weight[kg]'));
    });

    test(
      'parseString round-trip: export then import yields same data',
      () async {
        final List<Measurement> originals = <Measurement>[
          Measurement(weight: 65.0, date: DateTime(2024, 6, 1, 6, 30)),
          Measurement(weight: 64.5, date: DateTime(2024, 6, 8, 6, 0)),
          Measurement(weight: 63.8, date: DateTime(2024, 6, 15, 7, 0)),
        ];
        for (final Measurement m in originals) {
          await box.add(m);
        }
        final String exported = db.exportString;
        final List<Measurement> parsed = db.parseString(exportString: exported);
        // measurements sorted newest-first; match against originals in reverse
        expect(parsed.length, originals.length);
        for (int i = 0; i < originals.length; i++) {
          final Measurement expected = originals[originals.length - 1 - i];
          expect(parsed[i].weight, closeTo(expected.weight, 0.0001));
          expect(parsed[i].date.year, expected.date.year);
          expect(parsed[i].date.month, expected.date.month);
          expect(parsed[i].date.day, expected.date.day);
          expect(parsed[i].date.hour, expected.date.hour);
          expect(parsed[i].date.minute, expected.date.minute);
        }
      },
    );
  });
}
