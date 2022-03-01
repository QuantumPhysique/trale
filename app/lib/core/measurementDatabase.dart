import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:trale/core/interpolation.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/main.dart';


/// check if two integers corresponds to same day
bool sameDay(DateTime? d1, DateTime? d2) {
  if (d1 == null || d2 == null)
    return false;
  return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}

/// check if day is in list
bool dayInMeasurements(DateTime d1, List<Measurement> measurements) =>
    <bool>[
      for (final Measurement m in measurements)
        sameDay(d1, m.date)
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

  /// insert Measurements into box
  void insertMeasurement(Measurement m) {
    box.add(m);
    reinit();
  }

  /// delete Measurements into box
  void deleteMeasurement(SortedMeasurement m) {
    box.delete(m.key);
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
    measurements;
    sortedMeasurements;
    dailyAveragedMeasurements;
    dailyAveragedGaussianMeasurements;
    dailyAveragedInterpolatedMeasurements;
    dailyAveragedExtrapolatedMeasurements;
    gaussianInterpolatedMeasurements;
    gaussianExtrapolatedMeasurements;

    final TraleNotifier notifier = TraleNotifier();
    notifier.notify;
  }

  List<Measurement>? _measurements;
  /// get sorted measurements
  List<Measurement> get measurements => _measurements ??=
    box.values.toList()..sort(
      (Measurement a, Measurement b) => a.compareTo(b)
    );

  /// get mean measurements
  List<Measurement> averageMeasurements(List<Measurement> ms) {
    if (ms.isEmpty)
      return ms;

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
    if (ms.isEmpty)
      return measurements;
    final List<Measurement> dailyAverage = <Measurement>[];
    final List<double> dailyWeightAverage = <double>[];

    DateTime lastDate = DateTime(
      ms[0].date.year, ms[0].date.month, ms[0].date.day, _offsetInH,
    );
    for (int idx=0; idx < ms.length; idx++){
      final DateTime date = ms[idx].date;
      if (!sameDay(date, lastDate)) {
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
    return dailyAverage;
  }

  List<Measurement>? _dailyAveragedGaussianMeasurements;
  /// get linearly interpolated and sorted list of daily-averaged measurements
  List<Measurement> get dailyAveragedGaussianMeasurements =>
      _dailyAveragedGaussianMeasurements ??=
          _calcDailyAveragedGaussianMeasurements();

  /// get linearly interpolated and sorted list of daily-averaged measurements
  List<Measurement> _calcDailyAveragedGaussianMeasurements() => <Measurement>[
      for (final Measurement m in dailyAveragedMeasurements)
        InterpolFunc.gaussian.function(
          m.dateInMs, dailyAveragedMeasurements,
        ) as Measurement
    ];

  List<Measurement>? _dailyAveragedInterpolatedMeasurements;
  /// get linearly interpolated and sorted list of daily-averaged measurements
  List<Measurement> get dailyAveragedInterpolatedMeasurements =>
    _dailyAveragedInterpolatedMeasurements ??=
      _calcDailyAveragedInterpolatedMeasurements();

  /// get linearly interpolated and sorted list of daily-averaged measurements
  List<Measurement> _calcDailyAveragedInterpolatedMeasurements() {
    final List<Measurement> ms = dailyAveragedMeasurements;
    final List<Measurement> msGauss = dailyAveragedGaussianMeasurements;
    final List<Measurement> dailyMeasurements = <Measurement>[];

    final int intervalInDays = ms.last.date.difference(ms.first.date).inDays;
    final DateTime dateStart = ms.first.date;

    for (int days = 0; days <= intervalInDays; days += 1) {
      DateTime date = dateStart.add(Duration(days: days));
      date = DateTime(date.year, date.month, date.day, _offsetInH);
      bool isDayInMeasurements = false;
      for (final Measurement m in ms) {
        if (sameDay(date, m.date)) {
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
    final List<Measurement> msGaussian = gaussianInterpolatedMeasurements;

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
          dateF.millisecondsSinceEpoch, msGaussian,
        ) as Measurement).apply(isMeasured: true),
      );
      extrapolH.add(
        (InterpolFunc.linear.function(
            dateH.millisecondsSinceEpoch, msGaussian,
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

  /// get slope in unit
  double get finalSlope {
    final List<Measurement> measurementsInterpol =
      gaussianInterpolatedMeasurements;

    final Measurement mLast = measurementsInterpol.last;
    final Measurement m2Last = measurementsInterpol.elementAt(
      measurementsInterpol.length - 2
    );

    return (
      mLast.weight - m2Last.weight
    ) / (
      mLast.dateInMs - m2Last.dateInMs
    );
  }

  /// duration between first and last measurement [days]
  int get durationMeasurements => dailyAveragedMeasurements.isNotEmpty
    ? dailyAveragedInterpolatedMeasurements.length
    : 0;

  /// get weight change [kg] within last N Days from last measurement
  double? deltaWeightLastNDays (int nDays) {
    if (durationMeasurements < nDays)
      return null;

    final List<Measurement> ms = dailyAveragedInterpolatedMeasurements;
    return ms.last.weight - ms.elementAt(ms.length - nDays).weight;
  }

  /// get weight change [kg] within last month from last measurement
  double? get deltaWeightLastYear => deltaWeightLastNDays(365);

  /// get weight change [kg] within last month from last measurement
  double? get deltaWeightLastMonth => deltaWeightLastNDays(30);

  /// get weight change [kg] within last week from last measurement
  double? get deltaWeightLastWeek => deltaWeightLastNDays(7);

  /// get time of reaching target weight in kg
  Duration? timeOfTargetWeight(double? targetWeight) {
    if (targetWeight == null)
      return null;

    if (dailyAveragedMeasurements.length < 2)
      return null;

    final Measurement mLast = gaussianInterpolatedMeasurements.last;
    final double slope = finalSlope;

    // Crossing is in the past
    if (slope * (mLast.weight - targetWeight) >= 0)
      return null;

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
    if (height == null || gaussianInterpolatedMeasurements.isEmpty)
      return null;
    return gaussianInterpolatedMeasurements.last.weight / (height * height);
  }

  /// offset of day in hours
  static const int _offsetInH = 12;
  /// offset of day in interpolation
  static const int _offsetInDays = 7;
}