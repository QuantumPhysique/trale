import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quantumphysique/quantumphysique.dart';

import 'package:trale/core/l10n_extension.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurement_database.dart';
import 'package:trale/core/measurement_stats.dart';
import 'package:trale/core/trale_notifier.dart';
import 'package:trale/widget/empty_chart.dart';
import 'package:trale/widget/stats_range_dialog.dart';
import 'package:trale/widget/stats_widgets_list.dart';

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
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();
  final GlobalKey<ScaffoldState> key = GlobalKey();
  late final Stream<List<Measurement>> _measurementStream;
  final QPAnimationReplayController _replayController =
      QPAnimationReplayController();

  Timer? _bannerTimer;
  late final AnimationController _bannerController;

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

    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      final TraleNotifier notifier = Provider.of<TraleNotifier>(
        context,
        listen: false,
      );
      if (!notifier.showStatsHintBanner) {
        return;
      }
      _bannerTimer?.cancel();
      _bannerTimer = Timer(const Duration(seconds: 3), () {
        if (!mounted) {
          return;
        }
        _bannerController.forward();
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bannerController.duration = QPTheme.of(
      context,
    )!.transitionDuration.normal;
  }

  @override
  void dispose() {
    widget.tabController.animation?.removeListener(_onTabAnimationTick);
    _replayController.dispose();
    _bannerTimer?.cancel();
    _bannerController.dispose();
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

      final DateTime dbFirstDate = MeasurementDatabase().firstDate;
      final DateTime today = DateTime.now();
      const double minVal = 0;
      final double maxVal = today
          .difference(dbFirstDate)
          .inDays
          .clamp(1, 1 << 30)
          .toDouble();
      final double fromVal = stats.fromDate
          .difference(dbFirstDate)
          .inDays
          .clamp(0, maxVal.toInt())
          .toDouble();
      final double toVal = stats.toDate
          .difference(dbFirstDate)
          .inDays
          .clamp(0, maxVal.toInt())
          .toDouble();

      final int animationDurationInMilliseconds = QPTheme.of(
        context,
      )!.transitionDuration.slow.inMilliseconds;
      final AppLocalizations l10n = context.l10n;

      return CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        cacheExtent: MediaQuery.of(context).size.height,
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Consumer<TraleNotifier>(
              builder: (BuildContext ctx, TraleNotifier n, Widget? _) {
                final String sourceName = n.statsUseInterpolation
                    ? l10n.interpolation
                    : l10n.measurements;
                return SizeTransition(
                  sizeFactor: CurvedAnimation(
                    parent: _bannerController,
                    curve: Curves.easeOut,
                  ),
                  axisAlignment: -1.0,
                  child: !n.showStatsHintBanner
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.fromLTRB(
                            QPTheme.of(ctx)!.padding,
                            QPTheme.of(ctx)!.padding,
                            QPTheme.of(ctx)!.padding,
                            0,
                          ),
                          child: Dismissible(
                            key: const Key('stats_hint_banner'),
                            direction: DismissDirection.horizontal,
                            onDismissed: (DismissDirection direction) {
                              n.showStatsHintBanner = false;
                            },
                            child: Material(
                              elevation: 0,
                              borderRadius: BorderRadius.circular(4),
                              color: Theme.of(ctx).colorScheme.inverseSurface,
                              child: Padding(
                                padding: EdgeInsets.all(
                                  QPTheme.of(ctx)!.padding,
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      PhosphorIconsBold.info,
                                      color: Theme.of(
                                        ctx,
                                      ).colorScheme.onInverseSurface,
                                      size: 20,
                                    ),
                                    SizedBox(
                                      width: QPTheme.of(ctx)!.padding,
                                    ),
                                    Expanded(
                                      child: Text(
                                        l10n.statsHintBanner(
                                          sourceName: sourceName,
                                        ),
                                        style: Theme.of(ctx)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              color: Theme.of(
                                                ctx,
                                              ).colorScheme.onInverseSurface,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: QPAnimateInEffect(
              durationInMilliseconds: animationDurationInMilliseconds,
              child: Padding(
                padding: EdgeInsets.all(QPTheme.of(context)!.padding),
                child: Center(
                  child: Text(
                    l10n.stats,
                    style: Theme.of(context).textTheme.emphasized.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: QPAnimateInEffect(
              durationInMilliseconds: animationDurationInMilliseconds,
              child: InkWell(
                onTap: () => showStatsRangeDialog(context: context),
                borderRadius: BorderRadius.circular(
                  QPTheme.of(context)!.padding,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3 * QPTheme.of(context)!.padding,
                  ),
                  child: Row(
                    children: <Widget>[
                      Text(
                        fromStr,
                        style: Theme.of(context).textTheme.emphasized.bodyLarge,
                      ),
                      Expanded(
                        child: IgnorePointer(
                          child: RangeSlider(
                            values: RangeValues(fromVal, toVal),
                            min: minVal,
                            max: maxVal,
                            divisions: maxVal.toInt(),
                            onChanged: (_) {},
                          ),
                        ),
                      ),
                      Text(
                        toStr,
                        style: Theme.of(context).textTheme.emphasized.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            key: ValueKey<int>(stats.hashCode),
            child: const StatsWidgetsList(),
          ),
          SliverToBoxAdapter(
            child: QPAnimateInEffect(
              durationInMilliseconds: animationDurationInMilliseconds,
              child: Padding(
                padding: EdgeInsets.all(QPTheme.of(context)!.padding),
                child: Center(
                  child: Text(
                    l10n.allTimeStats,
                    style: Theme.of(context).textTheme.emphasized.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            key: ValueKey<int>(stats.ip.hashCode),
            child: const GlobalStatsWidgetsList(),
          ),
        ],
      );
    }

    Widget statsScreenWrapper(BuildContext context) {
      return MeasurementDatabase().isEmpty
          ? defaultEmptyChart(context: context)
          : statsScreen(context);
    }

    return QPAnimationReplayScope(
      controller: _replayController,
      child: StreamBuilder<List<Measurement>>(
        stream: _measurementStream,
        builder: (BuildContext context, _) => statsScreenWrapper(context),
      ),
    );
  }
}
