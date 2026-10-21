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
    required this.modes,
    required this.states,
    required this.stepKg,
    required this.refit,
    required this.growing,
    required this.testGrowing,
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

  /// The modes the curve is drawn from.
  final List<SmoothingMode> modes;

  /// The amplitudes and the scale error of each of [modes].
  final Map<SmoothingMode, SmoothingState> states;

  /// Step in kg that weights are entered in.
  final double stepKg;

  /// Whether to refit [states] before smoothing.
  final bool refit;

  /// Whether the body is growing, see [smoothingModel].
  final bool growing;

  /// Whether a refit also tests the growing profile against the other.
  final bool testGrowing;

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
    required this.modeWeights,
    required this.refitted,
    required this.turnedGrowing,
  });

  /// The curve: the tissue trend plus the week-scale changes, in kg.
  final List<double> weights;

  /// Slope of the tissue trend in kg/day.
  final List<double> slopes;

  /// 95 % predictive band of a single measurement, empty when there is none.
  final List<double> bandLower;

  /// Upper edge of the band, see [bandLower].
  final List<double> bandUpper;

  /// Weight of each mode the curve is drawn from.
  final Map<SmoothingMode, double> modeWeights;

  /// The state of each refitted mode, null without a refit.
  final Map<SmoothingMode, SmoothingState>? refitted;

  /// Whether the refit found the body growing.
  final bool turnedGrowing;
}

/// One mode's posterior of the log curve on the grid.
class _ModeCurve {
  _ModeCurve(this.mean, this.variance, this.slope, this.readingVariance);

  /// Mean of the log curve.
  final List<double> mean;

  /// Variance of the log curve.
  final List<double> variance;

  /// Slope of the tissue trend in log units per day.
  final List<double> slope;

  /// Variance of a single reading's logarithm around [mean].
  final List<double> readingVariance;
}

/// Smooths the logarithm of the measured days with [smoothingModel] in each
/// mode, after refitting their states when that is due, and mixes the modes
/// by their [modeEvidence]. Top-level, so that [compute] can run it in an
/// isolate.
_InterpolationResult _computeInterpolation(_InterpolationPayload p) {
  final List<double> grid = <double>[
    for (int idx = p.displayStart; idx < p.displayEnd; idx++) idx.toDouble(),
  ];
  final List<Observation> observations = _observations(p);
  final double bodyKg = bodyWeightKg(p.weightsMeasured);
  SmoothingFit refit(SmoothingMode mode, {required bool growing}) =>
      refitSmoothing(
        observations: observations,
        state: p.states[mode]!,
        slopeSd: mode.slopeSd,
        bodyKg: bodyKg,
        stepKg: p.stepKg,
        growing: growing,
      );

  List<SmoothingMode> modes = p.modes;
  Map<SmoothingMode, SmoothingState> states = p.states;
  Map<SmoothingMode, SmoothingState>? refitted;
  bool turnedGrowing = false;
  if (p.refit) {
    Map<SmoothingMode, SmoothingFit> fits = <SmoothingMode, SmoothingFit>{
      for (final SmoothingMode mode in modes)
        mode: refit(mode, growing: p.growing),
    };
    if (p.testGrowing) {
      final SmoothingMode mode = growingMode(modes);
      final SmoothingFit grown = refit(mode, growing: true);
      // The two models integrate out different flat directions, so the
      // threshold holds only for the units it was set in: days and log kg.
      if (grown.logPosterior > fits[mode]!.logPosterior + growingEvidenceNats) {
        modes = <SmoothingMode>[mode];
        fits = <SmoothingMode, SmoothingFit>{mode: grown};
        turnedGrowing = true;
      }
    }
    refitted = states = <SmoothingMode, SmoothingState>{
      for (final MapEntry<SmoothingMode, SmoothingFit> fit in fits.entries)
        fit.key: fit.value.state,
    };
  }
  final bool growing = p.growing || turnedGrowing;
  final List<StructuralModel> models = <StructuralModel>[
    for (final SmoothingMode mode in modes)
      smoothingModel(
        state: states[mode]!,
        slopeSd: mode.slopeSd,
        bodyKg: bodyKg,
        stepKg: p.stepKg,
        growing: growing,
      ),
  ];
  final List<double> modeWeights = modes.length == 1
      ? <double>[1]
      : softmax(modeEvidence(models, observations));
  final List<_ModeCurve> curves = <_ModeCurve>[
    for (int k = 0; k < modes.length; k++)
      _modeCurve(
        p,
        models[k],
        states[modes[k]]!,
        observations,
        grid,
        growing: growing,
      ),
  ];

  final bool hasBand =
      p.idxsMeasurements.length >= minimumDaysForBand && !p.isNone;
  final List<double> curve = <double>[];
  final List<double> slopes = <double>[];
  final List<double> bandLower = <double>[];
  final List<double> bandUpper = <double>[];
  for (int i = 0; i < grid.length; i++) {
    final List<double> means = <double>[
      for (final _ModeCurve c in curves) c.mean[i],
    ];
    final double weight = math.exp(
      mixtureQuantile(modeWeights, means, <double>[
        for (final _ModeCurve c in curves) c.variance[i],
      ], 0),
    );
    curve.add(weight);
    double slope = 0;
    for (int k = 0; k < curves.length; k++) {
      slope += modeWeights[k] * curves[k].slope[i];
    }
    slopes.add(slope * weight);
    if (hasBand) {
      final List<double> readings = <double>[
        for (final _ModeCurve c in curves) c.readingVariance[i],
      ];
      bandLower.add(
        math.exp(mixtureQuantile(modeWeights, means, readings, -z95)),
      );
      bandUpper.add(
        math.exp(mixtureQuantile(modeWeights, means, readings, z95)),
      );
    }
  }

  return _InterpolationResult(
    weights: p.isNone ? _polyline(p, slopes) : curve,
    slopes: slopes,
    bandLower: bandLower,
    bandUpper: bandUpper,
    modeWeights: <SmoothingMode, double>{
      for (int k = 0; k < modes.length; k++) modes[k]: modeWeights[k],
    },
    refitted: refitted,
    turnedGrowing: turnedGrowing,
  );
}

/// The posterior of [model] with [state] on [grid]; past the last reading it
/// keeps the tissue slope there, which the model lets fade.
_ModeCurve _modeCurve(
  _InterpolationPayload p,
  StructuralModel model,
  SmoothingState state,
  List<Observation> observations,
  List<double> grid, {
  required bool growing,
}) {
  final SmoothingResult posterior = model.smooth(
    observations,
    grid: grid,
    signal: curveComponents,
  );
  final List<double> mean = posterior.mean.toList();
  final List<double> variance = posterior.variance.toList();
  final List<double> slope = posterior.trendSlope!.toList();
  if (!growing) {
    final int last = p.idxsMeasurements.last - p.displayStart;
    final double slopeVariance = posterior.trendSlopeVariance![last];
    const double tau = tissueSlopeMemoryInDays;
    for (int i = last + 1; i < grid.length; i++) {
      final double days = (i - last).toDouble();
      final double faded = tau * (1 - math.exp(-days / tau));
      mean[i] += slope[last] * (days - faded);
      variance[i] += (days * days - faded * faded) * slopeVariance;
      slope[i] = slope[last];
    }
  }
  final double water = state.waterAmplitude * state.waterAmplitude;
  final double reading = readingVarianceKg(state.scaleErrorKg, p.stepKg);
  return _ModeCurve(mean, variance, slope, <double>[
    for (int i = 0; i < grid.length; i++)
      variance[i] + water + reading / math.exp(2 * mean[i]),
  ]);
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
