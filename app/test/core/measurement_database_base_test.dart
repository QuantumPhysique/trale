import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurement_database.dart';

void main() {
  group('MeasurementDatabaseBaseclass', () {
    late MeasurementDatabaseBaseclass db;

    setUp(() {
      db = MeasurementDatabaseBaseclass();
    });

    test('measurements is empty by default', () {
      expect(db.measurements, isEmpty);
      expect(db.isEmpty, true);
      expect(db.nMeasurements, 0);
    });

    test('max and min return null when empty', () {
      expect(db.max, isNull);
      expect(db.min, isNull);
    });

    test('measuredTimeSpan is 0 when empty', () {
      expect(db.measuredTimeSpan, 0);
    });

    test('measurementDuration is zero when empty', () {
      expect(db.measurementDuration, Duration.zero);
    });
  });

  group('MeasurementDatabaseBaseclass.averageMeasurements', () {
    late MeasurementDatabaseBaseclass db;

    setUp(() {
      db = MeasurementDatabaseBaseclass();
    });

    test('returns empty list for empty input', () {
      expect(db.averageMeasurements(<Measurement>[]), isEmpty);
    });

    test('returns single measurement with same weight', () {
      final Measurement m = Measurement(
        weight: 75.0,
        date: DateTime(2024, 1, 1),
      );
      final List<Measurement> result = db.averageMeasurements(<Measurement>[m]);
      expect(result.length, 1);
      expect(result.first.weight, 75.0);
    });

    test('averages weights across multiple measurements', () {
      final List<Measurement> ms = <Measurement>[
        Measurement(weight: 70.0, date: DateTime(2024, 1, 1)),
        Measurement(weight: 80.0, date: DateTime(2024, 1, 2)),
      ];
      final List<Measurement> result = db.averageMeasurements(ms);
      expect(result.length, 2);
      for (final Measurement m in result) {
        expect(m.weight, 75.0);
      }
    });

    test('preserves dates but replaces weights with mean', () {
      final DateTime d1 = DateTime(2024, 1, 1);
      final DateTime d2 = DateTime(2024, 1, 2);
      final DateTime d3 = DateTime(2024, 1, 3);
      final List<Measurement> ms = <Measurement>[
        Measurement(weight: 60.0, date: d1),
        Measurement(weight: 70.0, date: d2),
        Measurement(weight: 80.0, date: d3),
      ];
      final List<Measurement> result = db.averageMeasurements(ms);
      expect(result[0].date, d1);
      expect(result[1].date, d2);
      expect(result[2].date, d3);
      expect(result[0].weight, closeTo(70.0, 0.001));
    });
  });

  group('DateTimeExtension.sameDay', () {
    test('same day returns true', () {
      final DateTime a = DateTime(2024, 1, 15, 8, 0);
      final DateTime b = DateTime(2024, 1, 15, 22, 0);
      expect(a.sameDay(b), true);
    });

    test('different day returns false', () {
      final DateTime a = DateTime(2024, 1, 15);
      final DateTime b = DateTime(2024, 1, 16);
      expect(a.sameDay(b), false);
    });

    test('null returns false', () {
      final DateTime a = DateTime(2024, 1, 15);
      expect(a.sameDay(null), false);
    });
  });

  group('dayInMeasurements', () {
    test('returns true when date matches a measurement', () {
      final List<Measurement> ms = <Measurement>[
        Measurement(weight: 75.0, date: DateTime(2024, 1, 15, 10, 30)),
      ];
      expect(dayInMeasurements(DateTime(2024, 1, 15, 8, 0), ms), true);
    });

    test('returns false when date does not match', () {
      final List<Measurement> ms = <Measurement>[
        Measurement(weight: 75.0, date: DateTime(2024, 1, 15)),
      ];
      expect(dayInMeasurements(DateTime(2024, 1, 16), ms), false);
    });
  });
}
