import 'package:flutter/material.dart';

import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/widget/emptyChart.dart';
import 'package:trale/widget/weightList.dart';

class MeasurementScreen extends StatefulWidget {
  const MeasurementScreen({super.key, required this.tabController});

  final TabController tabController;
  @override
  _MeasurementScreen createState() => _MeasurementScreen();
}

class _MeasurementScreen extends State<MeasurementScreen> {
  final ScrollController scrollController = ScrollController();
  final GlobalKey<ScaffoldState> key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final MeasurementDatabase database = MeasurementDatabase();
    final List<SortedMeasurement> measurements = database.sortedMeasurements;

    final int animationDurationInMilliseconds =
        TraleTheme.of(context)!.transitionDuration.slow.inMilliseconds;
    final int firstDelayInMilliseconds =
        TraleTheme.of(context)!.transitionDuration.normal.inMilliseconds;
    final int secondDelayInMilliseconds =  firstDelayInMilliseconds;

    Widget measurementScreen(BuildContext context,
        AsyncSnapshot<List<Measurement>> snapshot) {
      return Scrollbar(
        radius: const Radius.circular(4),
        thickness: 8,
        interactive: true,
        child: TotalWeightList(
          durationInMilliseconds: animationDurationInMilliseconds,
          delayInMilliseconds: secondDelayInMilliseconds,
          scrollController: scrollController,
          tabController: widget.tabController,
        ),
      );
    }

    Widget measurementScreenWrapper(BuildContext context,
        AsyncSnapshot<List<Measurement>> snapshot) {
      return measurements.isNotEmpty
        ? measurementScreen(context, snapshot)
        : defaultEmptyChart(context: context);
    }

    return StreamBuilder<List<Measurement>>(
        stream: database.streamController.stream,
        builder: (
            BuildContext context, AsyncSnapshot<List<Measurement>> snapshot,
            ) => measurementScreenWrapper(context, snapshot)
    );

  }
}
