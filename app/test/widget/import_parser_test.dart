import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/widget/io_widgets.dart';

void main() {
  // ---------------------------------------------------------------------------
  // parseMeasurementsTxt
  // ---------------------------------------------------------------------------
  group('parseMeasurementsTxt', () {
    test('parses standard trale .txt export', () {
      final List<String?> lines = <String?>[
        '# This file was created with trale.',
        '#Date weight[kg]',
        '2024-03-01T08:00:00.000 75.5000000000',
        '2024-03-02T08:00:00.000 76.0000000000',
      ];
      final List<Measurement> result = parseMeasurementsTxt(lines);
      expect(result.length, 2);
      expect(result[0].weight, closeTo(75.5, 0.0001));
      expect(result[0].date.day, 1);
      expect(result[1].weight, closeTo(76.0, 0.0001));
      expect(result[1].date.day, 2);
    });

    test('skips malformed lines without throwing', () {
      final List<String?> lines = <String?>[
        'not-valid',
        '2024-03-01T08:00:00.000 75.0000000000',
        'also bad',
      ];
      final List<Measurement> result = parseMeasurementsTxt(lines);
      expect(result.length, 1);
      expect(result[0].weight, closeTo(75.0, 0.0001));
    });

    test('parses date-only format (2024-03-01 75.0)', () {
      final List<String?> lines = <String?>['2024-03-01 75.0000000000'];
      final List<Measurement> result = parseMeasurementsTxt(lines);
      expect(result.length, 1);
      expect(result[0].weight, closeTo(75.0, 0.0001));
      expect(result[0].date.year, 2024);
      expect(result[0].date.month, 3);
      expect(result[0].date.day, 1);
    });
  });

  // ---------------------------------------------------------------------------
  // openScaleIndices
  // ---------------------------------------------------------------------------
  group('openScaleIndices', () {
    test('detects standard OpenScales CSV header', () {
      const String header =
          'dateTime,weight,fat,water,muscle,bone,visceralFat,waist,caliper,'
          'bodyCaliper,comment';
      final List<String?> lines = <String?>[
        header,
        '2024-03-01 08:00,75.4,,,,,,,,,',
      ];
      final List<int>? indices = openScaleIndices(lines);
      expect(indices, isNotNull);
      expect(indices![0], 0); // dateTime at index 0
      expect(indices[1], 1); // weight at index 1
    });

    test('detects OpenScales header with mixed case (Weight, DateTime)', () {
      final List<String?> lines = <String?>[
        'DateTime,Weight,Fat,Water',
        '2024-03-01 08:00,75.4,,',
      ];
      final List<int>? indices = openScaleIndices(lines);
      expect(indices, isNotNull);
      expect(indices![0], 0);
      expect(indices[1], 1);
    });
  });

  // ---------------------------------------------------------------------------
  // parseMeasurementsCSV
  // ---------------------------------------------------------------------------
  group('parseMeasurementsCSV', () {
    test('parses standard OpenScales CSV data', () {
      final List<String?> lines = <String?>[
        'dateTime,weight,fat,water,muscle',
        '2024-03-01 08:00,75.4,,,,',
        '2024-03-02 09:30,76.0,,,,',
      ];
      // openScaleIndices would return [0, 1] for this header
      final List<Measurement> result = parseMeasurementsCSV(
        lines,
        0,
        1,
        dateFormat: 'yyyy-MM-dd HH:mm',
      );
      expect(result.length, 2);
      expect(result[0].weight, closeTo(75.4, 0.0001));
      expect(result[0].date.day, 1);
      expect(result[0].date.hour, 8);
      expect(result[1].weight, closeTo(76.0, 0.0001));
    });

    test('skips lines with too few columns without throwing (bounds fix)', () {
      // weightIdx=2 but line only has 2 columns (indices 0 and 1) —
      // previously would throw RangeError before the try/catch.
      final List<String?> lines = <String?>[
        'header',
        '2024-03-01 08:00,75.4', // only 2 columns; weightIdx=2 is out-of-bounds
      ];
      expect(() => parseMeasurementsCSV(lines, 0, 2), returnsNormally);
      final List<Measurement> result = parseMeasurementsCSV(lines, 0, 2);
      // The data line is too short for weightIdx=2; it should be skipped.
      expect(result, isEmpty);
    });

    test('removes quotes from date string', () {
      final List<String?> lines = <String?>[
        'header',
        '"2024-03-01 08:00",75.4',
      ];
      final List<Measurement> result = parseMeasurementsCSV(lines, 0, 1);
      expect(result.length, 1);
      expect(result[0].date.month, 3);
    });

    test('supports semicolon separator', () {
      final List<String?> lines = <String?>[
        'date;weight',
        '2024-03-01 08:00;75.4',
      ];
      final List<Measurement> result = parseMeasurementsCSV(
        lines,
        0,
        1,
        separator: ';',
      );
      expect(result.length, 1);
      expect(result[0].weight, closeTo(75.4, 0.0001));
    });
  });

  // ---------------------------------------------------------------------------
  // parseOpenScaleCSV
  // ---------------------------------------------------------------------------
  group('parseOpenScaleCSV', () {
    // New format: separate DATE + TIME + uppercase WEIGHT columns
    test('parses new OpenScale export format (DATE, TIME, WEIGHT columns)', () {
      const String header =
          'DATE,TIME,BICEPS,BMI,BMR,BODY_FAT,BONE,CALIPER,CALIPER_1,CALIPER_2,'
          'CALIPER_3,CALORIES,CHEST,COMMENT,HEART_RATE,HIPS,LBM,MUSCLE,NECK,'
          'TDEE,THIGH,VISCERAL_FAT,WAIST,WATER,WEIGHT,WHR,WHTR';
      final List<String?> lines = <String?>[
        header,
        '2026-04-23,20:30:13.974,,5.32,3383.75,,,,,,,,,,,,,,,4060.5,,,,,90.0,,',
      ];
      final List<Measurement>? result = parseOpenScaleCSV(lines);
      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result[0].weight, closeTo(90.0, 0.0001));
      expect(result[0].date.year, 2026);
      expect(result[0].date.month, 4);
      expect(result[0].date.day, 23);
      expect(result[0].date.hour, 20);
      expect(result[0].date.minute, 30);
    });

    test('parses legacy OpenScale format (combined dateTime column)', () {
      final List<String?> lines = <String?>[
        'dateTime,weight,fat,water,muscle,bone,visceralFat',
        '2024-03-01 08:00,75.4,,,,',
        '2024-03-02 09:30,76.0,,,,',
      ];
      final List<Measurement>? result = parseOpenScaleCSV(lines);
      expect(result, isNotNull);
      expect(result!.length, 2);
      expect(result[0].weight, closeTo(75.4, 0.0001));
      expect(result[0].date.day, 1);
      expect(result[1].weight, closeTo(76.0, 0.0001));
    });

    test('returns null when header is not an OpenScale format', () {
      final List<String?> lines = <String?>[
        'Date,Weight,Height',
        '2024-03-01,75.4,180',
      ];
      // "Weight" with capital W matches neither exact "weight" nor "datetime"
      // — wait, our matcher lowercases, so "Weight" -> "weight" == "weight" ✓.
      // But "Date" != "date" after lowercase → no "date" exact match.
      // And "Date" doesn't contain "datetime". So this should return null.
      final List<Measurement>? result = parseOpenScaleCSV(lines);
      expect(result, isNull);
    });

    test('skips rows with too few columns without throwing', () {
      final List<String?> lines = <String?>[
        'DATE,TIME,WEIGHT',
        'short', // only 1 column — all indices are out of bounds
        '2026-04-01,08:00:00,75.4',
      ];
      final List<Measurement>? result = parseOpenScaleCSV(lines);
      expect(result, isNotNull);
      expect(result!.length, 1);
    });
  });
}
