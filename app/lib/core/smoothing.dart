import 'dart:math' as math;

import 'package:state_space/state_space.dart'
    show
        Component,
        DampedLinearTrend,
        Matern,
        Observation,
        StructuralModel;
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
  });

  /// The prior centres, with the scale error at the display step [stepKg].
  const SmoothingState.prior(double stepKg)
    : weekAmplitude = amplitudePriorCentre,
      waterAmplitude = amplitudePriorCentre,
      scaleErrorKg = stepKg;

  /// Standard deviation of the week-scale changes, as a fraction of body
  /// weight.
  final double weekAmplitude;

  /// Standard deviation of water and gut content, as a fraction of body
  /// weight.
  final double waterAmplitude;

  /// Standard deviation in kg of a reading's error besides its rounding.
  final double scaleErrorKg;
}

/// Variance in kg² of one reading around the weight: the scale error and the
/// rounding to the display step [stepKg].
double readingVarianceKg(double scaleErrorKg, double stepKg) =>
    scaleErrorKg * scaleErrorKg + stepKg * stepKg / 12;

/// The model of the log weight: a tissue trend whose slope has the sd
/// [slopeSd] at [strengthReferenceKg], scaled to [bodyKg]; week-scale changes;
/// water; and each reading's own error in kg.
StructuralModel smoothingModel({
  required SmoothingState state,
  required double slopeSd,
  required double bodyKg,
  required double stepKg,
}) {
  final double s =
      slopeSd * math.pow(bodyKg / strengthReferenceKg, kleiberExponent);
  return StructuralModel(<Component>[
    DampedLinearTrend(
      processVariance: 2 * s * s / tissueSlopeMemoryInDays,
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
