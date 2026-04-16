import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ml_linalg/linalg.dart';
import 'package:ml_linalg/vector.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/constants.dart' as constants;
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurement_database.dart';
import 'package:trale/core/measurement_interpolation.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/stats_range.dart';
import 'package:trale/core/trale_notifier.dart';

/// class providing an API to handle interpolation of measurements
class MeasurementStats {
  /// singleton constructor
  factory MeasurementStats() => _instance;

  /// single instance creation
  MeasurementStats._internal() : _testDb = null, _testIp = null;

  /// Constructor for testing with injected dependencies.
  @visibleForTesting
  MeasurementStats.forTesting({
    MeasurementDatabaseBaseclass? db,
    MeasurementInterpolation? ip,
  }) : _testDb = db,
       _testIp = ip;

  final MeasurementDatabaseBaseclass? _testDb;
  final MeasurementInterpolation? _testIp;

  /// singleton instance
  static MeasurementStats _instance = MeasurementStats._internal();

  /// Replace the singleton instance for testing.
  @visibleForTesting
  static set testInstance(MeasurementStats instance) => _instance = instance;

  /// Reset the singleton instance after testing.
  @visibleForTesting
  static void resetInstance() {
    _instance = MeasurementStats._internal();
  }

  /// get measurementbase
  MeasurementDatabaseBaseclass get db => _testDb ?? MeasurementDatabase();

  /// get interpolation
  MeasurementInterpolation get ip => _testIp ?? MeasurementInterpolation();

  /// get stats range setting
  StatsRange get _statsRange => Preferences().statsRange;

  /// get dates for stats range
  ({DateTime? from, DateTime? to}) get _dates => _statsRange.dates;

  /// cached measurements in stats range
  Vector? _measurements;

  /// get measurements in stats range
  Vector get measurements => _measurements ??= ip
      .measured(from: _dates.from, to: _dates.to)
      .measurements;

  /// cached diff in stats range
  Vector? _diff;

  /// get measurements in stats range
  Vector get diff =>
      _diff ??= ip.measuredDiff(from: _dates.from, to: _dates.to).difference;

  /// cached weights in stats range
  Vector? _weights;

  /// get weights in stats range
  Vector get weights =>
      _weights ??= ip.weightsInRange(from: _dates.from, to: _dates.to);

  /// get toDate, default to now if null
  DateTime get toDate => _dates.to ?? DateTime.now();

  /// get fromDate, default to first measurement date if null
  DateTime get fromDate => _dates.from ?? db.firstDate;

  /// get number of measurements in stats range
  int get nMeasurements => measurements.length;

  /// Content-based hash combining date range and interpolation state.
  int get hashCode => Object.hash(toDate, fromDate, ip.hashCode);

  /// re initialize database
  void reinit() {
    _globalStreakList = null;
    _deltaWeightLastWeek = null;
    _deltaWeightLastMonth = null;
    _deltaWeightLastYear = null;
    _measurements = null;
    _weights = null;
    _diff = null;

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
  double? get maxWeight => measurements.max();

  /// get max interpolated weight in stats range
  double? get maxInterpolatedWeight => weights.max();

  /// get min weight
  double? get minWeight => measurements.min();

  /// get min interpolated weight in stats range
  double? get minInterpolatedWeight => weights.min();

  /// get max measured weight with date in stats range
  ({double? weight, DateTime? date}) get maxWeightDate {
    if (nMeasurements == 0) {
      return (weight: null, date: null);
    }
    final ({Vector times, Vector measurements}) data = ip.measured(
      from: _dates.from,
      to: _dates.to,
    );
    final int maxIndex = data.measurements.argmax();
    return (
      weight: data.measurements[maxIndex],
      date: DateTime.fromMillisecondsSinceEpoch(data.times[maxIndex].round()),
    );
  }

  /// get min measured weight with date in stats range
  ({double? weight, DateTime? date}) get minWeightDate {
    if (nMeasurements == 0) {
      return (weight: null, date: null);
    }
    final ({Vector times, Vector measurements}) data = ip.measured(
      from: _dates.from,
      to: _dates.to,
    );
    final int minIndex = data.measurements.argmin();
    return (
      weight: data.measurements[minIndex],
      date: DateTime.fromMillisecondsSinceEpoch(data.times[minIndex].round()),
    );
  }

  /// get max interpolated weight with date in stats range
  ({double? weight, DateTime? date}) get maxInterpolatedWeightDate {
    if (nMeasurements == 0) {
      return (weight: null, date: null);
    }
    final Vector dates = ip.timesInRange(from: _dates.from, to: _dates.to);
    final int maxIndex = weights.argmax();
    return (
      weight: weights[maxIndex],
      date: DateTime.fromMillisecondsSinceEpoch(dates[maxIndex].round()),
    );
  }

  /// get min interpolated weight with date in stats range
  ({double? weight, DateTime? date}) get minInterpolatedWeightDate {
    if (nMeasurements == 0) {
      return (weight: null, date: null);
    }
    final Vector dates = ip.timesInRange(from: _dates.from, to: _dates.to);
    final int minIndex = weights.argmin();
    return (
      weight: weights[minIndex],
      date: DateTime.fromMillisecondsSinceEpoch(dates[minIndex].round()),
    );
  }

  /// get mean weight
  double? get meanWeight => measurements.mean();

  /// get mean interpolated weight in stats range
  double? get meanInterpolatedWeight => weights.mean();

  /// get median weight
  double? get medianWeight => measurements.median();

  /// get median weight
  double? get medianInterpolatedWeight => weights.median();

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

  /// get frequency of taking measurements (in stats range) [/week]
  double? get frequency => 7 * nMeasurements / (deltaTime.inDays + 1);

  ////////////////////////////////////////////////////////////////////
  // Global stats (always computed over the full measurement range) //
  ////////////////////////////////////////////////////////////////////

  /// get total number of measurements (all time)
  int get globalNMeasurements => db.nMeasurements;

  /// the start of the first measurement until now (all time)
  Duration get globalDeltaTime => DateTime.now().difference(db.firstDate);

  Vector? _globalStreakList;

  /// get list of all streaks (all time)
  Vector get globalStreakList => _globalStreakList ??= _estimateStreakList();

  /// get current streak (all time)
  Duration get globalCurrentStreak => ip.hasMeasurementOnDay(DateTime.now())
      ? Duration(days: globalStreakList.last.round())
      : Duration.zero;

  /// get max streak (all time)
  Duration get globalMaxStreak =>
      Duration(days: globalStreakList.max().round());

  /// get frequency of taking measurements (all time) [/week]
  double? get globalFrequency =>
      7 * globalNMeasurements / (globalDeltaTime.inDays + 1);

  /// get global max weight with date
  ({double? weight, DateTime? date}) get globalMaxWeightDate {
    if (db.nMeasurements == 0) {
      return (weight: null, date: null);
    }
    Measurement currentMax = db.measurements.first;
    for (final Measurement m in db.measurements) {
      if (m.weight > currentMax.weight) {
        currentMax = m;
      }
    }
    return (weight: currentMax.weight, date: currentMax.date);
  }

  /// get global min weight with date
  ({double? weight, DateTime? date}) get globalMinWeightDate {
    if (db.nMeasurements == 0) {
      return (weight: null, date: null);
    }
    Measurement currentMin = db.measurements.first;
    for (final Measurement m in db.measurements) {
      if (m.weight <= currentMin.weight) {
        currentMin = m;
      }
    }
    return (weight: currentMin.weight, date: currentMin.date);
  }

  /// get global interpolated max weight with date
  ({double? weight, DateTime? date}) get globalMaxInterpolatedWeightDate {
    if (db.nMeasurements == 0) {
      return (weight: null, date: null);
    }
    final Vector weights = ip.weightsInRange(
      from: db.firstDate,
      to: DateTime.now(),
    );
    final Vector dates = ip.timesInRange(
      from: db.firstDate,
      to: DateTime.now(),
    );
    // get where weights is max
    final int maxIndex = weights.argmax();
    return (
      weight: weights[maxIndex],
      date: DateTime.fromMillisecondsSinceEpoch(dates[maxIndex].round()),
    );
  }

  /// get global interpolated min weight with date
  ({double? weight, DateTime? date}) get globalMinInterpolatedWeightDate {
    if (db.nMeasurements == 0) {
      return (weight: null, date: null);
    }
    final Vector weights = ip.weightsInRange(
      from: db.firstDate,
      to: DateTime.now(),
    );
    final Vector dates = ip.timesInRange(
      from: db.firstDate,
      to: DateTime.now(),
    );
    // get where weights is min
    final int minIndex = weights.argmin();
    return (
      weight: weights[minIndex],
      date: DateTime.fromMillisecondsSinceEpoch(dates[minIndex].round()),
    );
  }

  // ---- Shared helpers ----

  /// Estimate streak list for a given date range.
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

  /// get daily calorie deficit based on final slope [kcal/day]
  /// give in precision of 10 kcal/day
  int get dailyDeficit =>
      (ip.slopeAtDay(toDate) * constants.kcalPerKg / 10).round() * 10;

  /// get monthly change in weight [kg/month]
  double get monthlyChange => ip.slopeAtDay(toDate) * 30;

  /// get interpolated weight today [kg]
  double? get weightToday => ip.interpolationForDay(toDate);

  /// get forecast weight in n days [kg], extrapolated from today's slope
  double? weightInNDays(int nDays) {
    final double? today = weightToday;
    if (today == null) {
      return null;
    }
    return today + ip.slopeAtDay(toDate) * nDays;
  }

  /// get forecast weight in 1 week [kg], extrapolated from today's slope
  double? get weightInOneWeek => weightInNDays(7);

  /// get forecast weight in 1 month [kg], extrapolated from today's slope
  double? get weightInOneMonth => weightInNDays(30);

  /// get standard deviation from interpolation
  double? stdLastNDays(int nDays) {
    final Vector diff = ip
        .measuredDiff(
          from: toDate.subtract(Duration(days: nDays)),
          to: toDate,
        )
        .difference;
    if (diff.isEmpty) {
      return null;
    }
    return sqrt(diff.pow(2).mean());
  }

  /// get standard deviation from interpolation in last month
  double? get stdLastMonth => stdLastNDays(30);

  /// get standard deviation from interpolation in last year
  double? get stdLastYear => stdLastNDays(365);

  /// get standard deviation from interpolation in stats range
  double? get std {
    final Vector diff = this.diff;
    if (diff.isEmpty) {
      return null;
    }
    return sqrt(diff.pow(2).mean());
  }
}

/// add extension to Vector for standard deviation
extension VectorStats on Vector {
  /// get index of max value in vector
  int argmax() {
    int maxIndex = 0;
    for (int i = 1; i < length; i++) {
      if (this[i] > this[maxIndex]) {
        maxIndex = i;
      }
    }
    return maxIndex;
  }

  /// get index of min value in vector
  int argmin() {
    int minIndex = 0;
    for (int i = 1; i < length; i++) {
      if (this[i] <= this[minIndex]) {
        minIndex = i;
      }
    }
    return minIndex;
  }
}
