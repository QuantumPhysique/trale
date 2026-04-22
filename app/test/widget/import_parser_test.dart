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

    test('skips comment lines', () {
      final List<String?> lines = <String?>[
        '# header',
        '#another comment',
        '2024-03-01T08:00:00.000 70.0000000000',
      ];
      final List<Measurement> result = parseMeasurementsTxt(lines);
      expect(result.length, 1);
      expect(result[0].weight, closeTo(70.0, 0.0001));
    });

    test('returns empty list for all-comment input', () {
      final List<String?> lines = <String?>[
        '# This file was created with trale.',
        '#Date weight[kg]',
      ];
      final List<Measurement> result = parseMeasurementsTxt(lines);
      expect(result, isEmpty);
    });

    test('skips null lines', () {
      final List<String?> lines = <String?>[
        null,
        '2024-03-01T08:00:00.000 80.0000000000',
      ];
      final List<Measurement> result = parseMeasurementsTxt(lines);
      expect(result.length, 1);
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
      final List<String?> lines = <String?>[
        'dateTime,weight,fat,water,muscle,bone,visceralFat,waist,caliper,bodyCaliper,comment',
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

    test(
      'detects OpenScales header with leading/trailing spaces around names',
      () {
        final List<String?> lines = <String?>[
          ' dateTime , weight , fat ',
          '2024-03-01 08:00,75.4,',
        ];
        final List<int>? indices = openScaleIndices(lines);
        expect(indices, isNotNull);
      },
    );

    test('returns null when weight column is missing', () {
      final List<String?> lines = <String?>['date,fat,water', '2024-03-01,,,'];
      final List<int>? indices = openScaleIndices(lines);
      expect(indices, isNull);
    });

    test('returns null when dateTime column is missing', () {
      final List<String?> lines = <String?>[
        'timestamp,weight',
        '2024-03-01 08:00,75.4',
      ];
      final List<int>? indices = openScaleIndices(lines);
      expect(indices, isNull);
    });

    test('returns null for empty list', () {
      final List<int>? indices = openScaleIndices(<String?>[]);
      expect(indices, isNull);
    });

    test('returns null for null first line', () {
      final List<int>? indices = openScaleIndices(<String?>[null]);
      expect(indices, isNull);
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

    test('removes header row when hasHeader is true (default)', () {
      final List<String?> lines = <String?>[
        'header,line',
        '2024-03-01 08:00,75.4',
      ];
      final List<Measurement> result = parseMeasurementsCSV(lines, 0, 1);
      expect(result.length, 1);
    });

    test('parses all lines when hasHeader is false', () {
      final List<String?> lines = <String?>[
        '2024-03-01 08:00,75.4',
        '2024-03-02 09:30,76.0',
      ];
      final List<Measurement> result = parseMeasurementsCSV(
        lines,
        0,
        1,
        hasHeader: false,
      );
      expect(result.length, 2);
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
      // The data line has too few columns for weightIdx=2; it should be skipped.
      expect(result, isEmpty);
    });

    test('skips null lines', () {
      final List<String?> lines = <String?>[
        'header',
        null,
        '2024-03-01 08:00,75.4',
      ];
      final List<Measurement> result = parseMeasurementsCSV(lines, 0, 1);
      expect(result.length, 1);
    });

    test('skips lines with invalid date', () {
      final List<String?> lines = <String?>[
        'header',
        'not-a-date,75.4',
        '2024-03-01 08:00,75.4',
      ];
      final List<Measurement> result = parseMeasurementsCSV(lines, 0, 1);
      expect(result.length, 1);
    });

    test('skips lines with invalid weight', () {
      final List<String?> lines = <String?>[
        'header',
        '2024-03-01 08:00,not-a-weight',
        '2024-03-02 09:30,76.0',
      ];
      final List<Measurement> result = parseMeasurementsCSV(lines, 0, 1);
      expect(result.length, 1);
      expect(result[0].weight, closeTo(76.0, 0.0001));
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
}
