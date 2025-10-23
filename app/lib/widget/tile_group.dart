import 'package:flutter/material.dart';
import 'package:trale/core/theme.dart';


/// A rounded section that groups a list of tiles and draws dividers between
/// theme.
class WidgetGroup extends StatelessWidget {
  const WidgetGroup({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: TraleTheme.of(context)!.padding
      ),
      child: Card(
        color: Colors.transparent,
        shape: TraleTheme.of(context)!.borderShape,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: _withDividers(context, children),
        ),
      ),
    );
  }

  List<Widget> _withDividers(BuildContext context, List<Widget> items) {
    final List<Widget> result = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i != items.length - 1) {
        result.add(
          SizedBox(
            height: TraleTheme.of(context)!.space,
          ),
        );
      }
    }
    return result;
  }
}

/// Rounded tile with icon, title, subtitle and optional trailing widget.
class GroupedWidget extends StatelessWidget {
  const GroupedWidget({super.key, 
    required this.child,
    this.color,
  });

  final Widget child;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Card(
      // Remove default Card margin so tile fills parent width/height
      margin: EdgeInsets.zero,
      color: color ?? Theme.of(context).colorScheme.surfaceContainer,
      shape: TraleTheme.of(context)!.innerBorderShape,
      child: child,
    );
  }
}

/// ListTile wrapped in GroupedWidget
class GroupedListTile extends ListTile {
  const GroupedListTile({
    super.key,
    super.leading,
    super.title,
    super.subtitle,
    super.trailing,
    super.isThreeLine,
    super.dense,
    super.visualDensity,
    super.shape,
    super.style,
    super.selectedColor,
    super.iconColor,
    super.textColor,
    super.titleTextStyle,
    super.subtitleTextStyle,
    super.leadingAndTrailingTextStyle,
    super.contentPadding,
    super.enabled,
    super.onTap,
    super.onLongPress,
    super.mouseCursor,
    super.selected,
    super.focusColor,
    super.hoverColor,
    super.focusNode,
    super.autofocus,
    super.tileColor,
    super.selectedTileColor,
    super.enableFeedback,
    super.horizontalTitleGap,
    super.minVerticalPadding,
    super.minLeadingWidth,
    super.minTileHeight,
    super.titleAlignment,
    super.internalAddSemanticForOnTap,
    super.statesController,
    this.color,
  });

  /// Background color of the grouped tile
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ShapeBorder fallbackShape = TraleTheme.of(context)!.innerBorderShape;
    return ListTileTheme(
      shape: shape ?? fallbackShape,
      child: GroupedWidget(
        color: color ?? Theme.of(context).colorScheme.surfaceContainer,
        child: Builder(
          builder: (BuildContext innerContext) => super.build(innerContext),
        ),
      ),
    );
  }
}