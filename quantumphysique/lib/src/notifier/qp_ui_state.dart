part of 'qp_notifier.dart';

/// Extension on [QPNotifier] holding UI and app-lifecycle state.
extension QPUiStateExtension on QPNotifier {
  /// Current language preference.
  QPLanguage get language => prefs.language;

  /// Sets the language preference.
  set language(QPLanguage value) {
    if (value != language) {
      prefs.language = value;
      notify;
    }
  }

  /// Whether to show the onboarding screen.
  bool get showOnBoarding => prefs.showOnBoarding;

  /// Sets the show-onboarding flag.
  set showOnBoarding(bool value) {
    if (value != showOnBoarding) {
      prefs.showOnBoarding = value;
      notify;
    }
  }

  /// Whether to show the changelog on next app start.
  bool get showChangelog => prefs.showChangelog;

  /// Sets the show-changelog flag.
  set showChangelog(bool value) {
    if (value != showChangelog) {
      prefs.showChangelog = value;
      notify;
    }
  }

  /// Last build number seen by the user.
  int get lastBuildNumber => prefs.lastBuildNumber;

  /// Sets the last-seen build number.
  set lastBuildNumber(int value) {
    if (value != lastBuildNumber) {
      prefs.lastBuildNumber = value;
      notify;
    }
  }
}
