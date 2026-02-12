import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';

void main() {
  group('DateTimeExtension', () {
    test('sameDay returns true for same day', () {
      final date1 = DateTime(2024, 1, 15, 10, 30);
      final date2 = DateTime(2024, 1, 15, 14, 45);

      expect(date1.sameDay(date2), true);
    });

    test('sameDay returns false for different days', () {
      final date1 = DateTime(2024, 1, 15);
      final date2 = DateTime(2024, 1, 16);

      expect(date1.sameDay(date2), false);
    });

    test('sameDay returns false for different months', () {
      final date1 = DateTime(2024, 1, 15);
      final date2 = DateTime(2024, 2, 15);

      expect(date1.sameDay(date2), false);
    });

    test('sameDay returns false for different years', () {
      final date1 = DateTime(2024, 1, 15);
      final date2 = DateTime(2023, 1, 15);

      expect(date1.sameDay(date2), false);
    });

    test('sameDay returns false for null', () {
      final date = DateTime(2024, 1, 15);

      expect(date.sameDay(null), false);
    });
  });

  group('dayInMeasurements', () {
    test('returns true when day is in measurements', () {
      final date = DateTime(2024, 1, 15);
      final measurements = [
        Measurement(weight: 70.0, date: DateTime(2024, 1, 14)),
        Measurement(weight: 71.0, date: DateTime(2024, 1, 15, 10, 30)),
        Measurement(weight: 72.0, date: DateTime(2024, 1, 16)),
      ];

      expect(dayInMeasurements(date, measurements), true);
    });

    test('returns false when day is not in measurements', () {
      final date = DateTime(2024, 1, 17);
      final measurements = [
        Measurement(weight: 70.0, date: DateTime(2024, 1, 14)),
        Measurement(weight: 71.0, date: DateTime(2024, 1, 15)),
        Measurement(weight: 72.0, date: DateTime(2024, 1, 16)),
      ];

      expect(dayInMeasurements(date, measurements), false);
    });

    test('handles empty measurements list', () {
      final date = DateTime(2024, 1, 15);
      final measurements = <Measurement>[];

      // With empty list, reduce will throw, so this test verifies the behavior
      expect(() => dayInMeasurements(date, measurements), throwsStateError);
    });
  });

  group('MeasurementDatabaseBaseclass', () {
    test('measurements returns empty list when null', () {
      final db = MeasurementDatabaseBaseclass();

      expect(db.measurements, isEmpty);
    });

    test('nMeasurements returns count', () {
      final db = MeasurementDatabaseBaseclass();

      expect(db.nMeasurements, 0);
    });

    test('averageMeasurements calculates mean weight', () {
      final db = MeasurementDatabaseBaseclass();
      final measurements = [
        Measurement(weight: 70.0, date: DateTime(2024, 1, 1)),
        Measurement(weight: 80.0, date: DateTime(2024, 1, 2)),
        Measurement(weight: 75.0, date: DateTime(2024, 1, 3)),
      ];

      final averaged = db.averageMeasurements(measurements);

      expect(averaged.length, 3);
      expect(averaged[0].weight, 75.0);
      expect(averaged[1].weight, 75.0);
      expect(averaged[2].weight, 75.0);
    });

    test('averageMeasurements handles empty list', () {
      final db = MeasurementDatabaseBaseclass();
      final measurements = <Measurement>[];

      final averaged = db.averageMeasurements(measurements);

      expect(averaged, isEmpty);
    });

    test('max returns null for empty measurements', () {
      final db = MeasurementDatabaseBaseclass();

      expect(db.max, isNull);
    });

    test('min returns null for empty measurements', () {
      final db = MeasurementDatabaseBaseclass();

      expect(db.min, isNull);
    });

    test('streamController is broadcast', () {
      final db = MeasurementDatabaseBaseclass();

      expect(db.streamController.stream.isBroadcast, true);
    });
  });
}
