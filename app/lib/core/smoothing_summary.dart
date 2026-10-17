import 'package:trale/core/constants.dart';
import 'package:trale/core/interpolation.dart';
import 'package:trale/core/smoothing.dart';

/// What the smoothing learned from the user's diary, to share.
class SmoothingSummary {
  /// Creates a [SmoothingSummary].
  const SmoothingSummary({
    required this.state,
    required this.strength,
    required this.growing,
    required this.daysPerWeek,
    required this.historyInDays,
  });

  /// The learned amplitudes, scale error and growth factor.
  final SmoothingState state;

  /// The strength the curve is drawn with.
  final InterpolStrength strength;

  /// Whether the body counts as still growing.
  final bool growing;

  /// Days with a measurement per week.
  final double daysPerWeek;

  /// Days from the first to the last measurement.
  final int historyInDays;

  /// The summary as plain text to share, rounded so that it cannot single out
  /// a diary.
  String toText() {
    String percent(double fraction) =>
        '${((fraction * 2000).round() / 20).toStringAsFixed(2)} %';
    final String growth = growing
        ? 'yes, growth factor ${state.growthFactor.toStringAsFixed(1)}'
        : 'no';
    return <String>[
      'trale: smoothing summary',
      'strength: ${strength.name}',
      'week-scale changes: ${percent(state.weekAmplitude)} of body weight',
      'water: ${percent(state.waterAmplitude)} of body weight',
      'scale error: ${state.scaleErrorKg.toStringAsFixed(2)} kg',
      'growing: $growth',
      'days with a measurement per week: ${daysPerWeek.toStringAsFixed(1)}',
      'history: ${(historyInDays / daysPerMonth).round()} months',
    ].join('\n');
  }
}
