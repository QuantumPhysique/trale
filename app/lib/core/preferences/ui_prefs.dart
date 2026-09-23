part of '../preferences.dart';

/// Extension grouping ui_prefs settings on [Preferences].
extension UiPrefsExtension on Preferences {
  /// Get show measurement hint banner
  bool get showMeasurementHintBanner =>
      prefs.getBool('showMeasurementHintBanner')!;

  /// Set show measurement hint banner
  set showMeasurementHintBanner(bool show) =>
      prefs.setBool('showMeasurementHintBanner', show);

  /// Get show stats hint banner
  bool get showStatsHintBanner => prefs.getBool('showStatsHintBanner')!;

  /// Set show stats hint banner
  set showStatsHintBanner(bool show) =>
      prefs.setBool('showStatsHintBanner', show);

  /// Get show GitHub star banner
  bool get showGithubStarBanner => prefs.getBool('showGithubStarBanner')!;

  /// Set show GitHub star banner
  set showGithubStarBanner(bool show) =>
      prefs.setBool('showGithubStarBanner', show);
}
