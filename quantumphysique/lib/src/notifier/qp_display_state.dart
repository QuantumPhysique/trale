part of 'qp_notifier.dart';

/// Pads single-letter day and month fields of an ICU [pattern] to two digits.
/// Fields that are already padded (`dd`) or spell out the month (`MMM`) stay
/// as they are.
String _padDayAndMonth(String pattern) => pattern.replaceAllMapped(
  RegExp('d+|M+'),
  (Match match) => match[0]!.length == 1 ? match[0]! * 2 : match[0]!,
);

/// Extension on [QPNotifier] holding display / date-format state.
extension QPDisplayStateExtension on QPNotifier {
  /// Current first day of week preference.
  QPFirstDay get firstDay => prefs.firstDay;

  /// Sets the first day of week.
  set firstDay(QPFirstDay value) {
    if (value != firstDay) {
      prefs.firstDay = value;
      notify;
    }
  }

  /// Current date print format preference.
  QPDateFormat get datePrintFormat => prefs.datePrintFormat;

  /// Sets the date print format.
  set datePrintFormat(QPDateFormat value) {
    if (value != datePrintFormat) {
      prefs.datePrintFormat = value;
      notify;
    }
  }

  /// Returns a [DateFormat] for formatting full dates, respecting the active
  /// locale when [datePrintFormat] is [QPDateFormat.systemDefault].
  DateFormat dateFormat(BuildContext context) {
    if (datePrintFormat == QPDateFormat.systemDefault) {
      final Locale activeLocale = Localizations.localeOf(context);
      final Map<String, Map<String, String>>? patterns = dateTimePatternMap();
      if (patterns != null && patterns.containsKey(activeLocale.languageCode)) {
        final Map<String, String>? localeMap =
            patterns[activeLocale.languageCode];
        if (localeMap != null && localeMap.containsKey('yMd')) {
          return DateFormat(_padDayAndMonth(localeMap['yMd']!));
        }
      }
    } else {
      return datePrintFormat.dateFormat;
    }
    return DateFormat('dd/MM/yyyy');
  }

  /// Returns a [DateFormat] for formatting day/month, respecting the active
  /// locale when [datePrintFormat] is [QPDateFormat.systemDefault].
  DateFormat dayFormat(BuildContext context) {
    if (datePrintFormat == QPDateFormat.systemDefault) {
      final Locale activeLocale = Localizations.localeOf(context);
      final Map<String, Map<String, String>>? patterns = dateTimePatternMap();
      if (patterns != null && patterns.containsKey(activeLocale.languageCode)) {
        final Map<String, String>? localeMap =
            patterns[activeLocale.languageCode];
        if (localeMap != null && localeMap.containsKey('Md')) {
          return DateFormat(_padDayAndMonth(localeMap['Md']!));
        }
      }
    } else {
      return datePrintFormat.dayFormat;
    }
    return DateFormat('dd/MM');
  }
}
