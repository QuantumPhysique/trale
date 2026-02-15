import 'package:flutter/material.dart';

import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/widget/animation_replay_scope.dart';
import 'package:trale/widget/emptyChart.dart';
import 'package:trale/widget/statsWidgetsList.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key, required this.tabController});

  final TabController tabController;
  @override
  _StatsScreen createState() => _StatsScreen();
}

class _StatsScreen extends State<StatsScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController scrollController = ScrollController();
  final GlobalKey<ScaffoldState> key = GlobalKey();
  late final Stream<List<Measurement>> _measurementStream;
  final AnimationReplayController _replayController =
      AnimationReplayController();

  /// Whether this tab is currently the nearest visible tab.
  bool _isActive = false;

  /// The last animation value, used to determine swipe direction.
  double _lastAnimValue = 1.0;

  @override
  bool get wantKeepAlive => true;

  void _onTabAnimationTick() {
    final double value = widget.tabController.animation!.value;
    // Tab 1 "owns" the range [0.5, 1.5).
    final bool nowActive = value >= 0.1 && value < 1.9;
    if (nowActive && !_isActive) {
      final SlideDirection dir = value > _lastAnimValue
          ? SlideDirection
                .fromRight // swiping rightward (from tab 0)
          : SlideDirection.fromLeft; // swiping leftward (from tab 2)
      _replayController.replay(dir: dir);
    }
    _lastAnimValue = value;
    _isActive = nowActive;
  }

  @override
  void initState() {
    super.initState();
    _measurementStream = MeasurementDatabase().streamController.stream;
    _isActive = widget.tabController.index == 1;
    _lastAnimValue = widget.tabController.animation?.value ?? 1.0;
    widget.tabController.animation?.addListener(_onTabAnimationTick);
  }

  @override
  void dispose() {
    widget.tabController.animation?.removeListener(_onTabAnimationTick);
    _replayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget statsScreen(
      BuildContext context,
      AsyncSnapshot<List<Measurement>> snapshot,
    ) {
      return CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        cacheExtent: MediaQuery.of(context).size.height,
        slivers: const <Widget>[SliverToBoxAdapter(child: StatsWidgetsList())],
      );
    }

    Widget statsScreenWrapper(
      BuildContext context,
      AsyncSnapshot<List<Measurement>> snapshot,
    ) {
      final MeasurementDatabase database = MeasurementDatabase();
      final List<SortedMeasurement> measurements = database.sortedMeasurements;
      return measurements.isNotEmpty
          ? statsScreen(context, snapshot)
          : defaultEmptyChart(context: context);
    }

    return AnimationReplayScope(
      controller: _replayController,
      child: StreamBuilder<List<Measurement>>(
        stream: _measurementStream,
        builder:
            (BuildContext context, AsyncSnapshot<List<Measurement>> snapshot) =>
                statsScreenWrapper(context, snapshot),
      ),
    );
  }
}
