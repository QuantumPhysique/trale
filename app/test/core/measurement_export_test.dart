import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/measurement.dart';

void main() {
  group('parseString', () {
    // parseString is an instance method on MeasurementDatabase but its
    // logic is pure string parsing. We replicate it here to test without
    // Hive, since the implementation is a simple LineSplitter + filter.
    List<Measurement> parseString(String exportString) {
      final List<String> lines =
          const LineSplitter().convert(exportString);
      lines.removeWhere(
        (String element) => element.startsWith('#'),
      );
      return <Measurement>[
        for (final String line in lines)
          Measurement.fromString(exportString: line),
      ];
    }

    test('parses exported data skipping comment lines', () {
      const String data = '# This file was created with trale.\n'
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
      const String data =
          '# header\n2024-03-01T12:00:00.000 80.0000000000';
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
      final Measurement parsed =
          Measurement.fromString(exportString: export);
      expect(parsed.weight, closeTo(original.weight, 0.0001));
      expect(parsed.date.year, original.date.year);
      expect(parsed.date.month, original.date.month);
      expect(parsed.date.day, original.date.day);
      expect(parsed.date.hour, original.date.hour);
      expect(parsed.date.minute, original.date.minute);
    });

    test('multiple measurements round-trip through export format',
        () {
      final List<Measurement> originals = <Measurement>[
        Measurement(
          weight: 70.0,
          date: DateTime(2024, 1, 1, 8, 0),
        ),
        Measurement(
          weight: 75.5,
          date: DateTime(2024, 1, 15, 10, 30),
        ),
        Measurement(
          weight: 73.2,
          date: DateTime(2024, 2, 1, 7, 0),
        ),
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
      final List<String> lines =
          const LineSplitter().convert(exportData);
      lines.removeWhere(
        (String element) => element.startsWith('#'),
      );
      final List<Measurement> parsed = <Measurement>[
        for (final String line in lines)
          Measurement.fromString(exportString: line),
      ];

      expect(parsed.length, originals.length);
      for (int i = 0; i < originals.length; i++) {
        expect(
          parsed[i].weight,
          closeTo(originals[i].weight, 0.0001),
        );
        expect(parsed[i].date.day, originals[i].date.day);
      }
    });
  });
}
