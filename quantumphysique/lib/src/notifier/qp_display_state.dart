part of 'qp_notifier.dart';

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
          return DateFormat(
            localeMap['yMd']!.replaceFirst('d', 'dd').replaceFirst('M', 'MM'),
          );
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
          return DateFormat(
            localeMap['Md']!.replaceFirst('d', 'dd').replaceFirst('M', 'MM'),
          );
        }
      }
    } else {
      return datePrintFormat.dayFormat;
    }
    return DateFormat('dd/MM');
  }
}
