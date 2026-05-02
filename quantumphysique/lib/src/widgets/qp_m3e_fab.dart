import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// A Material 3 medium floating action button (80×80, corner radius 20).
///
/// Extracted from app code so it can be reused by any QP-based app.
class M3EFloatingActionButton extends StatelessWidget {
  /// Medium FAB: 80×80, icon size 34, corner radius 20.
  const M3EFloatingActionButton.medium({
    super.key,
    required this.onPressed,
    this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.enableFeedback = true,
  });

  /// Callback invoked when the button is tapped.
  final VoidCallback onPressed;

  /// Icon displayed in the button centre. Defaults to a plus icon.
  final Widget? icon;

  /// Optional tooltip text.
  final String? tooltip;

  /// Button background color. Defaults to [ColorScheme.primaryContainer].
  final Color? backgroundColor;

  /// Icon / foreground color. Defaults to [ColorScheme.onPrimaryContainer].
  final Color? foregroundColor;

  /// Elevation of the button surface.
  final double elevation;

  /// Whether to enable haptic / audio feedback.
  final bool enableFeedback;

  static const double _size = 80.0;
  static const double _iconSize = 34.0;
  static const double _borderRadius = 20.0;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color bg = backgroundColor ?? cs.primaryContainer;
    final Color fg = foregroundColor ?? cs.onPrimaryContainer;

    final Widget inkContent = SizedBox(
      width: _size,
      height: _size,
      child: Center(
        child:
            icon ?? Icon(PhosphorIconsRegular.plus, size: _iconSize, color: fg),
      ),
    );

    Widget tappable = InkWell(
      borderRadius: BorderRadius.circular(_borderRadius),
      onTap: onPressed,
      enableFeedback: enableFeedback,
      child: inkContent,
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      tappable = Tooltip(message: tooltip!, child: tappable);
    }

    return SizedBox(
      width: _size,
      height: _size,
      child: Material(
        color: bg,
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: tappable,
      ),
    );
  }
}
