import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/durationExtension.dart';
import 'package:trale/core/gap.dart';
import 'package:trale/core/measurementStats.dart';
import 'package:trale/core/statsCards.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/statsWidgets.dart';


class StatsWidgetsList extends StatefulWidget {
  const StatsWidgetsList({
    super.key});

  @override
  _StatsWidgetsListState createState() => _StatsWidgetsListState();
}

class _StatsWidgetsListState extends State<StatsWidgetsList> {

  @override
  Widget build(BuildContext context) {
    final MeasurementStats stats = MeasurementStats();

    int getDelayInMilliseconds(int i){
      return TraleTheme.of(context)!.transitionDuration.normal.inMilliseconds
          * (1 + i / 3).round();
    }

    final TraleNotifier notifier =
        Provider.of<TraleNotifier>(context, listen: false);

    final Widget minMaxWidget = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        getMinWidget(
          context: context,
          stats: stats,
          delayInMilliseconds: getDelayInMilliseconds(5)
        ),
        getIconWidget(
          context: context,
          stats: stats,
          delayInMilliseconds: getDelayInMilliseconds(6),
        ),
        getMaxWidget(
          context: context,
          stats: stats,
          delayInMilliseconds: getDelayInMilliseconds(7)
        ),
      ].addGap(
        padding: TraleTheme.of(context)!.padding,
        direction: Axis.horizontal,
      ),
    );


    final Widget streakAndFrequencyWidget = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Column(
          children: <Widget>[
            DefaultStatCard(
              firstRow: AppLocalizations.of(context)!.currentStreak,
              secondRow: stats.currentStreak.durationToString(context),
              delayInMilliseconds: getDelayInMilliseconds(9),
            ),
            SizedBox(height: TraleTheme.of(context)!.padding),
            DefaultStatCard(
              firstRow: AppLocalizations.of(context)!.maxStreak,
              secondRow: stats.maxStreak.durationToString(context),
              delayInMilliseconds: getDelayInMilliseconds(10),
            ),
          ],
        ),
        Column(
          children: <Widget>[
            getFrequencyInTotal(
                context: context,
                stats: stats,
                delayInMilliseconds: getDelayInMilliseconds(11)),
          ],
        ),
      ].addGap(
        padding: TraleTheme.of(context)!.padding,
        direction: Axis.horizontal,
      ),
    );


    final Widget col234 = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Column(
          children: <Widget>[
            getReachingTargetWeightWidget(
              context: context,
              stats: stats,
              delayInMilliseconds: getDelayInMilliseconds(2)),
            SizedBox(height: TraleTheme.of(context)!.padding),
            DefaultStatCard(
              firstRow: AppLocalizations.of(context)!.timeSinceFirstMeasurement,
              secondRow: stats.deltaTime.durationToString(context),
              delayInMilliseconds: getDelayInMilliseconds(4),
            ),
          ],
        ),
        Column(
          children: <Widget>[
            DefaultStatCard(
              firstRow: '# ${AppLocalizations.of(context)!.measurements.toLowerCase()}',
              secondRow: '${stats.nMeasurements}',
              delayInMilliseconds: getDelayInMilliseconds(1),
            ),
            SizedBox(height: TraleTheme.of(context)!.padding),
            getTotalChangeWidget(
              context: context,
              stats: stats,
              delayInMilliseconds: getDelayInMilliseconds(3)),
          ],
        ),
      ].addGap(
        padding: TraleTheme.of(context)!.padding,
        direction: Axis.horizontal,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        getChangeRatesWidget(
          context: context,
          stats:stats,
          delayInMilliseconds: getDelayInMilliseconds(0)),
        col234,
        minMaxWidget,
        getMeanWidget(
          context: context,
          stats: stats,
          delayInMilliseconds: getDelayInMilliseconds(8)
        ),
        streakAndFrequencyWidget,
        if (notifier.userHeight != null)
          getBMIWidget(
            context: context,
            stats: stats,
            delayInMilliseconds: getDelayInMilliseconds(12)),
        SizedBox(height: TraleTheme.of(context)!.padding)
      ].addGap(
        padding: TraleTheme.of(context)!.padding,
        direction: Axis.vertical,
      ),
    );
  }
}

