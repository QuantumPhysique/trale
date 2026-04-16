part of '../tile_group.dart';

class GroupedSwitchListTile extends StatelessWidget {
  /// Creates a [GroupedSwitchListTile].
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

  /// Mouse cursor for the tile.
  final MouseCursor? mouseCursor;

  /// Active switch color.
  final Color? activeColor;

  /// Active switch track color.
  final Color? activeTrackColor;

  /// Inactive switch thumb color.
  final Color? inactiveThumbColor;

  /// Inactive switch track color.
  final Color? inactiveTrackColor;

  /// Hover highlight color.
  final Color? hoverColor;

  /// Whether the tile auto-focuses.
  final bool autofocus;

  /// Padding around the content.
  final EdgeInsetsGeometry? contentPadding;

  /// Secondary widget (e.g. icon).
  final Widget? secondary;

  /// Title widget.
  final Widget? title;

  /// Subtitle widget.
  final Widget? subtitle;

  /// Whether the tile has three lines.
  final bool isThreeLine;

  /// Whether the tile is dense.
  final bool? dense;

  /// Color of the list tile background.
  final Color? tileColor;

  /// Color when selected.
  final Color? selectedTileColor;

  /// Shape of the list tile.
  final ShapeBorder? shape;

  /// Whether the tile is selected.
  final bool selected;

  /// Position of the switch control.
  final ListTileControlAffinity controlAffinity;

  /// Whether feedback is enabled.
  final bool? enableFeedback;

  /// Visual density of the tile.
  final VisualDensity? visualDensity;

  /// Focus node.
  final FocusNode? focusNode;

  /// Called when focus changes.
  final ValueChanged<bool>? onFocusChange;

  /// Splash radius.
  final double? splashRadius;

  /// Thumb color state property.
  final WidgetStateProperty<Color?>? thumbColor;

  /// Track color state property.
  final WidgetStateProperty<Color?>? trackColor;

  /// Background color of the grouped tile.
  final Color? color;

  /// Optional leading widget shown before the title.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final ShapeBorder fallbackShape = TraleTheme.of(context)!.innerBorderShape;
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

/// Squared selectable chip for use inside a horizontal [WidgetGroup].
///
/// Unselected: rounded-rectangle shape ([TraleTheme.innerBorderShape]).
/// Selected: circle shape with the primary colour.
///
/// The border-radius animates smoothly between the two states.
