import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurement_database.dart';
import 'package:trale/core/measurement_stats.dart';
import 'package:trale/core/preferences.dart';

// ---------------------------------------------------------------------------
// Fake database that returns a fixed list without requiring Hive.
// ---------------------------------------------------------------------------

class _FakeDb extends MeasurementDatabaseBaseclass {
  _FakeDb(this._fakeMeasurements);

  final List<Measurement> _fakeMeasurements;

  @override
  List<Measurement> get measurements =>
      _fakeMeasurements..sort((Measurement a, Measurement b) => b.compareTo(a));
}

void main() {
  late Preferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences sp = await SharedPreferences.getInstance();
    prefs = Preferences.forTesting(sp);
    Preferences.testInstance = prefs;
  });

  tearDown(() {
    Preferences.resetInstance();
  });

  group('MeasurementStats global db-only calculations', () {
    late _FakeDb fakeDb;
    late MeasurementStats stats;

    setUp(() {
      fakeDb = _FakeDb(<Measurement>[
        Measurement(weight: 80.0, date: DateTime(2024, 1, 1)),
        Measurement(weight: 75.0, date: DateTime(2024, 2, 1)),
        Measurement(weight: 70.0, date: DateTime(2024, 3, 1)),
      ]);
      stats = MeasurementStats.forTesting(db: fakeDb);
    });

    test('globalNMeasurements returns correct count', () {
      expect(stats.globalNMeasurements, 3);
    });

    test('globalMaxWeightDate returns the heaviest measurement', () {
      final ({double? weight, DateTime? date}) result =
          stats.globalMaxWeightDate;
      expect(result.weight, closeTo(80.0, 0.001));
      expect(result.date?.month, 1);
    });

    test('globalMinWeightDate returns the lightest measurement', () {
      final ({double? weight, DateTime? date}) result =
          stats.globalMinWeightDate;
      expect(result.weight, closeTo(70.0, 0.001));
      expect(result.date?.month, 3);
    });

    test('globalMaxWeightDate returns nulls when db is empty', () {
      final MeasurementStats emptyStats = MeasurementStats.forTesting(
        db: _FakeDb(<Measurement>[]),
      );
      final ({double? weight, DateTime? date}) result =
          emptyStats.globalMaxWeightDate;
      expect(result.weight, isNull);
      expect(result.date, isNull);
    });

    test('globalMinWeightDate returns nulls when db is empty', () {
      final MeasurementStats emptyStats = MeasurementStats.forTesting(
        db: _FakeDb(<Measurement>[]),
      );
      final ({double? weight, DateTime? date}) result =
          emptyStats.globalMinWeightDate;
      expect(result.weight, isNull);
      expect(result.date, isNull);
    });

    test('globalNMeasurements is zero when db is empty', () {
      final MeasurementStats emptyStats = MeasurementStats.forTesting(
        db: _FakeDb(<Measurement>[]),
      );
      expect(emptyStats.globalNMeasurements, 0);
    });

    test('globalMinWeightDate finds minimum correctly when '
        'multiple candidates exist', () {
      final _FakeDb db = _FakeDb(<Measurement>[
        Measurement(weight: 90.0, date: DateTime(2024, 1, 1)),
        Measurement(weight: 60.0, date: DateTime(2024, 2, 1)),
        Measurement(weight: 75.0, date: DateTime(2024, 3, 1)),
      ]);
      final MeasurementStats s = MeasurementStats.forTesting(db: db);
      expect(s.globalMinWeightDate.weight, closeTo(60.0, 0.001));
      expect(s.globalMaxWeightDate.weight, closeTo(90.0, 0.001));
    });
  });

  group('MeasurementStats.referenceAtDay', () {
    late MeasurementStats stats;

    setUp(() {
      stats = MeasurementStats.forTesting(
        db: _FakeDb(<Measurement>[
          Measurement(weight: 80.0, date: DateTime(2024, 1, 1)),
        ]),
      );
    });

    test('returns null when targetWeightEnabled is false', () {
      // Preferences defaults have targetWeightEnabled = false
      expect(stats.referenceAtDay(DateTime(2024, 6, 1)), isNull);
    });

    test('returns targetWeight when no targetDate is set', () {
      prefs.targetWeightEnabled = true;
      prefs.userTargetWeight = 70.0;
      // no targetDate set → constant at targetWeight
      expect(stats.referenceAtDay(DateTime(2024, 6, 1)), closeTo(70.0, 0.001));
    });
  });
}
