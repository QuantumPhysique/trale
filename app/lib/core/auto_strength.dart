import 'package:state_space/state_space.dart'
    show FitResult, Observation, StructuralModel, fit;
import 'package:trale/core/constants.dart';

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
