import 'dart:math' as math;

import 'package:state_space/state_space.dart'
    show FitResult, Observation, StructuralModel, fit;
import 'package:trale/core/constants.dart';
import 'package:trale/core/interpolation.dart';

/// The variance ratio the automatic strength holds after fitting the trend to
/// [observations], or null when the fit does not pin it down.
///
/// A fit that does replaces [heldRatio] only when it explains the data clearly
/// better; otherwise [heldRatio] is returned.
double? learnAutoStrength(List<Observation> observations, double heldRatio) {
  final FitResult result = fit(
    StructuralModel.localLinearTrend(processVariance: heldRatio),
    observations,
  );
  if (result.atBracketEdge ||
      result.plateauDecadesByParameter.single > autoStrengthMaxPlateauDecades) {
    return null;
  }
  final double heldLogLikelihood = StructuralModel.localLinearTrend(
    processVariance: heldRatio,
  ).withEstimatedScale(observations).logLikelihood(observations);
  return result.logMarginalLikelihood - heldLogLikelihood >
          autoStrengthMinGainInNats
      ? result.varianceRatio
      : heldRatio;
}

/// What replaying the automatic strength over a diary, as it grew, found.
class AutoStrengthSummary {
  /// Creates an [AutoStrengthSummary].
  const AutoStrengthSummary({
    required this.bandwidthInDays,
    required this.daysPerWeek,
    required this.historyInDays,
    required this.firstFitInDays,
    required this.switches,
    required this.gainInNats,
    required this.noiseInKg,
    required this.autocorrelation,
  });

  /// Bandwidth the learned strength smooths with at the diary's density.
  final double bandwidthInDays;

  /// Days with a measurement per week.
  final double daysPerWeek;

  /// Days from the first to the last measurement.
  final double historyInDays;

  /// History in days at the first accepted fit, null without one.
  final double? firstFitInDays;

  /// How often an accepted fit replaced the strength in use.
  final int switches;

  /// Log-likelihood by which the learned strength beats the start value.
  final double gainInNats;

  /// Standard deviation of a reading around the trend.
  final double noiseInKg;

  /// Correlation of consecutive standardised residuals, the water wobble the
  /// model leaves out.
  final double autocorrelation;

  /// The summary as plain text to share, rounded so that it cannot single out
  /// a diary.
  String toText() {
    final String bandwidth = ((bandwidthInDays * 2).round() / 2)
        .toStringAsFixed(1);
    final String noise = ((noiseInKg * 20).round() / 20).toStringAsFixed(2);
    final String gain = gainInNats.toStringAsFixed(1);
    final String firstFit = firstFitInDays == null
        ? 'none'
        : 'month ${(firstFitInDays! / daysPerMonth).round()}';
    return <String>[
      'trale: automatic smoothing summary',
      'bandwidth: $bandwidth days',
      'days with a measurement per week: ${daysPerWeek.toStringAsFixed(1)}',
      'history: ${(historyInDays / daysPerMonth).round()} months',
      'first accepted fit: $firstFit',
      'switches: $switches',
      'gain over $autoStrengthStartInDays days: $gain nats',
      'noise: $noise kg',
      'autocorrelation at one reading: ${autocorrelation.toStringAsFixed(2)}',
    ].join('\n');
  }
}

/// Replays the automatic strength over [observations] as they grew, with a
/// fit due under the same rule as on the phone.
AutoStrengthSummary summarizeAutoStrength(List<Observation> observations) {
  final double startRatio = ratioForBandwidth(autoStrengthStartInDays);
  final double firstDay = observations.first.time;
  double held = startRatio;
  double? firstFitInDays;
  int switches = 0;
  int daysAtLastTry = 0;
  for (int k = 1; k <= observations.length; k++) {
    final double historyInDays = observations[k - 1].time - firstDay + 1;
    if (historyInDays < autoStrengthMinHistoryInDays ||
        k - daysAtLastTry < autoStrengthTryEveryDays) {
      continue;
    }
    daysAtLastTry = k;
    final double? learned = learnAutoStrength(observations.sublist(0, k), held);
    if (learned == null) {
      continue;
    }
    firstFitInDays ??= historyInDays;
    if (learned != held) {
      switches++;
      held = learned;
    }
  }

  final double historyInDays = observations.last.time - firstDay + 1;
  final StructuralModel learnedModel = StructuralModel.localLinearTrend(
    processVariance: held,
  ).withEstimatedScale(observations);
  final double startLogLikelihood = StructuralModel.localLinearTrend(
    processVariance: startRatio,
  ).withEstimatedScale(observations).logLikelihood(observations);
  return AutoStrengthSummary(
    bandwidthInDays: bandwidthForRatio(
      held * observations.length / historyInDays,
    ),
    daysPerWeek: 7 * observations.length / historyInDays,
    historyInDays: historyInDays,
    firstFitInDays: firstFitInDays,
    switches: switches,
    gainInNats: learnedModel.logLikelihood(observations) - startLogLikelihood,
    noiseInKg: math.sqrt(learnedModel.measurementVariance),
    autocorrelation: learnedModel.diagnose(observations).autocorrelation(1),
  );
}
