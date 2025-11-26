import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/measurement.dart';

void main() {
  group('Measurement', () {
    test('constructor creates measurement correctly', () {
      final date = DateTime(2024, 1, 1, 10, 30);
      final measurement = Measurement(
        weight: 70.5,
        date: date,
        isMeasured: true,
      );

      expect(measurement.weight, 70.5);
      expect(measurement.date, date);
      expect(measurement.isMeasured, true);
    });

    test('constructor with default isMeasured', () {
      final measurement = Measurement(
        weight: 70.5,
        date: DateTime(2024, 1, 1),
      );

      expect(measurement.isMeasured, false);
    });

    test('apply creates modified copy', () {
      final original = Measurement(
        weight: 70.5,
        date: DateTime(2024, 1, 1),
        isMeasured: false,
      );

      final modified = original.apply(weight: 75.0);

      expect(modified.weight, 75.0);
      expect(modified.date, original.date);
      expect(modified.isMeasured, false);
    });

    test('apply with all parameters', () {
      final original = Measurement(
        weight: 70.5,
        date: DateTime(2024, 1, 1),
      );

      final newDate = DateTime(2024, 2, 1);
      final modified = original.apply(
        weight: 75.0,
        date: newDate,
        isMeasured: true,
      );

      expect(modified.weight, 75.0);
      expect(modified.date, newDate);
      expect(modified.isMeasured, true);
    });

    test('compareTo compares by date', () {
      final earlier = Measurement(
        weight: 70.0,
        date: DateTime(2024, 1, 1),
      );
      final later = Measurement(
        weight: 75.0,
        date: DateTime(2024, 2, 1),
      );

      expect(earlier.compareTo(later), lessThan(0));
      expect(later.compareTo(earlier), greaterThan(0));
      expect(earlier.compareTo(earlier), 0);
    });

    test('isIdentical checks weight and date', () {
      final date = DateTime(2024, 1, 1, 10, 30);
      final m1 = Measurement(weight: 70.5, date: date);
      final m2 = Measurement(weight: 70.5, date: date);
      final m3 = Measurement(weight: 75.0, date: date);

      expect(m1.isIdentical(m2), true);
      expect(m1.isIdentical(m3), false);
    });

    test('isIdentical allows small time differences', () {
      final date1 = DateTime(2024, 1, 1, 10, 30, 0);
      final date2 = DateTime(2024, 1, 1, 10, 30, 30); // 30 seconds later
      final m1 = Measurement(weight: 70.5, date: date1);
      final m2 = Measurement(weight: 70.5, date: date2);

      expect(m1.isIdentical(m2), true);
    });

    test('isIdentical rejects large time differences', () {
      final date1 = DateTime(2024, 1, 1, 10, 30);
      final date2 = DateTime(2024, 1, 1, 10, 32); // 2 minutes later
      final m1 = Measurement(weight: 70.5, date: date1);
      final m2 = Measurement(weight: 70.5, date: date2);

      expect(m1.isIdentical(m2), false);
    });

    test('dayInMs returns day in milliseconds', () {
      final date = DateTime(2024, 1, 15, 14, 30);
      final measurement = Measurement(weight: 70.5, date: date);

      // Should return midnight of the day (with 12h offset)
      final expected = DateTime(2024, 1, 15, 12).millisecondsSinceEpoch;
      expect(measurement.dayInMs, expected);
    });

    test('dateInMs returns date in milliseconds', () {
      final date = DateTime(2024, 1, 15, 14, 30);
      final measurement = Measurement(weight: 70.5, date: date);

      expect(measurement.dateInMs, date.millisecondsSinceEpoch);
    });

    test('exportString formats correctly', () {
      final date = DateTime(2024, 1, 15, 14, 30);
      final measurement = Measurement(weight: 70.123456789, date: date);

      final exportString = measurement.exportString;

      expect(exportString, contains(date.toIso8601String()));
      expect(exportString, contains('70.1234567890'));
    });

    test('fromString parses correctly', () {
      final exportString = '2024-01-15T14:30:00.000 70.5000000000';
      final measurement = Measurement.fromString(exportString: exportString);

      expect(measurement.weight, 70.5);
      expect(measurement.date.year, 2024);
      expect(measurement.date.month, 1);
      expect(measurement.date.day, 15);
      expect(measurement.isMeasured, true);
    });

    test('compare static method works', () {
      final m1 = Measurement(weight: 70.0, date: DateTime(2024, 1, 1));
      final m2 = Measurement(weight: 75.0, date: DateTime(2024, 2, 1));

      expect(Measurement.compare(m1, m2), lessThan(0));
      expect(Measurement.compare(m2, m1), greaterThan(0));
    });
  });

  group('SortedMeasurement', () {
    test('constructor creates sorted measurement correctly', () {
      final measurement = Measurement(
        weight: 70.5,
        date: DateTime(2024, 1, 1),
      );
      final sorted = SortedMeasurement(
        key: 'test_key',
        measurement: measurement,
      );

      expect(sorted.key, 'test_key');
      expect(sorted.measurement, measurement);
    });

    test('compareTo compares by measurement date', () {
      final m1 = Measurement(weight: 70.0, date: DateTime(2024, 1, 1));
      final m2 = Measurement(weight: 75.0, date: DateTime(2024, 2, 1));
      final sm1 = SortedMeasurement(key: '1', measurement: m1);
      final sm2 = SortedMeasurement(key: '2', measurement: m2);

      expect(sm1.compareTo(sm2), lessThan(0));
      expect(sm2.compareTo(sm1), greaterThan(0));
      expect(sm1.compareTo(sm1), 0);
    });

    test('compare static method works', () {
      final m1 = Measurement(weight: 70.0, date: DateTime(2024, 1, 1));
      final m2 = Measurement(weight: 75.0, date: DateTime(2024, 2, 1));
      final sm1 = SortedMeasurement(key: '1', measurement: m1);
      final sm2 = SortedMeasurement(key: '2', measurement: m2);

      expect(SortedMeasurement.compare(sm1, sm2), lessThan(0));
      expect(SortedMeasurement.compare(sm2, sm1), greaterThan(0));
    });
  });
}
