import 'package:flutter/material.dart';
import 'package:ml_linalg/linalg.dart';
import 'package:ml_linalg/vector.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/measurementInterpolation.dart';
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


  /// return difference of Gaussian smoothed weights
  double? deltaWeightLastNDays (int nDays) {
    if (ip.measuredTimeSpan < nDays) {
      return null;
    }
    return ip.weightsGaussianExtrapol[ip.idxLast] -
    ip.weightsGaussianExtrapol[ip.idxLast - nDays];
  }

  /// get max weight
  double? get maxWeight => ip.weights_measured.max();

  /// get min weight
  double? get minWeight => ip.weights_measured.min();

  /// get min weight
  double? get meanWeight => ip.weights_measured.mean();

  /// get current BMI
  double? currentBMI(BuildContext context){
    final TraleNotifier notifier =
        Provider.of<TraleNotifier>(context, listen: false);
    if (notifier.userHeight == null) {
      return null;
    }
    return ip.weights_measured.last /
        (notifier.userHeight! * notifier.userHeight! * 0.0001);
  }

  /// get total change in weight
  double? get deltaWeight => maxWeight == null ?
    null : maxWeight! - ip.weights_measured.last;

  /// the start of the first measurement until now
  /// get time of records
  Duration get deltaTime => DateTime.now().difference(db.firstDate);

  /// get number of measurements
  int get nMeasurements => ip.NMeasurements;

  /// get current streak
  Duration get currentStreak =>
    db.lastDate.sameDay(DateTime.now())
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
    final int startingTime = DateTime.now().subtract(
        Duration(days: nDays)).millisecondsSinceEpoch;
    /// count number of measurements in the last n days
    int numberOfMeasurements = 0;
    for (final double time in ip.times_measured.toList()) {
      if(time >= startingTime) {
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
  double? get deltaWeightLastYear => _deltaWeightLastYear ??= deltaWeightLastNDays(365);

  double? _deltaWeightLastMonth;
  /// get weight change [kg] within last month from last measurement
  double? get deltaWeightLastMonth => _deltaWeightLastMonth ??= deltaWeightLastNDays(30);

  double? _deltaWeightLastWeek;
  /// get weight change [kg] within last week from last measurement
  double? get deltaWeightLastWeek => _deltaWeightLastWeek ??= deltaWeightLastNDays(7);

  /// get time of reaching target weight in kg
  Duration? timeOfTargetWeight(double? targetWeight, bool loose) {
    if ((targetWeight == null) || (db.nMeasurements < 2)){
      return null;
    }

    // Check if target weight is already completed
    if (
      loose
        ? targetWeight > ip.weightsDisplay[ip.idxLastDisplay]
        : targetWeight <= ip.weightsDisplay[ip.idxLastDisplay]
    ){
      return const Duration(days: -1);
    }

    final double slope = ip.finalSlope;
    // Crossing is in the past
    if (slope * (ip.weightsDisplay[ip.idxLastDisplay] - targetWeight) >= 0) {
      return null;
    }

    // in ms from last measurement
    final int remainingTime = (
        (targetWeight - ip.weightsDisplay[ip.idxLastDisplay]) / slope
    ).round();

    // if remaining time is rounded to 0, return -1
    if (remainingTime == 0) {
      return const Duration(days: -1);
    }

    return Duration(days: remainingTime);
  }

}
