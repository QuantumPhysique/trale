import 'package:flutter/foundation.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trale/core/backup_interval.dart';
import 'package:trale/core/interpolation.dart';
import 'package:trale/core/language.dart';
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

/// Trale's preferences, extending [QPPreferences] with app-specific keys.
class Preferences extends QPPreferences {
  /// Singleton constructor.
  factory Preferences() => _instance;

  Preferences._internal() : super.base();

  /// Constructor for testing with a pre-configured [SharedPreferences].
  @visibleForTesting
  Preferences.forTesting(super.prefs) : super.baseForTesting();

  /// Singleton instance.
  static Preferences _instance = Preferences._internal();

  /// Replace the singleton instance for testing.
  @visibleForTesting
  static set testInstance(Preferences instance) => _instance = instance;

  /// Reset the singleton instance after testing.
  @visibleForTesting
  static void resetInstance() {
    _instance = Preferences._internal();
  }

  // ---------------------------------------------------------------------------
  // Default theme name (required by QPPreferences)
  // ---------------------------------------------------------------------------

  @override
  String get defaultThemeName => TraleCustomTheme.water.name;

  // ---------------------------------------------------------------------------
  // Trale-specific default values
  // ---------------------------------------------------------------------------

  /// Default for userName.
  final String defaultUserName = '';

  /// Default for target weight enabled.
  final bool defaultTargetWeightEnabled = false;

  /// Default for userTargetWeight in kg.
  final double? defaultUserTargetWeight = null;

  /// Default for userTargetWeightDate (not set).
  final DateTime? defaultUserTargetWeightDate = null;

  /// Default for userTargetWeightSetDate (not set).
  final DateTime? defaultUserTargetWeightSetDate = null;

  /// Default for statsRangeFrom.
  final DateTime? defaultStatsRangeFrom = null;

  /// Default for statsRangeTo.
  final DateTime? defaultStatsRangeTo = null;

  /// Default for stats use interpolation (true = interpolated, false = raw).
  final bool defaultStatsUseInterpolation = true;

  /// Default user weight in kg.
  final double defaultUserWeight = 70;

  /// Default user height in m.
  final double? defaultUserHeight = null;

  /// Default unit.
  final TraleUnit defaultUnit = TraleUnit.kg;

  /// Default height unit.
  final TraleUnitHeight defaultHeightUnit = TraleUnitHeight.metric;

  /// Default unit precision.
  final TraleUnitPrecision defaultUnitPrecision =
      TraleUnitPrecision.unitDefault;

  /// Default interpolation strength.
  final InterpolStrength defaultInterpolStrength = InterpolStrength.medium;

  /// Default zoom level.
  final ZoomLevel defaultZoomLevel = ZoomLevel.all;

  /// Default backup interval.
  final BackupInterval defaultBackupInterval = BackupInterval.monthly;

  /// Latest backup date.
  final DateTime defaultLatestBackupDate = DateTime.fromMillisecondsSinceEpoch(
    0,
  );

  /// Latest backup reminder date.
  final DateTime defaultLatestBackupReminderDate =
      DateTime.fromMillisecondsSinceEpoch(0);

  /// Default loose mode.
  final bool defaultLooseWeight = true;

  /// Default show measurement hint banner.
  final bool defaultShowMeasurementHintBanner = true;

  /// Default show stats hint banner.
  final bool defaultShowStatsHintBanner = true;

  /// Default stats range.
  final StatsRange defaultStatsRange = StatsRange.all;

  // ---------------------------------------------------------------------------
  // loadDefaultSettings override
  // ---------------------------------------------------------------------------

  @override
  void loadDefaultSettings({bool override = false}) {
    // Apply all QP-owned defaults first.
    super.loadDefaultSettings(override: override);

    // Trale-specific defaults.
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
    if (override || !prefs.containsKey('looseWeight')) {
      looseWeight = defaultLooseWeight;
    }
    if (override || !prefs.containsKey('showMeasurementHintBanner')) {
      showMeasurementHintBanner = defaultShowMeasurementHintBanner;
    }
    if (override || !prefs.containsKey('showStatsHintBanner')) {
      showStatsHintBanner = defaultShowStatsHintBanner;
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
}
