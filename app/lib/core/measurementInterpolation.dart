import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:ml_linalg/linalg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trale/core/interpolation.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/preferences.dart';


extension SharedPrefsCache on SharedPreferences {
  Future<void> setJsonString(String key, Object value) =>
      setString(key, jsonEncode(value));
  List<dynamic>? getJsonList(String key) {
    final s = getString(key);
    return s == null ? null : jsonDecode(s) as List<dynamic>;
  }
}


/// Base class for measurement interpolation
class MeasurementInterpolationBaseclass {
  late final SharedPreferences _prefs;
  final Map<String, dynamic> _cache = {};

  MeasurementInterpolationBaseclass() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadAllCachedKeys();
    init();
  }

  void _loadAllCachedKeys() {
    final dt = _prefs.getJsonList('dateTimes');
    if (dt != null) {
      _cache['dateTimes'] =
          dt.map((e) => DateTime.parse(e as String)).toList();
    }
    void loadVector(String key) {
      final lst = _prefs.getJsonList(key);
      if (lst != null) {
        _cache[key] = Vector.fromList(
            lst.map((e) => (e as num).toDouble()).toList());
      }
    }
    void loadIntList(String key) {
      final lst = _prefs.getJsonList(key);
      if (lst != null) {
        _cache[key] = lst.map((e) => (e as num).toInt()).toList();
      }
    }

    loadVector('times');
    loadIntList('timesIdx');
    loadVector('times_measured');
    loadVector('weights_measured');
    loadVector('weights');
    loadVector('isNoMeasurement');
    loadVector('isNotExtrapolated');
    loadVector('sigma');
    loadVector('weightsSmoothed');
    loadVector('weightsLinExtrapol');
    loadVector('weightsGaussianExtrapol');
    loadVector('weightsDisplay');
    loadVector('timesDisplay');
  }

  MeasurementDatabaseBaseclass get db => MeasurementDatabaseBaseclass();
  InterpolStrength get interpolStrength => Preferences().interpolStrength;

  void reinit() {
    _cache.clear();
    for (final key in [
      'dateTimes',
      'times',
      'timesIdx',
      'times_measured',
      'weights_measured',
      'weights',
      'isNoMeasurement',
      'isNotExtrapolated',
      'sigma',
      'weightsSmoothed',
      'weightsLinExtrapol',
      'weightsGaussianExtrapol',
      'weightsDisplay',
      'timesDisplay',
    ]) {
      _prefs.remove(key);
    }
    init();
  }

  void init() {
    dateTimes;
    times;
    timesIdx;
    times_measured;
    weights_measured;
    weights;
    isNoMeasurement;
    isNotExtrapolated;
    sigma;
    weightsSmoothed;
    weightsLinExtrapol;
    weightsGaussianExtrapol;
    weightsDisplay;
    timesDisplay;
  }

  Future<void> _saveCache(String key, Object value) async {
    _cache[key] = value;
    if (value is List<DateTime>) {
      await _prefs.setJsonString(
          key, value.map((dt) => dt.toIso8601String()).toList());
    } else if (value is List<int>) {
      await _prefs.setJsonString(key, value);
    } else if (value is Vector) {
      await _prefs.setJsonString(key, value.toList());
    }
  }

  T _cached<T>(String key, T Function() compute) {
    if (_cache.containsKey(key)) return _cache[key] as T;
    final result = compute();
    unawaited(_saveCache(key, result as Object));
    return result;
  }

  /// get vector containing the times given in [ms since epoch]
  List<DateTime> get dateTimes =>
      _cached('dateTimes', _createDateTimes);

  /// get vector containing the times given in [ms since epoch]
  Vector get times => _cached('times', _createTimes);

  /// get vector containing the times given in [ms since epoch]
  List<int> get timesIdx => _cached('timesIdx', () => List<int>.generate(N, (i) => i));

  /// get vector containing the times of the measurements
  Vector get times_measured =>
      _cached('times_measured', _createTimesMeasured);

  /// create vector of all measurements weights
  Vector get weights_measured =>
      _cached('weights_measured', _createWeightsMeasured);

  /// get vector containing the weights of the measurements [kg]
  /// get vector containing the measurements corresponding to self.times
  Vector get weights => _cached('weights', _createWeights);

  /// get vector containing 0 if measurement else 1
  Vector get isNoMeasurement =>
      _cached('isNoMeasurement', () => (isMeasurement - 1).abs());

  /// get vector containing 1 if values withing measurement range else 0
  Vector get isNotExtrapolated =>
      _cached('isNotExtrapolated',
              () => isExtrapolated.mapToVector((v) => v == 0 ? 1 : 0));

  /// get vector containing sigma depending if measurement or not [ms]
  Vector get sigma => _cached('sigma', () => (
      isMeasurement * interpolStrength.strengthMeasurement +
          isNoMeasurement * interpolStrength.strengthInterpol
  ) * _dayInMs);

  /// get vector containing the Gaussian smoothed measurements
  Vector get weightsSmoothed =>
      _cached('weightsSmoothed', () =>
      _gaussianInterpolation(
          _linearExtrapolation(_linearInterpolation(weights))
      ) * isMeasurement);

  /// get vector containing the weights with linear interpolated missing values
  Vector get weightsLinExtrapol =>
      _cached('weightsLinExtrapol', () =>
          _linearExtrapolation(_linearInterpolation(weightsSmoothed)));

  /// get vector containing the weights with linear interpolated missing values
  Vector get weightsGaussianExtrapol =>
      _cached('weightsGaussianExtrapol', () =>
          _gaussianInterpolation(weightsLinExtrapol));

  /// get vector containing the weights to display
  Vector get weightsDisplay =>
      _cached('weightsDisplay', _createWeightsDisplay);

  /// get vector containing the weights to display
  Vector get timesDisplay =>
      _cached('timesDisplay', () => N == 0
          ? times
          : times.subvector(
        (interpolStrength == InterpolStrength.none)
            ? _offsetInDays
            : _offsetInDays - _offsetInDaysShown,
        N - _offsetInDays + _offsetInDaysShown,
      ) + _dailyOffsetInHours / 24 * _dayInMs);

  /// data type of vectors
  static const DType dtype = DType.float64;

  /// length of vectors
  int get N => times.length;

  /// length of displayed vectors
  int get NDisplay => timesDisplay.length;

  /// get DateTime List corresponding to times and weights
  List<DateTime> _createDateTimes() {
    if (db.nMeasurements == 0) {
      return <DateTime>[];
    }

    final int timeSpawn = db.lastDate.difference(
        db.firstDate
    ).inDays + 1 + 2 * _offsetInDays;

    return List<DateTime>.generate(
        timeSpawn,
            (int idx) => DateTime(
          db.firstDate.year,
          db.firstDate.month,
          db.firstDate.day + idx - _offsetInDays,
        )
    );

  }

  /// number of measurements
  int get NMeasurements => times_measured.length;

  /// time span of measurements
  int get measuredTimeSpan => N == 0 ? 0 : N - 2 * _offsetInDays;

  /// idx of last measurement
  int get idxLast => N - 1 - _offsetInDays;
  /// idx of last displayed measurement
  int get idxLastDisplay => NDisplay - 1 - _offsetInDaysShown;

  /// get linearly interpolated and sorted list of daily-averaged measurements
  Vector _createTimes() {
    final List<DateTime> dts = dateTimes;
    if (dts.isEmpty) {
      _isExtrapolated = Vector.empty();
      return Vector.empty();
    }
    // set isExtrapolated
    _isExtrapolated = Vector.fromList(
        List.generate(
          dts.length,
              (int idx) =>
          (
              (idx < _offsetInDays) ||
                  (idx + 1 > dts.length - _offsetInDays)
          ) ? 1 : 0,
        )
    );
    return Vector.fromList(
      dts.map(
              (DateTime dt) => dt.millisecondsSinceEpoch
      ).toList(),
      dtype: dtype,
    );
  }

  /// create vector of all measurements time stamps
  Vector _createTimesMeasured() {
    return Vector.fromList(<int>[
      for (final Measurement ms in db.measurements.reversed)
        ms.dateInMs
    ], dtype: dtype);
  }

  Vector _createWeightsMeasured() {
    return Vector.fromList(<double>[
      for (final Measurement ms in db.measurements.reversed)
        ms.weight
    ], dtype: dtype);
  }

  /// get linearly interpolated and sorted list of daily-averaged measurements
  Vector _createWeights() {
    if (N == 0) {
      _isMeasurement = Vector.empty();
      _idxsMeasurements = <int>[];
      return Vector.empty();
    }
    final List<double> ms = Vector.zero(N).toList();
    final List<double> counts = Vector.zero(N).toList();
    final List<int> idxMs = <int>[];

    int idx = 0;
    for (final Measurement m in db.measurements.reversed) {
      while (
      ! m.date.sameDay(dateTimes[idx])
      ) {
        idx += 1;
      }
      ms[idx] += m.weight;
      counts[idx] += 1;
      if (counts[idx] == 1) {
        idxMs.add(idx);
      }
    }

    // set isMeasurement
    _isMeasurement = Vector.fromList(counts, dtype: dtype) / Vector.fromList(
        counts
    ).mapToVector((double val) => val == 0 ? 1 : val);

    _idxsMeasurements = idxMs;

    return Vector.fromList(ms, dtype: dtype) / Vector.fromList(
        counts
    ).mapToVector((double val) => val == 0 ? 1 : val);
  }

  late Vector _isMeasurement;
  /// get vector containing 1 if measurement else 0
  Vector get isMeasurement => _isMeasurement;

  late List<int> _idxsMeasurements;
  /// get List holding indices to all measurements
  List<int> get idxsMeasurements => _idxsMeasurements;

  late Vector _isExtrapolated;
  /// get vector containing 0 if values are outside of measurement range else 1
  Vector get isExtrapolated => _isExtrapolated;

  /// estimate weights of gaussian at time t with std sigma
  Vector gaussianWeights(double t, Vector ms) {
    final Vector norm = (sigma * math.sqrt(2 * math.pi)).pow(-1);
    final Vector gaussianWeights = (
        (times - t).pow(2) / (sigma.pow(2) * -2)
    ).exp() * norm * (
        isMeasurement * interpolStrength.weight + isNoMeasurement
    );
    final Vector mask = ms.mapToVector(
            (double val) => val > 0 ? 1 : 0
    );

    return (gaussianWeights * mask) / (gaussianWeights * mask).sum();
  }

  /// take mean of Vector ws weighted with Gaussian N(t, sigma)
  double gaussianMean(double t, Vector ms) =>
      gaussianWeights(t, ms).dot(ms);

  Vector _createWeightsDisplay() {
    if (N == 0) {
      return weights;
    }

    if (interpolStrength == InterpolStrength.none) {
      final Vector weightsLinear = _linearInterpolation(weights).subvector(
        _offsetInDays,
        N - _offsetInDays,
      );

      final Vector weightsExtrapol = Vector.fromList(<double>[
        for (int idx=1; idx <= _offsetInDaysShown; idx++)
          finalSlope * idx
      ]) + weightsLinear.last;

      return Vector.fromList(
          weightsLinear.toList()..addAll(weightsExtrapol)
      );
    }
    return weightsGaussianExtrapol.subvector(
      _offsetInDays - _offsetInDaysShown,
      N - _offsetInDays + _offsetInDaysShown,
    );
  }

  /// add linear interpolation to measurements
  Vector _linearExtrapolation(Vector weights) {
    final List<double> weightsList = weights.toList();

    if (db.nMeasurements == 0) {
      return Vector.empty();
    } else if (idxsMeasurements.length == 1) {
      return Vector.filled(N, weights[idxsMeasurements[0]]);
    }

    // add extrapolation
    final Vector initialExtrapolation = _linearRegression(
      weights,
      times[_offsetInDays],
      times.subvector(0, _offsetInDays),
    );
    final Vector finalExtrapolation = _linearRegression(
      weights,
      times[N - _offsetInDays],
      times.subvector(N - _offsetInDays, N),
    );

    for (int idx=0; idx < _offsetInDays; idx++) {
      weightsList[idx] = initialExtrapolation[idx];
      weightsList[N - _offsetInDays + idx] = finalExtrapolation[idx];
    }

    return Vector.fromList(weightsList, dtype: dtype);
  }

  /// Estimate linear regression for time ts with Gaussian weights relative to
  /// tRef
  Vector _linearRegression(Vector weights, double tRef, Vector ts) {
    final Vector gsWeights = gaussianWeights(tRef, weights);
    final double meanWeight = gsWeights.dot(weights);
    final double meanTime = gsWeights.dot(times);
    final double meanChange = gsWeights.dot(
        (weights - meanWeight) * times
    ) / gsWeights.dot(
        (times - meanTime) * times
    );
    final double intercept = meanWeight - meanChange * meanTime;

    return Vector.fromList(<double>[
      for (final double t in ts)
        meanChange * t + intercept < 0
            ? 0
            : meanChange * t + intercept
    ], dtype: dtype);
  }

  /// add linear interpolation to measurements
  Vector _linearInterpolation(Vector weights) {
    final List<double> weightsList = weights.toList();
    int idxFrom, idxTo;
    double changeRate;

    if (db.nMeasurements == 0) {
      return Vector.empty();
    } else if (idxsMeasurements.length == 1) {
      return Vector.filled(N, weights[idxsMeasurements[0]]);
    }

    // loop over all unique measurements
    for (int idx = 0; idx < idxsMeasurements.length - 1; idx++) {
      // interpolate between measurements idxs_i and idx_j
      idxFrom = idxsMeasurements[idx];
      idxTo = idxsMeasurements[idx + 1];
      if (idxFrom + 1 < idxTo) {
        // estimate change rate
        changeRate = _slope(idxFrom, idxTo, weights);
        for (int idxJ = idxFrom + 1; idxJ < idxTo; idxJ++) {
          weightsList[idxJ] = weightsList[idxFrom] + changeRate * (
              idxJ - idxFrom
          );
        }
      }
    }
    return Vector.fromList(weightsList, dtype: dtype);
  }

  /// estimate slope between two measurements in [kg/steps]
  double _slope(int idxFrom, int idxTo, Vector weights) =>
      weights.isNotEmpty
          ? (weights[idxTo] - weights[idxFrom]) / (idxTo - idxFrom)
          : 0;

  /// smooth weights with Gaussian kernel
  Vector _gaussianInterpolation(Vector weights) => Vector.fromList(
    <double>[
      for (final int idx in timesIdx)
        (weights[idx] != 0)
            ? gaussianMean(times[idx], weights)
            : 0
    ], dtype: dtype,
  );

  /// get time span between first and last measurement
  Duration get measurementDuration => times_measured.isNotEmpty
      ? Duration(
    milliseconds: (times_measured.last - times_measured.first).round(),
  )
      : Duration.zero;

  /// final slope of extrapolation
  double get finalSlope => _slope(
    idxLast,
    idxLast + _offsetInDaysShown,
    weightsGaussianExtrapol,
  );

  /// offset of day in interpolation
  static const int _offsetInDays = 21;

  /// offset of day in interpolation shown
  static const int _offsetInDaysShown = 7;

  /// offset of day in interpolation shown
  static const int _dailyOffsetInHours = 12;

  /// 24h given in [ms]
  static const int _dayInMs = 24 * 3600 * 1000;
}


/// class providing an API to handle interpolation of measurements
class MeasurementInterpolation extends MeasurementInterpolationBaseclass{
  /// singleton constructor
  factory MeasurementInterpolation() => _instance;

  /// single instance creation
  MeasurementInterpolation._internal();

  /// singleton instance
  static final MeasurementInterpolation _instance =
    MeasurementInterpolation._internal();

  /// get measurements
  @override
  MeasurementDatabase get db => MeasurementDatabase();
}
