/// String capitalization helpers.
extension QPCapExtension on String {
  /// Capitalizes the first character.
  String get inCaps =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';

  /// Capitalizes the first character of each word.
  String get allInCaps => replaceAll(
    RegExp(' +'),
    ' ',
  ).split(' ').map((String s) => s.inCaps).join(' ');
}
