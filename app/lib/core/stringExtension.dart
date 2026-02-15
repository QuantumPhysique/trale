/// Inspired by Günter Zöchbauer
/// https://stackoverflow.com/a/29629114
extension CapExtension on String {
  /// capitalize first char
  String get inCaps =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';

  /// capitalize first char in each word
  String get allInCaps => replaceAll(
    RegExp(' +'),
    ' ',
  ).split(' ').map((String str) => str.inCaps).join(' ');
}
