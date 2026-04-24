part of 'tile_group.dart';

/// A card-style container that wraps a single widget.
class QPGroupedWidget extends StatelessWidget {
  const QPGroupedWidget({
    super.key,
    required this.child,
    this.color,
    this.shape,
  });

  final Widget child;
  final Color? color;
  final ShapeBorder? shape;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: color ?? Theme.of(context).colorScheme.surfaceContainer,
      shape: shape ?? QPLayout.innerBorderShape,
      child: child,
    );
  }
}

/// [ListTile] wrapped in a [QPGroupedWidget].
class QPGroupedListTile extends ListTile {
  const QPGroupedListTile({
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

  /// Background color of the grouped tile.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ShapeBorder fallbackShape = QPLayout.innerBorderShape;
    return ListTileTheme(
      shape: shape ?? fallbackShape,
      child: QPGroupedWidget(
        shape: shape ?? fallbackShape,
        color: color ?? Theme.of(context).colorScheme.surfaceContainer,
        child: Builder(
          builder: (BuildContext innerContext) => super.build(innerContext),
        ),
      ),
    );
  }
}
