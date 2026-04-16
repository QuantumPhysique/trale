part of '../trale_notifier.dart';

/// Extension on [TraleNotifier] holding UI hint and app-lifecycle state.
extension UiStateExtension on TraleNotifier {
  /// getter
  Language get language => prefs.language;

  /// setter
  set language(Language newLanguage) {
    if (language != newLanguage) {
      prefs.language = newLanguage;
      notify;
    }
  }

  /// getter
  bool get showOnBoarding => prefs.showOnBoarding;

  /// setter
  set showOnBoarding(bool onBoarding) {
    if (onBoarding != showOnBoarding) {
      prefs.showOnBoarding = onBoarding;
      notify;
    }
  }

  /// getter
  bool get showMeasurementHintBanner => prefs.showMeasurementHintBanner;

  /// setter
  set showMeasurementHintBanner(bool show) {
    if (show != showMeasurementHintBanner) {
      prefs.showMeasurementHintBanner = show;
      notify;
    }
  }

  /// getter
  bool get showStatsHintBanner => prefs.showStatsHintBanner;

  /// setter
  set showStatsHintBanner(bool show) {
    if (show != showStatsHintBanner) {
      prefs.showStatsHintBanner = show;
      notify;
    }
  }

  /// getter
  bool get showChangelog => prefs.showChangelog;

  /// setter
  set showChangelog(bool show) {
    if (show != showChangelog) {
      prefs.showChangelog = show;
      notify;
    }
  }

  /// getter
  int get lastBuildNumber => prefs.lastBuildNumber;

  /// setter
  set lastBuildNumber(int number) {
    if (number != lastBuildNumber) {
      prefs.lastBuildNumber = number;
      notify;
    }
  }
}
