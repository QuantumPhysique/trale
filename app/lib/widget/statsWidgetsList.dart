import 'package:flutter/material.dart';

import 'package:trale/core/gap.dart';
import 'package:trale/core/measurementStats.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/widget/statsCards.dart';
import 'package:trale/widget/statsWidgets.dart';


class StatsWidgetsList extends StatefulWidget {
  const StatsWidgetsList({
    super.key});

  @override
  _StatsWidgetsListState createState() => _StatsWidgetsListState();
}

class _StatsWidgetsListState extends State<StatsWidgetsList> {

  String daysToString(int days){
    if (days < 1000) {
      return '$days days';
    } else if(days >= 1000) {
      final int weeks = (days / 7).round();
      return '$weeks weeks';
    } else {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final MeasurementStats stats = MeasurementStats();

    final int animationDurationInMilliseconds =
        TraleTheme.of(context)!.transitionDuration.slow.inMilliseconds;
    final int firstDelayInMilliseconds =
        TraleTheme.of(context)!.transitionDuration.normal.inMilliseconds;

    int getDelayInMilliseconds(int i){
      return firstDelayInMilliseconds * (1 + i / 2).round();
    }

    final Widget minMeanMaxWidget = Row(
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

    final Widget streakWidget = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        DefaultStatCard(
          firstRow: 'current streak',
          secondRow: daysToString(stats.currentStreak),
          delayInMilliseconds: getDelayInMilliseconds(8),
        ),
        DefaultStatCard(
          firstRow: 'longest streak',
          secondRow: daysToString(stats.maxStreak),
          delayInMilliseconds: getDelayInMilliseconds(9),
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
              firstRow: 'total time',
              secondRow: daysToString(stats.deltaTime),
              delayInMilliseconds: getDelayInMilliseconds(4),
            ),
          ],
        ),
        Column(
          children: <Widget>[
            DefaultStatCard(
              firstRow: '# measurements',
              secondRow: '${stats.nMeasurements}',
              delayInMilliseconds: getDelayInMilliseconds(1),
            ),
            SizedBox(height: TraleTheme.of(context)!.padding),
            getMeanWidget(
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
        minMeanMaxWidget,
        streakWidget,
        getTotalChangeWidget(
          context: context,
          stats: stats,
          delayInMilliseconds: getDelayInMilliseconds(10)
        ),
        SizedBox(height: TraleTheme.of(context)!.padding)
      ].addGap(
        padding: TraleTheme.of(context)!.padding,
        direction: Axis.vertical,
      ),
    );
  }
}

