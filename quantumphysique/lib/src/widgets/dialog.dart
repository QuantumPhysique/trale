import 'package:flutter/material.dart';
import 'package:quantumphysique/src/types/font.dart';
import 'package:quantumphysique/src/widgets/qp_layout.dart';

/// A Material 3–styled wrapper around [AlertDialog] used across QP apps.
class QPDialog extends StatelessWidget {
  /// Creates a M3 dialog with a centered [title], custom [content],
  /// and [actions] laid out with spaceBetween.
  const QPDialog({
    super.key,
    required this.content,
    required this.actions,
    required this.title,
    this.contentPadding,
    this.actionsPadding,
  });

  /// Body widget displayed in the dialog's content area.
  final Widget content;

  /// Action widgets displayed in the dialog's actions row.
  final List<Widget> actions;

  /// Plain title string rendered as a centered headline.
  final String title;

  /// Overrides the default padding around [content].
  final EdgeInsets? contentPadding;

  /// Overrides the default padding around [actions].
  final EdgeInsets? actionsPadding;

  @override
  Widget build(BuildContext context) {
    const double pad = QPLayout.padding;
    return AlertDialog(
      titlePadding: const EdgeInsets.all(pad),
      contentPadding:
          contentPadding ??
          const EdgeInsets.symmetric(horizontal: pad, vertical: pad),
      actionsPadding:
          actionsPadding ??
          const EdgeInsets.symmetric(
            horizontal: pad,
            // The action buttons carry their own touch-target inset, so the
            // dialog gives back half a [QPLayout.smallPadding] of its own.
            vertical: pad - QPLayout.smallPadding / 2,
          ),
      actionsAlignment: actions.length == 1
          ? MainAxisAlignment.end
          : MainAxisAlignment.spaceBetween,
      title: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.emphasized.headlineSmall!.apply(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          maxLines: 1,
        ),
      ),
      content: content,
      actions: actions,
    );
  }
}

/// A standardised dialog action button for [QPDialog].
///
/// Encapsulates three visual variants:
/// - **Default** (dismiss / cancel): `surfaceContainerLow` bg.
/// - **Primary** (save / confirm): `primary` bg.
/// - **Destructive** (delete): `errorContainer` bg.
///
/// Rendered as a [FilledButton.icon] matching the original default button style
/// (preserving padding and shapes) to maintain visual consistency.
class QPDialogAction extends StatelessWidget {
  /// Creates a dialog action button.
  const QPDialogAction({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isPrimary = false,
    this.isDestructive = false,
  });

  /// Callback when the button is pressed; `null` disables the button.
  final VoidCallback? onPressed;

  /// Leading icon displayed before the [label].
  final IconData icon;

  /// Text label for the button.
  final String label;

  /// When `true`, uses `primary` / `onPrimary`.
  final bool isPrimary;

  /// When `true`, uses `errorContainer` / `onErrorContainer`.
  /// Takes precedence over [isPrimary].
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    final Color bg;
    final Color fg;
    if (isDestructive) {
      bg = cs.errorContainer;
      fg = cs.onErrorContainer;
    } else if (isPrimary) {
      bg = cs.primary;
      fg = cs.onPrimary;
    } else {
      bg = cs.surfaceContainerLow;
      fg = cs.onSurface;
    }

    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(backgroundColor: bg, foregroundColor: fg),
      icon: Icon(icon, size: 18),
      label: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
    );
  }
}
