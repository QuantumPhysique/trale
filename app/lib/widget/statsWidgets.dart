// ignore_for_file: file_names
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:flutter_m3shapes_extended/flutter_m3shapes_extended.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/durationExtension.dart';
import 'package:trale/core/font.dart';
import 'package:trale/core/gap.dart';
import 'package:trale/core/measurementStats.dart';
import 'package:trale/core/textSize.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/units.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/animate_in_effect.dart';
import 'package:trale/widget/bento_card.dart';
import 'package:trale/widget/iconHero.dart';

/// Animated statistics widgets container.
class AnimatedStatsWidgets extends StatefulWidget {
  /// Constructor.
  const AnimatedStatsWidgets({super.key});

  @override
  State<AnimatedStatsWidgets> createState() => _AnimatedStatsWidgetsState();
}

class _AnimatedStatsWidgetsState extends State<AnimatedStatsWidgets> {
  Timer? _weightLostDelayTimer;
  bool _showWeightLostCard = false;

  void _ensureWeightLostCardVisibility(bool shouldShow) {
    if (!shouldShow) {
      _weightLostDelayTimer?.cancel();
      _weightLostDelayTimer = null;
      if (!_showWeightLostCard) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(() => _showWeightLostCard = false);
      });
      return;
    }
    if (_showWeightLostCard || _weightLostDelayTimer != null) {
      return;
    }
    _weightLostDelayTimer = Timer(
      Duration(
        milliseconds:
            (TraleTheme.of(context)!.transitionDuration.normal.inMilliseconds /
                    2)
                .toInt(),
      ),
      () {
        if (!mounted) {
          return;
        }
        setState(() {
          _showWeightLostCard = true;
          _weightLostDelayTimer = null;
        });
      },
    );
  }

  @override
  void dispose() {
    _weightLostDelayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MeasurementStats stats = MeasurementStats();
    final TraleNotifier notifier = Provider.of<TraleNotifier>(context);

    final double? userTargetWeight = notifier.effectiveTargetWeight;
    final Duration? timeOfTargetWeight = stats.timeOfTargetWeight(
      userTargetWeight,
      notifier.looseWeight,
    );
    final int nMeasured = stats.nMeasurements;
    _ensureWeightLostCardVisibility(nMeasured >= 2);
    Card userTargetWeightCard(double utw) => Card(
      shape: const StadiumBorder(),
      color: Theme.of(context).colorScheme.secondaryContainer,
      margin: EdgeInsets.symmetric(vertical: TraleTheme.of(context)!.padding),
      child: Padding(
        padding: EdgeInsets.all(TraleTheme.of(context)!.padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            AutoSizeText(
              '${notifier.unit.weightToString(utw, notifier.unitPrecision)} in',
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.onSecondaryContainer(context),
            ),
            AutoSizeText(
              timeOfTargetWeight == null
                  ? '--'
                  : timeOfTargetWeight.durationToString(context),
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.onSecondaryContainer(context),
            ),
          ],
        ),
      ),
    );

    Card userWeightLostCard() {
      final double deltaWeight = stats.monthlyChange;

      return Card(
        shape: const StadiumBorder(),
        margin: EdgeInsets.symmetric(vertical: TraleTheme.of(context)!.padding),
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Padding(
          padding: EdgeInsets.all(TraleTheme.of(context)!.padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              AutoSizeText(
                '${AppLocalizations.of(context)!.change} / '
                '${AppLocalizations.of(context)!.month}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall!.onSecondaryContainer(context),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AutoSizeText(
                    notifier.unit.weightToString(
                      deltaWeight,
                      notifier.unitPrecision,
                    ),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.onSecondaryContainer(context),
                  ),
                  const SizedBox(width: 5),
                  SizedBox(
                    height: sizeOfText(
                      text: '0',
                      context: context,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.onSecondaryContainer(context),
                    ).height,
                    child: Transform.rotate(
                      // a change of 1kg / 30d corresponds to 45°
                      angle: -1 * atan(deltaWeight),
                      child: Icon(
                        PhosphorIconsRegular.arrowRight,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return FractionallySizedBox(
      widthFactor: (userTargetWeight == null || nMeasured < 2) ? 0.5 : 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:
            <Widget>[
              if (userTargetWeight != null)
                Expanded(
                  child: AnimateInEffect(
                    durationInMilliseconds: TraleTheme.of(
                      context,
                    )!.transitionDuration.slow.inMilliseconds,
                    child: userTargetWeightCard(userTargetWeight),
                  ),
                ),
              if (nMeasured >= 2 && _showWeightLostCard)
                Expanded(
                  child: AnimateInEffect(
                    durationInMilliseconds: TraleTheme.of(
                      context,
                    )!.transitionDuration.slow.inMilliseconds,
                    child: userWeightLostCard(),
                  ),
                ),
            ].addGap(
              padding: TraleTheme.of(context)!.padding,
              direction: Axis.horizontal,
            ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BentoCard-based widget builders
// ---------------------------------------------------------------------------

/// Full-width change-rates card (week / month / year columns).
BentoCard changeRatesCard({
  required BuildContext context,
  required MeasurementStats stats,
  int delayInMilliseconds = 0,
}) {
  final String unit = Provider.of<TraleNotifier>(
    context,
    listen: false,
  ).unit.name;
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  return BentoCard(
    columnSpan: 12,
    rowSpan: 2,
    delayInMilliseconds: delayInMilliseconds,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.center,
            child: AutoSizeText(
              '${l10n.change} ($unit)',
              style: Theme.of(context).textTheme.emphasized.bodyLarge!
                  .onSurface(context)
                  .copyWith(fontWeight: FontWeight.w900),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: AutoSizeText(
              '/ ${l10n.week}\n${weightToString(context, stats.deltaWeightLastWeek)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.onSurface(context).copyWith(height: 1.0),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: AutoSizeText(
              '/ ${l10n.month}\n${weightToString(context, stats.deltaWeightLastMonth)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.onSurface(context).copyWith(height: 1.0),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: AutoSizeText(
              '/ ${l10n.year}\n${weightToString(context, stats.deltaWeightLastYear)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.onSurface(context).copyWith(height: 1.0),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Full-width weight forecast card (today / +1 week / +1 month).
BentoCard weightForecastCard({
  required BuildContext context,
  required MeasurementStats stats,
  int delayInMilliseconds = 0,
}) {
  final String unit = Provider.of<TraleNotifier>(
    context,
    listen: false,
  ).unit.name;
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  return BentoCard(
    columnSpan: 12,
    rowSpan: 2,
    delayInMilliseconds: delayInMilliseconds,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.center,
            child: AutoSizeText(
              '${l10n.weightForecast} ($unit)',
              style: Theme.of(context).textTheme.emphasized.bodyLarge!
                  .onSurface(context)
                  .copyWith(fontWeight: FontWeight.w900),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: AutoSizeText(
              '/ ${l10n.today}\n${weightToString(context, stats.weightToday)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.onSurface(context).copyWith(height: 1.0),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: AutoSizeText(
              '/ ${l10n.week}\n${weightToString(context, stats.weightInOneWeek)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.onSurface(context).copyWith(height: 1.0),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: AutoSizeText(
              '/ ${l10n.month}\n${weightToString(context, stats.weightInOneMonth)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.onSurface(context).copyWith(height: 1.0),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Hero card: days until target weight is reached (with rotating M3E shape).
BentoCard reachingTargetWeightCard({
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
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  final List<String> labels =
      (timeOfTargetWeight?.durationToString(context) ?? '-- ${l10n.days}')
          .split(' ');
  final String subtext = labels.length == 1
      ? l10n.targetWeightReached
      : '${labels[1]} ${l10n.targetWeightReachedIn}';

  return BentoCard.textInline(
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
BentoCard nMeasurementsCard({
  required BuildContext context,
  required MeasurementStats stats,
  int delayInMilliseconds = 0,
}) {
  final String measurementsLabel = AppLocalizations.of(
    context,
  )!.measurements.toLowerCase();
  return BentoCard.text(
    columnSpan: 6,
    label: '# $measurementsLabel',
    value: '${stats.globalNMeasurements}',
    delayInMilliseconds: delayInMilliseconds,
  );
}

/// Hero card: total weight change.
BentoCard totalChangeCard({
  required BuildContext context,
  required MeasurementStats stats,
  int delayInMilliseconds = 0,
}) {
  final String unit = Provider.of<TraleNotifier>(
    context,
    listen: false,
  ).unit.name;
  return BentoCard.hero(
    span: 4,
    label: '${AppLocalizations.of(context)!.totalChange}\n($unit)',
    value: weightToString(context, stats.deltaWeight),
    valueFlex: 3,
    textColor: Theme.of(context).colorScheme.onSecondaryContainer,
    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
    delayInMilliseconds: delayInMilliseconds,
  );
}

/// Inline card: time since first measurement (number on left, label on right).
BentoCard timeSinceFirstCard({
  required BuildContext context,
  required MeasurementStats stats,
  int delayInMilliseconds = 0,
}) {
  final String durationStr = stats.globalDeltaTime.durationToString(context);
  final List<String> parts = durationStr.split(' ');
  final String number = parts[0];
  final String unit = parts.length > 1 ? parts.sublist(1).join(' ') : '';
  return BentoCard.hero(
    span: 4,
    value: number,
    label:
        '${AppLocalizations.of(context)!.timeSinceFirstMeasurement}\n($unit)',
    delayInMilliseconds: delayInMilliseconds,
    textColor: Theme.of(context).colorScheme.onTertiaryContainer,
    backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
  );
}

/// Emphasized 4×4 card: all-time weight maximum with the date it was recorded.
BentoCard globalMaxWeightDateCard({
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
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  return BentoCard.textInline(
    columnSpan: 8,
    rowSpan: 2,
    label: '${l10n.max} (${notifier.unit.name})\n$dateStr',
    value: weightToString(context, record.weight),
    delayInMilliseconds: delayInMilliseconds,
    reversed: true,
  );
}

/// Emphasized 4×4 card: all-time weight minimum with the date it was recorded.
BentoCard globalMinWeightDateCard({
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
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  return BentoCard.textInline(
    columnSpan: 8,
    rowSpan: 2,
    label: '${l10n.min} (${notifier.unit.name})\n$dateStr',
    value: weightToString(context, record.weight),
    delayInMilliseconds: delayInMilliseconds,
  );
}

/// Emphasized card: median weight.
BentoCard medianWeightCard({
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
  return BentoCard.textInline(
    columnSpan: 8,
    rowSpan: 2,
    label: '${AppLocalizations.of(context)!.median} (${notifier.unit.name})',
    value: weightToString(context, weight),
    reversed: true,
    delayInMilliseconds: delayInMilliseconds,
  );
}

/// Emphasized-text card: minimum recorded weight with date (label, value, date).
BentoCard minWeightCard({
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
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  return BentoCard.textEmphasized(
    columnSpan: 4,
    rowSpan: 4,
    label: '${l10n.min} (${notifier.unit.name})',
    value: weightToString(context, record.weight),
    sublabel: dateStr,
    delayInMilliseconds: delayInMilliseconds,
  );
}

/// Transparent card: app icon hero, placed on a given M3 shape.
BentoCard iconHeroCard({
  required BuildContext context,
  required Shapes shape,
  VoidCallback? onTap,
  int delayInMilliseconds = 0,
}) {
  return BentoCard.shaped(
    span: 4,
    backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
    delayInMilliseconds: delayInMilliseconds,
    m3eShape: shape,
    rotateDuration: const Duration(seconds: 60),
    onTap: onTap,
    child: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => Padding(
        padding: EdgeInsets.only(bottom: constraints.maxHeight * 0.1),
        child: const IconHeroStatScreen(),
      ),
    ),
  );
}

/// Emphasized-text card: maximum recorded weight with date (value, label, date).
BentoCard maxWeightCard({
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
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  return BentoCard.textEmphasized(
    columnSpan: 4,
    rowSpan: 4,
    label: '${l10n.max} (${notifier.unit.name})',
    value: weightToString(context, record.weight),
    sublabel: dateStr,
    delayInMilliseconds: delayInMilliseconds,
  );
}

/// Emphasized card: mean weight.
BentoCard meanWeightCard({
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
  return BentoCard.textInline(
    columnSpan: 8,
    rowSpan: 2,
    label: '${AppLocalizations.of(context)!.mean} (${notifier.unit.name})',
    value: weightToString(context, weight),
    delayInMilliseconds: delayInMilliseconds,
  );
}

/// Text card: all-time max streak.
BentoCard maxStreakCard({
  required BuildContext context,
  required MeasurementStats stats,
  int delayInMilliseconds = 0,
}) => BentoCard.text(
  columnSpan: 6,
  label: AppLocalizations.of(context)!.maxStreak,
  value: stats.globalMaxStreak.streakToStringDays(context),
  delayInMilliseconds: delayInMilliseconds,
);

/// Hero card: current streak (with rotating M3E shape).
BentoCard currentStreakCard({
  required BuildContext context,
  required MeasurementStats stats,
  int delayInMilliseconds = 0,
}) {
  final AppLocalizations l10n = AppLocalizations.of(context)!;
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
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  return BentoCard.text(
    columnSpan: 6,
    label: '${l10n.measurementFrequency}\n(/ ${l10n.week})',
    value: stats.globalFrequency!.toStringAsFixed(2),
    delayInMilliseconds: delayInMilliseconds,
  );
}

/// Returns the BMI range string and category label for a given [bmi] value.
({String range, String category}) _bmiCategory(
  double bmi,
  AppLocalizations l10n,
) {
  if (bmi < 17) {
    return (range: '< 17', category: l10n.bmiSevereUnderweight);
  } else if (bmi < 18.5) {
    return (range: '17 – 18.5', category: l10n.bmiUnderweight);
  } else if (bmi < 25) {
    return (range: '18.5 – 25', category: l10n.bmiNormal);
  } else if (bmi < 30) {
    return (range: '25 – 30', category: l10n.bmiOverweight);
  } else {
    return (range: '> 30', category: l10n.bmiObese);
  }
}

/// Card: current BMI with value, range, and category.
BentoCard bmiCard({
  required BuildContext context,
  required MeasurementStats stats,
  int delayInMilliseconds = 0,
}) {
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  final double? bmi = stats.currentBMI(context);
  final String bmiStr = doubleToString(bmi);
  final ({String range, String category}) info = bmi != null
      ? _bmiCategory(bmi, l10n)
      : (range: '--', category: '--');
  return BentoCard(
    columnSpan: 12,
    rowSpan: 3,
    delayInMilliseconds: delayInMilliseconds,
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: TraleTheme.of(context)!.padding,
        vertical: TraleTheme.of(context)!.padding / 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: AutoSizeText(
                l10n.bmi,
                style: Theme.of(context).textTheme.emphasized.bodyLarge!
                    .onSurface(context)
                    .copyWith(fontWeight: FontWeight.w900),
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.center,
              child: AutoSizeText(
                bmiStr,
                style: Theme.of(context).textTheme.emphasized.bodyMedium!
                    .onSurface(context)
                    .copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 200,
                      height: 0.7,
                    ),
                maxLines: 1,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: AutoSizeText(
                '${info.range}\n${info.category}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall!.onSurface(context),
                maxLines: 3,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Text card: estimated daily calorie deficit.
BentoCard calorieDeficitCard({
  required BuildContext context,
  required MeasurementStats stats,
  int delayInMilliseconds = 0,
}) => BentoCard.textInline(
  columnSpan: 8,
  rowSpan: 2,
  label: '${AppLocalizations.of(context)!.calorieDeficit}\n(kcal/day)',
  value: '${stats.dailyDeficit}',
  delayInMilliseconds: delayInMilliseconds,
);

/// Text card: difference from target weight.
BentoCard diffFromTargetCard({
  required BuildContext context,
  required MeasurementStats stats,
  int delayInMilliseconds = 0,
}) {
  final String unit = Provider.of<TraleNotifier>(
    context,
    listen: false,
  ).unit.name;
  return BentoCard.textEmphasized(
    columnSpan: 4,
    rowSpan: 5,
    label: '${AppLocalizations.of(context)!.diffFromTarget} ($unit)',
    value: weightToString(context, stats.currentDifference),
    textColor: Theme.of(context).colorScheme.onTertiaryContainer,
    backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
    delayInMilliseconds: delayInMilliseconds,
  );
}

/// Converts a weight value to a display string.
String weightToString(BuildContext context, double? d) {
  return d == null
      ? '--'
      : Provider.of<TraleNotifier>(context).unit.weightToString(
          d,
          Provider.of<TraleNotifier>(context).unitPrecision,
          showUnit: false,
        );
}

/// Converts a double value to a display string.
String doubleToString(double? d) {
  return d == null ? '--' : d.toStringAsFixed(1);
}
