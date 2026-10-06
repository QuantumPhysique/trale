part of 'measurement_interpolation.dart';

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

  /// Whether the automatic strength is fitted to these measurements; only the
  /// user's own diary is.
  bool get learnsAutoStrength => false;

  /// Bandwidth in days the learned automatic strength smooths with at this
  /// diary's density of readings, null before its first accepted fit.
  double? get learnedAutoStrengthInDays {
    final double? ratio = Preferences().autoStrengthRatio;
    if (ratio == null || nDays == 0) {
      return null;
    }
    // A sparser diary spreads the same ratio over more days.
    return bandwidthForRatio(ratio * isMeasurement.sum() / nDays);
  }

  /// Whether the curve is drawn as straight lines between the measurements,
  /// which only a manual [InterpolStrength.none] does.
  bool get _isNone =>
      !Preferences().autoStrength && interpolStrength == InterpolStrength.none;

  /// re initialize database
  void reinit() {
    _clear();
    init();
  }

  /// re initialize database asynchronously (offloads the interpolation
  /// pipeline to a background isolate via [compute]). Until it is done, the
  /// previous curve stays readable.
  Future<void> reinitAsync() async {
    final int generation = ++_generation;
    __dateTimes = null;
    __times = null;
    __weights = null;
    if (_n == 0) {
      _clearDisplay();
      return;
    }
    final _InterpolationPayload payload = _payload(
      mayTryAutoStrength: learnsAutoStrength,
    );
    final _InterpolationResult result = await compute(
      _computeInterpolation,
      payload,
    );
    // A newer call has rebuilt the inputs in the meantime.
    if (generation != _generation) {
      return;
    }
    _clearDisplay();
    _store(result);
    if (payload.tryAutoStrength) {
      Preferences().autoStrengthDays = payload.idxsMeasurements.length;
      if (result.learnedAutoStrength != null) {
        Preferences().autoStrengthRatio = result.learnedAutoStrength;
      }
    }
  }

  /// initialize database
  void init() {
    if (_n > 0) {
      // A fit of the automatic strength would block the UI here.
      _store(_computeInterpolation(_payload(mayTryAutoStrength: false)));
    }
  }

  /// Counts recomputes, so that a result overtaken by a newer one is dropped.
  int _generation = 0;

  void _clear() {
    _generation++;
    __dateTimes = null;
    __times = null;
    __weights = null;
    _clearDisplay();
  }

  void _clearDisplay() {
    _timesDisplay = null;
    _weightsDisplay = null;
    _slopesDisplay = null;
    _bandLower = null;
    _bandUpper = null;
    _measurementsDisplay = null;
    _isMeasurementDisplay = null;
  }

  _InterpolationPayload _payload({required bool mayTryAutoStrength}) {
    // Building the weights builds _idxsMeasurements and _countsMeasured too.
    final Vector weights = _weights;
    final Preferences prefs = Preferences();
    return _InterpolationPayload(
      idxsMeasurements: _idxsMeasurements,
      weightsMeasured: <double>[
        for (final int idx in _idxsMeasurements) weights[idx],
      ],
      counts: _countsMeasured,
      manualRatio: prefs.autoStrength ? null : interpolStrength.processVariance,
      autoStrengthRatio:
          prefs.autoStrengthRatio ?? ratioForBandwidth(autoStrengthStartInDays),
      tryAutoStrength:
          mayTryAutoStrength &&
          nDays >= autoStrengthMinHistoryInDays &&
          _idxsMeasurements.length - prefs.autoStrengthDays >=
              autoStrengthTryEveryDays,
      isNone: _isNone,
      displayStart: _displayStart,
      displayEnd: _displayEnd,
    );
  }

  /// Stores [result] with every display vector derived from the same inputs,
  /// so that none is derived later from newer ones.
  void _store(_InterpolationResult result) {
    _weightsDisplay = Vector.fromList(result.weights, dtype: dtype);
    _slopesDisplay = Vector.fromList(result.slopes, dtype: dtype);
    _bandLower = Vector.fromList(result.bandLower, dtype: dtype);
    _bandUpper = Vector.fromList(result.bandUpper, dtype: dtype);
    times;
    measurements;
    isMeasurement;
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
  List<DateTime> get _dateTimes => __dateTimes ??= _createDateTimes();

  List<DateTime> _createDateTimes() {
    if (db.nMeasurements == 0) {
      return <DateTime>[];
    }

    final DateTime first = db.firstDate;
    final DateTime last = db.lastDate;
    // Counted on dates: a timestamp difference loses a day when the last
    // reading is earlier in the day than the first, or across a clock change.
    final int days = DateTime.utc(
      last.year,
      last.month,
      last.day,
    ).difference(DateTime.utc(first.year, first.month, first.day)).inDays;
    final int timeSpawn = days + 1 + 2 * _offsetInDaysShown;

    return List<DateTime>.generate(
      timeSpawn,
      (int idx) => DateTime(
        db.firstDate.year,
        db.firstDate.month,
        db.firstDate.day + idx - _offsetInDaysShown,
      ),
    );
  }

  Vector? __times;
  Vector get _times => __times ??= _createTimes();

  Vector _createTimes() {
    final List<DateTime> dts = _dateTimes;
    if (dts.isEmpty) {
      return Vector.empty();
    }
    return Vector.fromList(
      dts.map((DateTime dt) => dt.millisecondsSinceEpoch).toList(),
      dtype: dtype,
    );
  }

  Vector? __weights;
  Vector get _weights => __weights ??= _createWeights();

  Vector _createWeights() {
    if (_n == 0) {
      __isMeasurement = Vector.empty();
      __idxsMeasurements = <int>[];
      __countsMeasured = <int>[];
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
    __countsMeasured = <int>[for (final int idx in idxMs) counts[idx].toInt()];

    return Vector.fromList(ms, dtype: dtype) /
        Vector.fromList(counts).mapToVector((double val) => val == 0 ? 1 : val);
  }

  late Vector __isMeasurement;
  Vector get _isMeasurement => __isMeasurement;

  late List<int> __idxsMeasurements;
  List<int> get _idxsMeasurements => __idxsMeasurements;

  late List<int> __countsMeasured;

  /// Number of measurements on each day of [_idxsMeasurements].
  List<int> get _countsMeasured => __countsMeasured;

  /// First displayed internal index; `none` starts at the first measurement.
  int get _displayStart => _isNone ? _offsetInDaysShown : 0;

  /// One past the last displayed internal index.
  int get _displayEnd => _n;

  // -----------------------------------------------------------
  // Public API — display-length vectors
  // -----------------------------------------------------------

  Vector? _weightsDisplay;

  /// Interpolated weights to display (smoothed + extrapolated,
  /// display length).
  Vector get weights => _weightsDisplay ?? _weights;

  Vector? _slopesDisplay;

  Vector? _bandLower;

  /// Lower edge of the 95 % predictive band, the range a single measurement
  /// is expected in; empty below seven days with measurements and for
  /// [InterpolStrength.none].
  Vector get bandLower => _bandLower ?? Vector.empty();

  Vector? _bandUpper;

  /// Upper edge of the band, see [bandLower].
  Vector get bandUpper => _bandUpper ?? Vector.empty();

  /// Whether [bandLower] and [bandUpper] hold a band.
  bool get hasBand => bandLower.isNotEmpty;

  /// Content-based hash of the interpolated weights vector.
  @override
  int get hashCode => Object.hashAll(weights);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeasurementInterpolationBaseclass && hashCode == other.hashCode;

  Vector? _measurementsDisplay;

  /// Raw (daily-averaged) measurements aligned with [times].
  /// 0 on days without a measurement.
  Vector get measurements =>
      _measurementsDisplay ??= _createMeasurementsDisplay();

  Vector _createMeasurementsDisplay() =>
      _n == 0 ? _weights : _weights.subvector(_displayStart, _displayEnd);

  Vector? _isMeasurementDisplay;

  /// 1 if the corresponding [times] entry has a measurement,
  /// 0 otherwise.
  Vector get isMeasurement =>
      _isMeasurementDisplay ??= _createIsMeasurementDisplay();

  Vector _createIsMeasurementDisplay() => _n == 0
      ? _isMeasurement
      : _isMeasurement.subvector(_displayStart, _displayEnd);

  Vector? _timesDisplay;

  /// Times in ms since epoch, display length (one entry per day).
  Vector get times => _timesDisplay ??= _n == 0
      ? _times
      : _times.subvector(_displayStart, _displayEnd) +
            _dailyOffsetInHours / 24 * _dayInMs;

  /// Number of days between first and last measurement
  /// (inclusive).
  int get nDays => _n == 0 ? 0 : _n - 2 * _offsetInDaysShown;

  // -----------------------------------------------------------
  // Public API — date-range filtered accessors
  // -----------------------------------------------------------

  /// Return the pair of display-vector indices for the optional
  /// date range. If [from] is null, starts at 0. If [to] is
  /// null, ends at the last index.
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

  /// Return only the actual measurement data points (filtering
  /// out interpolated days) within the optional date range.
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

  /// Return only the actual deviatoin of measurement data points
  /// (filtering out interpolated days) within the optional date
  /// range from the interpolation.
  ({Vector times, Vector difference}) measuredDiff({
    DateTime? from,
    DateTime? to,
  }) {
    final Vector t = timesInRange(from: from, to: to);
    final Vector m = measurementsInRange(from: from, to: to);
    final Vector w = weightsInRange(from: from, to: to);
    final Vector mask = isMeasurementInRange(from: from, to: to);

    bool isMeasured(double _, int i) => mask[i] == 1;

    return (
      times: t.filterElements(isMeasured),
      difference: (w - m).filterElements(isMeasured),
    );
  }

  // -----------------------------------------------------------
  // Public API — scalar helpers
  // -----------------------------------------------------------

  /// Slope of the trend at [day] in kg/day, 0 outside the display range.
  double slopeAtDay(DateTime day) {
    final int? idx = indexForDay(day);
    return idx != null ? _slopesDisplay![idx] : 0;
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
    final int idx = ((dayMs - times.first) / _dayInMs).round();
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

  /// Days shown before the first and after the last measurement.
  static const int _offsetInDaysShown = 7;

  /// offset of day in interpolation shown
  static const int _dailyOffsetInHours = 12;

  /// 24h given in [ms]
  static const int _dayInMs = 24 * 3600 * 1000;
}
