part of 'measurement_interpolation.dart';

// ---------------------------------------------------------------------------
// Isolate payload & top-level function
// ---------------------------------------------------------------------------

/// The measured days on the internal daily grid, and the part of the grid
/// that is displayed, for [_computeInterpolation].
class _InterpolationPayload {
  _InterpolationPayload({
    required this.idxsMeasurements,
    required this.weightsMeasured,
    required this.counts,
    required this.physiological,
    required this.slopeSd,
    required this.state,
    required this.stepKg,
    required this.refit,
    required this.strengthMeasurement,
    required this.strengthInterpol,
    required this.interpolWeight,
    required this.firstDay,
    required this.gridLength,
    required this.isNone,
    required this.displayStart,
    required this.displayEnd,
  });

  /// Grid index of every day with a measurement, ascending.
  final List<int> idxsMeasurements;

  /// Mean weight of each of those days.
  final List<double> weightsMeasured;

  /// Number of measurements on each of those days.
  final List<int> counts;

  /// Whether the physiological model draws the curve, otherwise the
  /// Gaussian interpolation.
  final bool physiological;

  /// Slope sd of the strength, see [InterpolStrengthExtension.slopeSd].
  final double slopeSd;

  /// The amplitudes and the scale error the curve is drawn with.
  final SmoothingState state;

  /// Step in kg that weights are entered in.
  final double stepKg;

  /// Whether to refit [state] before smoothing.
  final bool refit;

  /// Gaussian width in days around a measured day, see
  /// [InterpolStrengthExtension.strengthMeasurement].
  final double strengthMeasurement;

  /// Gaussian width in days around a day without a measurement.
  final double strengthInterpol;

  /// How much more a measured day weighs than one without a measurement.
  final double interpolWeight;

  /// Day of the first measurement.
  final DateTime firstDay;

  /// Number of days on the internal grid.
  final int gridLength;

  /// Whether the curve is drawn as straight lines between the days.
  final bool isNone;

  /// First displayed grid index.
  final int displayStart;

  /// One past the last displayed grid index.
  final int displayEnd;
}

/// The displayed curve and its rate, one entry per displayed day.
class _InterpolationResult {
  _InterpolationResult({
    required this.weights,
    required this.slopes,
    required this.refitted,
  });

  /// The curve in kg.
  final List<double> weights;

  /// The rate in kg/day that the cards show and the forecasts continue.
  final List<double> slopes;

  /// The state after a refit, null without one.
  final SmoothingState? refitted;
}

/// The curve of the model chosen in [_InterpolationPayload.physiological].
/// Top-level, so that [compute] can run it in an isolate.
_InterpolationResult _computeInterpolation(_InterpolationPayload p) =>
    p.physiological ? _computePhysiological(p) : _computeGaussian(p);

/// Smooths the logarithm of the measured days with [smoothingModel], after
/// refitting its state when that is due.
///
/// Past the last measurement the curve continues its rate in a straight
/// line, as the forecasts do.
_InterpolationResult _computePhysiological(_InterpolationPayload p) {
  final List<double> grid = <double>[
    for (int idx = p.displayStart; idx < p.displayEnd; idx++) idx.toDouble(),
  ];
  final List<Observation> observations = logObservations(
    // The grid index is the time in days: consecutive entries are consecutive
    // calendar days.
    <double>[for (final int idx in p.idxsMeasurements) idx.toDouble()],
    p.weightsMeasured,
    p.counts,
  );
  final SmoothingState? refitted = p.refit
      ? refitSmoothing(
          observations: observations,
          state: p.state,
          slopeSd: p.slopeSd,
          stepKg: p.stepKg,
        )
      : null;
  final StructuralModel model = smoothingModel(
    state: refitted ?? p.state,
    slopeSd: p.slopeSd,
    stepKg: p.stepKg,
  );
  final SmoothingResult posterior = model.smooth(
    observations,
    grid: grid,
    signal: curveComponents,
  );
  final List<double> curve = <double>[
    for (final double logWeight in posterior.mean) math.exp(logWeight),
  ];
  final List<double> levels = <double>[
    for (final double logLevel in posterior.componentMean(0))
      math.exp(logLevel),
  ];
  final List<double> rates = _rates(p, <double>[
    for (int i = 0; i < curve.length; i++) posterior.trendSlope![i] * curve[i],
  ], levels);
  final int last = p.idxsMeasurements.last - p.displayStart;

  return _InterpolationResult(
    weights: p.isNone
        ? _polyline(p, rates[last])
        : <double>[
            for (int i = 0; i < curve.length; i++)
              i <= last ? curve[i] : curve[last] + rates[last] * (i - last),
          ],
    slopes: rates,
    refitted: refitted,
  );
}

/// The rate on each displayed day: the tissue trend's slope, or for a sparse
/// diary the tissue level's change over [sparseRateWindowInDays]; past the
/// last measurement the rate there.
List<double> _rates(
  _InterpolationPayload p,
  List<double> slopes,
  List<double> levels,
) {
  final List<int> days = p.idxsMeasurements;
  final int last = days.last - p.displayStart;
  final List<double> rates = List<double>.of(slopes);
  int count = 0;
  for (int i = 0; i <= last; i++) {
    final int idx = i + p.displayStart;
    while (count < days.length && days[count] <= idx) {
      count++;
    }
    final int from = math.max(idx - sparseRateWindowInDays, days.first);
    if (from < idx && _isSparse(days, count)) {
      rates[i] = (levels[i] - levels[from - p.displayStart]) / (idx - from);
    }
  }
  for (int i = last + 1; i < rates.length; i++) {
    rates[i] = rates[last];
  }
  return rates;
}

/// Whether the median of the last [sparseGapsCounted] gaps between the first
/// [count] measured [days] is [sparseGapInDays] or more.
bool _isSparse(List<int> days, int count) {
  final List<int> gaps = <int>[
    for (int k = math.max(1, count - sparseGapsCounted); k < count; k++)
      days[k] - days[k - 1],
  ]..sort();
  return gaps.isNotEmpty && gaps[gaps.length ~/ 2] >= sparseGapInDays;
}

/// Straight lines between the daily means, continued past the last one at
/// [rate].
List<double> _polyline(_InterpolationPayload p, double rate) {
  final int last = p.idxsMeasurements.last;
  final List<double> weights = <double>[];
  int k = 0;
  for (int idx = p.displayStart; idx < p.displayEnd; idx++) {
    if (idx >= last) {
      weights.add(p.weightsMeasured.last + rate * (idx - last));
      continue;
    }
    while (p.idxsMeasurements[k + 1] <= idx) {
      k++;
    }
    final int from = p.idxsMeasurements[k];
    final int to = p.idxsMeasurements[k + 1];
    weights.add(
      p.weightsMeasured[k] +
          (p.weightsMeasured[k + 1] - p.weightsMeasured[k]) *
              (idx - from) /
              (to - from),
    );
  }
  return weights;
}
