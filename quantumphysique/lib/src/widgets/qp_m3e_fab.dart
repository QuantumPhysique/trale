import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// A Material 3 floating action button that supports both a compact (icon-only)
/// state and an extended (icon + label) pill state.
///
/// Use [M3EFloatingActionButton.medium] for a static 80×80 compact FAB.
/// Use [M3EFloatingActionButton.extended] for a FAB that starts fully expanded
/// with a visible label and collapses to the compact form while the user scrolls
/// down, then re-expands on scroll-up.
class M3EFloatingActionButton extends StatefulWidget {
  /// Medium FAB: 80×80, icon size 34, corner radius 20. Icon-only.
  const M3EFloatingActionButton.medium({
    super.key,
    required this.onPressed,
    this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.enableFeedback = true,
  }) : label = null,
       scrollController = null;

  /// Extended pill-shaped FAB. Starts showing [label] next to [icon] and
  /// collapses to the compact 80×80 form while the user scrolls down (using
  /// [scrollController]). Expands again on scroll-up.
  const M3EFloatingActionButton.extended({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.enableFeedback = true,
    this.scrollController,
  });

  /// Callback invoked when the button is tapped.
  final VoidCallback onPressed;

  /// Icon displayed in the button centre. Defaults to a plus icon.
  final Widget? icon;

  /// Optional tooltip text.
  final String? tooltip;

  /// Button background colour. Defaults to [ColorScheme.primaryContainer].
  final Color? backgroundColor;

  /// Icon / foreground colour. Defaults to [ColorScheme.onPrimaryContainer].
  final Color? foregroundColor;

  /// Elevation of the button surface.
  final double elevation;

  /// Whether to enable haptic / audio feedback.
  final bool enableFeedback;

  /// Text widget shown in the extended state. `null` for the [medium] variant.
  final Widget? label;

  /// Drives the collapse / expand animation. When the user scrolls down the
  /// FAB collapses; scrolling up expands it again. Has no effect for [medium].
  final ScrollController? scrollController;

  @override
  State<M3EFloatingActionButton> createState() =>
      _M3EFloatingActionButtonState();
}

class _M3EFloatingActionButtonState extends State<M3EFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curved;
  late final CurvedAnimation _labelFade;

  // ── geometry ──────────────────────────────────────────────────────────────
  static const double _size = 80.0;
  static const double _iconSize = 34.0;
  static const double _compactRadius = 20.0;
  static const double _compactPadH = (_size - _iconSize) / 2; // 23 dp
  static const double _extendedPadH = 28.0;
  static const double _labelSpacing = 12.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      // Start fully extended when a label is present.
      value: widget.label != null ? 1.0 : 0.0,
    );
    _curved = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    // Fade the label over the first 60 % of the animation so text disappears
    // before the pill becomes too narrow to contain it.
    _labelFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    );
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(M3EFloatingActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_onScroll);
      widget.scrollController?.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    _labelFade.dispose();
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    switch (widget.scrollController!.position.userScrollDirection) {
      case ScrollDirection
          .reverse: // finger up → content scrolls down → collapse
        _controller.reverse();
      case ScrollDirection.forward: // finger down → content scrolls up → expand
        _controller.forward();
      case ScrollDirection.idle:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color bg = widget.backgroundColor ?? cs.primaryContainer;
    final Color fg = widget.foregroundColor ?? cs.onPrimaryContainer;
    final Widget iconWidget =
        widget.icon ??
        Icon(PhosphorIconsRegular.plus, size: _iconSize, color: fg);

    if (widget.label == null) {
      return _buildStaticMedium(bg, fg, iconWidget);
    }

    return AnimatedBuilder(
      animation: _curved,
      builder: (BuildContext context, Widget? _) {
        final double t = _curved.value;
        const double radius = _compactRadius;
        final double padH = _compactPadH + (_extendedPadH - _compactPadH) * t;

        Widget tappable = InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: widget.onPressed,
          enableFeedback: widget.enableFeedback,
          child: SizedBox(
            height: _size,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padH),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: _iconSize,
                    height: _iconSize,
                    child: Center(child: iconWidget),
                  ),
                  SizeTransition(
                    axis: Axis.horizontal,
                    sizeFactor: _curved,
                    alignment: AlignmentDirectional.centerStart,
                    child: FadeTransition(
                      opacity: _labelFade,
                      child: SizedBox(
                        height: _size,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const SizedBox(width: _labelSpacing),
                            DefaultTextStyle.merge(
                              style: Theme.of(
                                context,
                              ).textTheme.labelLarge!.copyWith(color: fg),
                              child: widget.label!,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        if (widget.tooltip != null && widget.tooltip!.isNotEmpty) {
          tappable = Tooltip(message: widget.tooltip!, child: tappable);
        }

        return Material(
          color: bg,
          elevation: widget.elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          clipBehavior: Clip.antiAlias,
          child: tappable,
        );
      },
    );
  }

  Widget _buildStaticMedium(Color bg, Color fg, Widget iconWidget) {
    Widget tappable = InkWell(
      borderRadius: BorderRadius.circular(_compactRadius),
      onTap: widget.onPressed,
      enableFeedback: widget.enableFeedback,
      child: SizedBox(
        width: _size,
        height: _size,
        child: Center(child: iconWidget),
      ),
    );

    if (widget.tooltip != null && widget.tooltip!.isNotEmpty) {
      tappable = Tooltip(message: widget.tooltip!, child: tappable);
    }

    return SizedBox(
      width: _size,
      height: _size,
      child: Material(
        color: bg,
        elevation: widget.elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_compactRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: tappable,
      ),
    );
  }
}
