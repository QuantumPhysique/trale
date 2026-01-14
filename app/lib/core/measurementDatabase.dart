import 'dart:async';
import 'dart:convert';

import 'package:trale/core/db/app_database.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementInterpolation.dart';
import 'package:trale/core/measurementStats.dart';
import 'package:trale/core/traleNotifier.dart';
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

  /// date of latest measurement
  DateTime get lastDate => measurements.first.date;

  /// date of first measurement
  DateTime get firstDate => measurements.last.date;

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

  /// singleton instance
  static final MeasurementDatabase _instance = MeasurementDatabase._internal();

  /// check if measurement exists
  bool containsMeasurement(Measurement m) {
    final List<bool> isMeasurement = <bool>[
      for (final Measurement measurement in measurements)
        measurement.isIdentical(m),
    ];
    return isMeasurement.contains(true);
  }

  /// insert Measurements into box
  bool insertMeasurement(Measurement m) {
    // TODO: migrate to Drift
    // final bool isContained = containsMeasurement(m);
    // if (!isContained) {
    //   box.add(m);
    //   reinit();
    // }
    // return !isContained;
    return false;
  }

  /// insert a list of measurements into the box
  int insertMeasurementList(List<Measurement> ms) {
    // TODO: migrate to Drift
    // int count = 0;
    // for (final Measurement m in ms) {
    //   final bool isContained = containsMeasurement(m);
    //   if (!isContained) {
    //     box.add(m);
    //     count++;
    //   }
    // }
    // if (count > 0) {
    //   reinit();
    // }
    // return count;
    return 0;
  }

  /// delete Measurements from box
  void deleteMeasurement(Measurement m) {
    // TODO: migrate to Drift
    // box.delete(m.key);
    reinit();
  }

  /// delete all Measurements from box
  Future<void> deleteAllMeasurements() async {
    // TODO: migrate to Drift
    // for (final SortedMeasurement m in sortedMeasurements) {
    //   await box.delete(m.key);
    // }
    reinit();
  }

  /// re initialize database
  void reinit() {
    _measurements = null;

    // recalc all
    init();

    // update interpolation
    MeasurementInterpolation().reinit();
    MeasurementStats().reinit();

    // fire stream
    fireStream();
    TraleNotifier().notify;
  }

  /// initialize database
  void init() {
    measurements;
  }

  @override
  List<Measurement>? _measurements;

  /// get sorted measurements
  @override
  List<Measurement> get measurements =>
      _measurements ??= <Measurement>[]; // TODO: migrate to Drift
      // box.values.toList()
      //   ..sort((Measurement a, Measurement b) => b.compareTo(a));

  /// date of latest measurement
  @override
  DateTime get lastDate => measurements.isNotEmpty ? measurements.first.date : DateTime.now();

  /// date of first measurement
  @override
  DateTime get firstDate => measurements.isNotEmpty ? measurements.last.date : DateTime.now();

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

    return <Measurement>[
      for (final String line in lines)
        Measurement.fromString(exportString: line),
    ];
  }
}
