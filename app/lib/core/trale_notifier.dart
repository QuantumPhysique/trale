import 'package:flutter/material.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:intl/intl.dart';
import 'package:trale/core/backup_interval.dart';
import 'package:trale/core/contrast.dart';
import 'package:trale/core/first_day.dart';
import 'package:trale/core/interpolation.dart';
import 'package:trale/core/language.dart';
import 'package:trale/core/measurement_database.dart';
import 'package:trale/core/measurement_interpolation.dart';
import 'package:trale/core/measurement_stats.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/print_format.dart';
import 'package:trale/core/stats_range.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/unit_precision.dart';
import 'package:trale/core/units.dart';
import 'package:trale/core/zoom_level.dart';

part 'trale_notifier/theme_state.dart';
part 'trale_notifier/user_state.dart';
part 'trale_notifier/stats_state.dart';
part 'trale_notifier/backup_state.dart';
part 'trale_notifier/reminder_state.dart';
part 'trale_notifier/ui_state.dart';

/// Class to dynamically change themeMode, isAmoled and language within app
class TraleNotifier with ChangeNotifier {
  /// empty constructor, in main.dart load preferences is called first.
  TraleNotifier();

  /// call notifier
  void get notify => notifyListeners();

  /// shared preferences instance
  final Preferences prefs = Preferences();

  ColorScheme? _systemLightDynamic;
  ColorScheme? _systemDarkDynamic;

  /// The system seed color if available, otherwise black.
  Color get systemSeedColor =>
      systemColorsAvailable ? _systemLightDynamic!.primary : Colors.black;

  /// set system color accent
  void setColorScheme(ColorScheme? systemLight, ColorScheme? systemDark) {
    _systemDarkDynamic = systemDark;
    _systemLightDynamic = systemLight;
  }

  /// If system accent color is available (Android OS 12+)
  bool get systemColorsAvailable =>
      _systemDarkDynamic != null && _systemLightDynamic != null;

  /// get locale
  Locale? get locale => language.compareTo(Language.system())
      ? null // defaults to systems default
      : language.locale;

  /// factory reset
  Future<void> factoryReset() async {
    prefs.resetSettings();
    await MeasurementDatabase().deleteAllMeasurements();
    notifyListeners();
  }
}
