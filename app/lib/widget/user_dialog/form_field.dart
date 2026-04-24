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
    this.onEditingComplete,
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
  final VoidCallback? onEditingComplete;
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
        onEditingComplete: onEditingComplete,
        onTap: onTap,
      ),
      onTap: () {},
    );
  }
}
