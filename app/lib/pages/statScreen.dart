import 'package:flutter/material.dart';

import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/widget/emptyChart.dart';
import 'package:trale/widget/statsWidgetsList.dart';

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

    Widget statsScreen(BuildContext context,
        AsyncSnapshot<List<Measurement>> snapshot) {

      return CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        cacheExtent: MediaQuery.of(context).size.height,
        slivers: const <Widget>[
          SliverToBoxAdapter(
            child: StatsWidgetsList(),
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
      ) => statsScreenWrapper(context, snapshot),
    );

  }
}
