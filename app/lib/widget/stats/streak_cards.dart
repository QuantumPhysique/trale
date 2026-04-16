part of '../stats_widgets.dart';

/// Text card: all-time max streak.
BentoCard maxStreakCard({
  required BuildContext context,
  required MeasurementStats stats,
  int delayInMilliseconds = 0,
}) => BentoCard.text(
  columnSpan: 6,
  label: context.l10n.maxStreak,
  value: stats.globalMaxStreak.streakToStringDays(context),
  delayInMilliseconds: delayInMilliseconds,
);

/// Hero card: current streak (with rotating M3E shape).
BentoCard currentStreakCard({
  required BuildContext context,
  required MeasurementStats stats,
  int delayInMilliseconds = 0,
}) {
  final AppLocalizations l10n = context.l10n;
  return BentoCard.hero(
    span: 6,
    label: '${l10n.currentStreak}\n(/ ${l10n.days})',
    value: stats.globalCurrentStreak.streakToStringDays(
      context,
      addLabel: false,
    ),
    textColor: Theme.of(context).colorScheme.onPrimaryContainer,
    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    delayInMilliseconds: delayInMilliseconds,
    m3eShape: Shapes.c12_sided_cookie,
    rotateDuration: const Duration(seconds: 60),
  );
}

/// Text card: measurement frequency per week.
BentoCard measurementFrequencyCard({
  required BuildContext context,
  required MeasurementStats stats,
  int delayInMilliseconds = 0,
}) {
  final AppLocalizations l10n = context.l10n;
  return BentoCard.text(
    columnSpan: 6,
    label: '${l10n.measurementFrequency}\n(/ ${l10n.week})',
    value: stats.globalFrequency!.toStringAsFixed(2),
    delayInMilliseconds: delayInMilliseconds,
  );
}

