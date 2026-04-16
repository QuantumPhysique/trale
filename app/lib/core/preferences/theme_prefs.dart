part of '../preferences.dart';

/// Extension grouping theme_prefs settings on [Preferences].
extension ThemePrefsExtension on Preferences {
  /// set if onboarding screen is shown
  set showOnBoarding(bool show) => prefs.setBool('showOnBoarding', show);

  /// get if onboarding screen is shown
  //bool get showOnBoarding => prefs.getBool('showOnBoarding')!;
  bool get showOnBoarding => false;

  /// get night mode value
  String get nightMode => prefs.getString('nightMode')!;

  /// set night mode value
  set nightMode(String nightMode) => prefs.setString('nightMode', nightMode);

  /// get isAmoled value
  bool get isAmoled => prefs.getBool('isAmoled')!;

  /// set isAmoled value
  set isAmoled(bool isAmoled) => prefs.setBool('isAmoled', isAmoled);

  /// get language value
  Language get language => prefs.getString('language')!.toLanguage();

  /// set language value
  set language(Language language) =>
      prefs.setString('language', language.language);

  /// get theme mode
  String get theme => prefs.getString('theme')!;

  /// set theme mode
  set theme(String theme) => prefs.setString('theme', theme);

  /// get scheme variant
  String get schemeVariant => prefs.getString('schemeVariant')!;

  /// set scheme variant
  set schemeVariant(String variant) =>
      prefs.setString('schemeVariant', variant);

  /// get contrast level
  ContrastLevel get contrastLevel =>
      prefs.getString('contrastLevel')!.toContrastLevel()!;

  /// set contrast level
  set contrastLevel(ContrastLevel level) =>
      prefs.setString('contrastLevel', level.name);
}
