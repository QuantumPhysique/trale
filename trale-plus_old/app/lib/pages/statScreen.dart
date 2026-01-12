import 'package:flutter/material.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key, required this.tabController});

  final TabController tabController;
  @override
  _StatsScreen createState() => _StatsScreen();
}

class _StatsScreen extends State<StatsScreen> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Under construction',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
/*
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
*/
}
