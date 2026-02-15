import 'package:flutter/material.dart';
import 'package:trale/core/font.dart';
import 'package:trale/core/theme.dart';

/// A Material 3–styled wrapper around [AlertDialog] used across Trale.
///
/// DialogM3E centralizes dialog paddings and title styling using [TraleTheme]
/// and the current [Theme]. It:
/// - Applies consistent paddings for title, content, and actions
/// - Centers the title using [TextTheme.headlineSmall]
/// - Aligns actions with [MainAxisAlignment.spaceBetween]
///
/// Provide the dialog [content], [actions], and [title] via the constructor.
class DialogM3E extends StatelessWidget {
  /// Creates a M3 dialog with a centered [title], custom [content],
  /// and [actions] laid out with spaceBetween.
  const DialogM3E({
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
    return AlertDialog(
      titlePadding: EdgeInsets.all(TraleTheme.of(context)!.padding),
      contentPadding: EdgeInsets.symmetric(
        horizontal: TraleTheme.of(context)!.padding,
        vertical: TraleTheme.of(context)!.padding,
      ),
      actionsPadding: EdgeInsets.symmetric(
        horizontal: TraleTheme.of(context)!.padding,

        /// todo: why -4? Find reason and fix properly
        vertical: TraleTheme.of(context)!.padding - 4,
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
