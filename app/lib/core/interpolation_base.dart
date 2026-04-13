part of 'measurement_interpolation.dart';

/// Base class for measurement interpolation
class MeasurementInterpolationBaseclass {
  /// Creates a [MeasurementInterpolationBaseclass] and calls [init].
  MeasurementInterpolationBaseclass() {
    init();
  }

  /// The underlying measurement database.
  MeasurementDatabaseBaseclass get db =>
      MeasurementDatabaseBaseclass();

  /// get interpolation strength values
  InterpolStrength get interpolStrength =>
      Preferences().interpolStrength;

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

  /// re initialize database asynchronously (offloads the entire
  /// interpolation pipeline — linear interpolation, Gaussian
  /// regression, Gaussian smoothing, and weightsDisplay — to a
  /// background isolate via [compute]).
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

    // Compute the lightweight synchronous vectors first (times,
    // weights, isMeasurement, idxsMeasurements).  These are O(N)
    // and fast.
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
        strengthMeasurement:
            interpolStrength.strengthMeasurement,
        strengthInterpol: interpolStrength.strengthInterpol,
        interpolWeight: interpolStrength.weight,
        interpolStrengthIsNone:
            interpolStrength == InterpolStrength.none,
      ),
    );

    // Store the results.
    __weightsSmoothed = Vector.fromList(
      result.weightsSmoothed,
      dtype: dtype,
    );
    __weightsLinExtrapol = Vector.fromList(
      result.weightsLinExtrapol,
      dtype: dtype,
    );
    __weightsGaussianExtrapol = Vector.fromList(
      result.weightsGaussianExtrapol,
      dtype: dtype,
    );
    _weightsDisplay = Vector.fromList(
      result.weightsDisplay,
      dtype: dtype,
    );

    // Derive remaining display vectors (cheap subvector / offset
    // ops).
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

  // -----------------------------------------------------------
  // Internal (length-N) vectors — all private
  // -----------------------------------------------------------

  /// internal length of full vectors (including extrapolation
  /// padding)
  int get _n => _times.length;

  List<DateTime>? __dateTimes;
  List<DateTime> get _dateTimes =>
      __dateTimes ??= _createDateTimes();

  List<DateTime> _createDateTimes() {
    if (db.nMeasurements == 0) {
      return <DateTime>[];
    }

    final int timeSpawn =
        db.lastDate.difference(db.firstDate).inDays +
        1 +
        2 * _offsetInDays;

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
            ((idx < _offsetInDays) ||
                    (idx + 1 > dts.length - _offsetInDays))
                ? 1
                : 0,
      ),
    );
    return Vector.fromList(
      dts
          .map(
            (DateTime dt) => dt.millisecondsSinceEpoch,
          )
          .toList(),
      dtype: dtype,
    );
  }

  List<int>? __timesIdx;
  List<int> get _timesIdx =>
      __timesIdx ??=
          List<int>.generate(_n, (int idx) => idx);

  Vector? __timesMeasured;
  Vector get _timesMeasured =>
      __timesMeasured ??= _createTimesMeasured();

  Vector _createTimesMeasured() {
    return Vector.fromList(<int>[
      for (final Measurement ms in db.measurements.reversed)
        ms.dateInMs,
    ], dtype: dtype);
  }

  Vector? __weightsMeasured;
  Vector get _weightsMeasured =>
      __weightsMeasured ??= _createWeightsMeasured();

  Vector _createWeightsMeasured() {
    return Vector.fromList(<double>[
      for (final Measurement ms in db.measurements.reversed)
        ms.weight,
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
        Vector.fromList(counts).mapToVector(
          (double val) => val == 0 ? 1 : val,
        );

    __idxsMeasurements = idxMs;

    return Vector.fromList(ms, dtype: dtype) /
        Vector.fromList(counts).mapToVector(
          (double val) => val == 0 ? 1 : val,
        );
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
  Vector get _sigma =>
      __sigma ??=
          (_isMeasurement *
                      interpolStrength.strengthMeasurement +
                  _isNoMeasurement *
                      interpolStrength.strengthInterpol) *
              _dayInMs;

  Vector _gaussianWeights(double t, Vector ms) {
    final Vector norm =
        (_sigma * math.sqrt(2 * math.pi)).pow(-1);
    final Vector gw =
        ((_times - t).pow(2) / (_sigma.pow(2) * -2)).exp() *
        norm *
        (_isMeasurement * interpolStrength.weight +
            _isNoMeasurement);
    final Vector mask =
        ms.mapToVector((double val) => val > 0 ? 1 : 0);

    return (gw * mask) / (gw * mask).sum();
  }

  double _gaussianMean(double t, Vector ms) =>
      _gaussianWeights(t, ms).dot(ms);

  Vector? __weightsSmoothed;
  Vector get _weightsSmoothed =>
      __weightsSmoothed ??=
          _gaussianInterpolation(
            _linearExtrapolation(
              _linearInterpolation(_weights),
            ),
          ) *
          _isMeasurement;

  Vector? __weightsLinExtrapol;
  Vector get _weightsLinExtrapol =>
      __weightsLinExtrapol ??= _linearExtrapolation(
        _linearInterpolation(_weightsSmoothed),
      );

  Vector? __weightsGaussianExtrapol;
  Vector get _weightsGaussianExtrapol =>
      __weightsGaussianExtrapol ??=
          _gaussianInterpolation(_weightsLinExtrapol);

  /// convert display idx to internal idx (returns null if out of
  /// range)
  int? _idxDisplayToInternal(int idxDisplay) {
    final int idxInternal =
        idxDisplay + _offsetInDays - _offsetInDaysShown;
    if (idxInternal < 0 || idxInternal >= _n) {
      return null;
    }
    return idxInternal;
  }

  // -----------------------------------------------------------
  // Public API — display-length vectors
  // -----------------------------------------------------------

  Vector? _weightsDisplay;

  /// Interpolated weights to display (smoothed + extrapolated,
  /// display length).
  Vector get weights =>
      _weightsDisplay ??= _createWeightsDisplay();

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

      return Vector.fromList(
        weightsLinear.toList()..addAll(weightsExtrapol),
      );
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
        slice.toList()
          ..addAll(
            List<double>.filled(_offsetInDaysShown, 0),
          ),
      );
    }
    return _weights.subvector(
      _offsetInDays - _offsetInDaysShown,
      _n - _offsetInDays + _offsetInDaysShown,
    );
  }

  Vector? _isMeasurementDisplay;

  /// 1 if the corresponding [times] entry has a measurement,
  /// 0 otherwise.
  Vector get isMeasurement =>
      _isMeasurementDisplay ??=
          _createIsMeasurementDisplay();

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
        slice.toList()
          ..addAll(
            List<double>.filled(_offsetInDaysShown, 0),
          ),
      );
    }
    return _isMeasurement.subvector(
      _offsetInDays - _offsetInDaysShown,
      _n - _offsetInDays + _offsetInDaysShown,
    );
  }

  Vector? _timesDisplay;

  /// Times in ms since epoch, display length (one entry per day).
  Vector get times =>
      _timesDisplay ??= _n == 0
          ? _times
          : _times.subvector(
                  (interpolStrength == InterpolStrength.none)
                      ? _offsetInDays
                      : _offsetInDays - _offsetInDaysShown,
                  _n - _offsetInDays + _offsetInDaysShown,
                ) +
              _dailyOffsetInHours / 24 * _dayInMs;

  /// Number of days between first and last measurement
  /// (inclusive).
  int get nDays => times.length - 2 * _offsetInDaysShown;

  // -----------------------------------------------------------
  // Public API — date-range filtered accessors
  // -----------------------------------------------------------

  /// Return the pair of display-vector indices for the optional
  /// date range. If [from] is null, starts at 0. If [to] is
  /// null, ends at the last index.
  (int start, int end) _displayRange({
    DateTime? from,
    DateTime? to,
  }) {
    final int start =
        from != null ? (indexForDay(from) ?? 0) : 0;
    final int end = to != null
        ? ((indexForDay(to) ?? times.length - 1) + 1)
        : times.length;
    return (start, end);
  }

  /// Subvector of [times] between [from] and [to].
  Vector timesInRange({DateTime? from, DateTime? to}) {
    final (int start, int end) =
        _displayRange(from: from, to: to);
    return times.subvector(start, end);
  }

  /// Subvector of [weights] between [from] and [to].
  Vector weightsInRange({DateTime? from, DateTime? to}) {
    final (int start, int end) =
        _displayRange(from: from, to: to);
    return weights.subvector(start, end);
  }

  /// Subvector of [measurements] between [from] and [to].
  Vector measurementsInRange({
    DateTime? from,
    DateTime? to,
  }) {
    final (int start, int end) =
        _displayRange(from: from, to: to);
    return measurements.subvector(start, end);
  }

  /// Subvector of [isMeasurement] between [from] and [to].
  Vector isMeasurementInRange({
    DateTime? from,
    DateTime? to,
  }) {
    final (int start, int end) =
        _displayRange(from: from, to: to);
    return isMeasurement.subvector(start, end);
  }

  /// Return only the actual measurement data points (filtering
  /// out interpolated days) within the optional date range.
  ({Vector times, Vector measurements}) measured({
    DateTime? from,
    DateTime? to,
  }) {
    final Vector t = timesInRange(from: from, to: to);
    final Vector m =
        measurementsInRange(from: from, to: to);
    final Vector mask =
        isMeasurementInRange(from: from, to: to);

    bool isMeasured(double _, int i) => mask[i] == 1;

    return (
      times: t.filterElements(isMeasured),
      measurements: m.filterElements(isMeasured),
    );
  }

  /// Return only the actual deviatoin of measurement data points
  /// (filtering out interpolated days) within the optional date
  /// range from the interpolation.
  ({Vector times, Vector difference}) measuredDiff({
    DateTime? from,
    DateTime? to,
  }) {
    final Vector t = timesInRange(from: from, to: to);
    final Vector m =
        measurementsInRange(from: from, to: to);
    final Vector w = weightsInRange(from: from, to: to);
    final Vector mask =
        isMeasurementInRange(from: from, to: to);

    bool isMeasured(double _, int i) => mask[i] == 1;

    return (
      times: t.filterElements(isMeasured),
      difference: (w - m).filterElements(isMeasured),
    );
  }

  // -----------------------------------------------------------
  // Internal interpolation helpers
  // -----------------------------------------------------------

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
      wList[_n - _offsetInDays + idx] =
          finalExtrapolation[idx];
    }

    return Vector.fromList(wList, dtype: dtype);
  }

  Vector _linearRegression(
    Vector w,
    double tRef,
    Vector ts,
  ) {
    final Vector gsWeights = _gaussianWeights(tRef, w);
    final double meanWeight = gsWeights.dot(w);
    final double meanTime = gsWeights.dot(_times);
    final double meanChange =
        gsWeights.dot((w - meanWeight) * _times) /
        gsWeights.dot((_times - meanTime) * _times);
    final double intercept =
        meanWeight - meanChange * meanTime;

    return Vector.fromList(<double>[
      for (final double t in ts)
        meanChange * t + intercept < 0
            ? 0
            : meanChange * t + intercept,
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

    for (int idx = 0;
        idx < _idxsMeasurements.length - 1;
        idx++) {
      idxFrom = _idxsMeasurements[idx];
      idxTo = _idxsMeasurements[idx + 1];
      if (idxFrom + 1 < idxTo) {
        changeRate = _slope(idxFrom, idxTo, w);
        for (int idxJ = idxFrom + 1; idxJ < idxTo; idxJ++) {
          wList[idxJ] =
              wList[idxFrom] + changeRate * (idxJ - idxFrom);
        }
      }
    }
    return Vector.fromList(wList, dtype: dtype);
  }

  double _slope(int idxFrom, int idxTo, Vector w) =>
      w.isNotEmpty
          ? (w[idxTo] - w[idxFrom]) / (idxTo - idxFrom)
          : 0;

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

  Vector _gaussianInterpolation(Vector w) =>
      Vector.fromList(<double>[
        for (final int idx in _timesIdx)
          (w[idx] != 0)
              ? _gaussianMean(_times[idx], w)
              : 0,
      ], dtype: dtype);

  // -----------------------------------------------------------
  // Public API — scalar helpers
  // -----------------------------------------------------------

  /// Final slope of extrapolation [kg/day].
  double get _finalSlope => _derivative(_idxLast);

  /// get slope of display weights at [day]
  double slopeAtDay(DateTime day) {
    final int? idx = indexForDay(day);
    final int? idxInternal =
        idx != null ? _idxDisplayToInternal(idx) : null;
    if (idxInternal == null) {
      return 0;
    }

    return _derivative(idxInternal);
  }

  /// Return the index into display vectors for a given [day],
  /// or null if [day] falls outside the display range.
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
    final int idx =
        ((dayMs - times.first) / _dayInMs).round();
    if (idx < 0 || idx >= times.length) {
      return null;
    }
    return idx;
  }

  /// Return the interpolated weight for [day], or null if out
  /// of range.
  double? interpolationForDay(DateTime day) {
    final int? idx = indexForDay(day);
    return idx != null ? weights[idx] : null;
  }

  /// Return the raw measurement for [day], or null if out of
  /// range or no measurement on that day.
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
