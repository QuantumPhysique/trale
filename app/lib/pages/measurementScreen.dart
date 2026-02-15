// ignore_for_file: file_names
import 'package:flutter/material.dart';

import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/widget/animation_replay_scope.dart';
import 'package:trale/widget/emptyChart.dart';
import 'package:trale/widget/weightList.dart';

/// Measurement screen widget.
class MeasurementScreen extends StatefulWidget {
  /// Constructor.
  const MeasurementScreen({super.key, required this.tabController});

  /// Tab controller for switching tabs.
  final TabController tabController;
  @override
  State<MeasurementScreen> createState() => _MeasurementScreen();
}

class _MeasurementScreen extends State<MeasurementScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController scrollController = ScrollController();
  final GlobalKey<ScaffoldState> key = GlobalKey();
  late final Stream<List<Measurement>> _measurementStream;
  final AnimationReplayController _replayController =
      AnimationReplayController();

  /// Whether this tab is currently the nearest visible tab.
  bool _isActive = false;

  @override
  bool get wantKeepAlive => true;

  void _onTabAnimationTick() {
    final double value = widget.tabController.animation!.value;
    // Tab 2 "owns" the range [1.1, 2.0].
    final bool nowActive = value >= 1.1;
    if (nowActive && !_isActive) {
      // Can only come from the left (tab 1).
      _replayController.replay(dir: SlideDirection.fromRight);
    }
    _isActive = nowActive;
  }

  @override
  void initState() {
    super.initState();
    _measurementStream = MeasurementDatabase().streamController.stream;
    _isActive = widget.tabController.index == 2;
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
    final MeasurementDatabase database = MeasurementDatabase();
    final List<SortedMeasurement> measurements = database.sortedMeasurements;

    final int animationDurationInMilliseconds = TraleTheme.of(
      context,
    )!.transitionDuration.slow.inMilliseconds;
    Widget measurementScreen(
      BuildContext context,
      AsyncSnapshot<List<Measurement>> snapshot,
    ) {
      return Scrollbar(
        radius: const Radius.circular(4),
        thickness: 8,
        interactive: true,
        controller: scrollController,
        child: TotalWeightList(
          durationInMilliseconds: animationDurationInMilliseconds,
          delayInMilliseconds: (animationDurationInMilliseconds / 5).toInt(),
          scrollController: scrollController,
          tabController: widget.tabController,
        ),
      );
    }

    Widget measurementScreenWrapper(
      BuildContext context,
      AsyncSnapshot<List<Measurement>> snapshot,
    ) {
      return measurements.isNotEmpty
          ? measurementScreen(context, snapshot)
          : defaultEmptyChart(context: context);
    }

    return AnimationReplayScope(
      controller: _replayController,
      child: StreamBuilder<List<Measurement>>(
        stream: _measurementStream,
        builder:
            (BuildContext context, AsyncSnapshot<List<Measurement>> snapshot) =>
                measurementScreenWrapper(context, snapshot),
      ),
    );
  }
}
