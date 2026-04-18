part of 'tile_group.dart';

/// A [SwitchListTile] wrapped in a [GroupedWidget].
class GroupedSwitchListTile extends StatelessWidget {
  const GroupedSwitchListTile({
    super.key,
    required this.value,
    required this.onChanged,
    this.mouseCursor,
    this.activeColor,
    this.activeTrackColor,
    this.inactiveThumbColor,
    this.inactiveTrackColor,
    this.hoverColor,
    this.autofocus = false,
    this.contentPadding,
    this.secondary,
    this.title,
    this.subtitle,
    this.isThreeLine = false,
    this.dense,
    this.tileColor,
    this.selectedTileColor,
    this.shape,
    this.selected = false,
    this.controlAffinity = ListTileControlAffinity.platform,
    this.enableFeedback,
    this.visualDensity,
    this.focusNode,
    this.onFocusChange,
    this.splashRadius,
    this.thumbColor,
    this.trackColor,
    this.color,
    this.leading,
  });

  /// Whether the switch is on.
  final bool value;

  /// Called when the switch value changes.
  final ValueChanged<bool?>? onChanged;

  final MouseCursor? mouseCursor;
  final Color? activeColor;
  final Color? activeTrackColor;
  final Color? inactiveThumbColor;
  final Color? inactiveTrackColor;
  final Color? hoverColor;
  final bool autofocus;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? secondary;
  final Widget? title;
  final Widget? subtitle;
  final bool isThreeLine;
  final bool? dense;
  final Color? tileColor;
  final Color? selectedTileColor;
  final ShapeBorder? shape;
  final bool selected;
  final ListTileControlAffinity controlAffinity;
  final bool? enableFeedback;
  final VisualDensity? visualDensity;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocusChange;
  final double? splashRadius;
  final WidgetStateProperty<Color?>? thumbColor;
  final WidgetStateProperty<Color?>? trackColor;

  /// Background color of the grouped tile.
  final Color? color;

  /// Optional leading widget shown before the title.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final ShapeBorder fallbackShape = QPLayout.innerBorderShape;
    final EdgeInsetsGeometry? effectiveContentPadding = leading == null
        ? contentPadding
        : contentPadding ??
              ListTileTheme.of(context).contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16.0);
    return GroupedWidget(
      color: color ?? Theme.of(context).colorScheme.surfaceContainer,
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        mouseCursor: mouseCursor,
        activeThumbColor: activeColor,
        activeTrackColor: activeTrackColor,
        inactiveThumbColor: inactiveThumbColor,
        inactiveTrackColor: inactiveTrackColor,
        hoverColor: hoverColor,
        autofocus: autofocus,
        contentPadding: effectiveContentPadding,
        secondary: leading ?? secondary,
        title: title,
        subtitle: subtitle,
        isThreeLine: isThreeLine,
        dense: dense,
        tileColor: tileColor,
        selectedTileColor: selectedTileColor,
        shape: shape ?? fallbackShape,
        selected: selected,
        controlAffinity: controlAffinity,
        enableFeedback: enableFeedback,
        visualDensity: visualDensity,
        focusNode: focusNode,
        onFocusChange: onFocusChange,
        splashRadius: splashRadius,
        thumbColor: thumbColor,
        trackColor: trackColor,
      ),
    );
  }
}
