import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/textSize.dart';
import 'package:trale/core/theme.dart';
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
    final double height = heightFactor
        * sizeOfText(text: '10', context: context).height;
    final MeasurementDatabase database = MeasurementDatabase();
    final List<SortedMeasurement> measurements = database.sortedMeasurements;
    const String groupTag = 'groupTag';

    Widget listTileMeasurement (SortedMeasurement m)
      =>  Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                //color: Theme.of(context).colorScheme.background,
                width: MediaQuery.of(context).size.width,
                height: height,
                child: AutoSizeText(
                  m.measurement.measureToString(
                    context, ws: 12,
                  ),
                  style: Theme.of(context).textTheme.bodyText1
                      ?.apply(fontFamily: 'Courier'),
                ),
              ),
            ],
      );

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

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: TraleTheme.of(context)!.padding),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: measurements.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int i) {
        return AnimateInEffect(
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
        );
      },
    );
  }
}
