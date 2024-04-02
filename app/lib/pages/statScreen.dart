import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:collection/collection.dart';

import 'package:trale/core/gap.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/measurementStats.dart';
import 'package:trale/core/stringExtension.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/units.dart';
import 'package:trale/widget/animate_in_effect.dart';
import 'package:trale/widget/emptyChart.dart';
import 'package:trale/widget/statsWidgets.dart';
import 'package:trale/widget/text_size_in_effect.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/traleNotifier.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key, required this.tabController});

  final TabController tabController;
  @override
  _StatsScreen createState() => _StatsScreen();
}

class _StatsScreen extends State<StatsScreen> {
  final ScrollController scrollController = ScrollController();
  final GlobalKey<ScaffoldState> key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final MeasurementDatabase database = MeasurementDatabase();
    final MeasurementStats stats = MeasurementStats();
    final EdgeInsets padding = EdgeInsets.symmetric(
      horizontal: TraleTheme.of(context)!.padding,
    );

    final int animationDurationInMilliseconds =
        TraleTheme.of(context)!.transitionDuration.slow.inMilliseconds;
    final int firstDelayInMilliseconds =
        TraleTheme.of(context)!.transitionDuration.normal.inMilliseconds;
    final int secondDelayInMilliseconds =  firstDelayInMilliseconds;

    /// convert to String
    String weightToString(double weight)
      => Provider.of<TraleNotifier>(context, listen: false).
        unit.weightToString(weight);
    /*
    * What Stats do we want to implement?
    * Trend   |   Change
    * Min  | Max  | Icon
    * Mean | Icon | Icon
    * #n    |    Delta t
    * [Freq , freq 28days]
    *  */

    Widget statsScreen(BuildContext context,
        AsyncSnapshot<List<Measurement>> snapshot) {

      final Widget minMeanMaxWidget = FractionallySizedBox(
        widthFactor: 1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(child: SmallStatCard(
              firstRow: 'min',
              secondRow: weightToString(stats.minWeight!))
            ),
            Expanded(child: SmallStatCard(
                firstRow: 'mean',
                secondRow: weightToString(stats.meanWeight!))
            ),Expanded(child: SmallStatCard(
                firstRow: 'max',
                secondRow: weightToString(stats.maxWeight!))
            ),
          ].addGap(
            padding: TraleTheme.of(context)!.padding,
            direction: Axis.horizontal,
          ),
        ),
      );

      return CustomScrollView(
        controller: scrollController,
        cacheExtent: MediaQuery.of(context).size.height,
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: padding,
              child: TextSizeInEffect(
                text: AppLocalizations.of(context)!.stats.inCaps,
                textStyle: Theme.of(context).textTheme.headlineMedium!,
                durationInMilliseconds: animationDurationInMilliseconds,
                delayInMilliseconds: firstDelayInMilliseconds,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: AnimateInEffect(
              durationInMilliseconds: animationDurationInMilliseconds,
              delayInMilliseconds: firstDelayInMilliseconds,
              child: minMeanMaxWidget,
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: TraleTheme.of(context)!.padding,
            ),
          ),
        ],
      );
    }

    Widget statsScreenWrapper(BuildContext context,
        AsyncSnapshot<List<Measurement>> snapshot) {
      final MeasurementDatabase database = MeasurementDatabase();
      final List<SortedMeasurement> measurements = database.sortedMeasurements;
      return measurements.isNotEmpty
          ? statsScreen(context, snapshot)
          : defaultEmptyChart(context:context);
    }


    return StreamBuilder<List<Measurement>>(
        stream: database.streamController.stream,
        builder: (
            BuildContext context, AsyncSnapshot<List<Measurement>> snapshot,
            ) => SafeArea(
            key: key,
            child: statsScreenWrapper(context, snapshot)
        )
    );

  }
}
