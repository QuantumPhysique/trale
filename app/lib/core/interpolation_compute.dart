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
    required this.slopeSd,
    required this.state,
    required this.stepKg,
    required this.refit,
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

  /// Slope sd of the strength, see [InterpolStrengthExtension.slopeSd].
  final double slopeSd;

  /// The amplitudes and the scale error the curve is drawn with.
  final SmoothingState state;

  /// Step in kg that weights are entered in.
  final double stepKg;

  /// Whether to refit [state] before smoothing.
  final bool refit;

  /// Whether the curve is drawn as straight lines between the days.
  final bool isNone;

  /// First displayed grid index.
  final int displayStart;

  /// One past the last displayed grid index.
  final int displayEnd;
}

/// The displayed curve and its slope, one entry per displayed day.
class _InterpolationResult {
  _InterpolationResult({
    required this.weights,
    required this.slopes,
    required this.refitted,
  });

  /// The curve: the tissue trend plus the week-scale changes, in kg.
  final List<double> weights;

  /// Slope of the tissue trend in kg/day.
  final List<double> slopes;

  /// The state after a refit, null without one.
  final SmoothingState? refitted;
}

/// Smooths the logarithm of the measured days with [smoothingModel], after
/// refitting its state when that is due. Top-level, so that [compute] can run
/// it in an isolate.
_InterpolationResult _computeInterpolation(_InterpolationPayload p) {
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
  final double bodyKg = bodyWeightKg(p.weightsMeasured);
  final SmoothingState? refitted = p.refit
      ? refitSmoothing(
          observations: observations,
          state: p.state,
          slopeSd: p.slopeSd,
          bodyKg: bodyKg,
          stepKg: p.stepKg,
        )
      : null;
  final StructuralModel model = smoothingModel(
    state: refitted ?? p.state,
    slopeSd: p.slopeSd,
    bodyKg: bodyKg,
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
  final List<double> slopes = <double>[
    for (int i = 0; i < curve.length; i++) posterior.trendSlope![i] * curve[i],
  ];

  return _InterpolationResult(
    weights: p.isNone ? _polyline(p, slopes) : curve,
    slopes: slopes,
    refitted: refitted,
  );
}

/// Straight lines between the daily means, continued past the last one with
/// the trend's slope there.
List<double> _polyline(_InterpolationPayload p, List<double> slopes) {
  final int last = p.idxsMeasurements.last;
  final double lastSlope = slopes[last - p.displayStart];
  final List<double> weights = <double>[];
  int k = 0;
  for (int idx = p.displayStart; idx < p.displayEnd; idx++) {
    if (idx >= last) {
      weights.add(p.weightsMeasured.last + lastSlope * (idx - last));
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
