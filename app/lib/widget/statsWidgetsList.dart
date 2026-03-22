// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/durationExtension.dart';
import 'package:trale/core/measurementStats.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/statsCards.dart';
import 'package:trale/widget/statsWidgets.dart';

/// List of statistics widgets.
class StatsWidgetsList extends StatefulWidget {
  /// Constructor.
  const StatsWidgetsList({super.key});

  @override
  State<StatsWidgetsList> createState() => _StatsWidgetsListState();
}

class _StatsWidgetsListState extends State<StatsWidgetsList> {
  @override
  Widget build(BuildContext context) {
    final MeasurementStats stats = MeasurementStats();

    final int delayInMilliseconds = TraleTheme.of(
      context,
    )!.transitionDuration.normal.inMilliseconds;

    final TraleNotifier notifier = Provider.of<TraleNotifier>(
      context,
      listen: false,
    );

    final Widget minMaxWidget = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: TraleTheme.of(context)!.padding,
      children: <Widget>[
        getMinWidget(context: context, stats: stats),
        getIconWidget(
          context: context,
          stats: stats,
          delayInMilliseconds: (delayInMilliseconds / 2).toInt(),
        ),
        getMaxWidget(
          context: context,
          stats: stats,
          delayInMilliseconds: delayInMilliseconds,
        ),
      ],
    );

    final Widget streakAndFrequencyWidget = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: TraleTheme.of(context)!.padding,
      children: <Widget>[
        Column(
          spacing: TraleTheme.of(context)!.padding,
          children: <Widget>[
            DefaultStatCard(
              firstRow: AppLocalizations.of(context)!.maxStreak,
              secondRow: stats.maxStreak.streakToStringDays(context),
            ),
            DefaultStatCard(
              firstRow:
                  '${AppLocalizations.of(context)!.measurementFrequency}\n'
                  '(/ ${AppLocalizations.of(context)!.week})',
              secondRow: stats.frequency!.toStringAsFixed(2),
            ),
          ],
        ),
        Column(
          spacing: TraleTheme.of(context)!.padding,
          children: <Widget>[
            getCurrentStreak(
              context: context,
              stats: stats,
              delayInMilliseconds: delayInMilliseconds,
            ),
          ],
        ),
      ],
    );

    final String measurementsLabel = AppLocalizations.of(
      context,
    )!.measurements.toLowerCase();

    final Widget col234 = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: TraleTheme.of(context)!.padding,
      children: <Widget>[
        Column(
          spacing: TraleTheme.of(context)!.padding,
          children: <Widget>[
            getReachingTargetWeightWidget(context: context, stats: stats),
            DefaultStatCard(
              firstRow: AppLocalizations.of(context)!.timeSinceFirstMeasurement,
              secondRow: stats.deltaTime.durationToString(context),
            ),
          ],
        ),
        Column(
          spacing: TraleTheme.of(context)!.padding,
          children: <Widget>[
            DefaultStatCard(
              firstRow: '# $measurementsLabel',
              secondRow: '${stats.nMeasurements}',
              delayInMilliseconds: delayInMilliseconds,
              pillShape: true,
            ),
            getTotalChangeWidget(
              context: context,
              stats: stats,
              delayInMilliseconds: delayInMilliseconds,
            ),
          ],
        ),
      ],
    );

    final Widget unsortedStatsWidget = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: TraleTheme.of(context)!.padding,
      children: <Widget>[
        getCalorieDeficitWidget(context: context, stats: stats),
        getDiffFromTargetWidget(context: context, stats: stats),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: TraleTheme.of(context)!.padding,
      children: <Widget>[
        SizedBox(height: TraleTheme.of(context)!.padding),
        getChangeRatesWidget(context: context, stats: stats),
        col234,
        minMaxWidget,
        getMeanWidget(context: context, stats: stats),
        streakAndFrequencyWidget,
        if (notifier.userHeight != null)
          getBMIWidget(context: context, stats: stats),
        unsortedStatsWidget,
        SizedBox(height: TraleTheme.of(context)!.padding),
      ],
    );
  }
}
