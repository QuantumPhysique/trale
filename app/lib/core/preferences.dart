import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trale/core/backup_interval.dart';
import 'package:trale/core/contrast.dart';
import 'package:trale/core/first_day.dart';
import 'package:trale/core/interpolation.dart';
import 'package:trale/core/language.dart';
import 'package:trale/core/print_format.dart';
import 'package:trale/core/stats_range.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/unit_precision.dart';
import 'package:trale/core/units.dart';
import 'package:trale/core/zoom_level.dart';

part 'preferences/user_prefs.dart';
part 'preferences/stats_prefs.dart';
part 'preferences/theme_prefs.dart';
part 'preferences/unit_prefs.dart';
part 'preferences/backup_prefs.dart';
part 'preferences/display_prefs.dart';
part 'preferences/ui_prefs.dart';
part 'preferences/reminder_prefs.dart';

/// Class to coordinate shared preferences access
class Preferences {
  /// singleton constructor
  factory Preferences() => _instance;

  /// single instance creation
  Preferences._internal() {
    _loaded = loadPreferences();
  }

  /// Constructor for testing with a pre-configured SharedPreferences.
  @visibleForTesting
  Preferences.forTesting(this.prefs) {
    loadDefaultSettings();
  }

  /// load preference
  Future<void> loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
    loadDefaultSettings();
  }

  /// if shared preferences finished to load
  Future<void>? get loaded => _loaded;
  Future<void>? _loaded;

  /// singleton instance
  static Preferences _instance = Preferences._internal();

  /// Replace the singleton instance for testing.
  @visibleForTesting
  static set testInstance(Preferences instance) => _instance = instance;

  /// Reset the singleton instance after testing.
  @visibleForTesting
  static void resetInstance() {
    _instance = Preferences._internal();
  }

  /// shared preference instance
  late SharedPreferences prefs;

  /// default values
  /// default for userName
  final String defaultUserName = '';

  /// default for target weight enabled
  final bool defaultTargetWeightEnabled = false;

  /// default for userTargetWeight in kg
  final double? defaultUserTargetWeight = null;

  /// default for userTargetWeightDate (not set)
  final DateTime? defaultUserTargetWeightDate = null;

  /// default for userTargetWeightSetDate (not set)
  final DateTime? defaultUserTargetWeightSetDate = null;

  /// default for statsRangeFrom
  final DateTime? defaultStatsRangeFrom = null;

  /// default for statsRangeTo
  final DateTime? defaultStatsRangeTo = null;

  /// default for stats use interpolation (true = interpolated, false = raw)
  final bool defaultStatsUseInterpolation = true;

  /// default for userTargetWeight in kg
  final double defaultUserWeight = 70;

  /// default for userHeight in m
  final double? defaultUserHeight = null;

  /// default for show onboarding screen
  final bool defaultShowOnboarding = true;

  /// default for nightMode setting
  final String defaultNightMode = 'auto';

  /// default for isAmoled
  final bool defaultIsAmoled = false;

  /// default language
  final Language defaultLanguage = Language.system();

  /// default for theme
  final String defaultTheme = TraleCustomTheme.water.name;

  /// default scheme variant
  final String defaultSchemeVariant = TraleSchemeVariant.material.name;

  /// default for contrast level
  final ContrastLevel defaultContrastLevel = ContrastLevel.normal;

  /// default unit
  final TraleUnit defaultUnit = TraleUnit.kg;

  /// default height unit
  final TraleUnitHeight defaultHeightUnit = TraleUnitHeight.metric;

  /// default unit precision
  final TraleUnitPrecision defaultUnitPrecision =
      TraleUnitPrecision.unitDefault;

  /// default interpolation strength
  final InterpolStrength defaultInterpolStrength = InterpolStrength.medium;

  /// default zoomLevel
  final ZoomLevel defaultZoomLevel = ZoomLevel.all;

  /// default backup interval
  final BackupInterval defaultBackupInterval = BackupInterval.monthly;

  /// default first day
  final TraleFirstDay defaultFirstDay = TraleFirstDay.Default;

  /// default date format
  final TraleDatePrintFormat defaultDatePrintFormat =
      TraleDatePrintFormat.systemDefault;

  /// latest backup date
  final DateTime defaultLatestBackupDate = DateTime.fromMillisecondsSinceEpoch(
    0,
  );

  /// latest backup date
  final DateTime defaultLatestBackupReminderDate =
      DateTime.fromMillisecondsSinceEpoch(0);

  /// default loose mode
  final bool defaultLooseWeight = true;

  /// default show measurement hint banner
  final bool defaultShowMeasurementHintBanner = true;

  /// default show stats hint banner
  final bool defaultShowStatsHintBanner = true;

  /// default show changelog
  final bool defaultShowChangelog = true;

  /// default build number (used for showing changelog after update)
  final int defaultLastBuildNumber = 0;

  /// default reminder enabled
  final bool defaultReminderEnabled = false;

  /// default reminder days (empty = none selected)
  final List<int> defaultReminderDays = <int>[];

  /// default reminder hour
  final int defaultReminderHour = 8;

  /// default reminder minute
  final int defaultReminderMinute = 0;

  /// default stats Range
  final StatsRange defaultStatsRange = StatsRange.all;

  /// getter and setter for all preferences
  /// set default settings /or reset to default
  void loadDefaultSettings({bool override = false}) {
    if (override || !prefs.containsKey('nightMode')) {
      nightMode = defaultNightMode;
    }
    if (override || !prefs.containsKey('isAmoled')) {
      isAmoled = defaultIsAmoled;
    }
    if (override || !prefs.containsKey('language')) {
      language = defaultLanguage;
    }
    if (override || !prefs.containsKey('theme')) {
      theme = defaultTheme;
    }
    if (override || !prefs.containsKey('schemeVariant')) {
      schemeVariant = defaultSchemeVariant;
    }
    if (override || !prefs.containsKey('contrastLevel')) {
      contrastLevel = defaultContrastLevel;
    }
    if (override || !prefs.containsKey('unit')) {
      unit = defaultUnit;
    }
    if (override || !prefs.containsKey('unitPrecision')) {
      unitPrecision = defaultUnitPrecision;
    }
    if (override || !prefs.containsKey('heightUnit')) {
      heightUnit = defaultHeightUnit;
    }
    if (override || !prefs.containsKey('interpolStrength')) {
      interpolStrength = defaultInterpolStrength;
    }
    if (override || !prefs.containsKey('userName')) {
      userName = defaultUserName;
    }
    if (override || !prefs.containsKey('targetWeightEnabled')) {
      targetWeightEnabled = defaultTargetWeightEnabled;
    }
    if (override || !prefs.containsKey('userTargetWeight')) {
      userTargetWeight = defaultUserTargetWeight;
    }
    if (override || !prefs.containsKey('userTargetWeightDate')) {
      userTargetWeightDate = defaultUserTargetWeightDate;
    }
    if (override || !prefs.containsKey('userTargetWeightSetDate')) {
      userTargetWeightSetDate = defaultUserTargetWeightSetDate;
    }
    if (override || !prefs.containsKey('userHeight')) {
      userHeight = defaultUserHeight;
    }
    if (override || !prefs.containsKey('showOnBoarding')) {
      showOnBoarding = defaultShowOnboarding;
    }
    if (override || !prefs.containsKey('zoomLevel')) {
      zoomLevel = defaultZoomLevel;
    }
    if (override || !prefs.containsKey('backupInterval')) {
      backupInterval = defaultBackupInterval;
    }
    if (override || !prefs.containsKey('latestBackupDate')) {
      latestBackupDate = defaultLatestBackupDate;
    }
    if (override || !prefs.containsKey('latestBackupReminderDate')) {
      latestBackupReminderDate = defaultLatestBackupReminderDate;
    }
    if (override || !prefs.containsKey('firstDay')) {
      firstDay = defaultFirstDay;
    }
    if (override || !prefs.containsKey('dateFormat')) {
      datePrintFormat = defaultDatePrintFormat;
    }
    if (override || !prefs.containsKey('looseWeight')) {
      looseWeight = defaultLooseWeight;
    }
    if (override || !prefs.containsKey('showMeasurementHintBanner')) {
      showMeasurementHintBanner = defaultShowMeasurementHintBanner;
    }
    if (override || !prefs.containsKey('showStatsHintBanner')) {
      showStatsHintBanner = defaultShowStatsHintBanner;
    }
    if (override || !prefs.containsKey('showChangelog')) {
      showChangelog = defaultShowChangelog;
    }
    if (override || !prefs.containsKey('lastBuildNumber')) {
      lastBuildNumber = defaultLastBuildNumber;
    }
    if (override || !prefs.containsKey('reminderEnabled')) {
      reminderEnabled = defaultReminderEnabled;
    }
    if (override || !prefs.containsKey('reminderDays')) {
      reminderDays = defaultReminderDays;
    }
    if (override || !prefs.containsKey('reminderHour')) {
      reminderHour = defaultReminderHour;
    }
    if (override || !prefs.containsKey('reminderMinute')) {
      reminderMinute = defaultReminderMinute;
    }
    if (override || !prefs.containsKey('statsRange')) {
      statsRange = defaultStatsRange;
    }
    if (override || !prefs.containsKey('statsRangeFrom')) {
      statsRangeFrom = defaultStatsRangeFrom;
    }
    if (override || !prefs.containsKey('statsRangeTo')) {
      statsRangeTo = defaultStatsRangeTo;
    }
    if (override || !prefs.containsKey('statsUseInterpolation')) {
      statsUseInterpolation = defaultStatsUseInterpolation;
    }
  }

  /// reset all settings
  void resetSettings() => loadDefaultSettings(override: true);
}
