part of 'tile_group.dart';

/// A [RadioListTile] wrapped in a [GroupedWidget].
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
  final Color? tileColor;
  final Color? selectedTileColor;
  final VisualDensity? visualDensity;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocusChange;
  final bool? enableFeedback;
  final double radioScaleFactor;
  final ListTileTitleAlignment? titleAlignment;
  final bool? enabled;
  final bool internalAddSemanticForOnTap;
  final WidgetStateProperty<Color?>? radioBackgroundColor;
  final BorderSide? radioSide;

  /// Background color of the grouped radio tile.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ShapeBorder fallbackShape = QPLayout.innerBorderShape;
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
  const GroupedText({super.key, required this.text, this.color});

  /// Background color of the grouped text widget.
  final Color? color;

  /// Text to display.
  final Widget text;

  @override
  Widget build(BuildContext context) {
    return GroupedWidget(
      color: color,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 0.5 * QPLayout.padding,
          horizontal: QPLayout.padding,
        ),
        width: double.infinity,
        child: text,
      ),
    );
  }
}

/// A squared selectable chip for use inside a horizontal [WidgetGroup].
///
/// Unselected: rounded-rectangle shape.
/// Selected: circle shape with the primary colour.
class GroupedChip extends StatelessWidget {
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

  /// Content displayed at the centre of the chip.
  final Widget child;

  /// Side length of the squared chip.
  final double size;

  /// Background colour when unselected.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final RoundedRectangleBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
        selected ? size / 2 : QPLayout.innerBorderRadius,
      ),
    );

    return SizedBox.square(
      dimension: size,
      child: AnimatedContainer(
        duration: QPLayout.transitionNormal,
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
