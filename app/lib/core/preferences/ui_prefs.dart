part of '../preferences.dart';

/// Extension grouping ui_prefs settings on [Preferences].
extension UiPrefsExtension on Preferences {
  /// Get loose mode
  bool get looseWeight => prefs.getBool('looseWeight')!;

  /// Set loose mode
  set looseWeight(bool loose) => prefs.setBool('looseWeight', loose);

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
