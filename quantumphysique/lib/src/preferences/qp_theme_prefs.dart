part of 'qp_preferences.dart';

/// Theme-related preferences for [QPPreferences].
extension QPThemePrefsExtension on QPPreferences {
  /// Get night mode value. One of `'auto'`, `'light'`, `'dark'`.
  String get nightMode => prefs.getString('qp_nightMode')!;

  /// Set night mode value.
  set nightMode(String value) => prefs.setString('qp_nightMode', value);

  /// Get AMOLED pure-black flag.
  bool get isAmoled => prefs.getBool('qp_isAmoled')!;

  /// Set AMOLED pure-black flag.
  set isAmoled(bool value) => prefs.setBool('qp_isAmoled', value);

  /// Get language preference.
  QPLanguage get language => prefs.getString('qp_language')!.toQPLanguage();

  /// Set language preference.
  set language(QPLanguage value) =>
      prefs.setString('qp_language', value.language);

  /// Get theme name (app-defined palette key).
  String get themeName => prefs.getString('qp_theme')!;

  /// Set theme name.
  set themeName(String value) => prefs.setString('qp_theme', value);

  /// Get scheme variant name.
  String get schemeVariant => prefs.getString('qp_schemeVariant')!;

  /// Set scheme variant name.
  set schemeVariant(String value) => prefs.setString('qp_schemeVariant', value);

  /// Get contrast level.
  QPContrast get contrastLevel =>
      prefs.getString('qp_contrastLevel')!.toQPContrast()!;

  /// Set contrast level.
  set contrastLevel(QPContrast value) =>
      prefs.setString('qp_contrastLevel', value.name);

  /// Writes theme-related defaults for missing keys.
  ///
  /// Called by [QPPreferences.loadDefaultSettings].
  void _loadThemeDefaults({bool override = false}) {
    if (override || !prefs.containsKey('qp_nightMode')) {
      nightMode = defaultNightMode;
    }
    if (override || !prefs.containsKey('qp_isAmoled')) {
      isAmoled = defaultIsAmoled;
    }
    if (override || !prefs.containsKey('qp_language')) {
      language = defaultLanguage;
    }
    if (override || !prefs.containsKey('qp_theme')) {
      themeName = defaultThemeName;
    }
    if (override || !prefs.containsKey('qp_schemeVariant')) {
      schemeVariant = defaultSchemeVariant;
    }
    if (override || !prefs.containsKey('qp_contrastLevel')) {
      contrastLevel = defaultContrastLevel;
    }
  }
}
