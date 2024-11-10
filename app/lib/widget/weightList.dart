import 'dart:math';

import 'package:flutter/material.dart';

import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/widget/animate_in_effect.dart';
import 'package:trale/widget/weightListTile.dart';

class WeightList extends StatefulWidget {
  const WeightList({
    super.key,
    required this.measurements,
    required this.scrollController,
    required this.tabController,
    this.durationInMilliseconds = 1000,
    this.delayInMilliseconds = 0,
    this.keepAlive = false,
  });

  final List<SortedMeasurement> measurements;
  final int durationInMilliseconds;
  final int delayInMilliseconds;
  final bool keepAlive;
  final ScrollController scrollController;
  final TabController tabController;

  @override
  _WeightList createState() => _WeightList();
}

class _WeightList extends State<WeightList>{
  double heightFactor = 1.5;
  int? activeListTile;

  void onScrollEvent() {
    if (activeListTile != null){
      setState(() => activeListTile = null);
    }
  }

  void onTabChangeEvent() {
    if (activeListTile != null){
      setState(() => activeListTile = null);
    }
  }

  @override
  void initState() {
    super.initState();
    activeListTile = null;
    widget.scrollController.addListener(onScrollEvent);
    widget.tabController.animation!.addListener(onTabChangeEvent);
  }

  @override
  void dispose() {
    super.dispose();
    widget.scrollController.removeListener(onScrollEvent);
    widget.tabController.animation!.removeListener(onTabChangeEvent);
  }

  @override
  Widget build(BuildContext context) {
    double getIntervalStart(int i) {
      const int maximalShownListTile = 15;
      if (maximalShownListTile < widget.measurements.length) {
        return <double>[i / maximalShownListTile, 1].reduce(min).toDouble();
      } else {
        return i / widget.measurements.length;
      }
    }

    void updateActiveListTile(int? key){
      setState(() {
        activeListTile = key;
      });
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int i) => AnimateInEffect(
          keepAlive: widget.keepAlive,
          durationInMilliseconds: widget.durationInMilliseconds,
          delayInMilliseconds: widget.delayInMilliseconds,
          intervalStart: getIntervalStart(i),
          child: WeightListTile(
            measurement: widget.measurements[i],
            updateActiveState: updateActiveListTile,
            activeKey: activeListTile,
            offset: Offset(-MediaQuery.of(context).size.width / 2, 0),
            durationInMilliseconds: widget.delayInMilliseconds,
          ),
        ),
        childCount: widget.measurements.length,
        addAutomaticKeepAlives: true,
      ),
    );
  }
}


/// A list of all measurements sorted by year.
class TotalWeightList extends StatefulWidget {
  const TotalWeightList({
    super.key,
    required this.scrollController,
    required this.tabController,
    this.durationInMilliseconds = 1000,
    this.delayInMilliseconds = 0,
    this.keepAlive = false,
  });

  final int durationInMilliseconds;
  final int delayInMilliseconds;
  final bool keepAlive;
  final ScrollController scrollController;
  final TabController tabController;

  @override
  _TotalWeightList createState() => _TotalWeightList();
}

class _TotalWeightList extends State<TotalWeightList>{
  double heightFactor = 1.5;
  int? activeListTile;

  void onScrollEvent() {
    if (activeListTile != null){
      setState(() => activeListTile = null);
    }
  }

  void onTabChangeEvent() {
    if (activeListTile != null){
      setState(() => activeListTile = null);
    }
  }

  @override
  void initState() {
    super.initState();
    activeListTile = null;
    widget.scrollController.addListener(onScrollEvent);
    widget.tabController.animation!.addListener(onTabChangeEvent);
  }

  @override
  void dispose() {
    super.dispose();
    widget.scrollController.removeListener(onScrollEvent);
    widget.tabController.animation!.removeListener(onTabChangeEvent);
  }

  @override
  Widget build(BuildContext context) {
    final MeasurementDatabase database = MeasurementDatabase();
    final List<SortedMeasurement> measurements = database.sortedMeasurements;

    final List<int> years = <int>[
      for (
      int year= measurements.first.measurement.date.year;
      year >= measurements.last.measurement.date.year;
      year--
      )
        year
    ];

    final Map<int, List<SortedMeasurement>> measurementsPerYear =
    <int, List<SortedMeasurement>>{
      for (final int year in years)
        year: <SortedMeasurement>[
          for (final SortedMeasurement m in measurements)
            if (m.measurement.date.year == year)
              m
        ]
    };

    return CustomScrollView(
      controller: widget.scrollController,
      cacheExtent: 2 * MediaQuery.of(context).size.height,
      slivers: <Widget>[
        ...<Widget>[
          for (final int year in years)
            ...<Widget>[
              SliverToBoxAdapter(
                child: Center(
                    child: Text(
                      '$year',
                      style: Theme.of(context).textTheme.displayMedium,
                    )
                ),
              ),
              WeightList(
                measurements: measurementsPerYear[year]!,
                durationInMilliseconds: widget.durationInMilliseconds,
                delayInMilliseconds: widget.delayInMilliseconds,
                scrollController: widget.scrollController,
                tabController: widget.tabController,
              ),
            ],
        ],
        SliverToBoxAdapter(
          child: SizedBox(
            height: TraleTheme.of(context)!.padding,
          ),
        ),
      ],
    );
  }
}