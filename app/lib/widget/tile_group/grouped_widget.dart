part of '../tile_group.dart';

class GroupedWidget extends StatelessWidget {
  const GroupedWidget({super.key, required this.child, this.color, this.shape});

  final Widget child;
  final Color? color;
  final ShapeBorder? shape;
  @override
  Widget build(BuildContext context) {
    return Card(
      // Remove default Card margin so tile fills parent width/height
      margin: EdgeInsets.zero,
      color: color ?? Theme.of(context).colorScheme.surfaceContainer,
      shape: shape ?? TraleTheme.of(context)!.innerBorderShape,
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
        shape: shape ?? fallbackShape,
        color: color ?? Theme.of(context).colorScheme.surfaceContainer,
        child: Builder(
          builder: (BuildContext innerContext) => super.build(innerContext),
        ),
      ),
    );
  }
}

