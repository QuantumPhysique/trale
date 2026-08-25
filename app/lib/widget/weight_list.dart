import 'dart:async';

import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/l10n_extension.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurement_database.dart';
import 'package:trale/core/trale_notifier.dart';
import 'package:trale/widget/weight_list_tile.dart';

/// A (year, month) pair identifying one calendar month.
typedef _YearMonth = (int, int);

/// A list of all measurements grouped by calendar month, filterable by
/// year and month via two rows of filter chips.
class TotalWeightList extends StatefulWidget {
  /// Creates a [TotalWeightList].
  const TotalWeightList({
    super.key,
    required this.scrollController,
    required this.tabController,
    this.durationInMilliseconds = 1000,
    this.delayInMilliseconds = 0,
    this.keepAlive = false,
  });

  /// Duration of entry animations in milliseconds.
  final int durationInMilliseconds;

  /// Delay before animations start in milliseconds.
  final int delayInMilliseconds;

  /// Whether to keep this widget alive when off-screen.
  final bool keepAlive;

  /// Scroll controller for the parent scroll view.
  final ScrollController scrollController;

  /// Tab controller to dismiss revealed tiles on tab change.
  final TabController tabController;

  @override
  State<TotalWeightList> createState() => _TotalWeightList();
}

class _TotalWeightList extends State<TotalWeightList>
    with SingleTickerProviderStateMixin {
  Timer? _bannerTimer;
  late final AnimationController _bannerController;

  /// Currently selected year filters; empty means all years.
  final Set<int> _selectedYears = <int>{};

  /// Currently selected month (1-12) filters; empty means all months.
  final Set<int> _selectedMonths = <int>{};

  void onTabChangeEvent() => WeightListTile.collapseOpen();

  @override
  void initState() {
    super.initState();
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
    _bannerController.duration = QPTheme.of(context)!.transitionDuration.normal;
  }

  @override
  void dispose() {
    widget.tabController.animation!.removeListener(onTabChangeEvent);

    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  /// Whether [month] occurs in any measured month matching the selected
  /// years (all years if none is selected).
  bool _hasMatch(List<_YearMonth> monthKeys, int month) => monthKeys.any(
    (_YearMonth k) =>
        (_selectedYears.isEmpty || _selectedYears.contains(k.$1)) &&
        k.$2 == month,
  );

  /// Whether [key] passes the selected year and month filters; an empty
  /// selection matches everything.
  bool _isVisible(_YearMonth key) =>
      (_selectedYears.isEmpty || _selectedYears.contains(key.$1)) &&
      (_selectedMonths.isEmpty || _selectedMonths.contains(key.$2));

  /// Two rows of year and month filter chips.
  ///
  /// The rows carry no titles on purpose: four-digit years and month names
  /// are self-describing, and a title here would be styled exactly like the
  /// [QPWidgetGroup] month headings below, making controls and content
  /// indistinguishable. Hidden entirely while there is nothing to filter.
  Widget _buildFilterBar(BuildContext context, List<_YearMonth> monthKeys) {
    if (monthKeys.length < 2) {
      return const SizedBox.shrink();
    }

    final String locale = Localizations.localeOf(context).toString();

    final List<int> years = <int>[];
    for (final _YearMonth key in monthKeys) {
      if (!years.contains(key.$1)) {
        years.add(key.$1);
      }
    }

    final List<int> availableMonths = <int>[
      for (int month = 1; month <= 12; month++)
        if (_hasMatch(monthKeys, month)) month,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        QPLayout.padding,
        QPLayout.padding,
        QPLayout.padding,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // A lone year chip filters nothing — every measurement is in it.
          if (years.length > 1) ...<Widget>[
            QPFilterChipBar(
              children: <Widget>[
                for (final int year in years)
                  QPFilterChip(
                    label: '$year',
                    selected: _selectedYears.contains(year),
                    onTap: () => setState(() {
                      if (!_selectedYears.remove(year)) {
                        _selectedYears.add(year);
                      }
                      _selectedMonths.removeWhere(
                        (int month) => !_hasMatch(monthKeys, month),
                      );
                    }),
                  ),
              ],
            ),
            const SizedBox(height: QPLayout.smallPadding),
          ],
          QPFilterChipBar(
            children: <Widget>[
              for (final int month in availableMonths)
                QPFilterChip(
                  label: _monthName(locale, month),
                  selected: _selectedMonths.contains(month),
                  onTap: () => setState(() {
                    if (!_selectedMonths.remove(month)) {
                      _selectedMonths.add(month);
                    }
                  }),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MeasurementDatabase database = MeasurementDatabase();
    final List<SortedMeasurement> measurements = database.sortedMeasurements;
    final TraleNotifier notifier = Provider.of<TraleNotifier>(context);
    final bool showBanner = notifier.showMeasurementHintBanner;
    final String locale = Localizations.localeOf(context).toString();

    // Group measurements by calendar month, preserving newest-first order.
    final List<_YearMonth> monthKeys = <_YearMonth>[];
    final Map<_YearMonth, List<SortedMeasurement>> measurementsPerMonth =
        <_YearMonth, List<SortedMeasurement>>{};
    for (final SortedMeasurement m in measurements) {
      final DateTime date = m.measurement.date;
      final _YearMonth key = (date.year, date.month);
      measurementsPerMonth
          .putIfAbsent(key, () {
            monthKeys.add(key);
            return <SortedMeasurement>[];
          })
          .add(m);
    }

    // Drop selections whose data no longer exists — deleting the last
    // measurement of a selected year removes its chip, which would otherwise
    // leave a filter active with nothing left to switch it off. Years first,
    // since _hasMatch reads the year selection.
    _selectedYears.retainWhere(
      (int year) => monthKeys.any((_YearMonth k) => k.$1 == year),
    );
    _selectedMonths.retainWhere((int m) => _hasMatch(monthKeys, m));

    final List<_YearMonth> visibleKeys = <_YearMonth>[
      for (final _YearMonth key in monthKeys)
        if (_isVisible(key)) key,
    ];

    return CustomScrollView(
      controller: widget.scrollController,
      cacheExtent: 2 * MediaQuery.of(context).size.height,
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: QPAnimateInEffect(
            durationInMilliseconds: widget.durationInMilliseconds,
            child: Padding(
              padding: const EdgeInsets.all(QPLayout.padding),
              child: Center(
                child: Text(
                  context.l10n.measurements,
                  style: Theme.of(context).textTheme.emphasized.displaySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
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
                    padding: const EdgeInsets.fromLTRB(
                      QPLayout.padding,
                      QPLayout.padding,
                      QPLayout.padding,
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
                          padding: const EdgeInsets.all(QPLayout.padding),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                PhosphorIconsBold.info,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onInverseSurface,
                                size: 20,
                              ),
                              const SizedBox(width: QPLayout.padding),
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
        SliverToBoxAdapter(child: _buildFilterBar(context, monthKeys)),
        for (final _YearMonth key in visibleKeys)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: QPLayout.padding),
            // Sliver rather than box group: a month holds up to ~31 tiles and
            // there is one group per month, so building them all up front
            // would materialise the entire history on every rebuild.
            sliver: QPSliverWidgetGroup(
              title: '${key.$1} - ${_monthName(locale, key.$2)}',
              itemCount: measurementsPerMonth[key]!.length,
              itemBuilder: (BuildContext context, int index) {
                final SortedMeasurement m = measurementsPerMonth[key]![index];
                return WeightListTile(
                  key: ValueKey<Object?>(m.key),
                  measurement: m,
                );
              },
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: QPLayout.padding)),
      ],
    );
  }
}

/// Localized full month name (e.g. "April") for [month] (1-12).
String _monthName(String locale, int month) =>
    DateFormat.MMMM(locale).format(DateTime(2000, month));
