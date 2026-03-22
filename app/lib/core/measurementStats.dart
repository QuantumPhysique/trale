// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:ml_linalg/linalg.dart';
import 'package:ml_linalg/vector.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/measurementInterpolation.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/stats_range.dart';
import 'package:trale/core/traleNotifier.dart';

/// class providing an API to handle interpolation of measurements
class MeasurementStats {
  /// singleton constructor
  factory MeasurementStats() => _instance;

  /// single instance creation
  MeasurementStats._internal();

  /// singleton instance
  static final MeasurementStats _instance = MeasurementStats._internal();

  /// get measurements
  MeasurementDatabase get db => MeasurementDatabase();

  /// get interpolation
  MeasurementInterpolation get ip => MeasurementInterpolation();

  /// get stats range setting
  StatsRange get _statsRange => Preferences().statsRange;

  /// get dates for stats range
  ({DateTime? from, DateTime? to}) get _dates => _statsRange.dates;

  /// get measurements in stats range
  Vector get _measurements =>
      ip.measured(from: _dates.from, to: _dates.to).measurements;

  /// get weights in stats range
  Vector get _weights =>
      ip.measurementsInRange(from: _dates.from, to: _dates.to);

  /// get toDate, default to now if null
  DateTime get toDate => _dates.to ?? DateTime.now();

  /// get fromDate, default to first measurement date if null
  DateTime get fromDate => _dates.from ?? db.firstDate;

  /// get number of measurements in stats range
  int get nMeasurements => _measurements.length;

  /// Content-based hash combining date range and interpolation state.
  int get hashCode => Object.hash(toDate, fromDate, ip.hashCode);

  /// re initialize database
  void reinit() {
    _streakList = null;
    _deltaWeightLastWeek = null;
    _deltaWeightLastMonth = null;
    _deltaWeightLastYear = null;
    // recalculate all vectors
    init();
  }

  /// initialize database
  void init() {}

  /// return difference of smoothed weights over last [nDays]
  double? deltaWeightLastNDays(int nDays) {
    final double? weight = ip.interpolationForDay(toDate);
    final double? weightLastN = ip.interpolationForDay(
      toDate.subtract(Duration(days: nDays)),
    );
    if (weight == null || weightLastN == null) {
      return null;
    }
    return weight - weightLastN;
  }

  /// get max weight
  double? get maxWeight => _measurements.max();

  /// get max interpolated weight in stats range
  double? get maxInterpolatedWeight => _weights.max();

  /// get min weight
  double? get minWeight => _measurements.min();

  /// get min interpolated weight in stats range
  double? get minInterpolatedWeight => _weights.min();

  /// get mean weight
  double? get meanWeight => _measurements.mean();

  /// get mean interpolated weight in stats range
  double? get meanInterpolatedWeight => _weights.mean();

  /// get current BMI
  double? currentBMI(BuildContext context) {
    final TraleNotifier notifier = Provider.of<TraleNotifier>(
      context,
      listen: false,
    );
    if (notifier.userHeight == null) {
      return null;
    }
    final double? weight = ip.interpolationForDay(toDate);
    if (weight == null) {
      return null;
    }
    return weight / (notifier.userHeight! * notifier.userHeight! * 0.0001);
  }

  /// get total change in weight
  double? get deltaWeight {
    final double? maxWeight = maxInterpolatedWeight;
    final double? weight = ip.interpolationForDay(toDate);
    if (weight == null || maxWeight == null) {
      return null;
    }
    return maxWeight - weight;
  }

  /// the start of the first measurement until now
  /// get time of records
  Duration get deltaTime => toDate.difference(fromDate);

  /// get current streak
  Duration get currentStreak => ip.hasMeasurementOnDay(toDate)
      ? Duration(days: streakList.last.round())
      : Duration.zero;

  /// get max streak
  Duration get maxStreak => Duration(days: streakList.max().round());

  Vector? _streakList;

  /// get list of all streaks
  Vector get streakList => _streakList ??= _estimateStreakList();
  Vector _estimateStreakList() {
    int streak = 0;
    final List<int> streakList = <int>[0]; // catch for no measurements
    for (final double isMS in ip.isMeasurementInRange(
      from: fromDate,
      to: toDate,
    )) {
      if (isMS.round() == 1) {
        streak++;
      } else if (streak > 0) {
        streakList.add(streak);
        streak = 0;
      }
    }
    return Vector.fromList(streakList);
  }

  /// get frequency of taking measurements (in total) [/week]
  double? get frequency => 7 * nMeasurements / (deltaTime.inDays + 1);

  double? _deltaWeightLastYear;

  /// get weight change [kg] within last month from last measurement
  double? get deltaWeightLastYear =>
      _deltaWeightLastYear ??= deltaWeightLastNDays(365);

  double? _deltaWeightLastMonth;

  /// get weight change [kg] within last month from last measurement
  double? get deltaWeightLastMonth =>
      _deltaWeightLastMonth ??= deltaWeightLastNDays(30);

  double? _deltaWeightLastWeek;

  /// get weight change [kg] within last week from last measurement
  double? get deltaWeightLastWeek =>
      _deltaWeightLastWeek ??= deltaWeightLastNDays(7);

  /// get time of reaching target weight in kg
  Duration? timeOfTargetWeight(double? targetWeight, bool loose) {
    if ((targetWeight == null) || (db.nMeasurements < 2)) {
      return null;
    }

    final double? weight = ip.interpolationForDay(toDate);
    // if no interpolation value for fromDate, no prediction
    if (weight == null) {
      return null;
    }
    // Check if target weight is already completed
    if (loose ? targetWeight > weight : targetWeight <= weight) {
      return const Duration(days: -1);
    }

    final double slope = ip.slopeAtDay(toDate);
    // Crossing is in the past
    if (slope * (weight - targetWeight) >= 0) {
      return null;
    }

    // if slope is less then 5 g/day, return null
    // slope is given in kg/day
    if (slope.abs() < 0.005) {
      return null;
    }
    // in ms from last measurement
    final int remainingTime = ((targetWeight - weight) / slope).round();

    // if remaining time is rounded to 0, return -1
    if (remainingTime == 0) {
      return const Duration(days: -1);
    }

    return Duration(days: remainingTime);
  }

  /// Return the target-weight reference value [kg] for a given day
  ///
  /// * Before [setDate]: constant at [targetWeight].
  /// * Between [setDate] and [targetDate]: linear from [setWeight] to
  ///   [targetWeight].
  /// * After [targetDate]: constant at [targetWeight].
  double? referenceAtDay(DateTime day) {
    final Preferences prefs = Preferences();
    if (!prefs.targetWeightEnabled) {
      return null;
    }

    final double? targetWeight = prefs.userTargetWeight;
    if (targetWeight == null) {
      return null;
    }

    final DateTime? targetDate = prefs.userTargetWeightDate;
    if (targetDate == null) {
      return targetWeight;
    }

    final TraleNotifier notifier = TraleNotifier();
    final DateTime? setDate = notifier.userTargetWeightSetDate;
    final double? setWeight = notifier.userTargetWeightSetWeight;
    if (setDate == null || setWeight == null) {
      return targetWeight;
    }

    final DateTime d = DateTime(day.year, day.month, day.day);
    final DateTime sd = DateTime(setDate.year, setDate.month, setDate.day);
    final DateTime td = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );

    // Before setDate or after targetDate -> constant at targetWeight
    if (d.compareTo(sd) <= 0 || d.compareTo(td) >= 0) {
      return targetWeight;
    }

    // Between setDate and targetDate -> linear interpolation
    final int totalDays = td.difference(sd).inDays;
    final int elapsedDays = d.difference(sd).inDays;
    return setWeight + (targetWeight - setWeight) * (elapsedDays / totalDays);
  }

  /// Return the difference between the interpolated weight and the
  /// target-weight reference for a given [day].
  double? differenceAtDay(DateTime day) {
    final double? interpolation = ip.interpolationForDay(day);
    final double? reference = referenceAtDay(day);
    if (interpolation == null || reference == null) {
      return null;
    }
    return interpolation - reference;
  }

  /// Return the difference between the interpolated weight and the
  double? get currentDifference => differenceAtDay(toDate);

  /// kcal per kg of weight change
  static const double _kcalPerKg = 7700;

  /// get daily calorie deficit based on final slope [kcal/day]
  /// give in precision of 10 kcal/day
  int get dailyDeficit =>
      (ip.slopeAtDay(toDate) * _kcalPerKg / 10).round() * 10;

  /// get monthly change in weight [kg/month]
  double get monthlyChange => ip.slopeAtDay(toDate) * 30;
}
