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

  /// Whether the curve is drawn as straight lines between the days.
  final bool isNone;

  /// First displayed grid index.
  final int displayStart;

  /// One past the last displayed grid index.
  final int displayEnd;
}

/// The displayed curve, its slope and the band around it, one entry per
/// displayed day.
class _InterpolationResult {
  _InterpolationResult({
    required this.weights,
    required this.slopes,
    required this.bandLower,
    required this.bandUpper,
  });

  /// The curve: the tissue trend plus the week-scale changes, in kg.
  final List<double> weights;

  /// Slope of the tissue trend in kg/day.
  final List<double> slopes;

  /// 95 % predictive band of a single measurement, empty when there is none.
  final List<double> bandLower;

  /// Upper edge of the band, see [bandLower].
  final List<double> bandUpper;
}

/// Smooths the logarithm of the measured days with [smoothingModel].
/// Top-level, so that [compute] can run it in an isolate.
_InterpolationResult _computeInterpolation(_InterpolationPayload p) {
  final List<double> grid = <double>[
    for (int idx = p.displayStart; idx < p.displayEnd; idx++) idx.toDouble(),
  ];
  final StructuralModel model = smoothingModel(
    state: p.state,
    slopeSd: p.slopeSd,
    bodyKg: bodyWeightKg(p.weightsMeasured),
    stepKg: p.stepKg,
  );
  final SmoothingResult posterior = model.smooth(
    _observations(p),
    grid: grid,
    signal: curveComponents,
  );
  final List<double> curve = <double>[
    for (final double logWeight in posterior.mean) math.exp(logWeight),
  ];
  final List<double> slopes = <double>[
    for (int i = 0; i < curve.length; i++)
      posterior.trendSlope![i] * curve[i],
  ];

  final List<double> bandLower = <double>[];
  final List<double> bandUpper = <double>[];
  if (p.idxsMeasurements.length >= minimumDaysForBand && !p.isNone) {
    final double water = p.state.waterAmplitude * p.state.waterAmplitude;
    final double reading = readingVarianceKg(p.state.scaleErrorKg, p.stepKg);
    for (int i = 0; i < curve.length; i++) {
      final double sd = math.sqrt(
        posterior.variance[i] + water + reading / (curve[i] * curve[i]),
      );
      bandLower.add(math.exp(posterior.mean[i] - z95 * sd));
      bandUpper.add(math.exp(posterior.mean[i] + z95 * sd));
    }
  }

  return _InterpolationResult(
    weights: p.isNone ? _polyline(p, slopes) : curve,
    slopes: slopes,
    bandLower: bandLower,
    bandUpper: bandUpper,
  );
}

/// The daily means of [p] as observations of their logarithm.
List<Observation> _observations(_InterpolationPayload p) => logObservations(
  // The grid index is the time in days: consecutive entries are consecutive
  // calendar days.
  <double>[for (final int idx in p.idxsMeasurements) idx.toDouble()],
  p.weightsMeasured,
  p.counts,
);

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
