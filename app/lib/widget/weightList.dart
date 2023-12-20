import 'dart:math';

import 'package:flutter/material.dart';

import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/widget/animate_in_effect.dart';
import 'package:trale/widget/weightListTile.dart';

class WeightList extends StatefulWidget {
  const WeightList({
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
    final MeasurementDatabase database = MeasurementDatabase();
    final List<SortedMeasurement> measurements = database.sortedMeasurements;

    double getIntervalStart(int i) {
      const int maximalShownListTile = 15;
      if (maximalShownListTile < measurements.length) {
        return <double>[i / maximalShownListTile, 1].reduce(min).toDouble();
      } else {
        return i / measurements.length;
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
            measurement: measurements[i],
            updateActiveState: updateActiveListTile,
            activeKey: activeListTile,
            offset: Offset(-MediaQuery.of(context).size.width / 2, 0),
            durationInMilliseconds: widget.delayInMilliseconds,
          ),
        ),
        childCount: measurements.length,
        addAutomaticKeepAlives: true,
      ),
    );
  }
}
