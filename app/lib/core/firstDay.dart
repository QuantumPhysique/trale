/// Enum representing the first day of the week
enum TraleFirstDay {
  /// Sunday as the first day of the week
  sunday,

  /// Monday as the first day of the week
  monday,

  /// Saturday as the first day of the week
  saturday,
}

/// Extension for additional properties and methods for TraleFirstDay
extension TraleFirstDayExtension on TraleFirstDay {
  /// Mapping of TraleFirstDay values to DateTime weekday values
  static const _weekdayMapping = <TraleFirstDay, int>{
    TraleFirstDay.sunday: 0,
    TraleFirstDay.monday: 1,
    TraleFirstDay.saturday: 6,
  };

  /// Mapping of TraleFirstDay values to their localized names
  static const _localizedNames = <TraleFirstDay, String>{
    TraleFirstDay.sunday: 'Sunday',
    TraleFirstDay.monday: 'Monday',
    TraleFirstDay.saturday: 'Saturday',
  };

  /// Converts the enum to a DateTime weekday value (Monday = 1, Sunday = 7)
  int get asDateTimeWeekday => _weekdayMapping[this]!;

  /// Gets the localized name for the enum
  String get localizedName => _localizedNames[this]!;

  /// Default first day (Sunday)
  static TraleFirstDay get defaultDay => TraleFirstDay.sunday;

  /// Converts DateTime weekday to TraleFirstDay enum (defaults to Sunday if not found)
  static TraleFirstDay fromDateTimeWeekday(int weekday) =>
      _weekdayMapping.entries
          .firstWhere(
            (entry) => entry.value == weekday,
            orElse: () => MapEntry(TraleFirstDay.sunday, DateTime.sunday),
          )
          .key;
}

/// Extension for string parsing to convert a string to TraleFirstDay
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
