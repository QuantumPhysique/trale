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
import 'package:trale/widget/iconHero.dart';
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

    String daysToString(int days){
        if (days < 1000) {
          return '${days} days';
        } else if(days >= 1000) {
          int weeks = (days / 7).round();
          return '${weeks} weeks';
        } else {
          return '-';
        }
    }

    Widget statsScreen(BuildContext context,
        AsyncSnapshot<List<Measurement>> snapshot) {

      final Widget minMeanMaxWidget = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          getMinWidget(context, stats),
          SizedBox(
            width: 82,
            height: 82,
            child: const IconHeroStatScreen(),
          ),
          getMaxWidget(context, stats),
        ].addGap(
          padding: TraleTheme.of(context)!.padding,
          direction: Axis.horizontal,
        ),
      );

      final Widget streakWidget = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SmallStatCard(
              firstRow: 'current streak',
              secondRow: daysToString(stats.currentStreak)),
          SmallStatCard(
              firstRow: 'longest streak',
              secondRow: daysToString(stats.maxStreak)),
        ].addGap(
          padding: TraleTheme.of(context)!.padding,
          direction: Axis.horizontal,
        ),
      );

      final Widget col234 = Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Column(
            children: [
              getReachingTargetWeightWidget(context, stats),
              SizedBox(height: TraleTheme.of(context)!.padding),
              SmallStatCard(
                  firstRow: 'total time',
                  secondRow: daysToString(stats.deltaTime)),
            ],
          ),
          Column(
            children: [
              SmallStatCard(
                  firstRow: '# measurements',
                  secondRow: '${stats.nMeasurements}'),
              SizedBox(height: TraleTheme.of(context)!.padding),
              getMeanWidget(context, stats),
            ],
          ),
        ].addGap(
          padding: TraleTheme.of(context)!.padding,
          direction: Axis.horizontal,
        ),
      );

      final Widget nWidget = FractionallySizedBox(
        widthFactor: 1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(child: SmallStatCard(
                firstRow: '# measurements',
                secondRow: '${stats.nMeasurements!}')
            ),
            Expanded(child: SmallStatCard(
                firstRow: 'mean',
                secondRow: weightToString(stats.meanWeight!))
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  getChangeRatesWidget(context, stats),
                  col234,
                  minMeanMaxWidget,
                  streakWidget,
                  getTotalChangeWidget(context, stats),
                  SizedBox(height: TraleTheme.of(context)!.padding)
                ].addGap(
                  padding: TraleTheme.of(context)!.padding,
                  direction: Axis.vertical,
                ),
              ),
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
