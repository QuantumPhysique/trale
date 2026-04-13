import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_m3shapes_extended/flutter_m3shapes_extended.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/measurement_stats.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/trale_notifier.dart';
import 'package:trale/widget/bento_card.dart';
import 'package:trale/widget/bento_grid.dart';
import 'package:trale/widget/stats_widgets.dart';

/// Shapes used for the trale icon card — cycled on tap.
const List<Shapes> _iconHeroShapes = <Shapes>[
  Shapes.sunny,
  Shapes.c4_sided_cookie,
  Shapes.c6_sided_cookie,
  Shapes.c7_sided_cookie,
  Shapes.c9_sided_cookie,
  Shapes.c12_sided_cookie,
  Shapes.l4_leaf_clover,
  Shapes.gem,
];

/// Range-based statistics widgets laid out as a bento grid.
class StatsWidgetsList extends StatefulWidget {
  /// Constructor.
  const StatsWidgetsList({super.key});

  @override
  State<StatsWidgetsList> createState() => _StatsWidgetsListState();
}

class _StatsWidgetsListState extends State<StatsWidgetsList> {
  Shapes _iconShape = _iconHeroShapes[Random().nextInt(_iconHeroShapes.length)];

  void _cycleIconShape() {
    setState(() {
      Shapes next;
      do {
        next = _iconHeroShapes[Random().nextInt(_iconHeroShapes.length)];
      } while (next == _iconShape);
      _iconShape = next;
    });
  }

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
            reachingTargetWeightCard(context: context, stats: stats),
            weightForecastCard(context: context, stats: stats),
            minWeightCard(context: context, stats: stats),
            iconHeroCard(
              context: context,
              shape: _iconShape,
              onTap: _cycleIconShape,
              delayInMilliseconds: (delay / 2).toInt(),
            ),
            maxWeightCard(
              context: context,
              stats: stats,
              delayInMilliseconds: delay,
            ),
            meanWeightCard(
              context: context,
              stats: stats,
              delayInMilliseconds: delay,
            ),
            totalChangeCard(
              context: context,
              stats: stats,
              delayInMilliseconds: delay,
            ),
            medianWeightCard(
              context: context,
              stats: stats,
              delayInMilliseconds: delay,
            ),
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
          timeSinceFirstCard(context: context, stats: stats),
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
        ],
      ),
    );
  }
}
