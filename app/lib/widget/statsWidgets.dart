import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/gap.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/textSize.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/units.dart';


class StatsWidgets extends StatefulWidget {
  const StatsWidgets({required this.visible, Key? key}) : super(key: key);

  final bool visible;

  @override
  _StatsWidgetsState createState() => _StatsWidgetsState();
}

class _StatsWidgetsState extends State<StatsWidgets> {
  @override
  Widget build(BuildContext context) {
    final MeasurementDatabase database = MeasurementDatabase();
    final TraleNotifier notifier = Provider.of<TraleNotifier>(context);

    final double? userTargetWeight = notifier.userTargetWeight;
    final int? timeOfTargetWeight = database.timeOfTargetWeight(
        userTargetWeight
    )?.inDays;
    final int nMeasured = database.durationMeasurements;
    const int nDays = 1;

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
              style: Theme.of(context).textTheme.caption!.copyWith(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            AutoSizeText(
              timeOfTargetWeight == null
                ? '-- days'
                : '$timeOfTargetWeight days',
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );

    Card userWeightLostCard(int nDays) {
      final double deltaWeight = database.finalSlope * 24 * 3600 * 1000 * 30;
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
                style: Theme.of(context).textTheme.caption,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AutoSizeText(
                    notifier.unit.weightToString(deltaWeight),
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                  SizedBox(
                    height: sizeOfText(
                      text: '0',
                      context: context,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ).height,
                    child: Transform.rotate(
                      // a change of 1kg / 30d corresponds to 45°
                      angle: -1 * atan(deltaWeight),
                      child: Icon(
                        CustomIcons.next,
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
                child: userWeightLostCard(nDays),
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
