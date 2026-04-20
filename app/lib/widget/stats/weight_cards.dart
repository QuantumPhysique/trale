part of '../stats_widgets.dart';

/// Hero card: days until target weight is reached (with rotating M3E shape).
QPBentoCard reachingTargetWeightCard({
  required BuildContext context,
  required MeasurementStats stats,
  int delayInMilliseconds = 0,
}) {
  final TraleNotifier notifier = Provider.of<TraleNotifier>(
    context,
    listen: false,
  );
  final Duration? timeOfTargetWeight = stats.timeOfTargetWeight(
    notifier.effectiveTargetWeight,
    notifier.looseWeight,
  );
  final AppLocalizations l10n = context.l10n;
  final List<String> labels =
      (timeOfTargetWeight?.durationToString(context) ?? '-- ${l10n.days}')
          .split(' ');
  final String subtext = labels.length == 1
      ? l10n.targetWeightReached
      : '${labels[1]} ${l10n.targetWeightReachedIn}';

  return QPBentoCard.textInline(
    columnSpan: 8,
    rowSpan: 3,
    label: subtext,
    value: labels[0],
    reversed: true,
    textColor: Theme.of(context).colorScheme.onPrimaryContainer,
    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    delayInMilliseconds: delayInMilliseconds,
  );
}

/// Text card: number of total measurements (pill shape).
QPBentoCard nMeasurementsCard({
  required BuildContext context,
  required MeasurementStats stats,
  int delayInMilliseconds = 0,
}) {
  final String measurementsLabel = AppLocalizations.of(
    context,
  )!.measurements.toLowerCase();
  return QPBentoCard.text(
    columnSpan: 6,
    label: '# $measurementsLabel',
    value: '${stats.globalNMeasurements}',
    delayInMilliseconds: delayInMilliseconds,
  );
}

/// Hero card: total weight change.
QPBentoCard totalChangeCard({
  required BuildContext context,
  required MeasurementStats stats,
  int delayInMilliseconds = 0,
}) {
  final String unit = Provider.of<TraleNotifier>(
    context,
    listen: false,
  ).unit.name;
  return QPBentoCard.hero(
    span: 4,
    label: '${context.l10n.totalChange}\n($unit)',
    value: weightToString(context, stats.deltaWeight),
    valueFlex: 3,
    textColor: Theme.of(context).colorScheme.onSecondaryContainer,
    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
    delayInMilliseconds: delayInMilliseconds,
  );
}

/// Inline card: time since first measurement (number on left, label on right).
QPBentoCard timeSinceFirstCard({
  required BuildContext context,
  required MeasurementStats stats,
  int delayInMilliseconds = 0,
}) {
  final String durationStr = stats.globalDeltaTime.durationToString(context);
  final List<String> parts = durationStr.split(' ');
  final String number = parts[0];
  final String unit = parts.length > 1 ? parts.sublist(1).join(' ') : '';
  return QPBentoCard.hero(
    span: 4,
    value: number,
    label: '${context.l10n.timeSinceFirstMeasurement}\n($unit)',
    delayInMilliseconds: delayInMilliseconds,
    textColor: Theme.of(context).colorScheme.onTertiaryContainer,
    backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
  );
}

/// Emphasized 4×4 card: all-time weight maximum with the date it was recorded.
QPBentoCard globalMaxWeightDateCard({
  required BuildContext context,
  required MeasurementStats stats,
  int delayInMilliseconds = 0,
}) {
  final TraleNotifier notifier = Provider.of<TraleNotifier>(
    context,
    listen: false,
  );
  final ({double? weight, DateTime? date}) record =
      notifier.statsUseInterpolation
      ? stats.globalMaxInterpolatedWeightDate
      : stats.globalMaxWeightDate;
  final String dateStr = record.date != null
      ? notifier.dateFormat(context).format(record.date!)
      : '--';
  final AppLocalizations l10n = context.l10n;
  return QPBentoCard.textInline(
    columnSpan: 8,
    rowSpan: 2,
    label: '${l10n.max} (${notifier.unit.name})\n$dateStr',
    value: weightToString(context, record.weight),
    delayInMilliseconds: delayInMilliseconds,
    reversed: true,
  );
}

/// Emphasized 4×4 card: all-time weight minimum with the date it was recorded.
QPBentoCard globalMinWeightDateCard({
  required BuildContext context,
  required MeasurementStats stats,
  int delayInMilliseconds = 0,
}) {
  final TraleNotifier notifier = Provider.of<TraleNotifier>(
    context,
    listen: false,
  );
  final ({double? weight, DateTime? date}) record =
      notifier.statsUseInterpolation
      ? stats.globalMinInterpolatedWeightDate
      : stats.globalMinWeightDate;
  final String dateStr = record.date != null
      ? notifier.dateFormat(context).format(record.date!)
      : '--';
  final AppLocalizations l10n = context.l10n;
  return QPBentoCard.textInline(
    columnSpan: 8,
    rowSpan: 2,
    label: '${l10n.min} (${notifier.unit.name})\n$dateStr',
    value: weightToString(context, record.weight),
    delayInMilliseconds: delayInMilliseconds,
  );
}

/// Emphasized card: median weight.
QPBentoCard medianWeightCard({
  required BuildContext context,
  required MeasurementStats stats,
  int delayInMilliseconds = 0,
}) {
  final TraleNotifier notifier = Provider.of<TraleNotifier>(
    context,
    listen: false,
  );
  final double? weight = notifier.statsUseInterpolation
      ? stats.medianInterpolatedWeight
      : stats.medianWeight;
  return QPBentoCard.textInline(
    columnSpan: 8,
    rowSpan: 2,
    label: '${context.l10n.median} (${notifier.unit.name})',
    value: weightToString(context, weight),
    reversed: true,
    delayInMilliseconds: delayInMilliseconds,
  );
}

/// Emphasized-text card: minimum recorded weight with date
/// (label, value, date).
QPBentoCard minWeightCard({
  required BuildContext context,
  required MeasurementStats stats,
  int delayInMilliseconds = 0,
}) {
  final TraleNotifier notifier = Provider.of<TraleNotifier>(
    context,
    listen: false,
  );
  final ({double? weight, DateTime? date}) record =
      notifier.statsUseInterpolation
      ? stats.minInterpolatedWeightDate
      : stats.minWeightDate;
  final String dateStr = record.date != null
      ? notifier.dateFormat(context).format(record.date!)
      : '--';
  final AppLocalizations l10n = context.l10n;
  return QPBentoCard.textEmphasized(
    columnSpan: 4,
    rowSpan: 4,
    label: '${l10n.min} (${notifier.unit.name})',
    value: weightToString(context, record.weight),
    sublabel: dateStr,
    delayInMilliseconds: delayInMilliseconds,
  );
}

/// Emphasized-text card: maximum recorded weight with date
/// (value, label, date).
QPBentoCard maxWeightCard({
  required BuildContext context,
  required MeasurementStats stats,
  int delayInMilliseconds = 0,
}) {
  final TraleNotifier notifier = Provider.of<TraleNotifier>(
    context,
    listen: false,
  );
  final ({double? weight, DateTime? date}) record =
      notifier.statsUseInterpolation
      ? stats.maxInterpolatedWeightDate
      : stats.maxWeightDate;
  final String dateStr = record.date != null
      ? notifier.dateFormat(context).format(record.date!)
      : '--';
  final AppLocalizations l10n = context.l10n;
  return QPBentoCard.textEmphasized(
    columnSpan: 4,
    rowSpan: 4,
    label: '${l10n.max} (${notifier.unit.name})',
    value: weightToString(context, record.weight),
    sublabel: dateStr,
    delayInMilliseconds: delayInMilliseconds,
  );
}

/// Emphasized card: mean weight.
QPBentoCard meanWeightCard({
  required BuildContext context,
  required MeasurementStats stats,
  int delayInMilliseconds = 0,
}) {
  final TraleNotifier notifier = Provider.of<TraleNotifier>(
    context,
    listen: false,
  );
  final double? weight = notifier.statsUseInterpolation
      ? stats.meanInterpolatedWeight
      : stats.meanWeight;
  return QPBentoCard.textInline(
    columnSpan: 8,
    rowSpan: 2,
    label: '${context.l10n.mean} (${notifier.unit.name})',
    value: weightToString(context, weight),
    delayInMilliseconds: delayInMilliseconds,
  );
}
