import 'package:flutter/foundation.dart';
import 'package:quantumphysique/src/theme/qp_theme.dart';
import 'package:quantumphysique/src/types/contrast.dart';
import 'package:quantumphysique/src/types/date_format.dart';
import 'package:quantumphysique/src/types/first_day.dart';
import 'package:quantumphysique/src/types/language.dart';
import 'package:quantumphysique/src/types/scheme_variant.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'qp_theme_prefs.dart';
part 'qp_ui_prefs.dart';
part 'qp_reminder_prefs.dart';
part 'qp_display_prefs.dart';

/// Base preferences class for quantumphysique-owned settings.
///
/// Subclasses must provide [defaultThemeName]. Apps extend this class and add
/// their own app-specific preference properties.
abstract class QPPreferences {
  /// Protected base constructor. Call via `super.base()` from subclass
  /// named constructors (e.g. `MyPrefs._internal() : super.base()`).
  @protected
  QPPreferences.base() {
    _loaded = loadPreferences();
  }

  /// Constructor for testing with a pre-configured [SharedPreferences].
  @visibleForTesting
  QPPreferences.forTesting(this.prefs) {
    loadDefaultSettings();
  }

  /// Protected constructor for subclasses to use in their own testing
  /// constructors, avoiding the `@visibleForTesting` restriction on
  /// [QPPreferences.forTesting] when called from non-test files.
  @protected
  QPPreferences.baseForTesting(this.prefs) {
    loadDefaultSettings();
  }

  /// Future that completes when preferences have been loaded from disk.
  Future<void>? get loaded => _loaded;
  Future<void>? _loaded;

  /// The backing [SharedPreferences] instance.
  late SharedPreferences prefs;

  // ---------------------------------------------------------------------------
  // Default values
  // ---------------------------------------------------------------------------

  /// Default night mode. One of `'auto'`, `'light'`, `'dark'`.
  final String defaultNightMode = 'auto';

  /// Default for AMOLED pure-black mode.
  final bool defaultIsAmoled = false;

  /// Default language (system default).
  final QPLanguage defaultLanguage = QPLanguage.system();

  /// Default scheme variant.
  final String defaultSchemeVariant = QPSchemeVariant.material.name;

  /// Default contrast level.
  final QPContrast defaultContrastLevel = QPContrast.normal;

  /// Default show-onboarding flag.
  final bool defaultShowOnboarding = true;

  /// Default show-changelog flag.
  final bool defaultShowChangelog = true;

  /// Default last-seen build number.
  final int defaultLastBuildNumber = 0;

  /// Default reminder-enabled flag.
  final bool defaultReminderEnabled = false;

  /// Default reminder days (empty list = none selected).
  final List<int> defaultReminderDays = const <int>[];

  /// Default reminder hour.
  final int defaultReminderHour = 8;

  /// Default reminder minute.
  final int defaultReminderMinute = 0;

  /// Default first day of week.
  final QPFirstDay defaultFirstDay = QPFirstDay.Default;

  /// Default date format.
  final QPDateFormat defaultDatePrintFormat = QPDateFormat.systemDefault;

  /// Default theme name used during [loadDefaultSettings].
  ///
  /// Override in subclasses to change the palette that is persisted on first
  /// run. Defaults to [QPCustomTheme.water].
  String get defaultThemeName => QPCustomTheme.water.name;

  // ---------------------------------------------------------------------------
  // Load / reset
  // ---------------------------------------------------------------------------

  /// Loads preferences from disk and applies defaults for missing keys.
  Future<void> loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
    await _migrateFromLegacyKeys(prefs);
    loadDefaultSettings();
  }

  /// Writes defaults for any QP key that has no stored value.
  ///
  /// Pass [override] = `true` to reset every QP key to its default.
  ///
  /// Each module's defaults are applied by a dedicated private helper defined
  /// in its own part file: [_loadThemeDefaults], [_loadUiDefaults],
  /// [_loadReminderDefaults], and [_loadDisplayDefaults].
  void loadDefaultSettings({bool override = false}) {
    _loadThemeDefaults(override: override);
    _loadUiDefaults(override: override);
    _loadReminderDefaults(override: override);
    _loadDisplayDefaults(override: override);
  }

  /// Resets all QP settings to their default values.
  void resetSettings() => loadDefaultSettings(override: true);

  // ---------------------------------------------------------------------------
  // Legacy key migration (Issue 21)
  // ---------------------------------------------------------------------------

  static const Map<String, String> _legacyMap = <String, String>{
    'nightMode': 'qp_nightMode',
    'isAmoled': 'qp_isAmoled',
    'language': 'qp_language',
    'theme': 'qp_theme',
    'schemeVariant': 'qp_schemeVariant',
    'contrastLevel': 'qp_contrastLevel',
    'showOnBoarding': 'qp_showOnBoarding',
    'showChangelog': 'qp_showChangelog',
    'lastBuildNumber': 'qp_lastBuildNumber',
    'reminderEnabled': 'qp_reminderEnabled',
    'reminderDays': 'qp_reminderDays',
    'reminderHour': 'qp_reminderHour',
    'reminderMinute': 'qp_reminderMinute',
    'firstDay': 'qp_firstDay',
    'dateFormat': 'qp_dateFormat',
  };

  /// Copies values from old (un-prefixed) keys to `qp_*` keys for users
  /// upgrading from trale versions that predate this package split.
  ///
  /// Old keys are left intact (non-destructive). Only copies when the old key
  /// exists and the new key does not, so this is safe to call repeatedly.
  Future<void> _migrateFromLegacyKeys(SharedPreferences sp) async {
    await _runMigration(sp);
  }

  /// Exposed for testing only. Runs the legacy-key migration on [sp].
  @visibleForTesting
  static Future<void> migrateForTesting(SharedPreferences sp) =>
      _runMigration(sp);

  static Future<void> _runMigration(SharedPreferences sp) async {
    for (final MapEntry<String, String> e in _legacyMap.entries) {
      if (sp.containsKey(e.key) && !sp.containsKey(e.value)) {
        final Object? v = sp.get(e.key);
        if (v is String) await sp.setString(e.value, v);
        if (v is bool) await sp.setBool(e.value, v);
        if (v is int) await sp.setInt(e.value, v);
        if (v is double) await sp.setDouble(e.value, v);
      }
    }
  }
}
