import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/font.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/statsCards.dart';
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

class _WeightList extends State<WeightList> {
  double heightFactor = 1.5;
  int? activeListTile;

  void onScrollEvent() {
    if (activeListTile != null) {
      setState(() => activeListTile = null);
    }
  }

  void onTabChangeEvent() {
    if (activeListTile != null) {
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
    void updateActiveListTile(int? key) {
      setState(() {
        activeListTile = key;
      });
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int i) => WeightListTile(
          measurement: widget.measurements[i],
          updateActiveState: updateActiveListTile,
          activeKey: activeListTile,
          offset: Offset(-MediaQuery.of(context).size.width / 2, 0),
          durationInMilliseconds: TraleTheme.of(
            context,
          )!.transitionDuration.slow.inMilliseconds,
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

class _TotalWeightList extends State<TotalWeightList>
    with SingleTickerProviderStateMixin {
  double heightFactor = 1.5;
  int? activeListTile;
  Timer? _bannerTimer;
  late final AnimationController _bannerController;

  void onScrollEvent() {
    if (activeListTile != null) {
      setState(() => activeListTile = null);
    }
  }

  void onTabChangeEvent() {
    if (activeListTile != null) {
      setState(() => activeListTile = null);
    }
  }

  @override
  void initState() {
    super.initState();
    activeListTile = null;
    widget.scrollController.addListener(onScrollEvent);
    widget.tabController.animation!.addListener(onTabChangeEvent);

    _bannerController = AnimationController(
      vsync: this,
      // place holder, will be updated in didChangeDependencies
      duration: const Duration(milliseconds: 200),
    );

    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      final TraleNotifier notifier = Provider.of<TraleNotifier>(
        context,
        listen: false,
      );
      if (!notifier.showMeasurementHintBanner) {
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
    _bannerController.duration = TraleTheme.of(
      context,
    )!.transitionDuration.normal;
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(onScrollEvent);
    widget.tabController.animation!.removeListener(onTabChangeEvent);

    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MeasurementDatabase database = MeasurementDatabase();
    final List<SortedMeasurement> measurements = database.sortedMeasurements;
    final TraleNotifier notifier = Provider.of<TraleNotifier>(context);
    final bool showBanner = notifier.showMeasurementHintBanner;

    final List<int> years = <int>[
      for (
        int year = measurements.first.measurement.date.year;
        year >= measurements.last.measurement.date.year;
        year--
      )
        year,
    ];

    final Map<int, List<SortedMeasurement>> measurementsPerYear =
        <int, List<SortedMeasurement>>{
          for (final int year in years)
            year: <SortedMeasurement>[
              for (final SortedMeasurement m in measurements)
                if (m.measurement.date.year == year) m,
            ],
        };

    return CustomScrollView(
      controller: widget.scrollController,
      cacheExtent: 2 * MediaQuery.of(context).size.height,
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: SizeTransition(
            sizeFactor: CurvedAnimation(
              parent: _bannerController,
              curve: Curves.easeOut,
            ),
            axisAlignment: -1.0,
            child: !showBanner
                ? const SizedBox.shrink()
                : Padding(
                    padding: EdgeInsets.fromLTRB(
                      TraleTheme.of(context)!.padding,
                      TraleTheme.of(context)!.padding,
                      TraleTheme.of(context)!.padding,
                      0,
                    ),
                    child: Dismissible(
                      key: const Key('measurement_hint_banner'),
                      direction: DismissDirection.horizontal,
                      onDismissed: (DismissDirection direction) {
                        notifier.showMeasurementHintBanner = false;
                      },
                      child: Material(
                        elevation: 0,
                        borderRadius: BorderRadius.circular(4),
                        color: Theme.of(context).colorScheme.inverseSurface,
                        child: Padding(
                          padding: EdgeInsets.all(
                            TraleTheme.of(context)!.padding,
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                PhosphorIconsBold.info,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onInverseSurface,
                                size: 20,
                              ),
                              SizedBox(width: TraleTheme.of(context)!.padding),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.measurementHintSubtitle,
                                  style: Theme.of(context).textTheme.bodyMedium!
                                      .copyWith(
                                        color: Theme.of(
                                          context,
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
          ),
        ),
        ...<Widget>[
          for (final int year in years) ...<Widget>[
            SliverToBoxAdapter(
              child: getYearWidget(year: '$year', context: context),
            ),
            WeightList(
              measurements: measurementsPerYear[year]!,
              durationInMilliseconds: widget.durationInMilliseconds,
              delayInMilliseconds: widget.delayInMilliseconds,
              scrollController: widget.scrollController,
              tabController: widget.tabController,
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: TraleTheme.of(context)!.padding),
            ),
          ],
        ],
      ],
    );
  }
}

/// define StatCard for change per week, month, and year
Widget getYearWidget({
  required BuildContext context,
  required String year,
  int? delayInMilliseconds,
}) {
  return Padding(
    padding: EdgeInsets.all(TraleTheme.of(context)!.padding),
    child: StatCard(
      pillShape: true,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      delayInMilliseconds: delayInMilliseconds,
      childWidget: Center(
        child: Text(
          year,
          style: Theme.of(context).textTheme.emphasized.displayLarge!.apply(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}
