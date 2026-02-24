import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:trale/core/icons.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/pages/measurementScreen.dart';
import 'package:trale/pages/overview.dart';
import 'package:trale/pages/settingsOverview.dart';
import 'package:trale/pages/statScreen.dart';
import 'package:trale/widget/addWeightDialog.dart';
import 'package:trale/widget/customSliverAppBar.dart';
import 'package:trale/widget/floatingActionButton.dart';
import 'package:trale/widget/userDialog.dart';
import 'package:trale/widget/changelog_widget.dart';

/// home scaffold
class Home extends StatefulWidget {
  /// constructor
  const Home({super.key});
  @override
  /// create state
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> key = GlobalKey();
  final Duration animationDuration = const Duration(milliseconds: 500);
  bool popupShown = false;
  late bool loadedFirst;
  final double minHeight = 45.0;

  @override
  void initState() {
    super.initState();
    loadedFirst = true;

    _selectedTab = TabController(
      vsync: this,
      length: 3,
      initialIndex: _selectedIndex,
    );
    _selectedTab.addListener(_onSlideTab);

    // Cache tab content widgets so they are not recreated on every rebuild
    _activeTabs = <Widget>[
      OverviewScreen(tabController: _selectedTab),
      StatsScreen(tabController: _selectedTab),
      MeasurementScreen(tabController: _selectedTab),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (loadedFirst && mounted) {
        loadedFirst = false;
        // Show changelog on first launch after update
        if (Preferences().showChangelog) {
          Preferences().showChangelog = false;
          showChangelog(context);
        }
      }
    });
  }

  /// Starts home with category all
  static int _selectedIndex = 0;
  // controller for selected category
  late TabController _selectedTab;
  // scrolling controller
  final ScrollController _scrollController = ScrollController();
  // cached tab content widgets
  late final List<Widget> _activeTabs;
  void _onItemTapped(int index) {
    if (index == _selectedTab.length) {
      onFABpress();
    } else {
      _selectedIndex = index;
      _selectedTab.index = _selectedIndex;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutExpo,
      );
      setState(() {});
    }
  }

  void _onSlideTab() {
    final int index = _selectedTab.index;
    if (index != _selectedIndex) {
      _onItemTapped(index);
    }
  }

  /// on pressing FAB button
  Future<void> onFABpress() async {
    final MeasurementDatabase database = MeasurementDatabase();
    final List<SortedMeasurement> measurements = database.sortedMeasurements;
    setState(() {
      popupShown = true;
    });
    await showAddWeightDialog(
      context: context,
      weight: measurements.isNotEmpty
          ? measurements.first.measurement.weight.toDouble()
          : Preferences().defaultUserWeight,
      date: DateTime.now(),
    );
    setState(() {
      popupShown = false;
    });
  }

  void handlePageChanged(int selectedPage) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool showFAB = !popupShown & (_selectedIndex == 0);
    final List<Widget> destinations = <Widget>[
      NavigationDestination(
        icon: PPIcon(PhosphorIconsDuotone.lineSegments, context),
        selectedIcon: PPIcon(PhosphorIconsFill.lineSegments, context),
        label: AppLocalizations.of(context)!.home,
      ),
      NavigationDestination(
        icon: PPIcon(PhosphorIconsDuotone.trophy, context),
        selectedIcon: PPIcon(PhosphorIconsFill.trophy, context),
        label: AppLocalizations.of(context)!.achievements,
      ),
      NavigationDestination(
        icon: PPIcon(PhosphorIconsDuotone.archive, context),
        selectedIcon: PPIcon(PhosphorIconsFill.archive, context),
        label: AppLocalizations.of(context)!.measurements,
      ),
    ];

    return Scaffold(
      key: key,
      //appBar: appBar,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: destinations,
      ),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool _) {
          return <Widget>[
            CustomSliverAppBar(
              leading: IconButton(
                icon: PPIcon(PhosphorIconsDuotone.gear, context),
                //onPressed: () => key.currentState!.openDrawer(),
                onPressed: () {
                  Navigator.of(context).push<dynamic>(
                    MaterialPageRoute<Widget>(
                      builder: (BuildContext context) =>
                          const SettingsOverviewPage(),
                    ),
                  );
                },
              ),
              actions: <Widget>[
                IconButton(
                  icon: PPIcon(PhosphorIconsDuotone.userCircle, context),
                  onPressed: () {
                    showUserDialog(context: context);
                  },
                ),
              ],
            ),
          ];
        },
        body: TabBarView(controller: _selectedTab, children: _activeTabs),
      ),
      floatingActionButton: FAB(onPressed: onFABpress, show: showFAB),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
