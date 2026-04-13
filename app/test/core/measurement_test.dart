import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/measurement.dart';

void main() {
  group('Measurement', () {
    test('constructor sets fields correctly', () {
      final DateTime now = DateTime(2024, 1, 15, 10, 30);
      final Measurement m = Measurement(weight: 75.5, date: now);
      expect(m.weight, 75.5);
      expect(m.date, now);
      expect(m.isMeasured, false);
    });

    test('constructor with isMeasured flag', () {
      final Measurement m = Measurement(
        weight: 75.5,
        date: DateTime(2024, 1, 15),
        isMeasured: true,
      );
      expect(m.isMeasured, true);
    });
  });

  group('Measurement.apply', () {
    late Measurement original;

    setUp(() {
      original = Measurement(
        weight: 75.5,
        date: DateTime(2024, 1, 15, 10, 30),
        isMeasured: true,
      );
    });

    test('apply with new weight preserves other fields', () {
      final Measurement modified = original.apply(weight: 80.0);
      expect(modified.weight, 80.0);
      expect(modified.date, original.date);
      expect(modified.isMeasured, original.isMeasured);
    });

    test('apply with new date preserves other fields', () {
      final DateTime newDate = DateTime(2024, 2, 1);
      final Measurement modified = original.apply(date: newDate);
      expect(modified.weight, original.weight);
      expect(modified.date, newDate);
    });

    test('apply with no arguments creates copy', () {
      final Measurement copy = original.apply();
      expect(copy.weight, original.weight);
      expect(copy.date, original.date);
      expect(copy.isMeasured, original.isMeasured);
    });
  });

  group('Measurement.compareTo', () {
    test('earlier date is less than later date', () {
      final Measurement earlier = Measurement(
        weight: 75.0,
        date: DateTime(2024, 1, 1),
      );
      final Measurement later = Measurement(
        weight: 75.0,
        date: DateTime(2024, 1, 2),
      );
      expect(earlier.compareTo(later), lessThan(0));
    });

    test('same date returns zero', () {
      final DateTime date = DateTime(2024, 1, 1);
      final Measurement a = Measurement(weight: 75.0, date: date);
      final Measurement b = Measurement(weight: 80.0, date: date);
      expect(a.compareTo(b), 0);
    });
  });

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

    test('different weight same date is not identical', () {
      final DateTime date = DateTime(2024, 1, 15, 10, 30);
      final Measurement a = Measurement(weight: 75.5, date: date);
      final Measurement b = Measurement(weight: 76.0, date: date);
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

    test('different times on same day return same dayInMs', () {
      final Measurement morning = Measurement(
        weight: 75.0,
        date: DateTime(2024, 1, 15, 7, 0),
      );
      final Measurement evening = Measurement(
        weight: 75.0,
        date: DateTime(2024, 1, 15, 22, 0),
      );
      expect(morning.dayInMs, evening.dayInMs);
    });
  });

  group('Measurement.dateInMs', () {
    test('returns exact milliseconds', () {
      final DateTime date = DateTime(2024, 1, 15, 10, 30);
      final Measurement m = Measurement(weight: 75.0, date: date);
      expect(m.dateInMs, date.millisecondsSinceEpoch);
    });
  });

  group('Measurement.exportString', () {
    test('returns iso8601 date followed by weight', () {
      final Measurement m = Measurement(
        weight: 75.5,
        date: DateTime(2024, 1, 15, 10, 30),
      );
      final String export = m.exportString;
      expect(export, contains('2024-01-15'));
      expect(export, contains('75.5'));
      // Exact format: iso8601 + space + weight with 10 decimal places
      final List<String> parts = export.split(' ');
      expect(parts.length, 2);
    });
  });

  group('Measurement.fromString', () {
    test('round-trip: exportString -> fromString', () {
      final Measurement original = Measurement(
        weight: 75.5,
        date: DateTime(2024, 1, 15, 10, 30),
      );
      final Measurement parsed =
          Measurement.fromString(exportString: original.exportString);
      expect(parsed.weight, closeTo(original.weight, 0.0001));
      expect(parsed.date.year, original.date.year);
      expect(parsed.date.month, original.date.month);
      expect(parsed.date.day, original.date.day);
      expect(parsed.isMeasured, true);
    });

    test('parses valid export string', () {
      final Measurement m = Measurement.fromString(
        exportString: '2024-01-15T10:30:00.000 75.5000000000',
      );
      expect(m.weight, 75.5);
      expect(m.date.year, 2024);
      expect(m.date.month, 1);
      expect(m.date.day, 15);
    });
  });

  group('Measurement.compare', () {
    test('static compare sorts by date', () {
      final Measurement a = Measurement(
        weight: 75.0,
        date: DateTime(2024, 1, 1),
      );
      final Measurement b = Measurement(
        weight: 80.0,
        date: DateTime(2024, 1, 2),
      );
      expect(Measurement.compare(a, b), lessThan(0));
      expect(Measurement.compare(b, a), greaterThan(0));
      expect(Measurement.compare(a, a), 0);
    });
  });

  group('SortedMeasurement', () {
    test('compareTo sorts by measurement date', () {
      final SortedMeasurement a = SortedMeasurement(
        key: 0,
        measurement: Measurement(weight: 75.0, date: DateTime(2024, 1, 1)),
      );
      final SortedMeasurement b = SortedMeasurement(
        key: 1,
        measurement: Measurement(weight: 80.0, date: DateTime(2024, 1, 2)),
      );
      expect(a.compareTo(b), lessThan(0));
    });

    test('static compare works like compareTo', () {
      final SortedMeasurement a = SortedMeasurement(
        key: 0,
        measurement: Measurement(weight: 75.0, date: DateTime(2024, 1, 1)),
      );
      final SortedMeasurement b = SortedMeasurement(
        key: 1,
        measurement: Measurement(weight: 80.0, date: DateTime(2024, 1, 2)),
      );
      expect(SortedMeasurement.compare(a, b), lessThan(0));
    });
  });
}
