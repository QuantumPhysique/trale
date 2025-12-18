import 'package:flutter/material.dart';
import 'package:trale/core/font.dart';
import 'package:trale/core/theme.dart';

/// A rounded section that groups a list of tiles and draws dividers between
/// theme.
class WidgetGroup extends StatelessWidget {
  const WidgetGroup({
    super.key,
    required this.children,
    this.title,
    this.titleStyle,
    this.direction = Axis.vertical,
  }) : itemBuilder = null,
       itemCount = null;

  const WidgetGroup.builder({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    this.title,
    this.titleStyle,
    this.direction = Axis.vertical,
  }) : children = const <Widget>[];

  /// List of GroupedWidgets to display in the group
  final List<Widget> children;

  /// Add a title above the grouped widgets
  final String? title;

  /// TextStyle for the title
  final TextStyle? titleStyle;

  /// Number of tiems for the builder
  final int? itemCount;

  /// Builder for GroupedWidgets
  final IndexedWidgetBuilder? itemBuilder;

  /// Vertical or horizontal layout
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    final double padding = TraleTheme.of(context)!.padding;
    final double gap = TraleTheme.of(context)!.space;

    final List<Widget> effectiveChildren = children.isNotEmpty
        ? children
        : List<Widget>.generate(
            itemCount ?? 0,
            (int i) => itemBuilder!(context, i),
          );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5 * padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (title != null)
            Padding(
              padding: EdgeInsets.only(
                top: 0.5 * padding,
                bottom: 0.5 * padding,
                left: 0.5 * padding,
              ),
              child: Text(
                title!,
                style:
                    titleStyle ??
                    Theme.of(
                      context,
                    ).textTheme.emphasized.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
          Card(
            margin: EdgeInsets.zero,
            color: Colors.transparent,
            shape: TraleTheme.of(context)!.borderShape,
            clipBehavior: Clip.antiAlias,
            child: Flex(
              spacing: gap,
              direction: direction,
              mainAxisSize: MainAxisSize.min,
              children: effectiveChildren,
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded tile with icon, title, subtitle and optional trailing widget.
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

class GroupedText extends StatelessWidget {
  const GroupedText({super.key, required this.text, this.color});

  /// Background color of the grouped text widget
  final Color? color;

  /// Text to display
  final Text text;

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

  final bool value;
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
