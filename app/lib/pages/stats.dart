import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:trale/core/icons.dart';
import 'package:trale/core/gap.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/stringExtension.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/widget/animate_in_effect.dart';
import 'package:trale/widget/fade_in_effect.dart';
import 'package:trale/widget/text_size_in_effect.dart';
import 'package:trale/widget/weightList.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  _StatsScreen createState() => _StatsScreen();
}

class _StatsScreen extends State<StatsScreen> {
  @override
  Widget build(BuildContext context) {
    final MeasurementDatabase database = MeasurementDatabase();
    final EdgeInsets padding = EdgeInsets.symmetric(
      horizontal: TraleTheme.of(context)!.padding,
    );

    final int animationDurationInMilliseconds =
        TraleTheme.of(context)!.transitionDuration.slow.inMilliseconds;
    final int firstDelayInMilliseconds =
        TraleTheme.of(context)!.transitionDuration.fast.inMilliseconds;
    final int secondDelayInMilliseconds =
        animationDurationInMilliseconds + 2 * firstDelayInMilliseconds;


    database.longestMeasurementStrike;
    Card getCard(String label, Measurement m) => Card(
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
              m.dateToString(context),
              style: Theme.of(context).textTheme.caption
                ?.apply(
                  fontFamily: 'Courier',
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            AutoSizeText(
              '$label: ${m.weightToString(context)}',
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );

    final Widget minmax_widget = FractionallySizedBox(
      widthFactor: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(child: getCard('min', database.min!)),
          Expanded(child: getCard('max', database.max!)),
        ].addGap(
          padding: TraleTheme.of(context)!.padding,
          direction: Axis.horizontal,
        ),
      ),
    );

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: padding,
            child: TextSizeInEffect(
              text: AppLocalizations.of(context)!.stats.inCaps,
              textStyle: Theme.of(context).textTheme.headline4!,
              durationInMilliseconds: animationDurationInMilliseconds,
              delayInMilliseconds: firstDelayInMilliseconds,
            ),
          ),
          AnimateInEffect(
            durationInMilliseconds: animationDurationInMilliseconds,
            delayInMilliseconds: firstDelayInMilliseconds,
            child: minmax_widget),
          Padding(
            padding: padding,
            child: TextSizeInEffect(
              text: AppLocalizations.of(context)!.measurements.inCaps,
              textStyle: Theme.of(context).textTheme.headline4!,
              durationInMilliseconds: animationDurationInMilliseconds,
              delayInMilliseconds: secondDelayInMilliseconds,
            ),
          ),
          WeightList(
            durationInMilliseconds: animationDurationInMilliseconds,
            delayInMilliseconds: secondDelayInMilliseconds,
          ),
        ],
      )
    );
  }
}
