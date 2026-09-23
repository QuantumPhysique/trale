import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:trale/core/constants.dart';
import 'package:trale/l10n-gen/app_localizations.dart';

/// What the user wants their weight to do relative to the target weight.
enum WeightGoal {
  /// Get down to the target weight.
  lose,

  /// Stay within a tolerance around the target weight.
  maintain,

  /// Get up to the target weight.
  gain,
}

/// Extend [WeightGoal].
extension WeightGoalExtension on WeightGoal {
  /// get international name
  String nameLong(BuildContext context) => <WeightGoal, String>{
    WeightGoal.lose: AppLocalizations.of(context)!.looseWeight,
    WeightGoal.maintain: AppLocalizations.of(context)!.maintainWeight,
    WeightGoal.gain: AppLocalizations.of(context)!.gainWeight,
  }[this]!;

  /// Duotone icon of the goal.
  IconData get icon => <WeightGoal, IconData>{
    WeightGoal.lose: PhosphorIconsDuotone.trendDown,
    WeightGoal.maintain: PhosphorIconsDuotone.arrowsInLineVertical,
    WeightGoal.gain: PhosphorIconsDuotone.trendUp,
  }[this]!;

  /// Icon of the goal in the goal selector, filled when [active].
  IconData selectorIcon({required bool active}) => <WeightGoal, IconData>{
    WeightGoal.lose: active
        ? PhosphorIconsFill.trendDown
        : PhosphorIconsRegular.trendDown,
    WeightGoal.maintain: active
        ? PhosphorIconsFill.arrowsInLineVertical
        : PhosphorIconsRegular.arrowsInLineVertical,
    WeightGoal.gain: active
        ? PhosphorIconsFill.trendUp
        : PhosphorIconsRegular.trendUp,
  }[this]!;

  /// Weights [kg] that count as on target for [target] and [tolerance].
  TargetRange range(double target, double tolerance) =>
      <WeightGoal, TargetRange>{
        WeightGoal.lose: TargetRange(double.negativeInfinity, target),
        WeightGoal.maintain: TargetRange(
          target - tolerance,
          target + tolerance,
        ),
        WeightGoal.gain: TargetRange(target, double.infinity),
      }[this]!;
}

/// Convert a string to a [WeightGoal].
extension WeightGoalParsing on String {
  /// Get the [WeightGoal] of this name, or null.
  WeightGoal? toWeightGoal() {
    for (final WeightGoal goal in WeightGoal.values) {
      if (this == goal.name) {
        return goal;
      }
    }
    return null;
  }
}

/// Closed weight interval [kg] that counts as on target.
@immutable
class TargetRange {
  /// Creates a [TargetRange]; either bound may be infinite.
  const TargetRange(this.lower, this.upper);

  /// Lower bound [kg].
  final double lower;

  /// Upper bound [kg].
  final double upper;

  /// Whether [weight] lies inside the range.
  bool contains(double weight) => lower <= weight && weight <= upper;

  /// Time until a trend at [weight], changing by [slope] kg/day, enters the
  /// range: -1 days when it is already inside, null when it is not heading
  /// there.
  Duration? timeToEnter({required double weight, required double slope}) {
    if (contains(weight)) {
      return const Duration(days: -1);
    }
    final double bound = weight > upper ? upper : lower;
    if (slope * (weight - bound) >= 0 || slope.abs() < minSlopeToTarget) {
      return null;
    }
    final int days = ((bound - weight) / slope).round();
    return days == 0 ? const Duration(days: -1) : Duration(days: days);
  }
}
