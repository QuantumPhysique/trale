/// First-day-of-week preference for QP apps.
library;

import 'package:intl/date_symbols.dart';
import 'package:intl/intl.dart';

/// The user-selectable first day of the week.
enum QPFirstDay {
  /// Default: derived from the active locale.
  // ignore: constant_identifier_names
  Default,

  /// Monday.
  monday,

  /// Tuesday.
  tuesday,

  /// Saturday.
  saturday,

  /// Sunday.
  sunday,
}

/// Utility methods for [QPFirstDay].
extension QPFirstDayExtension on QPFirstDay {
  // Cache of localized weekday names keyed by locale string.
  static final Map<String, Map<QPFirstDay, String>> _localizedNamesCache =
      <String, Map<QPFirstDay, String>>{};

  /// Mapping of [QPFirstDay] values to [DateTime] weekday integers
  /// (Monday = 1, Sunday = 7).
  static const Map<QPFirstDay, int?> _weekdayMapping = <QPFirstDay, int?>{
    QPFirstDay.Default: null,
    QPFirstDay.sunday: DateTime.sunday,
    QPFirstDay.monday: DateTime.monday,
    QPFirstDay.tuesday: DateTime.tuesday,
    QPFirstDay.saturday: DateTime.saturday,
  };

  /// Converts this value to the corresponding [DateTime] weekday integer
  /// (Monday = 1, Sunday = 7), or `null` for [QPFirstDay.Default].
  int? get asDateTimeWeekday => _weekdayMapping[this];

  /// Loads and caches the localized weekday names for [locale].
  static Future<void> loadLocalizedNames(String locale) async {
    if (_localizedNamesCache.containsKey(locale)) {
      return;
    }
    final DateSymbols dateSymbols = DateFormat('EEEE', locale).dateSymbols;
    final List<String> standaloneWeekdays = dateSymbols.STANDALONEWEEKDAYS;
    _localizedNamesCache[locale] = <QPFirstDay, String>{
      QPFirstDay.sunday: standaloneWeekdays[0],
      QPFirstDay.monday: standaloneWeekdays[1],
      QPFirstDay.tuesday: standaloneWeekdays[2],
      QPFirstDay.saturday: standaloneWeekdays[6],
    };
  }

  /// Returns the localized name for this day in the given [locale]
  /// (after [loadLocalizedNames] has been called).
  static String getLocalizedName(QPFirstDay day, String locale) =>
      _localizedNamesCache[locale]?[day] ?? 'Default';

  /// Returns the [QPFirstDay] matching the given [DateTime] weekday integer.
  static QPFirstDay fromDateTimeWeekday(int weekday) => _weekdayMapping.entries
      .firstWhere(
        (MapEntry<QPFirstDay, int?> e) => e.value == weekday,
        orElse: () => const MapEntry<QPFirstDay, int?>(
          QPFirstDay.sunday,
          DateTime.sunday,
        ),
      )
      .key;

  /// Serialization name (enum value name).
  String get name => toString().split('.').last;
}

/// Parse a [String] to [QPFirstDay].
extension QPFirstDayParsing on String {
  /// Returns the matching [QPFirstDay], or `null` if not found.
  QPFirstDay? toQPFirstDay() {
    for (final QPFirstDay day in QPFirstDay.values) {
      if (this == day.name) {
        return day;
      }
    }
    return null;
  }
}
