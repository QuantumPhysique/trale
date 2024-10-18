import 'package:ml_linalg/linalg.dart';
import 'package:ml_linalg/vector.dart';

import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/measurementInterpolation.dart';


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
  double? get deltaWeight => maxWeight! - ip.weights_measured.last!;

  /// the start of the first measurement until now
  /// get time of records
  Duration get deltaTime => DateTime.now().difference(db.firstDate);

  /// get number of measurements
  int get nMeasurements => ip.NMeasurements;

  /// get current streak
  Duration get currentStreak => Duration(days: streakList.last.round());

  /// get max streak
  Duration get maxStreak => Duration(days: streakList.max().round());

  Vector? _streakList;
  /// get list of all streaks
  Vector get streakList => _streakList ??= _estimateStreakList();
  Vector _estimateStreakList() {
    int streak = 0;
    final List<int> streakList = <int>[];
    for (final bool isMS
         in ip.isMeasurement.toList().map((double e) => e.round() == 1)
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
  /// get frequency of taking measurements (last week)
  double? get frequencyLastWeek => _getFrequency(7);
  /// get frequency of taking measurements (last month)
  double? get frequencyLastMonth => _getFrequency(30);
  /// get frequency of taking measurements (last year)
  double? get frequencyLastYear => _getFrequency(365);
  /// get frequency of taking measurements (in total)
  double? get frequencyInTotal => nMeasurements / deltaTime.inDays;

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

    // Check if target weight is already completed
    if (targetWeight > ip.weightsDisplay[ip.idxLastDisplay]){
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

    return Duration(days: remainingTime);
  }

}
