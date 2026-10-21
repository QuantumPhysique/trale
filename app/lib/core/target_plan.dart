import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:trale/core/weight_goal.dart';
import 'package:trale/l10n-gen/app_localizations.dart';

/// Path from a start weight to the target weight that changes by the same
/// share of the current weight every week, so it flattens towards the target.
@immutable
class TargetPlan {
  /// Creates a [TargetPlan] from [start] to [end].
  const TargetPlan({
    required this.start,
    required this.startWeight,
    required this.end,
    required this.target,
  });

  /// Plan from [start] reaching [target] at [weeklyRate], or null when the
  /// target is less than half a day away.
  static TargetPlan? fromRate({
    required DateTime start,
    required double startWeight,
    required double target,
    required double weeklyRate,
  }) {
    assert(weeklyRate > 0, 'weeklyRate must be positive');
    final int days = (7 * log(target / startWeight).abs() / weeklyRate).round();
    if (days <= 0) {
      return null;
    }
    return TargetPlan(
      start: start,
      startWeight: startWeight,
      end: DateTime(start.year, start.month, start.day + days),
      target: target,
    );
  }

  /// Day the plan starts.
  final DateTime start;

  /// Weight [kg] at [start].
  final double startWeight;

  /// Day the plan reaches [target].
  final DateTime end;

  /// Target weight [kg].
  final double target;

  /// Number of days from [start] to [end].
  int get days => _daysBetween(start, end);

  /// Weekly change as a share of the current weight, e.g. 0.005 for 0.5 %.
  double get weeklyRate => 7 * log(target / startWeight).abs() / days;

  /// Planned weight [kg] after [elapsedDays] from [start].
  double weightAfterDays(num elapsedDays) =>
      startWeight * pow(target / startWeight, elapsedDays / days);

  /// Planned weight [kg] on [day], [target] outside of the plan.
  double weightAt(DateTime day) {
    final int elapsed = _daysBetween(start, day);
    if (elapsed <= 0 || elapsed >= days) {
      return target;
    }
    return weightAfterDays(elapsed);
  }

  // Calendar days in UTC, so that a daylight saving switch does not lose one.
  static int _daysBetween(DateTime from, DateTime to) => DateTime.utc(
    to.year,
    to.month,
    to.day,
  ).difference(DateTime.utc(from.year, from.month, from.day)).inDays;
}

/// How demanding the weekly rate of a [TargetPlan] is.
enum TargetPace {
  /// Easy to keep up, but slow.
  gentle,

  /// The rate guidelines recommend.
  textbook,

  /// Faster, but harder to keep up.
  ambitious,

  /// Hard to keep up for long.
  aggressive,
}

/// Extend [TargetPace].
extension TargetPaceExtension on TargetPace {
  /// get international name
  String nameLong(BuildContext context) => <TargetPace, String>{
    TargetPace.gentle: AppLocalizations.of(context)!.targetPaceGentle,
    TargetPace.textbook: AppLocalizations.of(context)!.targetPaceTextbook,
    TargetPace.ambitious: AppLocalizations.of(context)!.targetPaceAmbitious,
    TargetPace.aggressive: AppLocalizations.of(context)!.targetPaceAggressive,
  }[this]!;

  /// One sentence on what the pace means.
  String description(BuildContext context) => <TargetPace, String>{
    TargetPace.gentle: AppLocalizations.of(
      context,
    )!.targetPaceGentleDescription,
    TargetPace.textbook: AppLocalizations.of(
      context,
    )!.targetPaceTextbookDescription,
    TargetPace.ambitious: AppLocalizations.of(
      context,
    )!.targetPaceAmbitiousDescription,
    TargetPace.aggressive: AppLocalizations.of(
      context,
    )!.targetPaceAggressiveDescription,
  }[this]!;

  /// Colour of the pace when selected.
  Color color(ColorScheme colorScheme) => <TargetPace, Color>{
    TargetPace.gentle: colorScheme.secondary,
    TargetPace.textbook: colorScheme.primary,
    TargetPace.ambitious: colorScheme.tertiary,
    TargetPace.aggressive: colorScheme.error,
  }[this]!;

  /// Colour of the pace when not selected.
  Color containerColor(ColorScheme colorScheme) => <TargetPace, Color>{
    TargetPace.gentle: colorScheme.secondaryContainer,
    TargetPace.textbook: colorScheme.primaryContainer,
    TargetPace.ambitious: colorScheme.tertiaryContainer,
    TargetPace.aggressive: colorScheme.errorContainer,
  }[this]!;
}

/// Weekly rates of the [TargetPace]s for a [WeightGoal].
extension WeightGoalPace on WeightGoal {
  /// Weekly rate, as a share of the weight, from which on each pace applies.
  // Losing: 10 % in 6 months is 0.4 % a week (NHLBI 1998), at most
  // 0.5–1 kg a week (NICE). Gaining: 0.25–0.5 % (Iraki et al. 2019).
  Map<TargetPace, double> get paceFrom => switch (this) {
    WeightGoal.lose => const <TargetPace, double>{
      TargetPace.gentle: 0,
      TargetPace.textbook: 0.0025,
      TargetPace.ambitious: 0.0075,
      TargetPace.aggressive: 0.0125,
    },
    WeightGoal.gain => const <TargetPace, double>{
      TargetPace.gentle: 0,
      TargetPace.textbook: 0.0025,
      TargetPace.ambitious: 0.005,
      TargetPace.aggressive: 0.0075,
    },
    WeightGoal.maintain => throw UnsupportedError('Maintaining has no pace'),
  };

  /// Slowest and fastest weekly rate, as a share of the weight, offered.
  ({double min, double max}) get weeklyRateRange => switch (this) {
    WeightGoal.lose => (min: 0.001, max: 0.02),
    WeightGoal.gain => (min: 0.0005, max: 0.01),
    WeightGoal.maintain => throw UnsupportedError('Maintaining has no pace'),
  };

  /// Weekly rate, as a share of the weight, a new plan starts at.
  double get defaultWeeklyRate => switch (this) {
    WeightGoal.lose => 0.005,
    WeightGoal.gain => 0.0035,
    WeightGoal.maintain => throw UnsupportedError('Maintaining has no pace'),
  };

  /// Pace of a plan at [weeklyRate].
  TargetPace paceOf(double weeklyRate) => TargetPace.values.lastWhere(
    (TargetPace pace) => weeklyRate >= paceFrom[pace]!,
  );
}
