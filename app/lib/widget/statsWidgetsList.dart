import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/durationExtension.dart';
import 'package:trale/core/gap.dart';
import 'package:trale/core/measurementStats.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/statsCards.dart';
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

    final int delayInMilliseconds = TraleTheme.of(context)!.transitionDuration.normal.inMilliseconds;

    final TraleNotifier notifier =
        Provider.of<TraleNotifier>(context, listen: false);

    final Widget minMaxWidget = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        getMinWidget(
          context: context,
          stats: stats,
        ),
        getIconWidget(
          context: context,
          stats: stats,
          delayInMilliseconds: (delayInMilliseconds / 2).toInt(),
        ),
        getMaxWidget(
          context: context,
          stats: stats,
          delayInMilliseconds: delayInMilliseconds
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
            ),
            SizedBox(height: TraleTheme.of(context)!.padding),
            DefaultStatCard(
              firstRow: AppLocalizations.of(context)!.maxStreak,
              secondRow: stats.maxStreak.durationToString(context),
            ),
          ],
        ),
        Column(
          children: <Widget>[
            getFrequencyInTotal(
              context: context,
              stats: stats,
              delayInMilliseconds: delayInMilliseconds,
            )
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
            ),
            SizedBox(height: TraleTheme.of(context)!.padding),
            DefaultStatCard(
              firstRow: AppLocalizations.of(context)!.timeSinceFirstMeasurement,
              secondRow: stats.deltaTime.durationToString(context),
            ),
          ],
        ),
        Column(
          children: <Widget>[
            DefaultStatCard(
              firstRow: '# ${AppLocalizations.of(context)!.measurements.toLowerCase()}',
              secondRow: '${stats.nMeasurements}',
              delayInMilliseconds: delayInMilliseconds,
              pillShape: true,
            ),
            SizedBox(height: TraleTheme.of(context)!.padding),
            getTotalChangeWidget(
              context: context,
              stats: stats,
              delayInMilliseconds: delayInMilliseconds),
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
          stats: stats,
        ),
        col234,
        minMaxWidget,
        getMeanWidget(
          context: context,
          stats: stats,
        ),
        streakAndFrequencyWidget,
        if (notifier.userHeight != null)
          getBMIWidget(
            context: context,
            stats: stats,
          ),
        SizedBox(height: TraleTheme.of(context)!.padding)
      ].addGap(
        padding: TraleTheme.of(context)!.padding,
        direction: Axis.vertical,
      ),
    );
  }
}

