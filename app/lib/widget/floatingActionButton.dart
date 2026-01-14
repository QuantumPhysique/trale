import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:trale/core/theme.dart';
import 'package:trale/l10n-gen/app_localizations.dart';

/// m3 floating action button
class FAB extends StatefulWidget {
  const FAB({required this.show, required this.onPressed, super.key});

  /// show FAB
  final bool show;

  /// onPressed
  final void Function() onPressed;

  @override
  State<FAB> createState() => _FABState();
}

class _FABState extends State<FAB> {
  @override
  Widget build(BuildContext context) {
    const double buttonHeight = 80;

    /// The new m3e size for a medium FAB
    return AnimatedContainer(
      alignment: Alignment.center,
      height: widget.show ? buttonHeight : 0,
      width: buttonHeight,
      duration: TraleTheme.of(context)!.transitionDuration.normal,
      child: M3EFloatingActionButton.medium(
        elevation: 0,
        onPressed: widget.onPressed,
        tooltip: AppLocalizations.of(context)!.addWeight,
      ),
    );
  }
}

/// Material3-style FloatingActionButton with a `.medium` constructor.
class M3EFloatingActionButton extends StatelessWidget {
  /// Medium FAB: 80x80, icon size 28, corner radius 20.
  const M3EFloatingActionButton.medium({
    super.key,
    required this.onPressed,
    this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.enableFeedback = true,
  }) : _size = 80.0,
       _iconSize = 34.0, // 28 is material spec, but icon has unwanted padding
       _borderRadius = 20.0;

  final VoidCallback onPressed;
  final Widget? icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool enableFeedback;

  final double _size;
  final double _iconSize;
  final double _borderRadius;

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
