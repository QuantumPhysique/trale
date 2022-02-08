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
    final int nDays = nMeasured > 7
        ? nMeasured > 30
          ? 30
          : 7
        : nMeasured;

    Card userTargetWeightCard(double utw) => Card(
      shape: TraleTheme.of(context)!.borderShape,
      margin: EdgeInsets.symmetric(
        vertical: TraleTheme.of(context)!.padding,
      ),
      child: Padding(
        padding: EdgeInsets.all(TraleTheme.of(context)!.padding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            AutoSizeText(
              '${notifier.unit.weightToString(utw)} in ' + (
                timeOfTargetWeight == null
                    ? '-- days'
                    : '$timeOfTargetWeight days'
              ),
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ],
        ),
      ),
    );

    Card userWeightLostCard(int nDays) {
      final double deltaWeight = database.deltaWeightLastNDays(nDays)!;
      final String label = nDays == 30
          ? 'month'
          : nDays == 7 ? 'week' : '{nDays}day';

      return Card(
        shape: TraleTheme.of(context)!.borderShape,
        margin: EdgeInsets.symmetric(
          vertical: TraleTheme.of(context)!.padding,
        ),
        child: Padding(
          padding: EdgeInsets.all(TraleTheme.of(context)!.padding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              AutoSizeText(
                '${notifier.unit.weightToString(deltaWeight)} / $label',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              SizedBox(
                height: sizeOfText(
                  text: '0',
                  context: context,
                  style: Theme.of(context).textTheme.bodyText1,
                ).height,
                child: Transform.rotate(
                  // a change of 1kg / 30d corresponds to 45°
                  angle: -1 * atan(30 * deltaWeight / nDays),
                  child: const Icon(CustomIcons.next),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return FractionallySizedBox(
      widthFactor: (userTargetWeight == null || nDays < 2) ? 0.5 : 1,
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
            if (nDays >= 2) Expanded(
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
