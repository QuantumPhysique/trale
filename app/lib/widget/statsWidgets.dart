import 'dart:math';

import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/durationExtension.dart';
import 'package:trale/core/gap.dart';
import 'package:trale/core/measurementInterpolation.dart';
import 'package:trale/core/measurementStats.dart';
import 'package:trale/core/statsCards.dart';
import 'package:trale/core/textSize.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/units.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/animate_in_effect.dart';
import 'package:trale/widget/iconHero.dart';


class StatsWidgets extends StatefulWidget {
  const StatsWidgets({required this.visible, super.key});

  final bool visible;

  @override
  _StatsWidgetsState createState() => _StatsWidgetsState();
}

class _StatsWidgetsState extends State<StatsWidgets> {
  @override
  Widget build(BuildContext context) {
    final MeasurementInterpolation ip = MeasurementInterpolation();
    final MeasurementStats stats = MeasurementStats();
    final TraleNotifier notifier = Provider.of<TraleNotifier>(context);

    final double? userTargetWeight = notifier.userTargetWeight;
    final Duration? timeOfTargetWeight = stats.timeOfTargetWeight(
        userTargetWeight, notifier.looseWeight,
    );
    final int nMeasured = ip.measurementDuration.inDays;
    Card userTargetWeightCard(double utw) => Card(
      shape: TraleTheme.of(context)!.borderShape,
      color: Theme.of(context).colorScheme.secondaryContainer,
      margin: EdgeInsets.symmetric(
        vertical: TraleTheme.of(context)!.padding,
      ),
      child: Padding(
        padding: EdgeInsets.all(TraleTheme.of(context)!.padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            AutoSizeText(
              '${notifier.unit.weightToString(utw)} in',
              style: Theme.of(context).textTheme.bodySmall!
                .onSecondaryContainer(context),
            ),
            AutoSizeText(
              timeOfTargetWeight == null
                ? '--'
                : timeOfTargetWeight.durationToString(context),
              style: Theme.of(context).textTheme.bodyLarge!
                .onSecondaryContainer(context),
            ),
          ],
        ),
      ),
    );

    Card userWeightLostCard() {
      final double deltaWeight = ip.finalSlope * 30;

      return Card(
        shape: TraleTheme.of(context)!.borderShape,
        margin: EdgeInsets.symmetric(
          vertical: TraleTheme.of(context)!.padding,
        ),
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
                style: Theme.of(context).textTheme.bodySmall!
                  .onSecondaryContainer(context),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AutoSizeText(
                    notifier.unit.weightToString(deltaWeight),
                    style: Theme.of(context).textTheme.bodyLarge!
                      .onSecondaryContainer(context),
                  ),
                  const SizedBox(width: 5),
                  SizedBox(
                    height: sizeOfText(
                      text: '0',
                      context: context,
                      style: Theme.of(context).textTheme.bodyLarge!
                        .onSecondaryContainer(context),
                    ).height,
                    child: Transform.rotate(
                      // a change of 1kg / 30d corresponds to 45°
                      angle: -1 * atan(deltaWeight),
                      child: Icon(
                          PhosphorIconsRegular.arrowRight,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
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
      child: AnimatedCrossFade(
        crossFadeState: widget.visible
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        duration: TraleTheme.of(context)!.transitionDuration.fast,
        secondChild: const SizedBox.shrink(),
        firstChild: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            if (userTargetWeight != null) Expanded(
                child: userTargetWeightCard(userTargetWeight)
            ),
            if (nMeasured >= 2) Expanded(
                child: userWeightLostCard(),
            ),
          ].addGap(
            padding: TraleTheme.of(context)!.padding,
            direction: Axis.horizontal,
          ),
        ),
      ),
    );
  }
}


/// define StatCard for number of days until target weight is reached
StatCard getReachingTargetWeightWidget({required BuildContext context,
                                        required MeasurementStats stats,
                                        int? delayInMilliseconds}) {

  final double? userTargetWeight =
      Provider.of<TraleNotifier>(context).userTargetWeight;
  final TraleNotifier notifier = Provider.of<TraleNotifier>(context);
  final Duration? timeOfTargetWeight = stats.timeOfTargetWeight(
    userTargetWeight, notifier.looseWeight,
  );

  final List<String> textLabels=
    (timeOfTargetWeight?.durationToString(context) ??
     '-- ${AppLocalizations.of(context)!.days}'
    ).split(' ');

  final String subtext = textLabels.length == 1
      ? AppLocalizations.of(context)!.targetWeightReached
      : '${textLabels[1]} ${AppLocalizations.of(context)!.targetWeightReachedIn}';

  return StatCard(
    backgroundColor: Theme.of(context).brightness == Brightness.light
      ? Theme.of(context).primaryColor
      : Theme.of(context).colorScheme.primaryContainer,
    delayInMilliseconds: delayInMilliseconds,
    ny: 2,
    childWidget: Padding(
      padding: EdgeInsets.all(TraleTheme.of(context)!.padding / 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.center,
              child: AutoSizeText(
                textLabels[0],
                style: Theme.of(context).textTheme.displayLarge!.copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                  fontSize: 200,
                ),
                maxLines: 1,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.topCenter,
              child: AutoSizeText(
                subtext,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onPrimaryContainer,
                  height: 1.0,
                ),
                maxLines: 3,
                textAlign: TextAlign.center,
              ),
            ),
          )
        ]),
    ),
  );
}


/// define StatCard for the frequency in total
StatCard getFrequencyInTotal({required BuildContext context,
                              required MeasurementStats stats,
                              int? delayInMilliseconds}) {

  return StatCard(
    backgroundColor: Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).primaryColor
        : Theme.of(context).colorScheme.primaryContainer,
    delayInMilliseconds: delayInMilliseconds,
    ny: 2,
    childWidget: Padding(
      padding: EdgeInsets.all(TraleTheme.of(context)!.padding / 2),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.center,
                child: AutoSizeText(
                  (7 * stats.frequencyInTotal!).toStringAsFixed(2),
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                    fontSize: 200,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.topCenter,
                child: AutoSizeText(
                '${AppLocalizations.of(context)!.measurementFrequency}\n'
                      '(/ ${AppLocalizations.of(context)!.week})',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onPrimaryContainer,
                    height: 1.0,
                  ),
                  maxLines: 3,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ]),
    ),
  );
}


/// define StatCard for number of days until target weight is reached
StatCard getTotalChangeWidget({required BuildContext context,
                        required MeasurementStats stats,
                        int? delayInMilliseconds}) {
  final String unit =
      Provider.of<TraleNotifier>(context, listen: false).unit.name;
  return StatCard(
    ny: 2,
    delayInMilliseconds: delayInMilliseconds,
    backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
    childWidget: Padding(
      padding: EdgeInsets.all(TraleTheme.of(context)!.padding / 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.center,
              child: AutoSizeText(
                weightToString(context, stats.deltaWeight),
                style: Theme.of(context).textTheme.displayLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.w900,
                  fontSize: 200,
                ),
                maxLines: 1,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.topCenter,
              child: AutoSizeText(
                '${AppLocalizations.of(context)!.totalChange}\n($unit)',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                  height: 1.0,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ),
          )
        ]
      ),
    ),
  );
}


/// define StatCard for number of days until target weight is reached
Widget getMeanWidget({required BuildContext context,
                             required MeasurementStats stats,
                             int? delayInMilliseconds}) {
  final String unit =
      Provider.of<TraleNotifier>(context, listen: false).unit.name;
  return StatCard(
    nx: 2,
    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    delayInMilliseconds: delayInMilliseconds,
    childWidget: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.center,
            child: AutoSizeText(
              weightToString(context, stats.meanWeight),
              style: Theme.of(context).textTheme.displayLarge!.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w900,
                fontSize: 200,
              ),
              maxLines: 1,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.center,
            child: AutoSizeText(
              '${AppLocalizations.of(context)!.mean} ($unit)',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                height: 1.0,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        )
      ]
    ),
  );
}



/// define StatCard for number of days until target weight is reached
Widget getBMIWidget({
    required BuildContext context,
    required MeasurementStats stats,
    int? delayInMilliseconds
  }) {
  return StatCard(
    nx: 2,
    delayInMilliseconds: delayInMilliseconds,
    childWidget: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.center,
            child: AutoSizeText(
              AppLocalizations.of(context)!.bmi,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                height: 1.0,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.center,
            child: AutoSizeText(
              doubleToString(stats.currentBMI(context)),
              style: Theme.of(context).textTheme.displayLarge!.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 200,
              ),
              maxLines: 1,
            ),
          ),
        ),
      ]
    ),
  );
}


/// define StatCard for change per week, month, and year
StatCard getChangeRatesWidget({required BuildContext context,
                               required MeasurementStats stats,
                               int? delayInMilliseconds}) {
  final String unit =
      Provider.of<TraleNotifier>(context, listen: false).unit.name;
  return StatCard(
    nx: 2,
    delayInMilliseconds: delayInMilliseconds,
    childWidget: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.center,
            child: AutoSizeText(
              '${AppLocalizations.of(context)!.change} ($unit)',
              style: Theme.of(context).textTheme.bodyLarge!.onSurface(context)
                .copyWith(fontWeight: FontWeight.w900),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerLeft,
            child: AutoSizeText(
              '/ ${AppLocalizations.of(context)!.week}\n'
                '${weightToString(context, stats.deltaWeightLastWeek)}',
              style: Theme.of(context).textTheme.bodyMedium!.onSurface(context)
                .copyWith(height: 1.0),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerLeft,
            child: AutoSizeText(
              '/ ${AppLocalizations.of(context)!.month}\n'
                '${weightToString(context, stats.deltaWeightLastMonth)}',
              style: Theme.of(context).textTheme.bodyMedium!.onSurface(context)
                .copyWith(height: 1.0),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerLeft,
            child: AutoSizeText(
              '/ ${AppLocalizations.of(context)!.year}\n'
                '${weightToString(context, stats.deltaWeightLastYear)}',
              style: Theme.of(context).textTheme.bodyMedium!.onSurface(context)
                .copyWith(height: 1.0),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        )
      ]
    ),
  );
}


/// define StatCard for change per week, month, and year
Widget getMinWidget({required BuildContext context,
                     required MeasurementStats stats,
                     int? delayInMilliseconds}) {
  final String unit =
      Provider.of<TraleNotifier>(context, listen: false).unit.name;
  return OneThirdStatCard(
    delayInMilliseconds: delayInMilliseconds,
    childWidget: Padding(
      padding: EdgeInsets.all(TraleTheme.of(context)!.padding / 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.center,
              child: AutoSizeText(
                '${AppLocalizations.of(context)!.min} ($unit)',
                 style: Theme.of(context).textTheme.bodyLarge!
                   .onSurface(context),
                 maxLines: 1,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.center,
              child: AutoSizeText(
                weightToString(context, stats.minWeight),
                style: Theme.of(context).textTheme.bodyMedium!
                  .onSurface(context).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 200,
                    height: 0.70,
                ),
                maxLines: 1,
              ),
            ),
          ),
        ]
      ),
    ),
  );
}

/// define StatCard for change per week, month, and year
Widget getMaxWidget({required BuildContext context,
                     required MeasurementStats stats,
                     int? delayInMilliseconds}) {
  final String unit =
      Provider.of<TraleNotifier>(context, listen: false).unit.name;
  return OneThirdStatCard(
    delayInMilliseconds: delayInMilliseconds,
    childWidget: Padding(
      padding: EdgeInsets.all(TraleTheme.of(context)!.padding / 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.center,
              child: AutoSizeText(
                weightToString(context, stats.maxWeight),
                style: Theme.of(context).textTheme.bodyMedium!
                  .onSurface(context).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 200,
                  height: 0.70,
                ),
                maxLines: 1,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.center,
              child: AutoSizeText(
                '${AppLocalizations.of(context)!.max} ($unit)',
                style: Theme.of(context).textTheme.bodyLarge!
                  .onSurface(context),
                maxLines: 1,
              ),
            ),
          ),
        ]
      ),
    ),
  );
}


/// define StatCard for change per week, month, and year
Widget getIconWidget({required BuildContext context,
                      required MeasurementStats stats,
                      int? delayInMilliseconds}) {
  final double iconHeroSize =
      (MediaQuery.sizeOf(context).width
       - 5 * TraleTheme.of(context)!.padding) / 4;
  final int animationDurationInMilliseconds =
      TraleTheme.of(context)!.transitionDuration.slow.inMilliseconds;

  return AnimateInEffect(
    delayInMilliseconds: delayInMilliseconds ?? 0,
    durationInMilliseconds: animationDurationInMilliseconds,
    child: SizedBox(
      width: iconHeroSize,
      height: iconHeroSize,
      child: const IconHeroStatScreen(),
    ),
  );
}


String weightToString(BuildContext context, double? d){
  return d == null
      ? '--'
      : Provider.of<TraleNotifier>(context).unit.weightToString(
      d, showUnit: false);
}

String doubleToString(double? d){
  print(d);
  return d == null
      ? '--'
      : d.toStringAsFixed(1);
}