part of 'qp_preferences.dart';

/// UI-related preferences for [QPPreferences].
extension QPUiPrefsExtension on QPPreferences {
  /// Get show-onboarding flag.
  bool get showOnBoarding => prefs.getBool('qp_showOnBoarding')!;

  /// Set show-onboarding flag.
  set showOnBoarding(bool value) => prefs.setBool('qp_showOnBoarding', value);

  /// Get show-changelog flag.
  bool get showChangelog => prefs.getBool('qp_showChangelog')!;

  /// Set show-changelog flag.
  set showChangelog(bool value) => prefs.setBool('qp_showChangelog', value);

  /// Get last-seen build number.
  int get lastBuildNumber => prefs.getInt('qp_lastBuildNumber') ?? 0;

  /// Set last-seen build number.
  set lastBuildNumber(int value) => prefs.setInt('qp_lastBuildNumber', value);

  /// Writes UI defaults for missing keys.
  ///
  /// Called by [QPPreferences.loadDefaultSettings].
  void _loadUiDefaults({bool override = false}) {
    if (override || !prefs.containsKey('qp_showOnBoarding')) {
      showOnBoarding = defaultShowOnboarding;
    }
    if (override || !prefs.containsKey('qp_showChangelog')) {
      showChangelog = defaultShowChangelog;
    }
    if (override || !prefs.containsKey('qp_lastBuildNumber')) {
      lastBuildNumber = defaultLastBuildNumber;
    }
  }
}
