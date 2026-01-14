import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/pages/homescreen_calendar.dart';
import 'package:trale/pages/measurementScreen.dart';
import 'package:trale/pages/overview.dart';
import 'package:trale/pages/settingsOverview.dart';
import 'package:trale/pages/statScreen.dart';
import 'package:trale/screens/daily_entry_screen.dart';
import 'package:trale/widget/customSliverAppBar.dart';
import 'package:trale/widget/floatingActionButton.dart';
import 'package:trale/widget/userDialog.dart';

/// home scaffold
class Home extends StatefulWidget {
  /// constructor
  const Home({super.key});
  @override
  /// create state
  _HomeState createState() => _HomeState();
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
    _pageIndex = 0;

    _selectedTab = TabController(
      vsync: this,
      length: 3,
      initialIndex: _selectedIndex,
    );
    _selectedTab.addListener(_onSlideTab);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (loadedFirst) {
        loadedFirst = false;
        setState(() {});
      }
    });
  }

  /// Starts home with category all
  static int _selectedIndex = 0;
  // controller for selected category
  late TabController _selectedTab;
  // scrolling controller
  final ScrollController _scrollController = ScrollController();
  // active page
  int _pageIndex = 0;

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
    _onItemTapped(_selectedTab.index);
  }

  /// on pressing FAB button
  Future<void> onFABpress() async {
    setState(() {
      popupShown = true;
    });
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => DailyEntryScreen(
          initialDate: DateTime.now(),
        ),
      ),
    );
    setState(() {
      popupShown = false;
    });
  }

  void handlePageChanged(int selectedPage) {
    setState(() {
      _pageIndex = selectedPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool showFAB = !popupShown & (_selectedIndex == 0);
    final List<Widget> activeTabs = <Widget>[
      const OverviewScreen(),
      StatsScreen(tabController: _selectedTab),
      MeasurementScreen(tabController: _selectedTab),
    ];
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
                  icon: PPIcon(PhosphorIconsDuotone.calendar, context),
                  tooltip: 'Open calendar',
                  onPressed: () {
                    Navigator.of(context).push<dynamic>(
                      MaterialPageRoute<Widget>(
                        builder: (BuildContext context) =>
                            const HomeScreenCalendarPage(),
                      ),
                    );
                  },
                ),
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
        body: TabBarView(controller: _selectedTab, children: activeTabs),
      ),
      floatingActionButton: FAB(onPressed: onFABpress, show: showFAB),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
