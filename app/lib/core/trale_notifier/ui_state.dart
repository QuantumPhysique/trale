part of '../trale_notifier.dart';

/// Extension on [TraleNotifier] holding trale-specific UI hint state.
///
/// [language], [showOnBoarding], [showChangelog], [lastBuildNumber] are now
/// inherited from [QPNotifier] / [QPUiStateExtension].
extension UiStateExtension on TraleNotifier {
  /// Whether to show the measurement hint banner.
  bool get showMeasurementHintBanner => _prefs.showMeasurementHintBanner;

  /// Sets the measurement hint banner flag.
  set showMeasurementHintBanner(bool show) {
    if (show != showMeasurementHintBanner) {
      _prefs.showMeasurementHintBanner = show;
      notify;
    }
  }

  /// Whether to show the stats hint banner.
  bool get showStatsHintBanner => _prefs.showStatsHintBanner;

  /// Sets the stats hint banner flag.
  set showStatsHintBanner(bool show) {
    if (show != showStatsHintBanner) {
      _prefs.showStatsHintBanner = show;
      notify;
    }
  }

  /// Whether to use loose interpolation mode.
  bool get looseWeight => _prefs.looseWeight;

  /// Sets the loose interpolation mode flag.
  set looseWeight(bool loose) {
    if (loose != looseWeight) {
      _prefs.looseWeight = loose;
      notify;
    }
  }
}
