import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/measurement.dart';

void main() {
  group('Measurement.isIdentical', () {
    test('same weight and date within 1 minute is identical', () {
      final DateTime date = DateTime(2024, 1, 15, 10, 30);
      final Measurement a = Measurement(weight: 75.5, date: date);
      final Measurement b = Measurement(
        weight: 75.5,
        date: date.add(const Duration(seconds: 30)),
      );
      expect(a.isIdentical(b), true);
    });

    test('same weight but dates more than 1 minute apart is not identical', () {
      final DateTime date = DateTime(2024, 1, 15, 10, 30);
      final Measurement a = Measurement(weight: 75.5, date: date);
      final Measurement b = Measurement(
        weight: 75.5,
        date: date.add(const Duration(minutes: 2)),
      );
      expect(a.isIdentical(b), false);
    });
  });

  group('Measurement.dayInMs', () {
    test('returns day at noon in milliseconds', () {
      final Measurement m = Measurement(
        weight: 75.0,
        date: DateTime(2024, 1, 15, 8, 30),
      );
      final int expected = DateTime(2024, 1, 15, 12).millisecondsSinceEpoch;
      expect(m.dayInMs, expected);
    });
  });

  group('Measurement.exportString', () {
    test('truncates microseconds to millisecond precision', () {
      final Measurement m = Measurement(
        weight: 73.8,
        date: DateTime(2026, 7, 15, 12, 13, 59, 170, 608),
      );
      expect(m.exportString, '2026-07-15T12:13:59.170 73.8000000000');
    });
  });

  group('Measurement.fromString', () {
    test('round-trip: exportString -> fromString', () {
      final Measurement original = Measurement(
        weight: 75.5,
        date: DateTime(2024, 1, 15, 10, 30),
      );
      final Measurement parsed = Measurement.fromString(
        exportString: original.exportString,
      );
      expect(parsed.weight, closeTo(original.weight, 0.0001));
      expect(parsed.date.year, original.date.year);
      expect(parsed.date.month, original.date.month);
      expect(parsed.date.day, original.date.day);
      expect(parsed.isMeasured, true);
    });
  });
}
