import 'package:flutter/material.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:intl/intl.dart';

import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/interpolation.dart';
import 'package:trale/core/language.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/units.dart';


/// Class to dynamically change themeMode, isAmoled and language within app
class TraleNotifier with ChangeNotifier {
  /// empty constructor, in main.dart load preferences is called first.
  TraleNotifier();

  /// call notifier
  void get notify => notifyListeners();

  /// shared preferences instance
  final Preferences prefs = Preferences();
  /// getter
  ThemeMode get themeMode => prefs.nightMode.toThemeMode();
  /// setter
  set themeMode(ThemeMode mode) {
    if (mode != themeMode) {
      prefs.nightMode = mode.toCustomString();
      notifyListeners();
    }
  }
  /// getter
  bool get isAmoled => prefs.isAmoled;
  /// setter
  set isAmoled(bool amoled) {
    if (amoled != isAmoled) {
      prefs.isAmoled = amoled;
      notifyListeners();
    }
  }
  /// getter
  TraleCustomTheme get theme => prefs.theme.toTraleCustomTheme()
    ?? prefs.defaultTheme.toTraleCustomTheme()!;
  /// setter
  set theme(TraleCustomTheme newTheme) {
    if (newTheme != theme) {
      prefs.theme = newTheme.name;
      notifyListeners();
    }
  }

  /// getter
  Language get language => prefs.language;
  /// setter
  set language(Language newLanguage) {
    if (language != newLanguage) {
      prefs.language = newLanguage;
      notifyListeners();
    }
  }

  /// getter
  DateFormat dateFormat(BuildContext context) {
    final Locale activeLocale = Localizations.localeOf(context);
    if (dateTimePatternMap().containsKey(activeLocale.languageCode)) {
      final Map<String, String> dateTimeLocaleMap =
        dateTimePatternMap()[activeLocale.languageCode]!;
      if (dateTimeLocaleMap.containsKey('yMd'))
        return DateFormat(
          dateTimeLocaleMap['yMd']!
            .replaceFirst('d', 'dd').replaceFirst('M', 'MM')
        );
    }
    return DateFormat('dd/MM/yyyy');
  }

  /// getter
  TraleUnit get unit => prefs.unit;
  /// setter
  set unit(TraleUnit newUnit) {
    if (unit != newUnit) {
      prefs.unit = newUnit;
      notifyListeners();
    }
  }

  /// getter
  String get userName => prefs.userName;
  /// setter
  set userName(String newName) {
    if (userName != newName) {
      prefs.userName = newName;
      notifyListeners();
    }
  }

  /// getter
  double? get userTargetWeight => prefs.userTargetWeight;
  /// setter
  set userTargetWeight(double? newWeight) {
    if (userTargetWeight != newWeight) {
      prefs.userTargetWeight = newWeight;
      notifyListeners();
    }
  }

  /// get user height in [m]
  double? get userHeight => prefs.userHeight;
  /// set user height in [m]
  set userHeight(double? newHeight) {
    if (userHeight != newHeight) {
      prefs.userHeight = newHeight;
      notifyListeners();
    }
  }

  /// getter
  InterpolStrength get interpolStrength => prefs.interpolStrength;
  /// setter
  set interpolStrength(InterpolStrength strength) {
    if (interpolStrength != strength) {
      prefs.interpolStrength = strength;
      MeasurementDatabase().reinit();
      notifyListeners();
    }
  }

  /// getter
  bool get showOnBoarding => prefs.showOnBoarding;
  /// setter
  set showOnBoarding(bool onBoarding) {
    if (onBoarding != showOnBoarding) {
      prefs.showOnBoarding = onBoarding;
      notifyListeners();
    }
  }

  /// get locale
  Locale? get locale => language.compareTo(Language.system())
      ? null  // defaults to systems default
      : language.locale;

  /// factory reset
  void factoryReset() async {
    prefs.resetSettings();
    /// todo: delete all measurements
    await MeasurementDatabase().deleteAllMeasurements();
    notifyListeners();
  }
}