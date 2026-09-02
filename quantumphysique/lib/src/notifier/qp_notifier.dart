import 'package:material_ui/material_ui.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:intl/intl.dart';
import 'package:quantumphysique/src/preferences/qp_preferences.dart';
import 'package:quantumphysique/src/types/contrast.dart';
import 'package:quantumphysique/src/types/date_format.dart';
import 'package:quantumphysique/src/types/first_day.dart';
import 'package:quantumphysique/src/types/language.dart';
import 'package:quantumphysique/src/types/scheme_variant.dart';
import 'package:quantumphysique/src/notifier/qp_theme_builder.dart';
import 'package:quantumphysique/src/theme/qp_system_colors.dart';
import 'package:quantumphysique/src/theme/qp_theme.dart';

part 'qp_theme_state.dart';
part 'qp_ui_state.dart';
part 'qp_reminder_state.dart';
part 'qp_display_state.dart';

/// Base ChangeNotifier for all quantumphysique-based apps.
///
/// Can be used directly — [seedColor] defaults to [QPCustomTheme.water].
/// Subclasses may override [seedColor] and [factoryReset] to add
/// app-specific behaviour (e.g. a user-selectable palette or database teardown).
class QPNotifier with ChangeNotifier {
  /// Constructor. Pass the app's [QPPreferences] subclass instance.
  QPNotifier(this.prefs);

  /// Triggers [notifyListeners].
  // ignore: unnecessary_getters_setters
  void get notify => notifyListeners();

  /// The underlying preferences instance.
  final QPPreferences prefs;

  QPSystemColors? _systemColors;

  /// Updates the colours reported by the operating system.
  ///
  /// Called from [QPApp] while it builds, so it must not notify listeners.
  void setSystemColors(QPSystemColors? colors) {
    _systemColors = colors;
  }

  /// The colours reported by the operating system, or `null` when the platform
  /// provides none (Android below 12).
  QPSystemColors? get systemColors => _systemColors;

  /// Whether system dynamic color is available (Android 12+, or a desktop
  /// platform that reports an accent colour).
  bool get systemColorsAvailable => _systemColors != null;

  /// The system accent color, falling back to [Colors.black].
  Color get systemSeedColor => _systemColors?.accentColor ?? Colors.black;

  /// The seed color for this app's palette.
  ///
  /// Reads the persisted [QPPreferences.themeName], resolving
  /// [QPCustomTheme.system] to [systemSeedColor] at runtime.
  /// Override if your app uses a different palette mechanism.
  Color get seedColor {
    final QPCustomTheme theme =
        prefs.themeName.toQPCustomTheme() ??
        prefs.defaultThemeName.toQPCustomTheme()!;
    return theme == QPCustomTheme.system ? systemSeedColor : theme.seed;
  }

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
