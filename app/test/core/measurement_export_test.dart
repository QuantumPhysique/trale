import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurement_database.dart';

void main() {
  group('parseString', () {
    // parseString is an instance method on MeasurementDatabase but its
    // logic is pure string parsing. We replicate it here to test without
    // Hive, since the implementation is a simple LineSplitter + filter.
    List<Measurement> parseString(String exportString) {
      final List<String> lines = const LineSplitter().convert(exportString);
      lines.removeWhere((String element) => element.startsWith('#'));
      return <Measurement>[
        for (final String line in lines)
          Measurement.fromString(exportString: line),
      ];
    }

    test('parses exported data skipping comment lines', () {
      const String data =
          '# This file was created with trale.\n'
          '#Date weight[kg]\n'
          '2024-01-15T10:30:00.000 75.5000000000\n'
          '2024-01-16T08:00:00.000 76.0000000000';
      final List<Measurement> result = parseString(data);
      expect(result.length, 2);
      expect(result[0].weight, closeTo(75.5, 0.001));
      expect(result[0].date.day, 15);
      expect(result[1].weight, closeTo(76.0, 0.001));
      expect(result[1].date.day, 16);
    });

    test('handles single measurement', () {
      const String data = '# header\n2024-03-01T12:00:00.000 80.0000000000';
      final List<Measurement> result = parseString(data);
      expect(result.length, 1);
      expect(result[0].weight, closeTo(80.0, 0.001));
    });

    test('handles only comment lines as empty', () {
      const String data =
          '# This file was created with trale.\n#Date weight[kg]';
      final List<Measurement> result = parseString(data);
      expect(result, isEmpty);
    });
  });

  group('exportString round-trip', () {
    test('measurement exportString can be parsed back', () {
      final Measurement original = Measurement(
        weight: 82.3,
        date: DateTime(2024, 6, 15, 9, 45),
      );
      final String export = original.exportString;
      final Measurement parsed = Measurement.fromString(exportString: export);
      expect(parsed.weight, closeTo(original.weight, 0.0001));
      expect(parsed.date.year, original.date.year);
      expect(parsed.date.month, original.date.month);
      expect(parsed.date.day, original.date.day);
      expect(parsed.date.hour, original.date.hour);
      expect(parsed.date.minute, original.date.minute);
    });

    test('multiple measurements round-trip through export format', () {
      final List<Measurement> originals = <Measurement>[
        Measurement(weight: 70.0, date: DateTime(2024, 1, 1, 8, 0)),
        Measurement(weight: 75.5, date: DateTime(2024, 1, 15, 10, 30)),
        Measurement(weight: 73.2, date: DateTime(2024, 2, 1, 7, 0)),
      ];

      // Build export string matching the database format
      const String header =
          '# This file was created with trale.\n'
          '#Date weight[kg]\n';
      final String body = originals
          .map((Measurement m) => m.exportString)
          .join('\n');
      final String exportData = header + body;

      // Parse it back
      final List<String> lines = const LineSplitter().convert(exportData);
      lines.removeWhere((String element) => element.startsWith('#'));
      final List<Measurement> parsed = <Measurement>[
        for (final String line in lines)
          Measurement.fromString(exportString: line),
      ];

      expect(parsed.length, originals.length);
      for (int i = 0; i < originals.length; i++) {
        expect(parsed[i].weight, closeTo(originals[i].weight, 0.0001));
        expect(parsed[i].date.day, originals[i].date.day);
      }
    });
  });

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

    test('exportString includes all measurements', () async {
      await box.add(
        Measurement(weight: 70.0, date: DateTime(2024, 1, 1, 8, 0)),
      );
      await box.add(
        Measurement(weight: 72.5, date: DateTime(2024, 1, 2, 9, 0)),
      );
      final String export = db.exportString;
      expect(export, contains('70.0000000000'));
      expect(export, contains('72.5000000000'));
    });

    test('parseString returns correct list from exportString', () async {
      final List<Measurement> originals = <Measurement>[
        Measurement(weight: 80.0, date: DateTime(2024, 3, 5, 7, 0)),
        Measurement(weight: 78.5, date: DateTime(2024, 3, 10, 8, 0)),
      ];
      for (final Measurement m in originals) {
        await box.add(m);
      }
      final String exported = db.exportString;
      final List<Measurement> parsed = db.parseString(exportString: exported);
      // measurements are sorted newest-first
      expect(parsed.length, originals.length);
      expect(parsed[0].weight, closeTo(78.5, 0.0001)); // newer
      expect(parsed[0].date.day, 10);
      expect(parsed[1].weight, closeTo(80.0, 0.0001)); // older
      expect(parsed[1].date.day, 5);
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

    test('parseString with empty export returns empty list', () {
      const String empty =
          '# This file was created with trale.\n'
          '#Date weight[kg]\n';
      final List<Measurement> result = db.parseString(exportString: empty);
      expect(result, isEmpty);
    });
  });
}
