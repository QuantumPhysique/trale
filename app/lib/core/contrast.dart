import 'package:quantumphysique/quantumphysique.dart';

/// Backward-compat alias: [ContrastLevel] is now [QPContrast].
typedef ContrastLevel = QPContrast;

/// Bridge: convert a stored [String] to [ContrastLevel] (= [QPContrast]).
extension ContrastLevelParsing on String {
  /// Convert a serialised name to [ContrastLevel], or `null` if unrecognised.
  ContrastLevel? toContrastLevel() => toQPContrast();
}
