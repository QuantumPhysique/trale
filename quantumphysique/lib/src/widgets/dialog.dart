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
  });

  /// Body widget displayed in the dialog's content area.
  final Widget content;

  /// Action widgets displayed in the dialog's actions row.
  final List<Widget> actions;

  /// Plain title string rendered as a centered headline.
  final String title;

  @override
  Widget build(BuildContext context) {
    const double pad = QPLayout.padding;
    return AlertDialog(
      titlePadding: const EdgeInsets.all(pad),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: pad,
        vertical: pad,
      ),
      actionsPadding: EdgeInsets.symmetric(horizontal: pad, vertical: pad - 4),
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
