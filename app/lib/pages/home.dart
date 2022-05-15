import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/icons.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/pages/overview.dart';
import 'package:trale/pages/weightList.dart';
import 'package:trale/widget/FABBottomNavigatonBar.dart';
import 'package:trale/widget/addWeightDialog.dart';
import 'package:trale/widget/appDrawer.dart';
import 'package:trale/widget/customSliverAppBar.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
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

    _selectedTab = TabController(
      vsync: this,
      length: 1,
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _selectedTab.index = _selectedIndex;

      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutExpo,
      );
    });
  }

  void _onSlideTab() {
    _onItemTapped(_selectedTab.index);
  }

  @override
  Widget build(BuildContext context) {
    final MeasurementDatabase database = MeasurementDatabase();
    final List<SortedMeasurement> measurements = database.sortedMeasurements;
    final bool showFAB = !popupShown;
    final TraleNotifier notifier = Provider.of<TraleNotifier>(context);

    Widget floatingActionButton () {
      const double buttonHeight = 60;
      return Container(
        padding: EdgeInsets.only(
          //todo add adaptive padding such that FAB is like a third bottom icon
          right: TraleTheme.of(context)!.padding,
          top: 80.0,
        ),
        child: AnimatedContainer(
            alignment: Alignment.center,
            height: showFAB ? buttonHeight : 0,
            width: showFAB ? buttonHeight : 0,
            margin: EdgeInsets.all(
              showFAB ? 0 : 0.5 * buttonHeight,
            ),
            duration: TraleTheme.of(context)!.transitionDuration.normal,
            child: FittedBox(
              fit: BoxFit.contain,
              child: FloatingActionButton(
                onPressed: () async {
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
                },
                tooltip: AppLocalizations.of(context)!.addWeight,
                child: const Icon(CustomIcons.add),
              ),
            )
        ),
      );
    }

    List<Widget> activeTab (int selectedIndex) {
      if (selectedIndex == 0) {
        return const <Widget>[OverviewScreen()];
      } else {
        return const <Widget>[WeightList()];
      }
    }

    return Scaffold(
      key: key,
      //appBar: appBar,
      bottomNavigationBar: FABBottomAppBar(
        selectedIndex: _selectedIndex,
        onTabSelected: _onItemTapped,
        items: <FABBottomAppBarItem>[
          FABBottomAppBarItem(iconData: Icons.mail, text: 'home'),
          FABBottomAppBarItem(iconData: Icons.mail, text: 'list'),
        ],
      ),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder:
            (BuildContext context, bool _) {
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
          children: activeTab(_selectedIndex),
        ),
      ),
      floatingActionButton: floatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      drawer: appDrawer(context),
    );
  }
}
