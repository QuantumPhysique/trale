import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:ml_linalg/linalg.dart';

import 'package:trale/core/interpolation.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/preferences.dart';

// ---------------------------------------------------------------------------
// Isolate payload & top-level function
// ---------------------------------------------------------------------------

/// Data payload sent to a background isolate for the full interpolation
/// pipeline (linear interpolation, linear extrapolation with Gaussian
/// regression, Gaussian smoothing – two passes – and weightsDisplay).
class _InterpolationPayload {
  _InterpolationPayload({
    required this.timesData,
    required this.weightsData,
    required this.isMeasurementData,
    required this.isNoMeasurementData,
    required this.idxsMeasurements,
    required this.n,
    required this.offsetInDays,
    required this.offsetInDaysShown,
    required this.strengthMeasurement,
    required this.strengthInterpol,
    required this.interpolWeight,
    required this.interpolStrengthIsNone,
  });

  final List<double> timesData;
  final List<double> weightsData;
  final List<double> isMeasurementData;
  final List<double> isNoMeasurementData;
  final List<int> idxsMeasurements;
  final int n;
  final int offsetInDays;
  final int offsetInDaysShown;
  final double strengthMeasurement;
  final double strengthInterpol;
  final double interpolWeight;
  final bool interpolStrengthIsNone;
}

/// Result returned from the isolate containing all computed vectors.
class _InterpolationResult {
  _InterpolationResult({
    required this.weightsSmoothed,
    required this.weightsLinExtrapol,
    required this.weightsGaussianExtrapol,
    required this.weightsDisplay,
  });

  final List<double> weightsSmoothed;
  final List<double> weightsLinExtrapol;
  final List<double> weightsGaussianExtrapol;
  final List<double> weightsDisplay;
}

/// Top-level function that runs the full interpolation pipeline in a
/// background isolate.  Must be top-level (not a closure) for [compute].
_InterpolationResult _computeFullInterpolation(_InterpolationPayload p) {
  // Derived constants
  const int dayInMs = 24 * 3600 * 1000;

  // Build sigma list (same logic as the getter on the base class).
  final List<double> sigma = List<double>.generate(p.n, (int i) {
    final double s =
        p.isMeasurementData[i] * p.strengthMeasurement +
        p.isNoMeasurementData[i] * p.strengthInterpol;
    return s * dayInMs;
  });

  // ---- helpers (plain-list implementations) ----

  double slope(int from, int to, List<double> w) =>
      w.isNotEmpty ? (w[to] - w[from]) / (to - from) : 0;

  List<double> linearInterpolation(List<double> w) {
    final List<double> out = List<double>.of(w);
    if (p.idxsMeasurements.length <= 1) {
      if (p.idxsMeasurements.length == 1) {
        return List<double>.filled(p.n, w[p.idxsMeasurements[0]]);
      }
      return out;
    }
    for (int i = 0; i < p.idxsMeasurements.length - 1; i++) {
      final int from = p.idxsMeasurements[i];
      final int to = p.idxsMeasurements[i + 1];
      if (from + 1 < to) {
        final double rate = slope(from, to, w);
        for (int j = from + 1; j < to; j++) {
          out[j] = out[from] + rate * (j - from);
        }
      }
    }
    return out;
  }

  /// Compute Gaussian weights at reference point [tRef] and return them
  /// normalised so they sum to 1.
  List<double> gaussianWeights(double tRef, List<double> w) {
    final List<double> gw = List<double>.filled(p.n, 0);
    double total = 0;
    for (int j = 0; j < p.n; j++) {
      if (w[j] <= 0) continue;
      final double s = sigma[j];
      final double diff = p.timesData[j] - tRef;
      final double gaussVal =
          math.exp(-diff * diff / (2 * s * s)) / (s * math.sqrt(2 * math.pi));
      final double val =
          gaussVal *
          (p.isMeasurementData[j] * p.interpolWeight +
              p.isNoMeasurementData[j]);
      gw[j] = val;
      total += val;
    }
    if (total > 0) {
      for (int j = 0; j < p.n; j++) {
        gw[j] /= total;
      }
    }
    return gw;
  }

  /// Linear regression extrapolation using Gaussian-weighted moments.
  List<double> linearRegression(
    List<double> w,
    double tRef,
    int startIdx,
    int endIdx,
  ) {
    final List<double> gw = gaussianWeights(tRef, w);
    double meanW = 0, meanT = 0;
    for (int j = 0; j < p.n; j++) {
      meanW += gw[j] * w[j];
      meanT += gw[j] * p.timesData[j];
    }
    double numChange = 0, denChange = 0;
    for (int j = 0; j < p.n; j++) {
      numChange += gw[j] * (w[j] - meanW) * p.timesData[j];
      denChange += gw[j] * (p.timesData[j] - meanT) * p.timesData[j];
    }
    final double meanChange = denChange != 0 ? numChange / denChange : 0;
    final double intercept = meanW - meanChange * meanT;
    final int count = endIdx - startIdx;
    return List<double>.generate(count, (int i) {
      final double t = p.timesData[startIdx + i];
      final double v = meanChange * t + intercept;
      return v < 0 ? 0 : v;
    });
  }

  List<double> linearExtrapolation(List<double> w) {
    final List<double> out = List<double>.of(w);
    if (p.idxsMeasurements.length <= 1) {
      if (p.idxsMeasurements.length == 1) {
        return List<double>.filled(p.n, w[p.idxsMeasurements[0]]);
      }
      return out;
    }
    final List<double> initExtrapol = linearRegression(
      w,
      p.timesData[p.offsetInDays],
      0,
      p.offsetInDays,
    );
    final List<double> finalExtrapol = linearRegression(
      w,
      p.timesData[p.n - p.offsetInDays],
      p.n - p.offsetInDays,
      p.n,
    );
    for (int i = 0; i < p.offsetInDays; i++) {
      out[i] = initExtrapol[i];
      out[p.n - p.offsetInDays + i] = finalExtrapol[i];
    }
    return out;
  }

  List<double> gaussianInterpolation(List<double> w) {
    final List<double> result = List<double>.filled(p.n, 0);
    for (int idx = 0; idx < p.n; idx++) {
      if (w[idx] == 0) continue;
      final double t = p.timesData[idx];
      double weightedSum = 0, normSum = 0;
      for (int j = 0; j < p.n; j++) {
        if (w[j] <= 0) continue;
        final double s = sigma[j];
        final double diff = p.timesData[j] - t;
        final double gaussVal =
            math.exp(-diff * diff / (2 * s * s)) / (s * math.sqrt(2 * math.pi));
        final double val =
            gaussVal *
            (p.isMeasurementData[j] * p.interpolWeight +
                p.isNoMeasurementData[j]);
        weightedSum += val * w[j];
        normSum += val;
      }
      result[idx] = normSum > 0 ? weightedSum / normSum : 0;
    }
    return result;
  }

  // ---- Pass 1: weightsSmoothed ----
  final List<double> linInterp = linearInterpolation(p.weightsData);
  final List<double> linExtrapol = linearExtrapolation(linInterp);
  final List<double> smoothedRaw = gaussianInterpolation(linExtrapol);
  // Zero out non-measurements
  final List<double> weightsSmoothed = List<double>.generate(
    p.n,
    (int i) => smoothedRaw[i] * p.isMeasurementData[i],
  );

  // ---- Pass 2: weightsGaussianExtrapol ----
  final List<double> linInterp2 = linearInterpolation(weightsSmoothed);
  final List<double> weightsLinExtrapol = linearExtrapolation(linInterp2);
  final List<double> weightsGaussianExtrapol = gaussianInterpolation(
    weightsLinExtrapol,
  );

  // ---- weightsDisplay ----
  List<double> weightsDisplay;
  if (p.interpolStrengthIsNone) {
    final List<double> wLinear = linearInterpolation(
      p.weightsData,
    ).sublist(p.offsetInDays, p.n - p.offsetInDays);
    // finalSlope for extrapolation
    final int idxLast = p.n - 1 - p.offsetInDays;
    final double fSlope = slope(
      idxLast,
      idxLast + p.offsetInDaysShown,
      weightsGaussianExtrapol,
    );
    weightsDisplay = List<double>.from(wLinear);
    for (int i = 1; i <= p.offsetInDaysShown; i++) {
      weightsDisplay.add(wLinear.last + fSlope * i);
    }
  } else {
    weightsDisplay = weightsGaussianExtrapol.sublist(
      p.offsetInDays - p.offsetInDaysShown,
      p.n - p.offsetInDays + p.offsetInDaysShown,
    );
  }

  return _InterpolationResult(
    weightsSmoothed: weightsSmoothed,
    weightsLinExtrapol: weightsLinExtrapol,
    weightsGaussianExtrapol: weightsGaussianExtrapol,
    weightsDisplay: weightsDisplay,
  );
}

/// Base class for measurement interpolation
class MeasurementInterpolationBaseclass {
  MeasurementInterpolationBaseclass() {
    init();
  }

  MeasurementDatabaseBaseclass get db => MeasurementDatabaseBaseclass();

  /// get interpolation strength values
  InterpolStrength get interpolStrength => Preferences().interpolStrength;

  /// re initialize database
  void reinit() {
    _dateTimes = null;
    _times = null;
    _timesIdx = null;
    _times_measured = null;
    _timesDisplay = null;
    _weights_measured = null;
    _weights = null;
    _weightsDisplay = null;
    _isNoMeasurement = null;
    _isNotExtrapolated = null;
    _sigma = null;
    _weightsLinExtrapol = null;
    _weightsSmoothed = null;
    _weightsGaussianExtrapol = null;

    // recalculate all vectors
    init();
  }

  /// re initialize database asynchronously (offloads the entire interpolation
  /// pipeline — linear interpolation, Gaussian regression, Gaussian smoothing,
  /// and weightsDisplay — to a background isolate via [compute]).
  Future<void> reinitAsync() async {
    _dateTimes = null;
    _times = null;
    _timesIdx = null;
    _times_measured = null;
    _timesDisplay = null;
    _weights_measured = null;
    _weights = null;
    _weightsDisplay = null;
    _isNoMeasurement = null;
    _isNotExtrapolated = null;
    _sigma = null;
    _weightsLinExtrapol = null;
    _weightsSmoothed = null;
    _weightsGaussianExtrapol = null;

    // Compute the lightweight synchronous vectors first (times, weights,
    // isMeasurement, idxsMeasurements).  These are O(N) and fast.
    times;
    weights;

    if (N == 0) return;

    // Ship the full pipeline to a background isolate.
    final _InterpolationResult result = await compute(
      _computeFullInterpolation,
      _InterpolationPayload(
        timesData: times.toList(),
        weightsData: weights.toList(),
        isMeasurementData: isMeasurement.toList(),
        isNoMeasurementData: isNoMeasurement.toList(),
        idxsMeasurements: idxsMeasurements,
        n: N,
        offsetInDays: _offsetInDays,
        offsetInDaysShown: _offsetInDaysShown,
        strengthMeasurement: interpolStrength.strengthMeasurement,
        strengthInterpol: interpolStrength.strengthInterpol,
        interpolWeight: interpolStrength.weight,
        interpolStrengthIsNone: interpolStrength == InterpolStrength.none,
      ),
    );

    // Store the results.
    _weightsSmoothed = Vector.fromList(result.weightsSmoothed, dtype: dtype);
    _weightsLinExtrapol = Vector.fromList(
      result.weightsLinExtrapol,
      dtype: dtype,
    );
    _weightsGaussianExtrapol = Vector.fromList(
      result.weightsGaussianExtrapol,
      dtype: dtype,
    );
    _weightsDisplay = Vector.fromList(result.weightsDisplay, dtype: dtype);

    // Derive remaining display vectors (cheap subvector / offset ops).
    timesDisplay;
  }

  /// initialize database
  void init() {
    times;
    weights;

    weightsGaussianExtrapol;
    weightsDisplay;
  }

  /// data type of vectors
  static const DType dtype = DType.float64;

  /// length of vectors
  int get N => times.length;

  /// length of displayed vectors
  int get NDisplay => timesDisplay.length;

  List<DateTime>? _dateTimes;

  /// get vector containing the times given in [ms since epoch]
  List<DateTime> get dateTimes => _dateTimes ??= _createDateTimes();

  /// get DateTime List corresponding to times and weights
  List<DateTime> _createDateTimes() {
    if (db.nMeasurements == 0) {
      return <DateTime>[];
    }

    final int timeSpawn =
        db.lastDate.difference(db.firstDate).inDays + 1 + 2 * _offsetInDays;

    return List<DateTime>.generate(
      timeSpawn,
      (int idx) => DateTime(
        db.firstDate.year,
        db.firstDate.month,
        db.firstDate.day + idx - _offsetInDays,
      ),
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

  Vector? _times;

  /// get vector containing the times given in [ms since epoch]
  Vector get times => _times ??= _createTimes();

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
            ((idx < _offsetInDays) || (idx + 1 > dts.length - _offsetInDays))
            ? 1
            : 0,
      ),
    );
    return Vector.fromList(
      dts.map((DateTime dt) => dt.millisecondsSinceEpoch).toList(),
      dtype: dtype,
    );
  }

  List<int>? _timesIdx;

  /// get vector containing the times given in [ms since epoch]
  List<int> get timesIdx =>
      _timesIdx ??= List<int>.generate(N, (int idx) => idx);

  Vector? _times_measured;

  /// get vector containing the times of the measurements
  Vector get times_measured => _times_measured ??= _createTimesMeasured();

  /// create vector of all measurements time stamps
  Vector _createTimesMeasured() {
    return Vector.fromList(<int>[
      for (final Measurement ms in db.measurements.reversed) ms.dateInMs,
    ], dtype: dtype);
  }

  Vector? _weights_measured;

  /// get vector containing the weights of the measurements [kg]
  Vector get weights_measured => _weights_measured ??= _createWeightsMeasured();

  /// create vector of all measurements weights
  Vector _createWeightsMeasured() {
    return Vector.fromList(<double>[
      for (final Measurement ms in db.measurements.reversed) ms.weight,
    ], dtype: dtype);
  }

  Vector? _weights;

  /// get vector containing the measurements corresponding to self.times
  Vector get weights => _weights ??= _createWeights();

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
      while (!m.date.sameDay(dateTimes[idx])) {
        idx += 1;
      }
      ms[idx] += m.weight;
      counts[idx] += 1;
      if (counts[idx] == 1) {
        idxMs.add(idx);
      }
    }

    // set isMeasurement
    _isMeasurement =
        Vector.fromList(counts, dtype: dtype) /
        Vector.fromList(counts).mapToVector((double val) => val == 0 ? 1 : val);

    _idxsMeasurements = idxMs;

    return Vector.fromList(ms, dtype: dtype) /
        Vector.fromList(counts).mapToVector((double val) => val == 0 ? 1 : val);
  }

  late Vector _isMeasurement;

  /// get vector containing 1 if measurement else 0
  Vector get isMeasurement => _isMeasurement;

  Vector? _isNoMeasurement;

  /// get vector containing 0 if measurement else 1
  Vector get isNoMeasurement => _isNoMeasurement ??= (isMeasurement - 1).abs();

  late List<int> _idxsMeasurements;

  /// get List holding indices to all measurements
  List<int> get idxsMeasurements => _idxsMeasurements;

  late Vector _isExtrapolated;

  /// get vector containing 0 if values are outside of measurement range else 1
  Vector get isExtrapolated => _isExtrapolated;

  Vector? _isNotExtrapolated;

  /// get vector containing 1 if values withing measurement range else 0
  Vector get isNotExtrapolated => _isNotExtrapolated ??= isExtrapolated
      .mapToVector((double val) => val == 0 ? 1 : 0);

  Vector? _sigma;

  /// get vector containing sigma depending if measurement or not [ms]
  Vector get sigma => _sigma ??=
      (isMeasurement * interpolStrength.strengthMeasurement +
          isNoMeasurement * interpolStrength.strengthInterpol) *
      _dayInMs;

  /// estimate weights of gaussian at time t with std sigma
  Vector gaussianWeights(double t, Vector ms) {
    final Vector norm = (sigma * math.sqrt(2 * math.pi)).pow(-1);
    final Vector gaussianWeights =
        ((times - t).pow(2) / (sigma.pow(2) * -2)).exp() *
        norm *
        (isMeasurement * interpolStrength.weight + isNoMeasurement);
    final Vector mask = ms.mapToVector((double val) => val > 0 ? 1 : 0);

    return (gaussianWeights * mask) / (gaussianWeights * mask).sum();
  }

  /// take mean of Vector ws weighted with Gaussian N(t, sigma)
  double gaussianMean(double t, Vector ms) => gaussianWeights(t, ms).dot(ms);

  Vector? _weightsSmoothed;

  /// get vector containing the Gaussian smoothed measurements
  Vector get weightsSmoothed => _weightsSmoothed ??=
      _gaussianInterpolation(
        _linearExtrapolation(_linearInterpolation(weights)),
      ) *
      isMeasurement; // set all non Measurements to zero.

  Vector? _weightsLinExtrapol;

  /// get vector containing the weights with linear interpolated missing values
  Vector get weightsLinExtrapol => _weightsLinExtrapol ??= _linearExtrapolation(
    _linearInterpolation(weightsSmoothed),
  );

  Vector? _weightsGaussianExtrapol;

  /// get vector containing the weights with linear interpolated missing values
  Vector get weightsGaussianExtrapol =>
      _weightsGaussianExtrapol ??= _gaussianInterpolation(weightsLinExtrapol);

  Vector? _weightsDisplay;

  /// get vector containing the weights to display
  Vector get weightsDisplay => _weightsDisplay ??= _createWeightsDisplay();

  Vector _createWeightsDisplay() {
    if (N == 0) {
      return weights;
    }

    if (interpolStrength == InterpolStrength.none) {
      final Vector weightsLinear = _linearInterpolation(
        weights,
      ).subvector(_offsetInDays, N - _offsetInDays);

      final Vector weightsExtrapol =
          Vector.fromList(<double>[
            for (int idx = 1; idx <= _offsetInDaysShown; idx++)
              finalSlope * idx,
          ]) +
          weightsLinear.last;

      return Vector.fromList(weightsLinear.toList()..addAll(weightsExtrapol));
    }
    return weightsGaussianExtrapol.subvector(
      _offsetInDays - _offsetInDaysShown,
      N - _offsetInDays + _offsetInDaysShown,
    );
  }

  Vector? _timesDisplay;

  /// get vector containing the weights to display
  Vector get timesDisplay => _timesDisplay ??= N == 0
      ? times
      : times.subvector(
              (interpolStrength == InterpolStrength.none)
                  ? _offsetInDays
                  : _offsetInDays - _offsetInDaysShown,
              N - _offsetInDays + _offsetInDaysShown,
            ) +
            _dailyOffsetInHours / 24 * _dayInMs;

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

    for (int idx = 0; idx < _offsetInDays; idx++) {
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
    final double meanChange =
        gsWeights.dot((weights - meanWeight) * times) /
        gsWeights.dot((times - meanTime) * times);
    final double intercept = meanWeight - meanChange * meanTime;

    return Vector.fromList(<double>[
      for (final double t in ts)
        meanChange * t + intercept < 0 ? 0 : meanChange * t + intercept,
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
          weightsList[idxJ] =
              weightsList[idxFrom] + changeRate * (idxJ - idxFrom);
        }
      }
    }
    return Vector.fromList(weightsList, dtype: dtype);
  }

  /// estimate slope between two measurements in [kg/steps]
  double _slope(int idxFrom, int idxTo, Vector weights) => weights.isNotEmpty
      ? (weights[idxTo] - weights[idxFrom]) / (idxTo - idxFrom)
      : 0;

  /// smooth weights with Gaussian kernel
  Vector _gaussianInterpolation(Vector weights) => Vector.fromList(<double>[
    for (final int idx in timesIdx)
      (weights[idx] != 0) ? gaussianMean(times[idx], weights) : 0,
  ], dtype: dtype);

  /// get time span between first and last measurement
  Duration get measurementDuration => times_measured.isNotEmpty
      ? Duration(
          milliseconds: (times_measured.last - times_measured.first).round(),
        )
      : Duration.zero;

  /// final slope of extrapolation
  double get finalSlope =>
      _slope(idxLast, idxLast + _offsetInDaysShown, weightsGaussianExtrapol);

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
class MeasurementInterpolation extends MeasurementInterpolationBaseclass {
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

  /// SharedPreferences key for the interpolation cache
  static const String _cacheKey = 'interpolation_cache';

  /// Cache version — bump when the cached data format changes
  static const int _cacheVersion = 1;

  /// Flag to skip cache loading during reinit (force recompute)
  bool _skipCache = false;

  @override
  void init() {
    if (!_skipCache && _loadFromCache()) {
      return;
    }
    _skipCache = false;
    super.init();
    _saveToCache();
  }

  @override
  Future<void> reinitAsync() async {
    _skipCache = true;
    await super.reinitAsync();
    _saveToCache();
  }

  @override
  void reinit() {
    _skipCache = true;
    super.reinit();
  }

  /// Try to restore all interpolation vectors from SharedPreferences.
  /// Returns true if the cache was valid and successfully restored.
  bool _loadFromCache() {
    try {
      final String? cached = Preferences().prefs.getString(_cacheKey);
      if (cached == null) return false;

      final Map<String, dynamic> map =
          jsonDecode(cached) as Map<String, dynamic>;

      // Validate cache matches current state
      if (map['version'] != _cacheVersion) return false;
      if (map['nMeasurements'] != db.nMeasurements) return false;
      if (map['interpolStrength'] != interpolStrength.name) return false;

      if (db.nMeasurements == 0) return false;

      if (map['firstDateMs'] != db.firstDate.millisecondsSinceEpoch) {
        return false;
      }
      if (map['lastDateMs'] != db.lastDate.millisecondsSinceEpoch) {
        return false;
      }

      // Restore all vectors
      _dateTimes = (map['dateTimes'] as List<dynamic>)
          .map(
            (dynamic ms) =>
                DateTime.fromMillisecondsSinceEpoch((ms as num).toInt()),
          )
          .toList();
      _times = _vectorFromJson(map['times']);
      _isExtrapolated = _vectorFromJson(map['isExtrapolated']);
      _weights = _vectorFromJson(map['weights']);
      _isMeasurement = _vectorFromJson(map['isMeasurement']);
      _idxsMeasurements = (map['idxsMeasurements'] as List<dynamic>)
          .map((dynamic e) => (e as num).toInt())
          .toList();
      _times_measured = _vectorFromJson(map['timesMeasured']);
      _weights_measured = _vectorFromJson(map['weightsMeasured']);
      _weightsSmoothed = _vectorFromJson(map['weightsSmoothed']);
      _weightsLinExtrapol = _vectorFromJson(map['weightsLinExtrapol']);
      _weightsGaussianExtrapol = _vectorFromJson(
        map['weightsGaussianExtrapol'],
      );
      _weightsDisplay = _vectorFromJson(map['weightsDisplay']);
      _timesDisplay = _vectorFromJson(map['timesDisplay']);

      return true;
    } catch (e) {
      // Cache is corrupt or incompatible — fall back to fresh computation
      return false;
    }
  }

  /// Persist all computed interpolation vectors to SharedPreferences.
  void _saveToCache() {
    try {
      if (db.nMeasurements == 0) {
        Preferences().prefs.remove(_cacheKey);
        return;
      }

      final Map<String, dynamic> map = <String, dynamic>{
        'version': _cacheVersion,
        'nMeasurements': db.nMeasurements,
        'interpolStrength': interpolStrength.name,
        'firstDateMs': db.firstDate.millisecondsSinceEpoch,
        'lastDateMs': db.lastDate.millisecondsSinceEpoch,
        'dateTimes': dateTimes
            .map((DateTime dt) => dt.millisecondsSinceEpoch)
            .toList(),
        'times': times.toList(),
        'isExtrapolated': isExtrapolated.toList(),
        'weights': weights.toList(),
        'isMeasurement': isMeasurement.toList(),
        'idxsMeasurements': idxsMeasurements,
        'timesMeasured': times_measured.toList(),
        'weightsMeasured': weights_measured.toList(),
        'weightsSmoothed': weightsSmoothed.toList(),
        'weightsLinExtrapol': weightsLinExtrapol.toList(),
        'weightsGaussianExtrapol': weightsGaussianExtrapol.toList(),
        'weightsDisplay': weightsDisplay.toList(),
        'timesDisplay': timesDisplay.toList(),
      };
      Preferences().prefs.setString(_cacheKey, jsonEncode(map));
    } catch (e) {
      // Cache save failure is non-critical
    }
  }

  /// Deserialize a JSON list back into a Vector.
  static Vector _vectorFromJson(dynamic json) {
    if (json == null) return Vector.empty();
    final List<double> list = (json as List<dynamic>)
        .map((dynamic e) => (e as num).toDouble())
        .toList();
    return list.isEmpty
        ? Vector.empty()
        : Vector.fromList(list, dtype: MeasurementInterpolationBaseclass.dtype);
  }
}
