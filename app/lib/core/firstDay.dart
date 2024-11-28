import 'package:intl/intl.dart';

/// Enum representing the first day of the week
enum TraleFirstDay {
  /// Default: locale-based
  Default,

  /// Sunday as the first day of the week
  sunday,

  /// Monday as the first day of the week
  monday,

  /// Tuesday as the first day of the week
  tuesday,

  /// Saturday as the first day of the week
  saturday,
}

extension TraleFirstDayExtension on TraleFirstDay {
  // Caching the localized names
  static final Map<String, Map<TraleFirstDay, String>> _localizedNamesCache =
      {};

  /// Mapping of TraleFirstDay values to DateTime weekday values (Monday = 1, Sunday = 7)
  static const Map<TraleFirstDay, int?> _weekdayMapping = {
    TraleFirstDay.Default: null, // No specific weekday for Default
    TraleFirstDay.sunday: DateTime.sunday,
    TraleFirstDay.monday: DateTime.monday,
    TraleFirstDay.tuesday: DateTime.tuesday,
    TraleFirstDay.saturday: DateTime.saturday,
  };

  /// Converts the enum to a DateTime weekday value (Monday = 1, Sunday = 7)
  int? get asDateTimeWeekday {
    return _weekdayMapping[this];
  }

  /// Load and store the localized names of weekdays for a specific locale
  static Future<void> loadLocalizedNames(String locale) async {
    if (_localizedNamesCache.containsKey(locale)) return;

    final dateSymbols = await DateFormat('EEEE', locale).dateSymbols;
    final standaloneWeekdays = dateSymbols.STANDALONEWEEKDAYS;

    _localizedNamesCache[locale] = {
      TraleFirstDay.sunday: standaloneWeekdays[0],
      TraleFirstDay.monday: standaloneWeekdays[1],
      TraleFirstDay.tuesday: standaloneWeekdays[2],
      TraleFirstDay.saturday: standaloneWeekdays[6],
    };
  }

  /// Get the localized name for the enum (after it's loaded)
  static String getLocalizedName(TraleFirstDay day, String locale) {
    return _localizedNamesCache[locale]?[day] ?? 'Default';
  }

  /// Converts DateTime weekday to TraleFirstDay enum
  static TraleFirstDay fromDateTimeWeekday(int weekday) =>
      _weekdayMapping.entries
          .firstWhere(
            (entry) => entry.value == weekday,
            orElse: () => MapEntry(TraleFirstDay.sunday, DateTime.sunday),
          )
          .key;
}

extension TraleFirstDayParsing on String {
  /// Convert string to TraleFirstDay enum
  TraleFirstDay? toTraleFirstDay() {
    for (final TraleFirstDay day in TraleFirstDay.values) {
      if (this == day.name) {
        return day;
      }
    }
    return null;
  }
}
