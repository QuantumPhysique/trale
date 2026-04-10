// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/measurementStats.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
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
            diffFromTargetCard(context: context, stats: stats),
            calorieDeficitCard(context: context, stats: stats),
            meanWeightCard(
              context: context,
              stats: stats,
              delayInMilliseconds: delay,
            ),
            medianWeightCard(
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
            reachingTargetWeightCard(context: context, stats: stats),
            totalChangeCard(
              context: context,
              stats: stats,
              delayInMilliseconds: delay,
            ),
            weightForecastCard(context: context, stats: stats),

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

    return Padding(
      padding: EdgeInsets.only(bottom: padding),
      child: BentoGrid(
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
          globalMaxWeightDateCard(
            context: context,
            stats: stats,
            delayInMilliseconds: delay,
          ),
          globalMinWeightDateCard(
            context: context,
            stats: stats,
            delayInMilliseconds: delay,
          ),
          timeSinceFirstCard(context: context, stats: stats),
        ],
      ),
    );
  }
}
