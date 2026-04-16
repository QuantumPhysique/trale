part of '../user_dialog.dart';

/// A grouped set of user-detail input fields.
class UserDetailsGroup extends StatelessWidget {
  /// Creates a [UserDetailsGroup].
  const UserDetailsGroup({
    super.key,
    required this.notifier,
    required this.onRefresh,
    this.title,
    this.backgroundColor,
  });

  /// The notifier providing user settings.
  final TraleNotifier notifier;

  /// Callback invoked when a field changes.
  final VoidCallback onRefresh;

  /// Optional title displayed above the group.
  final String? title;

  /// Optional background color.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final Color tileColor =
        backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerLow;
    return WidgetGroup(
      title: title,
      children: <Widget>[
        _GroupedFormFieldTile(
          color: tileColor,
          icon: PhosphorIconsDuotone.user,
          keyboardType: TextInputType.name,
          hintText: context.l10n.addUserName,
          labelText: context.l10n.name.inCaps,
          initialValue: notifier.userName,
          onChanged: (String value) {
            notifier.userName = value;
          },
        ),
        _GroupedFormFieldTile(
          color: tileColor,
          icon: PhosphorIconsDuotone.arrowsVertical,
          fieldKey: ValueKey<Object>((
            notifier.heightUnit,
            notifier.userHeight,
          )),
          keyboardType: notifier.heightUnit == TraleUnitHeight.metric
              ? TextInputType.number
              : TextInputType.text,
          inputFormatters: notifier.heightUnit == TraleUnitHeight.metric
              ? <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^[1-9][0-9]*')),
                ]
              : <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'''[0-9'″" ]''')),
                ],
          hintText: notifier.heightUnit == TraleUnitHeight.imperial
              ? '5\'11"'
              : context.l10n.addHeight,
          suffixText: notifier.heightUnit.suffixText,
          labelText: context.l10n.height.inCaps,
          initialValue: notifier.userHeight != null
              ? notifier.heightUnit.heightToString(notifier.userHeight!)
              : null,
          onChanged: (String value) {
            final double? newHeight = notifier.heightUnit.parseHeight(value);
            if (newHeight != null) {
              notifier.userHeight = newHeight;
            }
          },
          onEditingComplete: () {
            onRefresh();
          },
        ),
      ],
    );
  }
}
