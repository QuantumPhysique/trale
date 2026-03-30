// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/measurementStats.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/bento_card.dart';
import 'package:trale/widget/bento_grid.dart';
import 'package:trale/widget/statsWidgets.dart';

/// Range-based statistics widgets laid out as a bento grid.
class StatsWidgetsList extends StatelessWidget {
  /// Constructor.
  const StatsWidgetsList({super.key});

  @override
  Widget build(BuildContext context) {
    final MeasurementStats stats = MeasurementStats();
    final TraleNotifier notifier = Provider.of<TraleNotifier>(
      context,
      listen: false,
    );
    final int delay = TraleTheme.of(
      context,
    )!.transitionDuration.normal.inMilliseconds;
    final double padding = TraleTheme.of(context)!.padding;

    return Column(
      children: <Widget>[
        SizedBox(height: padding),
        BentoGrid(
          children: <BentoCard>[
            changeRatesCard(context: context, stats: stats),
            reachingTargetWeightCard(context: context, stats: stats),
            totalChangeCard(
              context: context,
              stats: stats,
              delayInMilliseconds: delay,
            ),
            minWeightCard(context: context, stats: stats),
            iconHeroCard(
              context: context,
              delayInMilliseconds: (delay / 2).toInt(),
            ),
            maxWeightCard(
              context: context,
              stats: stats,
              delayInMilliseconds: delay,
            ),
            diffFromTargetCard(context: context, stats: stats),
            meanWeightCard(
              context: context,
              stats: stats,
              delayInMilliseconds: delay,
            ),
            calorieDeficitCard(context: context, stats: stats),
            if (notifier.userHeight != null)
              bmiCard(context: context, stats: stats),
          ],
        ),
        SizedBox(height: padding),
      ],
    );
  }
}

/// All-time (global) statistics widgets with a section heading.
class GlobalStatsWidgetsList extends StatelessWidget {
  /// Constructor.
  const GlobalStatsWidgetsList({super.key});

  @override
  Widget build(BuildContext context) {
    final MeasurementStats stats = MeasurementStats();
    final int delay = TraleTheme.of(
      context,
    )!.transitionDuration.normal.inMilliseconds;
    final double padding = TraleTheme.of(context)!.padding;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Text(
            AppLocalizations.of(context)!.all,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(height: padding / 2),
        BentoGrid(
          children: <BentoCard>[
            nMeasurementsCard(
              context: context,
              stats: stats,
              delayInMilliseconds: delay,
            ),
            currentStreakCard(
              context: context,
              stats: stats,
              delayInMilliseconds: delay,
            ),
            maxStreakCard(context: context, stats: stats),
            measurementFrequencyCard(context: context, stats: stats),
            timeSinceFirstCard(context: context, stats: stats),
          ],
        ),
        SizedBox(height: padding),
      ],
    );
  }
}
