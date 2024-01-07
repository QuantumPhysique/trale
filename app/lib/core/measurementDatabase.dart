import 'dart:async';
import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:trale/core/interpolation.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/preferences.dart';
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
bool dayInMeasurements(DateTime date, List<Measurement> measurements) =>
    <bool>[
      for (final Measurement m in measurements)
        date.sameDay(m.date)
    ].reduce((bool value, bool element) => value || element);


/// class providing an API to handle measurements stored in hive
class MeasurementDatabase {
  /// singleton constructor
  factory MeasurementDatabase() => _instance;

  /// single instance creation
  MeasurementDatabase._internal();

  /// singleton instance
  static final MeasurementDatabase _instance = MeasurementDatabase._internal();

  static const String _boxName = measurementBoxName;

  /// get box
  Box<Measurement> get box => Hive.box<Measurement>(_boxName);

  /// broadcast stream to track change of db
  final StreamController<List<Measurement>> _streamController =
    StreamController<List<Measurement>>.broadcast();

  /// get broadcast stream to track change of db
  StreamController<List<Measurement>> get streamController => _streamController;

  /// check if measurement exists
  bool containsMeasurement(Measurement m) {
    final List<bool> isMeasurement = <bool>[
      for (final Measurement measurement in measurements)
        measurement.isIdentical(m)
    ];
    return isMeasurement.contains(true);
  }

  /// insert Measurements into box
  bool insertMeasurement(Measurement m) {
    final bool isContained = containsMeasurement(m);
    if (!isContained) {
      box.add(m);
      reinit();
    }
    return !isContained;
  }

  /// delete Measurements from box
  void deleteMeasurement(SortedMeasurement m) {
    box.delete(m.key);
    reinit();
  }

  /// delete all Measurements from box
  Future<void> deleteAllMeasurements() async {
    for (final SortedMeasurement m in sortedMeasurements) {
      await box.delete(m.key);
    }
    reinit();
  }

  /// re initialize database
  void reinit() {
    _measurements = null;
    _sortedMeasurements = null;
    _dailyAveragedMeasurements = null;
    _dailyAveragedGaussianMeasurements = null;
    _dailyAveragedInterpolatedMeasurements = null;
    _dailyAveragedExtrapolatedMeasurements = null;
    _gaussianInterpolatedMeasurements = null;
    _gaussianExtrapolatedMeasurements = null;

    // recalc all
    init();

    // fire stream
    fireStream();
    TraleNotifier().notify;
  }

  /// initialize database
  void init() {
    measurements;
    sortedMeasurements;
    dailyAveragedMeasurements;
    dailyAveragedGaussianMeasurements;
    dailyAveragedInterpolatedMeasurements;
    dailyAveragedExtrapolatedMeasurements;
    gaussianInterpolatedMeasurements;
    gaussianExtrapolatedMeasurements;
  }

  List<Measurement>? _measurements;
  /// get sorted measurements
  List<Measurement> get measurements => _measurements ??=
    box.values.toList()..sort(
      (Measurement a, Measurement b) => a.compareTo(b)
    );

  /// fire stream
  void fireStream() {
    streamController.add(measurements);
  }

  /// get mean measurements
  List<Measurement> averageMeasurements(List<Measurement> ms) {
    if (ms.isEmpty) {
      return ms;
    }

    final double meanWeight = ms.fold(
        0.0, (double sum, Measurement m) => sum + m.weight
    ) / ms.length;
    return <Measurement>[
      for (final Measurement m in ms)
        m.apply(weight: meanWeight)
    ];
  }

  List<SortedMeasurement>? _sortedMeasurements;
  /// get sorted measurements, key tuples
  List<SortedMeasurement> get sortedMeasurements => _sortedMeasurements ??=
    <SortedMeasurement>[
      for (final dynamic key in box.keys)
        SortedMeasurement(key: key, measurement: box.get(key)!)
    ]..sort(
      (SortedMeasurement a, SortedMeasurement b) => b.compareTo(a)
    );

  List<Measurement>? _dailyAveragedMeasurements;
  /// get sorted list of daily-averaged measurements
  List<Measurement> get dailyAveragedMeasurements  =>
    _dailyAveragedMeasurements ??= _calcDailyAveragedMeasurements();

  List<Measurement> _calcDailyAveragedMeasurements() {
    final List<Measurement> ms = measurements;
    if (ms.isEmpty) {
      return measurements;
    }
    final List<Measurement> dailyAverage = <Measurement>[];
    final List<double> dailyWeightAverage = <double>[];

    DateTime lastDate = DateTime(
      ms[0].date.year, ms[0].date.month, ms[0].date.day, _offsetInH,
    );
    for (int idx=0; idx < ms.length; idx++){
      final DateTime date = ms[idx].date;
      if (!date.sameDay(lastDate)) {
        dailyAverage.add(
          Measurement(
            weight: dailyWeightAverage.reduce(
                (double value, double element) => value + element
              ) / dailyWeightAverage.length,
            date: lastDate,
          )
        );

        // get new date and clear list
        dailyWeightAverage.clear();
        lastDate = DateTime(date.year, date.month, date.day, _offsetInH);
      }
      dailyWeightAverage.add(ms[idx].weight);
    }
    // add last element
    dailyAverage.add(Measurement(
      weight: dailyWeightAverage.reduce(
              (double value, double element) => value + element
      ) / dailyWeightAverage.length,
      date: lastDate,
    ));

    final double startWeight = dailyAverage.first.weight;
    final int startTime = dailyAverage.first.dateInMs;
    dailyAverage.insertAll(
        0,
        <Measurement>[
          for (int idx=-7; idx < 0; idx++)
            Measurement(
              weight: startWeight,
              date: DateTime.fromMillisecondsSinceEpoch(
                  startTime + idx * 24 * 3600 * 1000
              ),
              isMeasured: false,
            )
        ],
    );
    return dailyAverage;
  }

  List<Measurement>? _dailyAveragedGaussianMeasurements;
  /// get linearly interpolated and sorted list of daily-averaged measurements
  List<Measurement> get dailyAveragedGaussianMeasurements =>
      _dailyAveragedGaussianMeasurements ??=
          _calcDailyAveragedGaussianMeasurements();

  /// get linearly interpolated and sorted list of daily-averaged measurements
  List<Measurement> _calcDailyAveragedGaussianMeasurements() {
    final List<Measurement> ms = dailyAveragedMeasurements;
    if (ms.isEmpty) {
      return measurements;
    }

    /// add linear regression on last measurement to improve Gaussian
    /// interpolation
    final List<Measurement> msRegr = addLinearRegression(ms);

    return <Measurement>[
      for (final Measurement m in ms)
        InterpolFunc.gaussian.function(
          m.dateInMs, msRegr,
        ) as Measurement
    ];
  }

  List<Measurement>? _dailyAveragedInterpolatedMeasurements;
  /// get linearly interpolated and sorted list of daily-averaged measurements
  List<Measurement> get dailyAveragedInterpolatedMeasurements =>
    _dailyAveragedInterpolatedMeasurements ??=
      _calcDailyAveragedInterpolatedMeasurements();

  /// get linearly interpolated and sorted list of daily-averaged measurements
  List<Measurement> _calcDailyAveragedInterpolatedMeasurements() {
    final List<Measurement> ms = dailyAveragedMeasurements;
    if (ms.isEmpty) {
      return measurements;
    }
    final List<Measurement> msGauss = dailyAveragedGaussianMeasurements;
    final List<Measurement> dailyMeasurements = <Measurement>[];

    final int intervalInDays = ms.last.date.difference(ms.first.date).inDays;
    final DateTime dateStart = ms.first.date;

    for (int days = 0; days <= intervalInDays; days += 1) {
      DateTime date = dateStart.add(Duration(days: days));
      date = DateTime(date.year, date.month, date.day, _offsetInH);
      bool isDayInMeasurements = false;
      for (final Measurement m in ms) {
        if (date.sameDay(m.date)) {
          dailyMeasurements.add(
            Measurement(
              weight: m.weight,
              date: m.date,
              isMeasured: true,
            )
          );
          isDayInMeasurements = true;
          break;
        }
      }
      if (!isDayInMeasurements) {
        dailyMeasurements.add(
          InterpolFunc.linear.function(
            date.millisecondsSinceEpoch, msGauss,
          ) as Measurement
        );
      }
    }
    return dailyMeasurements;
  }

  List<Measurement>? _dailyAveragedExtrapolatedMeasurements;
  /// get linearly extrapolation based on gaussian interpolation
  List<Measurement> get dailyAveragedExtrapolatedMeasurements =>
    _dailyAveragedExtrapolatedMeasurements ??=
      _calcDailyAveragedExtrapolatedMeasurements();

  List<Measurement> _calcDailyAveragedExtrapolatedMeasurements() {
    final List<Measurement> ms = dailyAveragedInterpolatedMeasurements;
    if (ms.isEmpty) {
      return measurements;
    }
    final List<Measurement> msGaussian = gaussianInterpolatedMeasurements;
    final List<Measurement> msGaussianRegress = addLinearRegression(msGaussian);

    final List<Measurement> extrapolH = <Measurement>[];
    final List<Measurement> extrapolF = <Measurement>[];

    final DateTime dateStartH = ms.first.date.subtract(
        const Duration(days: _offsetInDays)
    );
    final DateTime dateStartF = ms.last.date;
    for (int days = 1; days - 1 <= _offsetInDays; days += 1) {
      DateTime dateF = dateStartF.add(Duration(days: days));
      DateTime dateH = dateStartH.add(Duration(days: days));
      dateF = DateTime(dateF.year, dateF.month, dateF.day, _offsetInH);
      dateH = DateTime(dateH.year, dateH.month, dateH.day, _offsetInH);
      extrapolF.add(
        (InterpolFunc.linear.function(
          dateF.millisecondsSinceEpoch, msGaussianRegress,
        ) as Measurement).apply(isMeasured: true),
      );
      extrapolH.add(
        (InterpolFunc.linear.function(
            dateH.millisecondsSinceEpoch, msGaussianRegress,
        ) as Measurement).apply(isMeasured: true),
      );
    }
    ms.addAll(extrapolF);
    ms.insertAll(0, extrapolH);
    return ms;
  }

  List<Measurement>? _gaussianExtrapolatedMeasurements;
  /// return daily averaged and linearly extrapolated measurements
  /// and smooth them with gaussian filter
  List<Measurement> get gaussianExtrapolatedMeasurements =>
    _gaussianExtrapolatedMeasurements ??= Interpolation(
    measures: dailyAveragedExtrapolatedMeasurements,
  ).interpolate(InterpolFunc.gaussian);

  List<Measurement>? _gaussianInterpolatedMeasurements;
  /// return daily averaged and linearly interpolated measurements
  /// and smooth them with gaussian filter
  List<Measurement> get gaussianInterpolatedMeasurements =>
    _gaussianInterpolatedMeasurements ??= Interpolation(
    measures: dailyAveragedInterpolatedMeasurements,
  ).interpolate(InterpolFunc.gaussian);

  /// get the extrapolated measurement at the time of last measurement
  Measurement get lastMeasurement => gaussianExtrapolatedMeasurements.lastWhere(
      (Measurement m) => (
        m.dateInMs - gaussianInterpolatedMeasurements.last.dateInMs
      ) < 12 * 3600 * 1000
    );

  /// get slope in unit
  double get finalSlope {
    // estimate weight at day after last measurement
    final Measurement mCurrent = lastMeasurement;
    final Measurement mLast = gaussianExtrapolatedMeasurements.last;
    return (
      mLast.weight - mCurrent.weight
    ) / (
      mLast.dateInMs - mCurrent.dateInMs
    );
  }

  /// duration between first and last measurement [days]
  int get durationMeasurements => dailyAveragedMeasurements.isNotEmpty
    ? dailyAveragedInterpolatedMeasurements.length
    : 0;

  /// get weight change [kg] within last N Days from last measurement
  double? deltaWeightLastNDays (int nDays) {
    if (durationMeasurements < nDays) {
      return null;
    }

    final List<Measurement> ms = gaussianInterpolatedMeasurements;
    return ms.last.weight - ms.elementAt(ms.length - 1 - nDays).weight;
  }

  /// get weight change [kg] within last month from last measurement
  double? get deltaWeightLastYear => deltaWeightLastNDays(365);

  /// get weight change [kg] within last month from last measurement
  double? get deltaWeightLastMonth => deltaWeightLastNDays(30);

  /// get weight change [kg] within last week from last measurement
  double? get deltaWeightLastWeek => deltaWeightLastNDays(7);

  /// get time of reaching target weight in kg
  Duration? timeOfTargetWeight(double? targetWeight) {
    if (targetWeight == null) {
      return null;
    }

    if (dailyAveragedMeasurements.length < 2) {
      return null;
    }

    final Measurement mLast = lastMeasurement;
    final double slope = finalSlope;

    // Crossing is in the past
    if (slope * (mLast.weight - targetWeight) >= 0) {
      return null;
    }

    // in ms from last measurement
    final int remainingTime = (
        (targetWeight - mLast.weight) / slope
    ).round();
    return Duration(milliseconds: remainingTime);

    // // change to last measurement
    // // time between passed since last measurement
    // final int passedTime =
    //   DateTime.now().millisecondsSinceEpoch - mLast.dateInMs;

    // return Duration(milliseconds: remainingTime - passedTime);
  }

  /// bmi at last measurement
  double? get bmi {
    final double? height = Preferences().userHeight;
    if (height == null || gaussianInterpolatedMeasurements.isEmpty) {
      return null;
    }
    return gaussianInterpolatedMeasurements.last.weight / (height * height);
  }

  /// get largest measurement
  Measurement? get maxInterpolated {
    if (measurements.isEmpty) {
      return null;
    }
    return dailyAveragedGaussianMeasurements.reduce(
      (Measurement current, Measurement next) =>
        current.weight > next.weight ? current : next
    );
  }

  /// get largest measurement
  Measurement? get max {
    if (measurements.isEmpty) {
      return null;
    }
    return measurements.reduce(
      (Measurement current, Measurement next) =>
        current.weight > next.weight ? current : next
    );
  }

  /// get lowest measurement
  Measurement? get minInterpolated {
    if (measurements.isEmpty) {
      return null;
    }
    return dailyAveragedGaussianMeasurements.reduce(
      (Measurement current, Measurement next) =>
        current.weight < next.weight ? current : next
    );
  }

  /// get lowest measurement
  Measurement? get min {
    if (measurements.isEmpty) {
      return null;
    }
    return measurements.reduce(
      (Measurement current, Measurement next) =>
        current.weight < next.weight ? current : next
    );
  }

  /// get list of all measurement strikes
  List<List<Measurement>>? get measurementStrikes {
    // todo: dailyAveragedMeasurements is based on the interpolation!
    // Thus, instead of dailyAveragedMeasurements the actual measurements should
    // be used!
    final List<Measurement> ms = dailyAveragedMeasurements;
    if (ms.isEmpty) {
      return null;
    }

    final List<List<Measurement>> strikes = <List<Measurement>>[];
    final List<Measurement> strike = <Measurement>[ms[0]];
    for (int i=1; i < ms.length; i++) {
      if (ms[i].date.difference(ms[i-1].date).inDays > 1) {
        // copy list to avoid reference issue
        strikes.add(List<Measurement>.of(strike));
        strike.clear();
      }
      strike.add(ms[i]);
    }
    return strikes;
  }

  /// get list of all longest measurement strike
  // todo: "return" statement is missing and measurementStrikes is errorous
  // todo: It should be streak NOT strike!!
  List<Measurement>? get longestMeasurementStrike {
    if (measurementStrikes == null) {
      return null;
    }
    final List<List<Measurement>> strikes = measurementStrikes!;

    // find longest, prefer newer sequences
    strikes.reduce(
      (List<Measurement> current, List<Measurement> next) =>
        current.length > next.length ? current : next
    );
    return null;
  }

  /// return string for export
  String get exportString {
    const String header = '# This file was created with trale.\n'
      '#Date weight[kg]\n';
    final String body = <String>[
      for (final Measurement m in measurements)
        m.exportString
    ].join('\n');
    return header + body;
  }

  /// parse list of measurements from export string
  List<Measurement> parseString({required String exportString}) {
    final List<String> lines = const LineSplitter().convert(exportString);
    lines.removeWhere((String element) => element.startsWith('#'));

    return <Measurement>[
      for (final String line in lines)
        Measurement.fromString(exportString: line)
    ];
  }

  /// offset of day in hours
  static const int _offsetInH = 12;
  /// offset of day in interpolation
  static const int _offsetInDays = 7;
}