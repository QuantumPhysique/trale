// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/font.dart';

import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/measurementStats.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/widget/animation_replay_scope.dart';
import 'package:trale/widget/emptyChart.dart';
import 'package:trale/widget/statsRangeDialog.dart';
import 'package:trale/widget/statsWidgetsList.dart';

/// Stats screen widget.
class StatsScreen extends StatefulWidget {
  /// Constructor.
  const StatsScreen({super.key, required this.tabController});

  /// Tab controller for switching tabs.
  final TabController tabController;
  @override
  State<StatsScreen> createState() => _StatsScreen();
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
    // Tab 1 "owns" the range [0.1, 1.9).
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

    Widget statsScreen(BuildContext context) {
      final MeasurementStats stats = MeasurementStats();
      final TraleNotifier notifier = Provider.of<TraleNotifier>(
        context,
        listen: false,
      );
      final String fromStr = notifier
          .dateFormat(context)
          .format(stats.fromDate);
      final String toStr = notifier.dateFormat(context).format(stats.toDate);

      return CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        cacheExtent: MediaQuery.of(context).size.height,
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: InkWell(
              onTap: () => showStatsRangeDialog(context: context),
              borderRadius: BorderRadius.circular(
                TraleTheme.of(context)!.padding,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: TraleTheme.of(context)!.padding,
                  vertical: 0.5 * TraleTheme.of(context)!.padding,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'data from',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    Text(
                      '$fromStr  –  $toStr',
                      style: Theme.of(context).textTheme.emphasized.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            key: ValueKey<int>(stats.hashCode),
            child: const StatsWidgetsList(),
          ),
        ],
      );
    }

    Widget statsScreenWrapper(BuildContext context) {
      return MeasurementDatabase().isEmpty
          ? defaultEmptyChart(context: context)
          : statsScreen(context);
    }

    return AnimationReplayScope(
      controller: _replayController,
      child: StreamBuilder<List<Measurement>>(
        stream: _measurementStream,
        builder: (BuildContext context, _) => statsScreenWrapper(context),
      ),
    );
  }
}
