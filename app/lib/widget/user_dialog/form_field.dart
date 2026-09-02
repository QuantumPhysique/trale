part of '../user_dialog.dart';

class _GroupedFormFieldTile extends StatelessWidget {
  const _GroupedFormFieldTile({
    required this.color,
    required this.icon,
    required this.labelText,
    this.fieldKey,
    this.hintText,
    this.suffixText,
    this.initialValue,
    this.keyboardType,
    this.inputFormatters,
    this.readOnly = false,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
  });

  final Color color;
  final IconData icon;
  final String labelText;
  final Key? fieldKey;
  final String? hintText;
  final String? suffixText;
  final String? initialValue;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final ValueChanged<String>? onChanged;

  /// Called when the input is committed with the keyboard's done key.
  ///
  /// Deliberately wired to `onFieldSubmitted` rather than
  /// `onEditingComplete`: the latter *replaces* the default handler, which is
  /// what closes the keyboard, so a field that supplied it left the keyboard
  /// open with nothing happening on done.
  final VoidCallback? onSubmitted;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.titleSmall!
        .copyWith(color: Theme.of(context).colorScheme.onSurface);
    return QPGroupedListTile(
      color: color,
      dense: false,
      leading: PPIcon(icon, context),
      title: TextFormField(
        key: fieldKey,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        readOnly: readOnly,
        maxLines: 1,
        initialValue: initialValue,
        style: textStyle,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintStyle: textStyle,
          hintText: hintText,
          hintMaxLines: 2,
          suffixText: suffixText,
          labelText: labelText,
        ),
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted == null
            ? null
            : (String _) => onSubmitted!(),
        onTap: onTap,
      ),
      onTap: () {},
    );
  }
}
