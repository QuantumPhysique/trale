// ignore_for_file: file_names
import 'package:flutter/material.dart';

/// SliverAppBar which prevents scrolling if not needed
class CustomSliverAppBar extends StatefulWidget {
  /// constructor
  const CustomSliverAppBar({
    super.key,
    this.pinned = true,
    this.snap = false,
    this.floating = false,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.forceElevated = false,
    this.leading,
    this.title,
    this.actions,
    this.backgroundColor,
    this.expandedHeight,
    this.collapsedHeight,
    this.flexibleSpace,
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

  /// collapsed height
  final double? collapsedHeight;

  /// flexible space
  final Widget? flexibleSpace;

  @override
  State<CustomSliverAppBar> createState() => _CustomSliverAppBarState();
}

class _CustomSliverAppBarState extends State<CustomSliverAppBar> {
  @override
  Widget build(BuildContext context) {
    return SliverOverlapAbsorber(
      sliver: SliverSafeArea(
        top: false,
        sliver: SliverAppBar(
          pinned: widget.pinned,
          centerTitle: widget.centerTitle,
          leading: widget.leading,
          title: widget.title,
          actions: widget.actions,
          forceElevated: widget.forceElevated,
          backgroundColor: widget.backgroundColor,
          automaticallyImplyLeading: widget.automaticallyImplyLeading,
          expandedHeight: widget.expandedHeight,
          collapsedHeight: widget.collapsedHeight,
          flexibleSpace: widget.flexibleSpace,
          snap: widget.snap,
          floating: widget.floating,
          elevation: Theme.of(context).bottomAppBarTheme.elevation,
        ),
      ),
      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
    );
  }
}
