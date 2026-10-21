import 'dart:math' as math;

import 'package:state_space/state_space.dart'
    show
        Component,
        DampedLinearTrend,
        FitResult,
        ForecastResult,
        LocalLinearTrend,
        LogNormalPrior,
        Matern,
        Observation,
        SearchStart,
        StructuralModel,
        fit;
import 'package:trale/core/constants.dart';

/// The components the curve is drawn from: the tissue trend and the
/// week-scale changes, without water and the scale error.
const Set<int> curveComponents = <int>{0, 1};

/// The strengths of the tissue trend, each named after the diet whose lasting
/// rate is its slope sd.
enum SmoothingMode {
  /// A weight held steady.
  maintenance,

  /// A diet at the usual recommendation.
  textbook,

  /// A faster diet.
  ambitious,

  /// A diet at the limit of what lasts.
  aggressive,
}

/// Extend [SmoothingMode].
extension SmoothingModeExtension on SmoothingMode {
  /// Standard deviation of the tissue trend's slope at [strengthReferenceKg],
  /// as a fraction of body weight per day: 0.20, 0.67, 0.84 and 1.19 % a
  /// week, about 180, 610, 770 and 1090 kcal/day at 83 kg.
  double get slopeSd => <SmoothingMode, double>{
    SmoothingMode.maintenance: 0.002 / 7,
    SmoothingMode.textbook: 0.00096,
    SmoothingMode.ambitious: 0.0012,
    SmoothingMode.aggressive: 0.0017,
  }[this]!;
}

/// The one of [modes] a growing body is smoothed with: their only one, or
/// textbook. A growing body's slope sd is fitted, and the modes differ in
/// nothing else.
SmoothingMode growingMode(List<SmoothingMode> modes) =>
    modes.length == 1 ? modes.single : SmoothingMode.textbook;

/// The part of the smoothing learned from one diary's readings.
class SmoothingState {
  /// Creates a [SmoothingState].
  const SmoothingState({
    required this.weekAmplitude,
    required this.waterAmplitude,
    required this.scaleErrorKg,
    this.growthFactor = 1,
  });

  /// The prior centres, with the scale error at the display step [stepKg].
  const SmoothingState.prior(double stepKg)
    : weekAmplitude = amplitudePriorCentre,
      waterAmplitude = amplitudePriorCentre,
      scaleErrorKg = stepKg,
      growthFactor = 1;

  /// Creates a [SmoothingState] from the values of [toList].
  SmoothingState.fromList(List<double> values)
    : weekAmplitude = values[0],
      waterAmplitude = values[1],
      scaleErrorKg = values[2],
      growthFactor = values[3];

  /// Standard deviation of the week-scale changes, as a fraction of body
  /// weight.
  final double weekAmplitude;

  /// Standard deviation of water and gut content, as a fraction of body
  /// weight.
  final double waterAmplitude;

  /// Standard deviation in kg of a reading's error besides its rounding.
  final double scaleErrorKg;

  /// Factor on the slope sd of a growing body; 1 for any other.
  final double growthFactor;

  /// The fields in the order [SmoothingState.fromList] reads them.
  List<double> toList() => <double>[
    weekAmplitude,
    waterAmplitude,
    scaleErrorKg,
    growthFactor,
  ];
}

/// A refitted [SmoothingState] and its log posterior density.
typedef SmoothingFit = ({SmoothingState state, double logPosterior});

/// Variance in kg² of one reading around the weight: the scale error and the
/// rounding to the display step [stepKg].
double readingVarianceKg(double scaleErrorKg, double stepKg) =>
    scaleErrorKg * scaleErrorKg + stepKg * stepKg / 12;

/// The slope sd [slopeSd] at [strengthReferenceKg], scaled to [bodyKg].
double _scaledSlopeSd(double slopeSd, double bodyKg) =>
    slopeSd * math.pow(bodyKg / strengthReferenceKg, kleiberExponent);

/// Process variance of the tissue trend whose slope has the sd [slopeSd] at
/// [strengthReferenceKg], scaled to [bodyKg].
double _trendVariance(double slopeSd, double bodyKg) {
  final double s = _scaledSlopeSd(slopeSd, bodyKg);
  return 2 * s * s / tissueSlopeMemoryInDays;
}

/// The model of the log weight: a tissue trend whose slope has the sd
/// [slopeSd] at [strengthReferenceKg], scaled to [bodyKg]; week-scale changes;
/// water; and each reading's own error in kg. A [growing] body's slope does
/// not revert to zero.
StructuralModel smoothingModel({
  required SmoothingState state,
  required double slopeSd,
  required double bodyKg,
  required double stepKg,
  required bool growing,
}) {
  final double trend = _trendVariance(slopeSd, bodyKg);
  final double g = state.growthFactor;
  return StructuralModel(<Component>[
    if (growing)
      LocalLinearTrend(processVariance: trend * g * g)
    else
      DampedLinearTrend(
        processVariance: trend,
        timeScale: tissueSlopeMemoryInDays,
      ),
    Matern.threeHalves(
      variance: state.weekAmplitude * state.weekAmplitude,
      lengthScale: weekScaleLengthInDays,
    ),
    Matern.oneHalf(
      variance: state.waterAmplitude * state.waterAmplitude,
      lengthScale: waterLengthInDays,
    ),
  ], measurementVariance: readingVarianceKg(state.scaleErrorKg, stepKg));
}

/// Whether the amplitudes and the scale error are due for a refit, with
/// [days] with measurements now and [fittedDays] at the last refit, or with
/// a mode [unfitted] so far.
bool isRefitDue(int days, int fittedDays, {required bool unfitted}) =>
    days >= firstRefitDays &&
    (unfitted ||
        (days <= refitEveryDayUpTo
            ? days != fittedDays
            : (days - fittedDays).abs() >= refitIntervalDays));

/// The amplitudes, the scale error and, for a [growing] body, the growth
/// factor at their posterior mode on [observations], refined from [state].
///
/// The priors are centred on [amplitudePriorCentre], the display step
/// [stepKg] and a growth factor of 1.
SmoothingFit refitSmoothing({
  required List<Observation> observations,
  required SmoothingState state,
  required double slopeSd,
  required double bodyKg,
  required double stepKg,
  required bool growing,
}) {
  final double width = 2 * math.log(priorWidthFactor);
  final LogNormalPrior amplitude = LogNormalPrior(
    median: amplitudePriorCentre * amplitudePriorCentre,
    logSd: width,
  );
  final double trend = _trendVariance(slopeSd, bodyKg);
  final double rounding = readingVarianceKg(0, stepKg);
  // The damped trend has a variance and a time scale, the growing one a
  // variance; the two Matérn components a variance and a length scale each.
  final int week = growing ? 1 : 2;
  final int water = week + 2;
  final FitResult fitted = fit(
    smoothingModel(
      state: state,
      slopeSd: slopeSd,
      bodyKg: bodyKg,
      stepKg: stepKg,
      growing: growing,
    ),
    observations,
    heldParameters: <int>{
      if (!growing) ...<int>{0, 1},
      week + 1,
      water + 1,
    },
    priors: <int, LogNormalPrior>{
      if (growing)
        0: LogNormalPrior(
          median: trend,
          logSd: 2 * math.log(growthPriorWidthFactor),
        ),
      week: amplitude,
      water: amplitude,
    },
    measurementVariancePrior: LogNormalPrior(
      median: readingVarianceKg(stepKg, stepKg),
      logSd: width,
    ),
    minimumMeasurementVariance: rounding,
    start: SearchStart.previousParameters,
  );
  final List<double> theta = fitted.model.parameters;
  return (
    state: SmoothingState(
      weekAmplitude: math.sqrt(math.exp(theta[week])),
      waterAmplitude: math.sqrt(math.exp(theta[water])),
      scaleErrorKg: math.sqrt(
        math.max(0, fitted.measurementVariance - rounding),
      ),
      growthFactor: growing ? math.sqrt(math.exp(theta[0]) / trend) : 1,
    ),
    logPosterior: fitted.logMarginalLikelihood + fitted.logPrior,
  );
}

/// The logarithm of each day's mean weight at [days], the mean of [counts]
/// readings.
///
/// A reading's variance on the log scale is its variance in kg over its
/// square, so the model's measurement variance stays in kg².
List<Observation> logObservations(
  List<double> days,
  List<double> weights,
  List<int> counts,
) => <Observation>[
  for (int k = 0; k < days.length; k++)
    Observation(
      days[k],
      math.log(weights[k]),
      relativeVariance: 1 / (counts[k] * weights[k] * weights[k]),
    ),
];

/// Mean of the last [readingsForBodyWeight] daily [weights], the body weight
/// the slope sd is scaled to.
double bodyWeightKg(List<double> weights) {
  final List<double> recent = weights.sublist(
    math.max(0, weights.length - readingsForBodyWeight),
  );
  return recent.reduce((double a, double b) => a + b) / recent.length;
}

/// Mean log density of [observations] entry [i] under [model], over its
/// forecasts from [evidenceHorizonsInDays] before it; null while too few
/// readings precede those.
///
/// The filter forgets within a few slope memories, so each forecast starts
/// [hindcastHistoryInDays] before its origin instead of at the first reading.
double? readingEvidence(
  StructuralModel model,
  List<Observation> observations,
  int i,
) {
  final Observation reading = observations[i];
  double sum = 0;
  int count = 0;
  for (final int horizon in evidenceHorizonsInDays) {
    int end = i;
    while (end > 0 && observations[end - 1].time > reading.time - horizon) {
      end--;
    }
    if (end == 0) {
      continue;
    }
    final double origin = observations[end - 1].time;
    int start = end - 1;
    while (start > 0 &&
        observations[start - 1].time >= origin - hindcastHistoryInDays) {
      start--;
    }
    if (end - start < minimumReadingsForHindcast) {
      continue;
    }
    final ForecastResult forecast = model.forecast(
      observations.sublist(start, end),
      <double>[reading.time],
    );
    sum += _logNormalDensity(
      reading.value,
      forecast.mean[0],
      forecast.variance[0] +
          model.measurementVariance * reading.relativeVariance,
    );
    count++;
  }
  return count == 0 ? null : sum / count;
}

/// Evidence in nats of each of [models]: the [readingEvidence] of the readings
/// in the last [evidenceWindowInDays], weighed by a Gaussian kernel on their
/// age.
List<double> modeEvidence(
  List<StructuralModel> models,
  List<Observation> observations,
) {
  final List<double> evidence = List<double>.filled(models.length, 0);
  final double last = observations.last.time;
  for (int i = observations.length - 1; i >= 0; i--) {
    final double age = last - observations[i].time;
    if (age > evidenceWindowInDays) {
      break;
    }
    final double kernel = math.exp(
      -age * age / (2 * evidenceKernelInDays * evidenceKernelInDays),
    );
    for (int k = 0; k < models.length; k++) {
      final double? score = readingEvidence(models[k], observations, i);
      // Whether a reading is scored depends on the times only, so it is
      // scored by every model or by none.
      if (score == null) {
        break;
      }
      evidence[k] += kernel * score;
    }
  }
  return evidence;
}

/// Weights proportional to the exponential of [logWeights].
List<double> softmax(List<double> logWeights) {
  final double top = logWeights.reduce(math.max);
  final List<double> weights = <double>[
    for (final double w in logWeights) math.exp(w - top),
  ];
  final double sum = weights.reduce((double a, double b) => a + b);
  return <double>[for (final double w in weights) w / sum];
}

double _logNormalDensity(double x, double mean, double variance) =>
    -0.5 * math.log(2 * math.pi * variance) -
    0.5 * (x - mean) * (x - mean) / variance;

/// Standard normal distribution function (Abramowitz and Stegun 7.1.26).
double _normalCdf(double z) {
  final double t = 1 / (1 + 0.3275911 * z.abs() / math.sqrt2);
  final double erf =
      1 -
      (((((1.061405429 * t - 1.453152027) * t) + 1.421413741) * t -
                      0.284496736) *
                  t +
              0.254829592) *
          t *
          math.exp(-z * z / 2);
  return z >= 0 ? 0.5 * (1 + erf) : 0.5 * (1 - erf);
}

/// The value below which the normal mixture with [weights], [means] and
/// [variances] lies with the probability a standard normal lies below [z].
double mixtureQuantile(
  List<double> weights,
  List<double> means,
  List<double> variances,
  double z,
) {
  if (means.length == 1) {
    return means.single + z * math.sqrt(variances.single);
  }
  // The mixture's quantile lies between its components' quantiles.
  double lo = double.infinity;
  double hi = double.negativeInfinity;
  for (int k = 0; k < means.length; k++) {
    final double quantile = means[k] + z * math.sqrt(variances[k]);
    lo = math.min(lo, quantile);
    hi = math.max(hi, quantile);
  }
  final double p = _normalCdf(z);
  for (int step = 0; step < mixtureBisectionSteps; step++) {
    final double mid = (lo + hi) / 2;
    double cdf = 0;
    for (int k = 0; k < means.length; k++) {
      cdf +=
          weights[k] * _normalCdf((mid - means[k]) / math.sqrt(variances[k]));
    }
    if (cdf < p) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  return (lo + hi) / 2;
}
