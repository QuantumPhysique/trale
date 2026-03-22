// ignore_for_file: file_names
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
      if (w[j] <= 0) {
        continue;
      }
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
      if (w[idx] == 0) {
        continue;
      }
      final double t = p.timesData[idx];
      double weightedSum = 0, normSum = 0;
      for (int j = 0; j < p.n; j++) {
        if (w[j] <= 0) {
          continue;
        }
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
  /// Creates a [MeasurementInterpolationBaseclass] and calls [init].
  MeasurementInterpolationBaseclass() {
    init();
  }

  /// The underlying measurement database.
  MeasurementDatabaseBaseclass get db => MeasurementDatabaseBaseclass();

  /// get interpolation strength values
  InterpolStrength get interpolStrength => Preferences().interpolStrength;

  /// re initialize database
  void reinit() {
    __dateTimes = null;
    __times = null;
    __timesIdx = null;
    __timesMeasured = null;
    _timesDisplay = null;
    __weightsMeasured = null;
    __weights = null;
    _weightsDisplay = null;
    _measurementsDisplay = null;
    _isMeasurementDisplay = null;
    __isNoMeasurement = null;
    __sigma = null;
    __weightsLinExtrapol = null;
    __weightsSmoothed = null;
    __weightsGaussianExtrapol = null;

    // recalculate all vectors
    init();
  }

  /// re initialize database asynchronously (offloads the entire interpolation
  /// pipeline — linear interpolation, Gaussian regression, Gaussian smoothing,
  /// and weightsDisplay — to a background isolate via [compute]).
  Future<void> reinitAsync() async {
    __dateTimes = null;
    __times = null;
    __timesIdx = null;
    __timesMeasured = null;
    _timesDisplay = null;
    __weightsMeasured = null;
    __weights = null;
    _weightsDisplay = null;
    _measurementsDisplay = null;
    _isMeasurementDisplay = null;
    __isNoMeasurement = null;
    __sigma = null;
    __weightsLinExtrapol = null;
    __weightsSmoothed = null;
    __weightsGaussianExtrapol = null;

    // Compute the lightweight synchronous vectors first (times, weights,
    // isMeasurement, idxsMeasurements).  These are O(N) and fast.
    _times;
    _weights;

    if (_n == 0) {
      return;
    }

    // Ship the full pipeline to a background isolate.
    final _InterpolationResult result = await compute(
      _computeFullInterpolation,
      _InterpolationPayload(
        timesData: _times.toList(),
        weightsData: _weights.toList(),
        isMeasurementData: _isMeasurement.toList(),
        isNoMeasurementData: _isNoMeasurement.toList(),
        idxsMeasurements: _idxsMeasurements,
        n: _n,
        offsetInDays: _offsetInDays,
        offsetInDaysShown: _offsetInDaysShown,
        strengthMeasurement: interpolStrength.strengthMeasurement,
        strengthInterpol: interpolStrength.strengthInterpol,
        interpolWeight: interpolStrength.weight,
        interpolStrengthIsNone: interpolStrength == InterpolStrength.none,
      ),
    );

    // Store the results.
    __weightsSmoothed = Vector.fromList(result.weightsSmoothed, dtype: dtype);
    __weightsLinExtrapol = Vector.fromList(
      result.weightsLinExtrapol,
      dtype: dtype,
    );
    __weightsGaussianExtrapol = Vector.fromList(
      result.weightsGaussianExtrapol,
      dtype: dtype,
    );
    _weightsDisplay = Vector.fromList(result.weightsDisplay, dtype: dtype);

    // Derive remaining display vectors (cheap subvector / offset ops).
    times;
    measurements;
    isMeasurement;
  }

  /// initialize database
  void init() {
    _times;
    _weights;

    _weightsGaussianExtrapol;
    weights;
  }

  /// data type of vectors
  static const DType dtype = DType.float64;

  // ---------------------------------------------------------------------------
  // Internal (length-N) vectors — all private
  // ---------------------------------------------------------------------------

  /// internal length of full vectors (including extrapolation padding)
  int get _n => _times.length;

  List<DateTime>? __dateTimes;
  List<DateTime> get _dateTimes => __dateTimes ??= _createDateTimes();

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

  /// idx of last measurement in internal vectors
  int get _idxLast => _n - 1 - _offsetInDays;

  Vector? __times;
  Vector get _times => __times ??= _createTimes();

  Vector _createTimes() {
    final List<DateTime> dts = _dateTimes;
    if (dts.isEmpty) {
      __isExtrapolated = Vector.empty();
      return Vector.empty();
    }
    __isExtrapolated = Vector.fromList(
      List<int>.generate(
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

  List<int>? __timesIdx;
  List<int> get _timesIdx =>
      __timesIdx ??= List<int>.generate(_n, (int idx) => idx);

  Vector? __timesMeasured;
  Vector get _timesMeasured => __timesMeasured ??= _createTimesMeasured();

  Vector _createTimesMeasured() {
    return Vector.fromList(<int>[
      for (final Measurement ms in db.measurements.reversed) ms.dateInMs,
    ], dtype: dtype);
  }

  Vector? __weightsMeasured;
  Vector get _weightsMeasured => __weightsMeasured ??= _createWeightsMeasured();

  Vector _createWeightsMeasured() {
    return Vector.fromList(<double>[
      for (final Measurement ms in db.measurements.reversed) ms.weight,
    ], dtype: dtype);
  }

  Vector? __weights;
  Vector get _weights => __weights ??= _createWeights();

  Vector _createWeights() {
    if (_n == 0) {
      __isMeasurement = Vector.empty();
      __idxsMeasurements = <int>[];
      return Vector.empty();
    }
    final List<double> ms = Vector.zero(_n).toList();
    final List<double> counts = Vector.zero(_n).toList();
    final List<int> idxMs = <int>[];

    int idx = 0;
    for (final Measurement m in db.measurements.reversed) {
      while (!m.date.sameDay(_dateTimes[idx])) {
        idx += 1;
      }
      ms[idx] += m.weight;
      counts[idx] += 1;
      if (counts[idx] == 1) {
        idxMs.add(idx);
      }
    }

    __isMeasurement =
        Vector.fromList(counts, dtype: dtype) /
        Vector.fromList(counts).mapToVector((double val) => val == 0 ? 1 : val);

    __idxsMeasurements = idxMs;

    return Vector.fromList(ms, dtype: dtype) /
        Vector.fromList(counts).mapToVector((double val) => val == 0 ? 1 : val);
  }

  late Vector __isMeasurement;
  Vector get _isMeasurement => __isMeasurement;

  Vector? __isNoMeasurement;
  Vector get _isNoMeasurement =>
      __isNoMeasurement ??= (_isMeasurement - 1).abs();

  late List<int> __idxsMeasurements;
  List<int> get _idxsMeasurements => __idxsMeasurements;

  late Vector __isExtrapolated;
  Vector get _isExtrapolated => __isExtrapolated;

  Vector? __sigma;
  Vector get _sigma => __sigma ??=
      (_isMeasurement * interpolStrength.strengthMeasurement +
          _isNoMeasurement * interpolStrength.strengthInterpol) *
      _dayInMs;

  Vector _gaussianWeights(double t, Vector ms) {
    final Vector norm = (_sigma * math.sqrt(2 * math.pi)).pow(-1);
    final Vector gw =
        ((_times - t).pow(2) / (_sigma.pow(2) * -2)).exp() *
        norm *
        (_isMeasurement * interpolStrength.weight + _isNoMeasurement);
    final Vector mask = ms.mapToVector((double val) => val > 0 ? 1 : 0);

    return (gw * mask) / (gw * mask).sum();
  }

  double _gaussianMean(double t, Vector ms) => _gaussianWeights(t, ms).dot(ms);

  Vector? __weightsSmoothed;
  Vector get _weightsSmoothed => __weightsSmoothed ??=
      _gaussianInterpolation(
        _linearExtrapolation(_linearInterpolation(_weights)),
      ) *
      _isMeasurement;

  Vector? __weightsLinExtrapol;
  Vector get _weightsLinExtrapol => __weightsLinExtrapol ??=
      _linearExtrapolation(_linearInterpolation(_weightsSmoothed));

  Vector? __weightsGaussianExtrapol;
  Vector get _weightsGaussianExtrapol =>
      __weightsGaussianExtrapol ??= _gaussianInterpolation(_weightsLinExtrapol);

  /// convert display idx to internal idx (returns null if out of range)
  int? _idxDisplayToInternal(int idxDisplay) {
    final int idxInternal = idxDisplay + _offsetInDays - _offsetInDaysShown;
    if (idxInternal < 0 || idxInternal >= _n) {
      return null;
    }
    return idxInternal;
  }

  // ---------------------------------------------------------------------------
  // Public API — display-length vectors
  // ---------------------------------------------------------------------------

  Vector? _weightsDisplay;

  /// Interpolated weights to display (smoothed + extrapolated, display length).
  Vector get weights => _weightsDisplay ??= _createWeightsDisplay();

  /// Content-based hash of the interpolated weights vector.
  int get hashCode => Object.hashAll(weights);

  Vector _createWeightsDisplay() {
    if (_n == 0) {
      return _weights;
    }

    if (interpolStrength == InterpolStrength.none) {
      final Vector weightsLinear = _linearInterpolation(
        _weights,
      ).subvector(_offsetInDays, _n - _offsetInDays);

      final Vector weightsExtrapol =
          Vector.fromList(<double>[
            for (int idx = 1; idx <= _offsetInDaysShown; idx++)
              _finalSlope * idx,
          ]) +
          weightsLinear.last;

      return Vector.fromList(weightsLinear.toList()..addAll(weightsExtrapol));
    }
    return _weightsGaussianExtrapol.subvector(
      _offsetInDays - _offsetInDaysShown,
      _n - _offsetInDays + _offsetInDaysShown,
    );
  }

  Vector? _measurementsDisplay;

  /// Raw (daily-averaged) measurements aligned with [times].
  /// 0 on days without a measurement.
  Vector get measurements =>
      _measurementsDisplay ??= _createMeasurementsDisplay();

  Vector _createMeasurementsDisplay() {
    if (_n == 0) {
      return _weights;
    }
    if (interpolStrength == InterpolStrength.none) {
      final Vector slice = _weights.subvector(
        _offsetInDays,
        _n - _offsetInDays,
      );
      return Vector.fromList(
        slice.toList()..addAll(List<double>.filled(_offsetInDaysShown, 0)),
      );
    }
    return _weights.subvector(
      _offsetInDays - _offsetInDaysShown,
      _n - _offsetInDays + _offsetInDaysShown,
    );
  }

  Vector? _isMeasurementDisplay;

  /// 1 if the corresponding [times] entry has a measurement, 0 otherwise.
  Vector get isMeasurement =>
      _isMeasurementDisplay ??= _createIsMeasurementDisplay();

  Vector _createIsMeasurementDisplay() {
    if (_n == 0) {
      return _isMeasurement;
    }
    if (interpolStrength == InterpolStrength.none) {
      final Vector slice = _isMeasurement.subvector(
        _offsetInDays,
        _n - _offsetInDays,
      );
      return Vector.fromList(
        slice.toList()..addAll(List<double>.filled(_offsetInDaysShown, 0)),
      );
    }
    return _isMeasurement.subvector(
      _offsetInDays - _offsetInDaysShown,
      _n - _offsetInDays + _offsetInDaysShown,
    );
  }

  Vector? _timesDisplay;

  /// Times in ms since epoch, display length (one entry per day).
  Vector get times => _timesDisplay ??= _n == 0
      ? _times
      : _times.subvector(
              (interpolStrength == InterpolStrength.none)
                  ? _offsetInDays
                  : _offsetInDays - _offsetInDaysShown,
              _n - _offsetInDays + _offsetInDaysShown,
            ) +
            _dailyOffsetInHours / 24 * _dayInMs;

  /// Number of days between first and last measurement (inclusive).
  int get nDays => times.length - 2 * _offsetInDaysShown;

  // ---------------------------------------------------------------------------
  // Public API — date-range filtered accessors
  // ---------------------------------------------------------------------------

  /// Return the pair of display-vector indices for the optional date range.
  /// If [from] is null, starts at 0. If [to] is null, ends at the last index.
  (int start, int end) _displayRange({DateTime? from, DateTime? to}) {
    final int start = from != null ? (indexForDay(from) ?? 0) : 0;
    final int end = to != null
        ? ((indexForDay(to) ?? times.length - 1) + 1)
        : times.length;
    return (start, end);
  }

  /// Subvector of [times] between [from] and [to].
  Vector timesInRange({DateTime? from, DateTime? to}) {
    final (int start, int end) = _displayRange(from: from, to: to);
    return times.subvector(start, end);
  }

  /// Subvector of [weights] between [from] and [to].
  Vector weightsInRange({DateTime? from, DateTime? to}) {
    final (int start, int end) = _displayRange(from: from, to: to);
    return weights.subvector(start, end);
  }

  /// Subvector of [measurements] between [from] and [to].
  Vector measurementsInRange({DateTime? from, DateTime? to}) {
    final (int start, int end) = _displayRange(from: from, to: to);
    return measurements.subvector(start, end);
  }

  /// Subvector of [isMeasurement] between [from] and [to].
  Vector isMeasurementInRange({DateTime? from, DateTime? to}) {
    final (int start, int end) = _displayRange(from: from, to: to);
    return isMeasurement.subvector(start, end);
  }

  /// Return only the actual measurement data points (filtering out
  /// interpolated days) within the optional date range.
  ({Vector times, Vector measurements}) measured({
    DateTime? from,
    DateTime? to,
  }) {
    final Vector t = timesInRange(from: from, to: to);
    final Vector m = measurementsInRange(from: from, to: to);
    final Vector mask = isMeasurementInRange(from: from, to: to);

    bool isMeasured(double _, int i) => mask[i] == 1;

    return (
      times: t.filterElements(isMeasured),
      measurements: m.filterElements(isMeasured),
    );
  }

  // ---------------------------------------------------------------------------
  // Internal interpolation helpers
  // ---------------------------------------------------------------------------

  Vector _linearExtrapolation(Vector w) {
    final List<double> wList = w.toList();

    if (db.nMeasurements == 0) {
      return Vector.empty();
    } else if (_idxsMeasurements.length == 1) {
      return Vector.filled(_n, w[_idxsMeasurements[0]]);
    }

    final Vector initialExtrapolation = _linearRegression(
      w,
      _times[_offsetInDays],
      _times.subvector(0, _offsetInDays),
    );
    final Vector finalExtrapolation = _linearRegression(
      w,
      _times[_n - _offsetInDays],
      _times.subvector(_n - _offsetInDays, _n),
    );

    for (int idx = 0; idx < _offsetInDays; idx++) {
      wList[idx] = initialExtrapolation[idx];
      wList[_n - _offsetInDays + idx] = finalExtrapolation[idx];
    }

    return Vector.fromList(wList, dtype: dtype);
  }

  Vector _linearRegression(Vector w, double tRef, Vector ts) {
    final Vector gsWeights = _gaussianWeights(tRef, w);
    final double meanWeight = gsWeights.dot(w);
    final double meanTime = gsWeights.dot(_times);
    final double meanChange =
        gsWeights.dot((w - meanWeight) * _times) /
        gsWeights.dot((_times - meanTime) * _times);
    final double intercept = meanWeight - meanChange * meanTime;

    return Vector.fromList(<double>[
      for (final double t in ts)
        meanChange * t + intercept < 0 ? 0 : meanChange * t + intercept,
    ], dtype: dtype);
  }

  Vector _linearInterpolation(Vector w) {
    final List<double> wList = w.toList();
    int idxFrom, idxTo;
    double changeRate;

    if (db.nMeasurements == 0) {
      return Vector.empty();
    } else if (_idxsMeasurements.length == 1) {
      return Vector.filled(_n, w[_idxsMeasurements[0]]);
    }

    for (int idx = 0; idx < _idxsMeasurements.length - 1; idx++) {
      idxFrom = _idxsMeasurements[idx];
      idxTo = _idxsMeasurements[idx + 1];
      if (idxFrom + 1 < idxTo) {
        changeRate = _slope(idxFrom, idxTo, w);
        for (int idxJ = idxFrom + 1; idxJ < idxTo; idxJ++) {
          wList[idxJ] = wList[idxFrom] + changeRate * (idxJ - idxFrom);
        }
      }
    }
    return Vector.fromList(wList, dtype: dtype);
  }

  double _slope(int idxFrom, int idxTo, Vector w) =>
      w.isNotEmpty ? (w[idxTo] - w[idxFrom]) / (idxTo - idxFrom) : 0;

  /// first derivative of gaussian Interpolation. Internal idx!
  double _derivative(int idx) {
    // check if idx + 2 and idx- 2 are in range
    if (idx - 2 >= 0 && idx + 2 < _n) {
      return (1 * _weightsGaussianExtrapol[idx - 2] -
              8 * _weightsGaussianExtrapol[idx - 1] +
              8 * _weightsGaussianExtrapol[idx + 1] -
              1 * _weightsGaussianExtrapol[idx + 2]) /
          12;
    } else if (idx - 1 >= 0 && idx + 1 < _n) {
      return (_weightsGaussianExtrapol[idx - 1] -
              _weightsGaussianExtrapol[idx + 1]) /
          2;
    }
    return 0;
  }

  Vector _gaussianInterpolation(Vector w) => Vector.fromList(<double>[
    for (final int idx in _timesIdx)
      (w[idx] != 0) ? _gaussianMean(_times[idx], w) : 0,
  ], dtype: dtype);

  // ---------------------------------------------------------------------------
  // Public API — scalar helpers
  // ---------------------------------------------------------------------------

  /// Final slope of extrapolation [kg/day].
  double get _finalSlope => _derivative(_idxLast);
  // _slope(_idxLast, _idxLast + _offsetInDaysShown, _weightsGaussianExtrapol);

  /// get slope of display weights at [day]
  double slopeAtDay(DateTime day) {
    final int? idx = indexForDay(day);
    final int? idxInternal = idx != null ? _idxDisplayToInternal(idx) : null;
    if (idxInternal == null) {
      return 0;
    }

    return _derivative(idxInternal);
  }

  /// Return the index into display vectors for a given [day], or null
  /// if [day] falls outside the display range.
  int? indexForDay(DateTime day) {
    if (times.isEmpty) {
      return null;
    }
    final double dayMs =
        DateTime(
          day.year,
          day.month,
          day.day,
        ).millisecondsSinceEpoch.toDouble() +
        _dailyOffsetInHours / 24 * _dayInMs;
    final int idx = ((dayMs - times.first) / _dayInMs).round();
    if (idx < 0 || idx >= times.length) {
      return null;
    }
    return idx;
  }

  /// Return the interpolated weight for [day], or null if out of range.
  double? interpolationForDay(DateTime day) {
    final int? idx = indexForDay(day);
    return idx != null ? weights[idx] : null;
  }

  /// Return the raw measurement for [day], or null if out of range or no
  /// measurement on that day.
  double? measurementForDay(DateTime day) {
    final int? idx = indexForDay(day);
    if (idx == null || isMeasurement[idx] == 0) {
      return null;
    }
    return measurements[idx];
  }

  /// Whether a measurement exists on [day].
  bool hasMeasurementOnDay(DateTime day) {
    final int? idx = indexForDay(day);
    return idx != null && isMeasurement[idx] == 1;
  }

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
  static const int _cacheVersion = 2;

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
      if (cached == null) {
        return false;
      }

      final Map<String, dynamic> map =
          jsonDecode(cached) as Map<String, dynamic>;

      // Validate cache matches current state
      if (map['version'] != _cacheVersion) {
        return false;
      }
      if (map['nMeasurements'] != db.nMeasurements) {
        return false;
      }
      if (map['interpolStrength'] != interpolStrength.name) {
        return false;
      }

      if (db.nMeasurements == 0) {
        return false;
      }

      if (map['firstDateMs'] != db.firstDate.millisecondsSinceEpoch) {
        return false;
      }
      if (map['lastDateMs'] != db.lastDate.millisecondsSinceEpoch) {
        return false;
      }

      // Restore all vectors
      __dateTimes = (map['dateTimes'] as List<dynamic>)
          .map(
            (dynamic ms) =>
                DateTime.fromMillisecondsSinceEpoch((ms as num).toInt()),
          )
          .toList();
      __times = _vectorFromJson(map['times']);
      __isExtrapolated = _vectorFromJson(map['isExtrapolated']);
      __weights = _vectorFromJson(map['weights']);
      __isMeasurement = _vectorFromJson(map['isMeasurement']);
      __idxsMeasurements = (map['idxsMeasurements'] as List<dynamic>)
          .map((dynamic e) => (e as num).toInt())
          .toList();
      __timesMeasured = _vectorFromJson(map['timesMeasured']);
      __weightsMeasured = _vectorFromJson(map['weightsMeasured']);
      __weightsSmoothed = _vectorFromJson(map['weightsSmoothed']);
      __weightsLinExtrapol = _vectorFromJson(map['weightsLinExtrapol']);
      __weightsGaussianExtrapol = _vectorFromJson(
        map['weightsGaussianExtrapol'],
      );
      _weightsDisplay = _vectorFromJson(map['weightsDisplay']);
      _measurementsDisplay = _vectorFromJson(map['measurementsDisplay']);
      _isMeasurementDisplay = _vectorFromJson(map['isMeasurementDisplay']);
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
        'dateTimes': _dateTimes
            .map((DateTime dt) => dt.millisecondsSinceEpoch)
            .toList(),
        'times': _times.toList(),
        'isExtrapolated': _isExtrapolated.toList(),
        'weights': _weights.toList(),
        'isMeasurement': _isMeasurement.toList(),
        'idxsMeasurements': _idxsMeasurements,
        'timesMeasured': _timesMeasured.toList(),
        'weightsMeasured': _weightsMeasured.toList(),
        'weightsSmoothed': _weightsSmoothed.toList(),
        'weightsLinExtrapol': _weightsLinExtrapol.toList(),
        'weightsGaussianExtrapol': _weightsGaussianExtrapol.toList(),
        'weightsDisplay': weights.toList(),
        'measurementsDisplay': measurements.toList(),
        'isMeasurementDisplay': isMeasurement.toList(),
        'timesDisplay': times.toList(),
      };
      Preferences().prefs.setString(_cacheKey, jsonEncode(map));
    } catch (e) {
      // Cache save failure is non-critical
    }
  }

  /// Deserialize a JSON list back into a Vector.
  static Vector _vectorFromJson(dynamic json) {
    if (json == null) {
      return Vector.empty();
    }
    final List<double> list = (json as List<dynamic>)
        .map((dynamic e) => (e as num).toDouble())
        .toList();
    return list.isEmpty
        ? Vector.empty()
        : Vector.fromList(list, dtype: MeasurementInterpolationBaseclass.dtype);
  }
}
