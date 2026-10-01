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
    required this.processVariance,
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

  /// Variance ratio of the trend, see [InterpolStrengthExtension].
  final double processVariance;

  /// Whether the curve is drawn as straight lines between the days.
  final bool isNone;

  /// First displayed grid index.
  final int displayStart;

  /// One past the last displayed grid index.
  final int displayEnd;
}

/// Fewer days than this leave the noise estimate too uncertain for a band.
const int _minDaysForBand = 7;

/// The displayed curve, its slope and the band around it, one entry per
/// displayed day.
class _InterpolationResult {
  _InterpolationResult({
    required this.weights,
    required this.slopes,
    required this.bandLower,
    required this.bandUpper,
  });

  final List<double> weights;

  /// Slope of the trend in kg/day.
  final List<double> slopes;

  /// 95 % predictive band of a single measurement, empty when there is none.
  final List<double> bandLower;

  /// Upper edge of the band, see [bandLower].
  final List<double> bandUpper;
}

/// Smooths the measured days with a local linear trend at the strength's
/// variance ratio. Top-level, so that [compute] can run it in an isolate.
_InterpolationResult _computeInterpolation(_InterpolationPayload p) {
  final List<double> grid = <double>[
    for (int idx = p.displayStart; idx < p.displayEnd; idx++) idx.toDouble(),
  ];
  final int nDays = p.idxsMeasurements.length;

  List<double> weights;
  List<double> slopes;
  List<double> bandLower = <double>[];
  List<double> bandUpper = <double>[];
  if (nDays == 1) {
    weights = List<double>.filled(grid.length, p.weightsMeasured.single);
    slopes = List<double>.filled(grid.length, 0);
  } else {
    // The grid index is the time in days: consecutive entries are
    // consecutive calendar days.
    final List<Observation> observations = <Observation>[
      for (int k = 0; k < nDays; k++)
        Observation(
          p.idxsMeasurements[k].toDouble(),
          p.weightsMeasured[k],
          relativeVariance: 1 / p.counts[k],
        ),
    ];
    final StructuralModel model = nDays < 3
        // Two days leave no residual to estimate the noise from.
        ? StructuralModel.localLinearTrend(
            processVariance: p.processVariance * minimumNoiseVariance,
            measurementVariance: minimumNoiseVariance,
          )
        : StructuralModel.localLinearTrend(
            processVariance: p.processVariance,
          ).withEstimatedScale(
            observations,
            minimumMeasurementVariance: minimumNoiseVariance,
          );
    final SmoothingResult posterior = model.smooth(observations, grid: grid);
    weights = posterior.mean.toList();
    slopes = posterior.trendSlope!.toList();
    if (nDays >= _minDaysForBand && !p.isNone) {
      final Bands band = posterior.predictiveBand();
      bandLower = band.lo.toList();
      bandUpper = band.hi.toList();
    }
  }

  if (p.isNone) {
    weights = _polyline(p, slopes);
  }
  return _InterpolationResult(
    weights: weights,
    slopes: slopes,
    bandLower: bandLower,
    bandUpper: bandUpper,
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
