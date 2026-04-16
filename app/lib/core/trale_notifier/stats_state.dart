part of '../trale_notifier.dart';

/// Extension on [TraleNotifier] holding stats and date-format state.
extension StatsStateExtension on TraleNotifier {
  /// getter
  DateFormat dateFormat(BuildContext context) {
    if (datePrintFormat == TraleDatePrintFormat.systemDefault) {
      final Locale activeLocale = Localizations.localeOf(context);
      if (dateTimePatternMap().containsKey(activeLocale.languageCode)) {
        final Map<String, String> dateTimeLocaleMap =
            dateTimePatternMap()[activeLocale.languageCode]!;
        if (dateTimeLocaleMap.containsKey('yMd')) {
          return DateFormat(
            dateTimeLocaleMap['yMd']!
                .replaceFirst('d', 'dd')
                .replaceFirst('M', 'MM'),
          );
        }
      }
    } else {
      return datePrintFormat.dateFormat;
    }
    return DateFormat('dd/MM/yyyy');
  }

  /// getter
  DateFormat dayFormat(BuildContext context) {
    if (datePrintFormat == TraleDatePrintFormat.systemDefault) {
      final Locale activeLocale = Localizations.localeOf(context);
      if (dateTimePatternMap().containsKey(activeLocale.languageCode)) {
        final Map<String, String> dateTimeLocaleMap =
            dateTimePatternMap()[activeLocale.languageCode]!;
        if (dateTimeLocaleMap.containsKey('Md')) {
          return DateFormat(
            dateTimeLocaleMap['Md']!
                .replaceFirst('d', 'dd')
                .replaceFirst('M', 'MM'),
          );
        }
      }
    } else {
      return datePrintFormat.dayFormat;
    }
    return DateFormat('dd/MM');
  }

  /// getter
  TraleDatePrintFormat get datePrintFormat => prefs.datePrintFormat;

  /// setter
  set datePrintFormat(TraleDatePrintFormat newDatePrintFormat) {
    if (datePrintFormat != newDatePrintFormat) {
      prefs.datePrintFormat = newDatePrintFormat;
      notify;
    }
  }

  /// getter for stats range from date used for StatsRange.custom
  DateTime? get statsRangeFrom => prefs.statsRangeFrom;

  /// setter for stats range from date used for StatsRange.custom
  set statsRangeFrom(DateTime? newDate) {
    if (statsRangeFrom != newDate) {
      prefs.statsRangeFrom = newDate;
      MeasurementStats().reinit();
      notify;
    }
  }

  /// getter for stats range to date used for StatsRange.custom
  DateTime? get statsRangeTo => prefs.statsRangeTo;

  /// setter for stats range to date used for StatsRange.custom
  set statsRangeTo(DateTime? newDate) {
    if (statsRangeTo != newDate) {
      prefs.statsRangeTo = newDate;
      MeasurementStats().reinit();
      notify;
    }
  }

  /// getter for stats range mode
  StatsRange get statsRange => prefs.statsRange;

  /// setter for stats range mode
  set statsRange(StatsRange newRange) {
    if (statsRange != newRange) {
      prefs.statsRange = newRange;
      MeasurementStats().reinit();
      notify;
    }
  }

  /// getter for stats use interpolation
  bool get statsUseInterpolation => prefs.statsUseInterpolation;

  /// setter for stats use interpolation
  set statsUseInterpolation(bool useInterpolation) {
    if (statsUseInterpolation != useInterpolation) {
      prefs.statsUseInterpolation = useInterpolation;
      MeasurementStats().reinit();
      notify;
    }
  }
}
