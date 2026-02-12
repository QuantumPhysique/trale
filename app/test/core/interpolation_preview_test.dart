import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/interpolationPreview.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/measurementInterpolation.dart';

void main() {
  group('PreviewDatabase', () {
    test('extends MeasurementDatabaseBaseclass', () {
      final db = PreviewDatabase();
      expect(db, isA<MeasurementDatabaseBaseclass>());
    });

    test('measurements returns non-empty list', () {
      final db = PreviewDatabase();
      final measurements = db.measurements;

      expect(measurements, isNotEmpty);
      expect(measurements, isA<List<Measurement>>());
    });

    test('measurements are sorted', () {
      final db = PreviewDatabase();
      final measurements = db.measurements;

      // Check if sorted in descending order (most recent first)
      for (int i = 0; i < measurements.length - 1; i++) {
        expect(
          measurements[i].date.isAfter(measurements[i + 1].date) ||
              measurements[i].date.isAtSameMomentAs(measurements[i + 1].date),
          true,
          reason: 'Measurements should be sorted in descending order by date',
        );
      }
    });

    test('measurements have valid weights', () {
      final db = PreviewDatabase();
      final measurements = db.measurements;

      for (final measurement in measurements) {
        expect(measurement.weight, greaterThan(0));
        expect(measurement.weight, lessThan(200)); // Reasonable max weight
      }
    });

    test('measurements have valid dates', () {
      final db = PreviewDatabase();
      final measurements = db.measurements;

      for (final measurement in measurements) {
        expect(measurement.date, isA<DateTime>());
        expect(measurement.date.isBefore(DateTime.now().add(Duration(days: 1))), true);
      }
    });
  });

  group('PreviewInterpolation', () {
    test('extends MeasurementInterpolationBaseclass', () {
      final interpolation = PreviewInterpolation();
      expect(interpolation, isA<MeasurementInterpolationBaseclass>());
    });

    test('db returns PreviewDatabase', () {
      final interpolation = PreviewInterpolation();
      expect(interpolation.db, isA<PreviewDatabase>());
    });

    test('db provides measurements', () {
      final interpolation = PreviewInterpolation();
      final db = interpolation.db;
      expect(db.measurements, isNotEmpty);
    });
  });
}
