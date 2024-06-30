import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/gap.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/core/measurementInterpolation.dart';
import 'package:trale/core/measurementStats.dart';
import 'package:trale/core/textSize.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/units.dart';


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
    final int? timeOfTargetWeight = stats.timeOfTargetWeight(
        userTargetWeight
    )?.inDays;
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
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            AutoSizeText(
              timeOfTargetWeight == null
                ? '-- days'
                : '$timeOfTargetWeight days',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );

    Card userWeightLostCard() {
      final double deltaWeight = ip.finalSlope * 30;
      const String label = 'month';

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
                'Change / $label',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AutoSizeText(
                    notifier.unit.weightToString(deltaWeight),
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                  SizedBox(
                    height: sizeOfText(
                      text: '0',
                      context: context,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).
                          colorScheme.onSecondaryContainer,
                      ),
                    ).height,
                    child: Transform.rotate(
                      // a change of 1kg / 30d corresponds to 45°
                      angle: -1 * atan(deltaWeight),
                      child: Icon(
                        CustomIcons.next,
                        color: Theme.of(context).
                          colorScheme.onSecondaryContainer,
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


class SmallStatCard extends StatefulWidget {
  const SmallStatCard({
    required this.firstRow,
    required this.secondRow,
    super.key});

  final String firstRow;
  final String secondRow;

  @override
  _SmallStatCardState createState() => _SmallStatCardState();
}

class _SmallStatCardState extends State<SmallStatCard> {
  @override
  Widget build(BuildContext context) {

    final StatCard card = StatCard(childWidget:
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          AutoSizeText(
            widget.firstRow,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            maxLines: 1,
          ),
          AutoSizeText(
            widget.secondRow,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w700
            ),
            maxLines: 1,
          ),
        ])
    );

    return card;
  }
}


class StatCard extends StatefulWidget {
  const StatCard({
    required this.childWidget,
    this.backgroundColor,
    this.nx = 1,
    this.ny = 1,
    super.key});

  final Widget childWidget;
  final int nx;
  final int ny;
  final Color? backgroundColor;

  @override
  _StatCardState createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  @override
  Widget build(BuildContext context) {

    Color backgroundcolor = widget.backgroundColor
        ?? Theme.of(context).colorScheme.secondaryContainer;
    double x_width = (MediaQuery.sizeOf(context).width
        - 3 * TraleTheme.of(context)!.padding) / 2;
    double y_width = (x_width - TraleTheme.of(context)!.padding) / 2;

    double height = widget.ny == 1
        ? y_width * widget.ny
        : y_width * widget.ny
          + (widget.ny - 1) * TraleTheme.of(context)!.padding;
    double width = widget.nx == 1
        ? x_width * widget.nx
        : x_width * widget.nx
          + (widget.nx - 1) * TraleTheme.of(context)!.padding;

    final Card card = Card(
      shape: TraleTheme.of(context)!.borderShape,
      color: backgroundcolor,
      margin: EdgeInsets.zero,
      child: SizedBox(
        height: height,
        width: width,
        child: widget.childWidget,
      ),
      clipBehavior: Clip.hardEdge,
    );
    return card;
  }
}


class OneThirdStatCard extends StatefulWidget {
  const OneThirdStatCard({
    required this.childWidget,
    super.key});

  final Widget childWidget;

  @override
  _OneThirdStatCardState createState() => _OneThirdStatCardState();
}

class _OneThirdStatCardState extends State<OneThirdStatCard> {
  @override
  Widget build(BuildContext context) {

    final double xWidth = (MediaQuery.sizeOf(context).width
        - 3 * TraleTheme.of(context)!.padding) / 2;
    final double height = (xWidth - TraleTheme.of(context)!.padding) / 2;
    final double width = (MediaQuery.sizeOf(context).width
        - 4 * TraleTheme.of(context)!.padding - height) / 2;

    final Card card = Card(
      shape: TraleTheme.of(context)!.borderShape,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: SizedBox(
        height: height,
        width: width,
        child: widget.childWidget,
      ),
    );
    return card;
  }
}


/// define StatCard for number of days until target weight is reached
StatCard getReachingTargetWeightWidget(BuildContext context, MeasurementStats stats) {

  final double? userTargetWeight =
      Provider.of<TraleNotifier>(context).userTargetWeight;
  final int? timeOfTargetWeight = stats.timeOfTargetWeight(
      userTargetWeight
  )?.inDays;

  return StatCard(
    backgroundColor: Theme.of(context).primaryColor,
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
                timeOfTargetWeight == null
                    ? '--'
                    : daysToString(context, timeOfTargetWeight),
                style: Theme.of(context).textTheme.displayLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
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
                'days left to reach\ntarget weight',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
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
StatCard getMeanWidget(BuildContext context, MeasurementStats stats) {
  final String unit =
      Provider.of<TraleNotifier>(context, listen: false).unit.name;
  return StatCard(
    ny: 2,
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
                doubleToString(context, stats.meanWeight, fractionDigits: 0),
                style: Theme.of(context).textTheme.displayLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
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
                'mean ($unit)',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  height: 1.0,
                ),
                maxLines: 1,
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
StatCard getTotalChangeWidget(BuildContext context, MeasurementStats stats) {
  final String unit =
      Provider.of<TraleNotifier>(context, listen: false).unit.name;
  return StatCard(
    nx: 2,
    backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
    childWidget: Padding(
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.center,
              child: AutoSizeText(
                doubleToString(context, stats.deltaWeight),
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
              alignment: Alignment.centerLeft,
              child: AutoSizeText(
                'total change\n($unit)',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
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


/// define StatCard for change per week, month, and year
StatCard getChangeRatesWidget(BuildContext context, MeasurementStats stats) {
  final String unit =
      Provider.of<TraleNotifier>(context, listen: false).unit.name;
  return StatCard(
    nx: 2,
    childWidget: Padding(
      padding: EdgeInsets.all(0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.center,
              child: AutoSizeText(
                'change ($unit)',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w900,
                ),
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
                '/week\n${doubleToString(context, stats.deltaWeightLastWeek)}',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  height: 1.0,
                ),
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
                '/month\n${doubleToString(context, stats.deltaWeightLastMonth)}',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  height: 1.0,
                ),
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
                '/year\n${doubleToString(context, stats.deltaWeightLastYear)}',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
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


/// define StatCard for change per week, month, and year
Widget getMinWidget(BuildContext context, MeasurementStats stats) {
  final String unit =
      Provider.of<TraleNotifier>(context, listen: false).unit.name;
  return OneThirdStatCard(
    childWidget: Padding(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AutoSizeText(
                'min ($unit)',
                 style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                   color: Theme.of(context).colorScheme.onSecondaryContainer,
                   fontFamily: 'Lexend',
                 ),
                 maxLines: 1,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: AutoSizeText(
                doubleToString(context, stats.minWeight),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
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
Widget getMaxWidget(BuildContext context, MeasurementStats stats) {
  final String unit =
      Provider.of<TraleNotifier>(context, listen: false).unit.name;
  return OneThirdStatCard(
  childWidget: Padding(
    padding: EdgeInsets.zero,
    child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.topRight,
              child: AutoSizeText(
                doubleToString(context, stats.maxWeight),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
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
              alignment: Alignment.topCenter,
              child: AutoSizeText(
                'max ($unit)',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
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


String daysToString(BuildContext context, int days){
  if (days < 1000) {
    return '$days days';
  } else if(days >= 1000) {
    int weeks = (days / 7).round();
    return '$weeks weeks';
  } else {
    return '-';
  }
}

String doubleToString(BuildContext context, double? d, {int fractionDigits = 1}){
  return d == null
    ? '--'
    : Provider.of<TraleNotifier>(context).unit.weightToString(
      d!, showUnit: false);
}