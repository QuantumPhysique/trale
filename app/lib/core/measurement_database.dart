import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:trale/core/logger.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurement_interpolation.dart';
import 'package:trale/core/measurement_stats.dart';
import 'package:trale/core/notification_service.dart';
import 'package:trale/main.dart';

/// Extend DateTime for faster comparison
extension DateTimeExtension on DateTime {
  /// check if two integers corresponds to same day
  bool sameDay(DateTime? other) {
    if (other == null) {
      return false;
    }
    return year == other.year && month == other.month && day == other.day;
  }
}

/// check if day is in list
bool dayInMeasurements(DateTime date, List<Measurement> measurements) => <bool>[
  for (final Measurement m in measurements) date.sameDay(m.date),
].reduce((bool value, bool element) => value || element);

/// Base class for measurement database
class MeasurementDatabaseBaseclass {
  /// Creates a [MeasurementDatabaseBaseclass].
  MeasurementDatabaseBaseclass();

  /// broadcast stream to track change of db
  final StreamController<List<Measurement>> _streamController =
      StreamController<List<Measurement>>.broadcast();

  /// get broadcast stream to track change of db
  StreamController<List<Measurement>> get streamController => _streamController;

  List<Measurement>? _measurements;

  /// get sorted measurements
  List<Measurement> get measurements =>
      _measurements == null ? <Measurement>[] : _measurements!
        ..sort((Measurement a, Measurement b) => b.compareTo(a));

  /// fire stream
  void fireStream() {
    streamController.add(measurements);
  }

  /// get mean measurements
  List<Measurement> averageMeasurements(List<Measurement> ms) {
    if (ms.isEmpty) {
      return ms;
    }

    final double meanWeight =
        ms.fold(0.0, (double sum, Measurement m) => sum + m.weight) / ms.length;
    return <Measurement>[
      for (final Measurement m in ms) m.apply(weight: meanWeight),
    ];
  }

  /// get number of measurements
  int get nMeasurements => measurements.length;

  /// is empty
  bool get isEmpty => measurements.isEmpty;

  /// date of latest measurement
  DateTime get lastDate => measurements.first.date;

  /// date of first measurement
  DateTime get firstDate => measurements.last.date;

  /// time span between first and last measurement in days
  int get measuredTimeSpan =>
      isEmpty ? 0 : lastDate.difference(firstDate).inDays;

  /// duration between first and last measurement
  Duration get measurementDuration =>
      isEmpty ? Duration.zero : lastDate.difference(firstDate);

  /// get largest measurement
  Measurement? get max {
    if (measurements.isEmpty) {
      return null;
    }
    return measurements.reduce(
      (Measurement current, Measurement next) =>
          current.weight > next.weight ? current : next,
    );
  }

  /// get lowest measurement
  Measurement? get min {
    if (measurements.isEmpty) {
      return null;
    }
    return measurements.reduce(
      (Measurement current, Measurement next) =>
          current.weight < next.weight ? current : next,
    );
  }
}

/// class providing an API to handle measurements stored in hive
class MeasurementDatabase extends MeasurementDatabaseBaseclass {
  /// singleton constructor
  factory MeasurementDatabase() => _instance;

  /// single instance creation
  MeasurementDatabase._internal();

  /// Constructor for testing with an injected Hive box.
  @visibleForTesting
  MeasurementDatabase.forTesting(this._testBox);

  Box<Measurement>? _testBox;

  /// singleton instance
  static MeasurementDatabase _instance = MeasurementDatabase._internal();

  /// Replace the singleton instance for testing.
  @visibleForTesting
  static set testInstance(MeasurementDatabase instance) => _instance = instance;

  /// Reset the singleton instance after testing.
  @visibleForTesting
  static void resetInstance() {
    _instance = MeasurementDatabase._internal();
  }

  static const String _boxName = measurementBoxName;

  /// get box
  Box<Measurement> get box => _testBox ?? Hive.box<Measurement>(_boxName);

  /// check if measurement exists
  bool containsMeasurement(Measurement m) =>
      measurements.any((Measurement measurement) => measurement.isIdentical(m));

  /// check if measurement exists on date
  bool existsMeasurementOnDate(DateTime date) =>
      dayInMeasurements(date, measurements);

  /// return
  Measurement? measurementOnDate(DateTime date) {
    for (final Measurement m in measurements) {
      if (date.sameDay(m.date)) {
        return m;
      }
    }
    return null;
  }

  /// insert Measurements into box
  Future<bool> insertMeasurement(Measurement m) async {
    final bool isContained = containsMeasurement(m);
    if (!isContained) {
      try {
        await box.add(m);
      } catch (e) {
        AppLogger.error(
          'Failed to insert measurement',
          tag: 'Database',
          error: e,
        );
        return false;
      }
      await reinit();
      // Cancel today's reminder notification since
      // we just logged a measurement.
      NotificationService().cancelTodayIfMeasured();
    }
    return !isContained;
  }

  /// insert a list of measurements into the box
  Future<int> insertMeasurementList(List<Measurement> ms) async {
    int count = 0;
    for (final Measurement m in ms) {
      final bool isContained = containsMeasurement(m);
      if (!isContained) {
        try {
          await box.add(m);
          count++;
        } catch (e) {
          AppLogger.error(
            'Failed to insert measurement in batch',
            tag: 'Database',
            error: e,
          );
        }
      }
    }
    if (count > 0) {
      await reinit();
    }
    return count;
  }

  /// delete Measurements from box
  Future<void> deleteMeasurement(SortedMeasurement m) async {
    try {
      await box.delete(m.key);
    } catch (e) {
      AppLogger.error(
        'Failed to delete measurement',
        tag: 'Database',
        error: e,
      );
      return;
    }
    await reinit();
  }

  /// delete all Measurements from box
  Future<void> deleteAllMeasurements() async {
    for (final SortedMeasurement m in sortedMeasurements) {
      try {
        await box.delete(m.key);
      } catch (e) {
        AppLogger.error(
          'Failed to delete measurement during deleteAll',
          tag: 'Database',
          error: e,
        );
      }
    }
    await reinit();
  }

  /// re initialize database
  Future<void> reinit() async {
    _measurements = null;
    _sortedMeasurements = null;

    // recalc all
    init();

    // update interpolation (heavy Gaussian work runs in background isolate)
    await MeasurementInterpolation().reinitAsync();
    MeasurementStats().reinit();

    // fire stream
    fireStream();
  }

  /// initialize database
  void init() {
    measurements;
    sortedMeasurements;
  }

  @override
  // ignore: overridden_fields
  List<Measurement>? _measurements;

  /// get sorted measurements
  @override
  List<Measurement> get measurements =>
      _measurements ??= box.values.toList()
        ..sort((Measurement a, Measurement b) => b.compareTo(a));

  List<SortedMeasurement>? _sortedMeasurements;

  /// get sorted measurements, key tuples
  List<SortedMeasurement> get sortedMeasurements =>
      _sortedMeasurements ??= <SortedMeasurement>[
        for (final dynamic key in box.keys)
          SortedMeasurement(key: key, measurement: box.get(key)!),
      ]..sort((SortedMeasurement a, SortedMeasurement b) => b.compareTo(a));

  /// date of latest measurement
  @override
  DateTime get lastDate => sortedMeasurements.first.measurement.date;

  /// date of first measurement
  @override
  DateTime get firstDate => sortedMeasurements.last.measurement.date;

  /// get largest measurement
  Measurement get latestMeasurement => sortedMeasurements.first.measurement;

  /// return string for export
  String get exportString {
    const String header =
        '# This file was created with trale.\n'
        '#Date weight[kg]\n';
    final String body = <String>[
      for (final Measurement m in measurements) m.exportString,
    ].join('\n');
    return header + body;
  }

  /// parse list of measurements from export string
  List<Measurement> parseString({required String exportString}) {
    final List<String> lines = const LineSplitter().convert(exportString);
    lines.removeWhere((String element) => element.startsWith('#'));

    final List<Measurement> results = <Measurement>[];
    for (final String line in lines) {
      try {
        results.add(Measurement.fromString(exportString: line));
      } on FormatException catch (e) {
        AppLogger.warning(
          'Skipping invalid measurement line',
          tag: 'Database',
          error: e,
        );
      }
    }
    return results;
  }
}
