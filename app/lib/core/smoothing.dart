import 'dart:math' as math;

import 'package:state_space/state_space.dart'
    show
        Component,
        DampedLinearTrend,
        FitResult,
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
}

/// A refitted [SmoothingState] and its log posterior density.
typedef SmoothingFit = ({SmoothingState state, double logPosterior});

/// Variance in kg² of one reading around the weight: the scale error and the
/// rounding to the display step [stepKg].
double readingVarianceKg(double scaleErrorKg, double stepKg) =>
    scaleErrorKg * scaleErrorKg + stepKg * stepKg / 12;

/// Process variance of the tissue trend whose slope has the sd [slopeSd] at
/// [strengthReferenceKg], scaled to [bodyKg].
double _trendVariance(double slopeSd, double bodyKg) {
  final double s =
      slopeSd * math.pow(bodyKg / strengthReferenceKg, kleiberExponent);
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
/// [days] with measurements now and [fittedDays] at the last refit.
bool isRefitDue(int days, int fittedDays) =>
    days >= firstRefitDays &&
    (days <= refitEveryDayUpTo
        ? days != fittedDays
        : (days - fittedDays).abs() >= refitIntervalDays);

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
