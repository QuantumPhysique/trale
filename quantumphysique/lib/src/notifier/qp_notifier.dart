import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:intl/intl.dart';
import 'package:quantumphysique/src/preferences/qp_preferences.dart';
import 'package:quantumphysique/src/types/contrast.dart';
import 'package:quantumphysique/src/types/date_format.dart';
import 'package:quantumphysique/src/types/first_day.dart';
import 'package:quantumphysique/src/types/language.dart';
import 'package:quantumphysique/src/types/scheme_variant.dart';
import 'package:quantumphysique/src/notifier/qp_theme_builder.dart';

part 'qp_theme_state.dart';
part 'qp_ui_state.dart';
part 'qp_reminder_state.dart';
part 'qp_display_state.dart';

/// Base ChangeNotifier for all quantumphysique-based apps.
///
/// Subclasses must implement [seedColor]. They may override [factoryReset] to
/// add app-specific teardown (e.g. clearing a local database).
abstract class QPNotifier with ChangeNotifier {
  /// Constructor. Pass the app's [QPPreferences] subclass instance.
  QPNotifier(this.prefs);

  /// Triggers [notifyListeners].
  // ignore: unnecessary_getters_setters
  void get notify => notifyListeners();

  /// The underlying preferences instance.
  final QPPreferences prefs;

  ColorScheme? _systemLightDynamic;
  ColorScheme? _systemDarkDynamic;

  /// Updates the system dynamic color schemes (Android 12+).
  void setColorScheme(ColorScheme? light, ColorScheme? dark) {
    _systemLightDynamic = light;
    _systemDarkDynamic = dark;
  }

  /// Whether system dynamic color is available (Android 12+).
  bool get systemColorsAvailable =>
      _systemLightDynamic != null && _systemDarkDynamic != null;

  /// The primary system seed color, falling back to [Colors.black].
  Color get systemSeedColor =>
      systemColorsAvailable ? _systemLightDynamic!.primary : Colors.black;

  /// The seed color for this app's palette.
  ///
  /// Override to return the current palette's seed colour, potentially
  /// incorporating [systemSeedColor] for the "system" palette entry.
  Color get seedColor;

  /// The locale to use for the app, or `null` for the system default.
  Locale? get locale =>
      language.compareTo(QPLanguage.system()) ? null : language.locale;

  /// Resets all QP settings to their defaults and notifies listeners.
  ///
  /// Subclasses that override this should call `super.factoryReset()`.
  Future<void> factoryReset() async {
    prefs.resetSettings();
    notifyListeners();
  }
}
