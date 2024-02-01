import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:collection/collection.dart';

import 'package:trale/core/gap.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/stringExtension.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/widget/animate_in_effect.dart';
import 'package:trale/widget/emptyChart.dart';
import 'package:trale/widget/statsWidgets.dart';
import 'package:trale/widget/text_size_in_effect.dart';

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
    final EdgeInsets padding = EdgeInsets.symmetric(
      horizontal: TraleTheme.of(context)!.padding,
    );

    final int animationDurationInMilliseconds =
        TraleTheme.of(context)!.transitionDuration.slow.inMilliseconds;
    final int firstDelayInMilliseconds =
        TraleTheme.of(context)!.transitionDuration.normal.inMilliseconds;
    final int secondDelayInMilliseconds =  firstDelayInMilliseconds;

    final double mean_weight =
        database.measurements.map((Measurement m) => m.weight).average;
    final int number_of_measurements = database.measurements.length;
    final int days_since_first_measurement =
        DateTime.now().difference(database.measurements.first.date).inDays;
    // Measurement frequency /week
    final double measurement_frequency = days_since_first_measurement > 0
        ? number_of_measurements / days_since_first_measurement * 7
        : 0;

    /*
    * What Stats do we want to implement?
    * Trend   |   Change
    * Min  | Max  | Icon
    * Mean | Icon | Icon
    * #n    |    Delta t
    * [Freq , freq 28days]
    *  */

    SmallStatCard getCard(String label, Measurement m) =>
        SmallStatCard(
            firstRow: m.dateToString(context),
            secondRow: '$label: ${m.weightToString(context)}');

    Widget statsScreen(BuildContext context,
        AsyncSnapshot<List<Measurement>> snapshot) {

      final Widget minMaxWidget = FractionallySizedBox(
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
              child: minMaxWidget,
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
