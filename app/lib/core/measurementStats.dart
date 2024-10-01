import 'dart:math' as math;

import 'package:ml_linalg/linalg.dart';
import 'package:ml_linalg/vector.dart';

import 'package:trale/core/interpolation.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/measurementInterpolation.dart';
import 'package:trale/core/preferences.dart';


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

  /// get total change in weight
  double? get deltaWeight => maxWeight! - minWeight!;

  /// todo: Define some kind of 'total duration' spanning from
  /// the start of the first measurement until now
  /// get time of records
  int get deltaTime => DateTime.now().difference(db.firstDate).inDays;

  /// get number of measurements
  int get nMeasurements => ip.NMeasurements;

  /// get current streak
  int get currentStreak => streakList.last.round();

  /// get max streak
  int get maxStreak => streakList.max().round();

  Vector? _streakList;
  /// get list of all streaks
  Vector get streakList => _streakList ??= _estimateStreakList();
  Vector _estimateStreakList() {
    int streak = 0;
    final List<int> streakList = <int>[];
    for (
    final bool isMS in ip.isMeasurement.toList().map((e) => e.round() == 1)
    ) {
      streak++;
      if (!isMS){
        streakList.add(streak - 1);
        streak = 0;
      }
    }
    return Vector.fromList(streakList);
  }

  /// get frequency of taking measurements
  double _getFrequency(int nDays) {
    /// todo: Add function returning the measurement frequency for a given
    /// duration (always starting from now?)
    double f = 2.1;
    return f;
  }
  /// get frequency of taking measurements (last week)
  double? get frequencyLastWeek => _getFrequency(7);
  /// get frequency of taking measurements (in total)
  double? get frequencyInTotal => this.nMeasurements / this.deltaTime;

  /// get weight change [kg] within last month from last measurement
  double? get deltaWeightLastYear => deltaWeightLastNDays(365);

  /// get weight change [kg] within last month from last measurement
  double? get deltaWeightLastMonth => deltaWeightLastNDays(30);

  /// get weight change [kg] within last week from last measurement
  double? get deltaWeightLastWeek => deltaWeightLastNDays(7);

  /// get time of reaching target weight in kg
  Duration? timeOfTargetWeight(double? targetWeight) {
    if ((targetWeight == null) || (db.nMeasurements < 2)){
      return null;
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

    final DateTime timeOfReachingTargetWeight =
      DateTime.fromMillisecondsSinceEpoch(
        ip.times_measured.last.round() + remainingTime
      );

    final int dayUntilReachingTargetWeight =
      timeOfReachingTargetWeight.day - DateTime.now().day;

    if (dayUntilReachingTargetWeight > 0){
      return Duration(days: dayUntilReachingTargetWeight);
    }
    return null;
  }

}
