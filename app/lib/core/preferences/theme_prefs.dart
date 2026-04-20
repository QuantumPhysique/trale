part of '../preferences.dart';

/// Language bridge: exposes [Language] (= [QPLanguage]) type while routing
/// storage through the QP-managed [qp_language] key for consistency with
/// [QPThemePrefsExtension].
///
/// All other theme prefs (nightMode, isAmoled, theme, schemeVariant,
/// contrastLevel, showOnBoarding) are now handled by [QPThemePrefsExtension]
/// on [QPPreferences] and do not need to be re-declared here.
extension ThemePrefsExtension on Preferences {
  /// Get language preference as trale's [Language] (= [QPLanguage]).
  Language get language => Language(prefs.getString('qp_language')!);

  /// Set language preference (writes through to the [qp_language] key).
  set language(Language lang) => prefs.setString('qp_language', lang.language);
}
