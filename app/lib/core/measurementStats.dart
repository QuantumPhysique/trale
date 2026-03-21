// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:ml_linalg/linalg.dart';
import 'package:ml_linalg/vector.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/measurementInterpolation.dart';
import 'package:trale/core/preferences.dart';
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

  /// re initialize database
  void reinit() {
    _streakList = null;
    _frequencyLastWeek = null;
    _frequencyLastMonth = null;
    _frequencyLastYear = null;
    _deltaWeightLastWeek = null;
    _deltaWeightLastMonth = null;
    _deltaWeightLastYear = null;
    // recalculate all vectors
    init();
  }

  /// initialize database
  void init() {}

  /// return difference of smoothed weights over last [nDays]
  double? deltaWeightLastNDays(int nDays, {DateTime? from}) {
    final DateTime fromDate = from ?? DateTime.now();
    final double? weightFrom = ip.interpolationForDay(fromDate);
    final double? weightTo = ip.interpolationForDay(
      fromDate.subtract(Duration(days: nDays)),
    );
    if (weightFrom == null || weightTo == null) {
      return null;
    }
    return weightFrom - weightTo;
  }

  /// get max weight
  double? get maxWeight => ip.measured().measurements.max();

  /// get min weight
  double? get minWeight => ip.measured().measurements.min();

  /// get mean weight
  double? get meanWeight => ip.measured().measurements.mean();

  /// get current BMI
  double? currentBMI(BuildContext context) {
    final TraleNotifier notifier = Provider.of<TraleNotifier>(
      context,
      listen: false,
    );
    if (notifier.userHeight == null) {
      return null;
    }
    return ip.measured().measurements.last /
        (notifier.userHeight! * notifier.userHeight! * 0.0001);
  }

  /// get total change in weight
  double? get deltaWeight =>
      maxWeight == null ? null : maxWeight! - ip.measured().measurements.last;

  /// the start of the first measurement until now
  /// get time of records
  Duration get deltaTime => DateTime.now().difference(db.firstDate);

  /// get number of measurements
  int get nMeasurements => db.nMeasurements;

  /// get current streak
  Duration get currentStreak => db.lastDate.sameDay(DateTime.now())
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
    for (final double isMS in ip.isMeasurement) {
      if (isMS.round() == 1) {
        streak++;
      } else if (streak > 0) {
        streakList.add(streak);
        streak = 0;
      }
    }
    return Vector.fromList(streakList);
  }

  /// get frequency of taking measurements
  double _getFrequency(int nDays) {
    final int startingTime = DateTime.now()
        .subtract(Duration(days: nDays))
        .millisecondsSinceEpoch;

    /// count number of measurements in the last n days
    int numberOfMeasurements = 0;
    for (final double time in ip.measured().times.toList()) {
      if (time >= startingTime) {
        numberOfMeasurements += 1;
      }
    }
    // to ensure that the time before the very first measurement is not
    // biasing the result, use as duration min of nDays or days since first m
    if (deltaTime.inDays < nDays) {
      return numberOfMeasurements / deltaTime.inDays;
    } else {
      return numberOfMeasurements / nDays;
    }
  }

  double? _frequencyLastWeek;

  /// get frequency of taking measurements (last week)
  double? get frequencyLastWeek => _frequencyLastWeek ??= _getFrequency(7);

  double? _frequencyLastMonth;

  /// get frequency of taking measurements (last month)
  double? get frequencyLastMonth => _frequencyLastMonth ??= _getFrequency(30);

  double? _frequencyLastYear;

  /// get frequency of taking measurements (last year)
  double? get frequencyLastYear => _frequencyLastYear ??= _getFrequency(365);

  /// get frequency of taking measurements (in total)
  double? get frequencyInTotal => nMeasurements / (deltaTime.inDays + 1);

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
  Duration? timeOfTargetWeight(
    double? targetWeight,
    bool loose, {
    DateTime? from,
  }) {
    if ((targetWeight == null) || (db.nMeasurements < 2)) {
      return null;
    }

    DateTime fromDate = from ?? DateTime.now();
    double? interpolationDate = ip.interpolationForDay(fromDate);
    // if no interpolation value for fromDate, no prediction
    if (interpolationDate == null) {
      return null;
    }
    // Check if target weight is already completed
    if (loose
        ? targetWeight > interpolationDate
        : targetWeight <= interpolationDate) {
      return const Duration(days: -1);
    }

    final double slope = ip.finalSlope;
    // Crossing is in the past
    if (slope * (interpolationDate - targetWeight) >= 0) {
      return null;
    }

    // if slope is less then 5 g/day, return null
    // slope is given in kg/day
    if (slope.abs() < 0.005) {
      return null;
    }
    // in ms from last measurement
    final int remainingTime = ((targetWeight - interpolationDate) / slope)
        .round();

    // if remaining time is rounded to 0, return -1
    if (remainingTime == 0) {
      return const Duration(days: -1);
    }

    return Duration(days: remainingTime);
  }

  /// Return the target-weight reference value [kg] for a given [day],
  /// following the "Z"-shaped line used in the line chart.
  ///
  /// * Before [setDate]: constant at [targetWeight].
  /// * Between [setDate] and [targetDate]: linear from [setWeight] to
  ///   [targetWeight].
  /// * After [targetDate]: constant at [targetWeight].
  ///
  /// Returns null when the target-weight feature is disabled or no target
  /// weight is set. When no target date is configured, returns a constant
  /// [targetWeight] for every day.
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
  ///
  /// Positive means above the reference, negative means below.
  /// Returns null when either value is unavailable.
  double? differenceAtDay(DateTime day) {
    final double? interpolation = ip.interpolationForDay(day);
    final double? reference = referenceAtDay(day);
    if (interpolation == null || reference == null) {
      return null;
    }
    return interpolation - reference;
  }
}
