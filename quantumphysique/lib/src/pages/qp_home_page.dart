import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:quantumphysique/src/types/icons.dart';
import 'package:quantumphysique/src/widgets/qp_m3e_fab.dart';

/// Describes a single tab in a [QPHomePage].
class QPHomeTab {
  /// Creates a [QPHomeTab].
  const QPHomeTab({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.buildContent,
  });

  /// Icon shown when the tab is not selected.
  final Widget icon;

  /// Icon shown when the tab is selected.
  final Widget selectedIcon;

  /// Label displayed below the tab icon.
  final String label;

  /// Builds the page content for this tab.
  ///
  /// Receives the shared [TabController] so content widgets can synchronise
  /// their scroll / swipe with the navigation bar.
  final Widget Function(TabController tabController) buildContent;
}

/// Generic home scaffold for quantumphysique-based apps.
///
/// Provides:
/// - A [NavigationBar] at the bottom driven by [tabs].
/// - A [NestedScrollView] with a pinned [SliverAppBar] containing a settings
///   gear icon (leading) and an optional user icon (trailing action).
/// - An optional Material 3 medium FAB that animates in/out.
/// - A one-shot [onPostInit] hook fired after the first frame (useful for
///   showing a changelog on first launch).
///
/// ```dart
/// QPHomePage(
///   tabs: [
///     QPHomeTab(
///       icon: PPIcon(PhosphorIconsDuotone.house, context),
///       selectedIcon: PPIcon(PhosphorIconsFill.house, context),
///       label: 'Home',
///       buildContent: (_) => const MyHomeTab(),
///     ),
///   ],
///   settingsPageBuilder: (_) => const MySettingsPage(),
///   onFABPressed: _handleAdd,
///   fabOnFirstTabOnly: true,
///   fabTooltip: 'Add',
/// )
/// ```
class QPHomePage extends StatefulWidget {
  /// Creates a [QPHomePage].
  const QPHomePage({
    required this.tabs,
    required this.settingsPageBuilder,
    this.onUserPressed,
    this.onFABPressed,
    this.fabTooltip,
    this.fabOnFirstTabOnly = false,
    this.onPostInit,
    super.key,
  });

  /// The tabs to display in the [NavigationBar] and [TabBarView].
  final List<QPHomeTab> tabs;

  /// Builds the settings page navigated to when the gear icon is tapped.
  final WidgetBuilder settingsPageBuilder;

  /// Called when the user icon (top-right) is tapped.
  ///
  /// When `null` the user icon is not shown.
  final VoidCallback? onUserPressed;

  /// Called when the FAB is tapped.
  ///
  /// When `null` no FAB is rendered.
  final Future<void> Function()? onFABPressed;

  /// Tooltip shown on the FAB.
  final String? fabTooltip;

  /// When `true` the FAB is only visible on tab index 0.
  final bool fabOnFirstTabOnly;

  /// Called once after the first frame with the current [BuildContext].
  ///
  /// Use this to show a one-shot changelog, onboarding prompt, etc.
  final void Function(BuildContext context)? onPostInit;

  @override
  State<QPHomePage> createState() => _QPHomePageState();
}

class _QPHomePageState extends State<QPHomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late final TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  late final List<Widget> _activeTabs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      vsync: this,
      length: widget.tabs.length,
      initialIndex: _selectedIndex,
    );
    _tabController.addListener(_onSlideTab);
    _activeTabs = <Widget>[
      for (final QPHomeTab tab in widget.tabs) tab.buildContent(_tabController),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onPostInit?.call(context);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _selectedIndex = index;
    _tabController.index = index;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutExpo,
    );
    setState(() {});
  }

  void _onSlideTab() {
    final int index = _tabController.index;
    if (index != _selectedIndex) {
      _onItemTapped(index);
    }
  }

  bool get _showFAB {
    if (widget.onFABPressed == null) {
      return false;
    }
    if (widget.fabOnFirstTabOnly) {
      return _selectedIndex == 0;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: <NavigationDestination>[
          for (final QPHomeTab tab in widget.tabs)
            NavigationDestination(
              icon: tab.icon,
              selectedIcon: tab.selectedIcon,
              label: tab.label,
            ),
        ],
      ),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool _) {
          return <Widget>[
            SliverOverlapAbsorber(
              sliver: SliverSafeArea(
                top: false,
                sliver: SliverAppBar(
                  pinned: true,
                  leading: IconButton(
                    icon: PPIcon(PhosphorIconsDuotone.gear, context),
                    onPressed: () => Navigator.of(context).push<dynamic>(
                      MaterialPageRoute<Widget>(
                        builder: widget.settingsPageBuilder,
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    if (widget.onUserPressed != null)
                      IconButton(
                        icon: PPIcon(PhosphorIconsDuotone.userCircle, context),
                        onPressed: widget.onUserPressed,
                      ),
                  ],
                  elevation: Theme.of(context).bottomAppBarTheme.elevation,
                ),
              ),
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
          ];
        },
        body: TabBarView(controller: _tabController, children: _activeTabs),
      ),
      floatingActionButton: widget.onFABPressed != null
          ? AnimatedContainer(
              alignment: Alignment.center,
              height: _showFAB ? 80.0 : 0.0,
              width: 80.0,
              duration: const Duration(milliseconds: 200),
              child: M3EFloatingActionButton.medium(
                onPressed: () => widget.onFABPressed!(),
                tooltip: widget.fabTooltip,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
