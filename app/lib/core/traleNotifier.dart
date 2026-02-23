// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:intl/intl.dart';
import 'package:trale/core/backupInterval.dart';
import 'package:trale/core/contrast.dart';
import 'package:trale/core/firstDay.dart';
import 'package:trale/core/interpolation.dart';
import 'package:trale/core/language.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/printFormat.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/unit_precision.dart';
import 'package:trale/core/units.dart';
import 'package:trale/core/zoomLevel.dart';

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

  /// get contrast level
  ContrastLevel get contrastLevel => prefs.contrastLevel;

  /// set contrast level
  set contrastLevel(ContrastLevel level) {
    if (level != contrastLevel) {
      prefs.contrastLevel = level;
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
  TraleCustomTheme get theme =>
      prefs.theme.toTraleCustomTheme() ??
      prefs.defaultTheme.toTraleCustomTheme()!;

  /// setter
  set theme(TraleCustomTheme newTheme) {
    if (newTheme != theme) {
      prefs.theme = newTheme.name;
      notifyListeners();
    }
  }

  /// getter
  TraleSchemeVariant get schemeVariant =>
      prefs.schemeVariant.toTraleSchemeVariant() ??
      prefs.defaultSchemeVariant.toTraleSchemeVariant()!;

  /// setter
  set schemeVariant(TraleSchemeVariant newVariant) {
    if (newVariant != schemeVariant) {
      prefs.schemeVariant = newVariant.name;
      notifyListeners();
    }
  }

  /// get zoom level
  ZoomLevel get zoomLevel => prefs.zoomLevel;

  /// choose next zoom level
  void nextZoomLevel() {
    final ZoomLevel newLevel = prefs.zoomLevel.next;
    if (newLevel != prefs.zoomLevel) {
      prefs.zoomLevel = newLevel;
      notifyListeners();
    }
  }

  /// zoomOut
  void zoomOut() {
    final ZoomLevel newLevel = prefs.zoomLevel.zoomOut;
    if (newLevel != prefs.zoomLevel) {
      prefs.zoomLevel = newLevel;
      notifyListeners();
    }
  }

  /// zoomIn
  void zoomIn() {
    final ZoomLevel newLevel = prefs.zoomLevel.zoomIn;
    if (newLevel != prefs.zoomLevel) {
      prefs.zoomLevel = newLevel;
      notifyListeners();
    }
  }

  /// get backup frequency
  BackupInterval get backupInterval => prefs.backupInterval;

  /// setter backup frequency
  set backupInterval(BackupInterval newInterval) {
    if (backupInterval != newInterval) {
      prefs.backupInterval = newInterval;
      notifyListeners();
    }
  }

  /// get latest backup date
  DateTime? get latestBackupDate => prefs.latestBackupDate;

  /// set latest backup date
  set latestBackupDate(DateTime? newDate) {
    if (latestBackupDate != newDate) {
      prefs.latestBackupDate = newDate;
      notifyListeners();
    }
  }

  /// get latest backup date
  DateTime? get nextBackupDate {
    if (backupInterval == BackupInterval.never) {
      return null;
    }
    if (latestBackupDate == null) {
      return DateTime.now();
    }
    final DateTime nextBackup = latestBackupDate!.add(
      Duration(days: backupInterval.inDays),
    );
    return nextBackup.isBefore(DateTime.now()) ? DateTime.now() : nextBackup;
  }

  /// get latest backup reminder date
  DateTime? get latestBackupReminderDate => prefs.latestBackupReminderDate;

  /// set latest backup reminder date
  set latestBackupReminderDate(DateTime? newDate) {
    if (latestBackupReminderDate != newDate) {
      prefs.latestBackupReminderDate = newDate;
      notifyListeners();
    }
  }

  /// get latest backup date
  bool get showBackupReminder {
    return backupInterval != BackupInterval.never &&
        nextBackupDate!.difference(DateTime.now()).inDays == 0 &&
        (latestBackupReminderDate == null ||
            latestBackupReminderDate!.difference(DateTime.now()).inDays < 0) &&
        MeasurementDatabase().measurements.length > 5;
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
    if (datePrintFormat == TraleDatePrintFormat.systemDefault) {
      final Locale activeLocale = Localizations.localeOf(context);
      if (dateTimePatternMap().containsKey(activeLocale.languageCode)) {
        final Map<String, String> dateTimeLocaleMap =
            dateTimePatternMap()[activeLocale.languageCode]!;
        if (dateTimeLocaleMap.containsKey('yMd')) {
          return DateFormat(
            dateTimeLocaleMap['yMd']!
                .replaceFirst('d', 'dd')
                .replaceFirst('M', 'MM'),
          );
        }
      }
    } else {
      return datePrintFormat.dateFormat;
    }
    return DateFormat('dd/MM/yyyy');
  }

  /// getter
  DateFormat dayFormat(BuildContext context) {
    if (datePrintFormat == TraleDatePrintFormat.systemDefault) {
      final Locale activeLocale = Localizations.localeOf(context);
      if (dateTimePatternMap().containsKey(activeLocale.languageCode)) {
        final Map<String, String> dateTimeLocaleMap =
            dateTimePatternMap()[activeLocale.languageCode]!;
        if (dateTimeLocaleMap.containsKey('Md')) {
          return DateFormat(
            dateTimeLocaleMap['Md']!
                .replaceFirst('d', 'dd')
                .replaceFirst('M', 'MM'),
          );
        }
      }
    } else {
      return datePrintFormat.dayFormat;
    }
    return DateFormat('dd/MM');
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
  TraleUnitHeight get heightUnit => prefs.heightUnit;

  /// setter
  set heightUnit(TraleUnitHeight newHeightUnit) {
    if (heightUnit != newHeightUnit) {
      prefs.heightUnit = newHeightUnit;
      notifyListeners();
    }
  }

  /// getter
  TraleUnitPrecision get unitPrecision => prefs.unitPrecision;

  /// setter
  set unitPrecision(TraleUnitPrecision newPrecision) {
    if (unitPrecision != newPrecision) {
      prefs.unitPrecision = newPrecision;
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

  /// get user height in [cm]
  double? get userHeight => prefs.userHeight;

  /// set user height in [cm]
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

  /// getter
  TraleFirstDay get firstDay => prefs.firstDay;

  /// setter
  set firstDay(TraleFirstDay newFirstDay) {
    if (firstDay != newFirstDay) {
      prefs.firstDay = newFirstDay;
      notifyListeners();
    }
  }

  /// getter
  TraleDatePrintFormat get datePrintFormat => prefs.datePrintFormat;

  /// setter
  set datePrintFormat(TraleDatePrintFormat newDatePrintFormat) {
    if (datePrintFormat != newDatePrintFormat) {
      prefs.datePrintFormat = newDatePrintFormat;
      notifyListeners();
    }
  }

  /// getter
  bool get looseWeight => prefs.looseWeight;

  /// setter
  set looseWeight(bool loose) {
    if (loose != looseWeight) {
      prefs.looseWeight = loose;
      notifyListeners();
    }
  }

  /// getter
  bool get showMeasurementHintBanner => prefs.showMeasurementHintBanner;

  /// setter
  set showMeasurementHintBanner(bool show) {
    if (show != showMeasurementHintBanner) {
      prefs.showMeasurementHintBanner = show;
      notifyListeners();
    }
  }

  /// getter
  bool get showChangelog => prefs.showChangelog;

  /// setter
  set showChangelog(bool show) {
    if (show != showChangelog) {
      prefs.showChangelog = show;
      notifyListeners();
    }
  }

  /// getter
  int get lastBuildNumber => prefs.lastBuildNumber;

  /// setter
  set lastBuildNumber(int number) {
    if (number != lastBuildNumber) {
      prefs.lastBuildNumber = number;
      notifyListeners();
    }
  }

  /// getter for reminder enabled
  bool get reminderEnabled => prefs.reminderEnabled;

  /// setter for reminder enabled
  set reminderEnabled(bool enabled) {
    if (enabled != reminderEnabled) {
      prefs.reminderEnabled = enabled;
      notifyListeners();
    }
  }

  /// getter for reminder days
  List<int> get reminderDays => prefs.reminderDays;

  /// setter for reminder days
  set reminderDays(List<int> days) {
    prefs.reminderDays = days;
    notifyListeners();
  }

  /// getter for reminder hour
  int get reminderHour => prefs.reminderHour;

  /// setter for reminder hour
  set reminderHour(int hour) {
    if (hour != reminderHour) {
      prefs.reminderHour = hour;
      notifyListeners();
    }
  }

  /// getter for reminder minute
  int get reminderMinute => prefs.reminderMinute;

  /// setter for reminder minute
  set reminderMinute(int minute) {
    if (minute != reminderMinute) {
      prefs.reminderMinute = minute;
      notifyListeners();
    }
  }

  /// get reminder TimeOfDay
  TimeOfDay get reminderTime =>
      TimeOfDay(hour: reminderHour, minute: reminderMinute);

  /// set reminder TimeOfDay
  set reminderTime(TimeOfDay time) {
    prefs.reminderHour = time.hour;
    prefs.reminderMinute = time.minute;
    notifyListeners();
  }

  ColorScheme? _systemLightDynamic;
  ColorScheme? _systemDarkDynamic;

  /// The system seed color if available, otherwise black.
  Color get systemSeedColor =>
      systemColorsAvailable ? _systemLightDynamic!.primary : Colors.black;

  /// set system color accent
  void setColorScheme(ColorScheme? systemLight, ColorScheme? systemDark) {
    _systemDarkDynamic = systemDark;
    _systemLightDynamic = systemLight;
  }

  /// If system accent color is available (Android OS 12+)
  bool get systemColorsAvailable =>
      _systemDarkDynamic != null && _systemLightDynamic != null;

  /// get locale
  Locale? get locale => language.compareTo(Language.system())
      ? null // defaults to systems default
      : language.locale;

  /// factory reset
  Future<void> factoryReset() async {
    prefs.resetSettings();
    await MeasurementDatabase().deleteAllMeasurements();
    notifyListeners();
  }
}
