part of '../tile_group.dart';

class GroupedRadioListTile<T> extends StatelessWidget {
  const GroupedRadioListTile({
    super.key,
    required this.value,
    this.mouseCursor,
    this.toggleable = false,
    this.activeColor,
    this.fillColor,
    this.hoverColor,
    this.overlayColor,
    this.splashRadius,
    this.materialTapTargetSize,
    this.title,
    this.subtitle,
    this.isThreeLine,
    this.dense,
    this.secondary,
    this.selected = false,
    this.controlAffinity,
    this.autofocus = false,
    this.contentPadding,
    this.shape,
    this.tileColor,
    this.selectedTileColor,
    this.visualDensity,
    this.focusNode,
    this.onFocusChange,
    this.enableFeedback,
    this.radioScaleFactor = 1.0,
    this.titleAlignment,
    this.enabled,
    this.internalAddSemanticForOnTap = false,
    this.radioBackgroundColor,
    this.radioSide,
    this.color,
  }) : assert(isThreeLine != true || subtitle != null);

  final T value;
  final MouseCursor? mouseCursor;
  final bool toggleable;
  final Color? activeColor;
  final WidgetStateProperty<Color?>? fillColor;
  final Color? hoverColor;
  final WidgetStateProperty<Color?>? overlayColor;
  final double? splashRadius;
  final MaterialTapTargetSize? materialTapTargetSize;
  final Widget? title;
  final Widget? subtitle;
  final bool? isThreeLine;
  final bool? dense;
  final Widget? secondary;
  final bool selected;
  final ListTileControlAffinity? controlAffinity;
  final bool autofocus;
  final EdgeInsetsGeometry? contentPadding;
  final ShapeBorder? shape;

  /// Color of the list tile background.
  final Color? tileColor;

  /// Color of the list tile when selected.
  final Color? selectedTileColor;

  /// Visual density of the list tile.
  final VisualDensity? visualDensity;

  /// Focus node for the list tile.
  final FocusNode? focusNode;

  /// Called when the focus state changes.
  final ValueChanged<bool>? onFocusChange;

  /// Whether feedback (sound/haptic) is enabled.
  final bool? enableFeedback;

  /// Scale factor for the radio button.
  final double radioScaleFactor;

  /// Title alignment within the list tile.
  final ListTileTitleAlignment? titleAlignment;

  /// Whether the tile is enabled.
  final bool? enabled;

  /// Whether to add internal semantics for tap events.
  final bool internalAddSemanticForOnTap;

  /// Background color of the radio button.
  final WidgetStateProperty<Color?>? radioBackgroundColor;

  /// Border side of the radio button.
  final BorderSide? radioSide;

  /// Background color of the grouped radio tile
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ShapeBorder fallbackShape = TraleTheme.of(context)!.innerBorderShape;
    return GroupedWidget(
      shape: shape ?? fallbackShape,
      color: color ?? Theme.of(context).colorScheme.surfaceContainer,
      child: RadioListTile<T>(
        value: value,
        mouseCursor: mouseCursor,
        toggleable: toggleable,
        activeColor: activeColor,
        fillColor: fillColor,
        hoverColor: hoverColor,
        overlayColor: overlayColor,
        splashRadius: splashRadius,
        materialTapTargetSize: materialTapTargetSize,
        title: title,
        subtitle: subtitle,
        isThreeLine: isThreeLine ?? false,
        dense: dense,
        secondary: secondary,
        selected: selected,
        controlAffinity: controlAffinity,
        autofocus: autofocus,
        contentPadding: contentPadding,
        shape: shape ?? fallbackShape,
        tileColor: tileColor,
        selectedTileColor: selectedTileColor,
        visualDensity: visualDensity,
        focusNode: focusNode,
        onFocusChange: onFocusChange,
        enableFeedback: enableFeedback,
        radioScaleFactor: radioScaleFactor,
        titleAlignment: titleAlignment,
        enabled: enabled,
        internalAddSemanticForOnTap: internalAddSemanticForOnTap,
        radioBackgroundColor: radioBackgroundColor,
        radioSide: radioSide,
      ),
    );
  }
}

/// A grouped text widget with a styled background.
class GroupedText extends StatelessWidget {
  /// Creates a [GroupedText].
  const GroupedText({super.key, required this.text, this.color});

  /// Background color of the grouped text widget
  final Color? color;

  /// Text to display
  final Widget text;

  @override
  Widget build(BuildContext context) {
    return GroupedWidget(
      color: color,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 0.5 * TraleTheme.of(context)!.padding,
          horizontal: TraleTheme.of(context)!.padding,
        ),
        width: double.infinity,
        child: text,
      ),
    );
  }
}

/// A grouped switch list tile with a styled background.

class GroupedChip extends StatelessWidget {
  /// Creates a [GroupedChip].
  const GroupedChip({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.child,
    this.size = 56,
    this.color,
  });

  /// Whether the chip is currently selected.
  final bool selected;

  /// Called when the chip is tapped.
  final ValueChanged<bool> onSelected;

  /// Content displayed at the centre of the chip (typically a [Text]).
  final Widget child;

  /// Side length of the squared chip.
  final double size;

  /// Background colour when unselected.
  /// Defaults to [ColorScheme.surfaceContainer].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final TraleTheme theme = TraleTheme.of(context)!;
    final ColorScheme colors = Theme.of(context).colorScheme;

    // Use RoundedRectangleBorder for both states so Flutter can lerp
    // smoothly between inner border radius and a full circle.
    final RoundedRectangleBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
        selected ? size / 2 : theme.innerBorderRadius,
      ),
    );

    return SizedBox.square(
      dimension: size,
      child: AnimatedContainer(
        duration: theme.transitionDuration.normal,
        curve: Curves.easeInOutCubic,
        decoration: ShapeDecoration(
          color: selected ? colors.primary : (color ?? colors.surfaceContainer),
          shape: shape,
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: shape,
            onTap: () => onSelected(!selected),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
