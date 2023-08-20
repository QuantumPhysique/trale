import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:trale/core/icons.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/pages/overview.dart';
import 'package:trale/pages/stats.dart';
import 'package:trale/widget/addWeightDialog.dart';
import 'package:trale/widget/appDrawer.dart';
import 'package:trale/widget/customSliverAppBar.dart';
import 'package:trale/widget/floatingActionButton.dart';


/// home scaffold
class Home extends StatefulWidget {
  /// constructor
  const Home({Key? key}) : super(key: key);
  @override

  /// create state
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin{
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
      length: 2,
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // color system bottom navigation bar
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        /// default values of flutter definition
        /// https://github.com/flutter/flutter/blob/ee4e09cce01d6f2d7f4baebd247fde02e5008851/packages/flutter/lib/src/material/navigation_bar.dart#L1237
        systemNavigationBarColor: ElevationOverlay.colorWithOverlay(
          Theme.of(context).colorScheme.surface,
          Theme.of(context).colorScheme.primary,
          3.0,
        ),
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Theme.of(context).brightness,
      ),
    );
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
    setState(() {
      _pageIndex = selectedPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool showFAB = !popupShown;
    final List<Widget> activeTabs = <Widget>[
      const OverviewScreen(),
      StatsScreen(tabController: _selectedTab),
    ];

    return Scaffold(
      key: key,
      //appBar: appBar,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: <Widget>[
          NavigationDestination(
            icon: const Icon(CustomIcons.home),
            label: AppLocalizations.of(context)!.home,
          ),
          NavigationDestination(
            icon: const Icon(CustomIcons.events),
            label: AppLocalizations.of(context)!.achievements,
          ),
          // fake container to keep space for FAB
          const NavigationDestination(
            icon: SizedBox.shrink(),
            label: '',
          ),
        ],
      ),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool _) {
          return <Widget>[
            CustomSliverAppBar(
              leading: IconButton(
                icon: const Icon(CustomIcons.settings),
                onPressed: () => key.currentState!.openDrawer(),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _selectedTab,
          children: activeTabs,
        ),
      ),
      floatingActionButton: FAB(
        onPressed: onFABpress,
        show: showFAB,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      drawer: appDrawer(context, handlePageChanged, _pageIndex),
    );
  }
}
