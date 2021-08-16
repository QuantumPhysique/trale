import 'package:flutter/material.dart';

import 'package:trale/core/language.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/preferences.dart';

/// Class to dynamically change themeMode, isAmoled and language within app
class TraleNotifier with ChangeNotifier {
  /// empty constructor, in main.dart load preferences is called first.
  TraleNotifier();

  /// shared preferences instance
  final Preferences prefs = Preferences();
  /// getter
  ThemeMode? get themeMode => prefs.nightMode.toThemeMode();
  /// setter
  set themeMode(ThemeMode? mode) {
    if (mode != themeMode) {
      prefs.nightMode = mode!.toCustomString()!;
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
  CustomTheme get theme => prefs.theme.toCustomTheme()
      ?? prefs.defaultTheme.toCustomTheme();
  /// setter
  set theme(CustomTheme newTheme) {
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

  /// get locale
  Locale? get locale => language.compareTo(Language.system())
      ? null  // defaults to systems default
      : language.locale;
}