import 'package:flutter/material.dart';
import 'package:trale/core/theme.dart';

/// Enum for selecting default SliverAppBar Height
enum AppBarSize {
  normal,
  medium,
  large,
}

/// SliverAppBar which prevents scrolling if not needed
class CustomSliverAppBar extends StatefulWidget {
  /// constructor
  const CustomSliverAppBar({
    this.pinned=true,
    this.snap=false,
    this.floating=false,
    this.centerTitle=true,
    this.automaticallyImplyLeading=true,
    this.forceElevated=false,
    this.leading,
    this.title,
    this.actions,
    this.backgroundColor,
    this.expandedHeight,
    this.flexibleSpace,
    this.size=AppBarSize.normal,
  });

  /// if AppBar is sticky
  final bool pinned;
  /// if title should be centered
  final bool centerTitle;
  /// floating
  final bool floating;
  /// snap
  final bool snap;
  /// force shadow
  final bool forceElevated;
  ///
  final bool automaticallyImplyLeading;
  /// leading widget
  final Widget? leading;
  /// title widget
  final Widget? title;
  /// trailing widgets
  final List<Widget>? actions;
  /// background color
  final Color? backgroundColor;
  /// expanded height
  final double? expandedHeight;
  /// flexible space
  final Widget? flexibleSpace;
  /// default Constructor for given size
  final AppBarSize size;

  @override
  _CustomSliverAppBarState createState() => _CustomSliverAppBarState();
}

class _CustomSliverAppBarState extends State<CustomSliverAppBar> {
  @override
  Widget build(BuildContext context) {
    SliverAppBar appBar;
    if (widget.size == AppBarSize.normal) {
      appBar = SliverAppBar(
        pinned: widget.pinned,
        centerTitle: widget.centerTitle,
        leading: widget.leading,
        title: widget.title,
        actions: widget.actions,
        forceElevated: widget.forceElevated,
        backgroundColor: widget.backgroundColor,
        automaticallyImplyLeading: widget.automaticallyImplyLeading,
        expandedHeight: widget.expandedHeight,
        flexibleSpace: widget.flexibleSpace,
        snap: widget.snap,
        floating: widget.floating,
        elevation: Theme.of(context).bottomAppBarTheme.elevation,
      );
    } else if (widget.size == AppBarSize.large) {
      appBar = SliverAppBar.large(
        pinned: widget.pinned,
        centerTitle: widget.centerTitle,
        leading: widget.leading,
        title: widget.title,
        actions: widget.actions,
        forceElevated: widget.forceElevated,
        backgroundColor: widget.backgroundColor,
        automaticallyImplyLeading: widget.automaticallyImplyLeading,
        expandedHeight: widget.expandedHeight,
        flexibleSpace: FlexibleSpaceBar(
          titlePadding:EdgeInsetsDirectional.only(
            start: 2 * TraleTheme.of(context)!.padding,
            bottom: 16,
          ),
          title: widget.title,
          centerTitle: false,
          collapseMode: CollapseMode.none,
        ),
        snap: widget.snap,
        floating: widget.floating,
        elevation: Theme.of(context).bottomAppBarTheme.elevation,
      );
    } else {
      appBar = SliverAppBar.medium(
        pinned: widget.pinned,
        centerTitle: widget.centerTitle,
        leading: widget.leading,
        title: widget.title,
        actions: widget.actions,
        forceElevated: widget.forceElevated,
        backgroundColor: widget.backgroundColor,
        automaticallyImplyLeading: widget.automaticallyImplyLeading,
        expandedHeight: widget.expandedHeight,
        flexibleSpace: widget.flexibleSpace,
        snap: widget.snap,
        floating: widget.floating,
        elevation: Theme.of(context).bottomAppBarTheme.elevation,
      );
    }
    return SliverOverlapAbsorber(
      sliver: SliverSafeArea(
        top: false,
        sliver: appBar,
      ),
      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
    );
  }
}
