import 'package:shared_preferences/shared_preferences.dart';
import 'package:trale/core/backupInterval.dart';
import 'package:trale/core/contrast.dart';
import 'package:trale/core/firstDay.dart';
import 'package:trale/core/interpolation.dart';
import 'package:trale/core/language.dart';
import 'package:trale/core/printFormat.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/unit_precision.dart';
import 'package:trale/core/units.dart';
import 'package:trale/core/zoomLevel.dart';

/// Class to coordinate shared preferences access
class Preferences {
  /// singleton constructor
  factory Preferences() => _instance;

  /// single instance creation
  Preferences._internal() {
    _loaded = loadPreferences();
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
  static final Preferences _instance = Preferences._internal();

  /// shared preference instance
  late SharedPreferences prefs;

  /// default values
  /// default for userName
  final String defaultUserName = '';

  /// default for userTargetWeight in kg
  final double defaultUserTargetWeight = -1;

  /// default for userTargetWeight in kg
  final double defaultUserWeight = 70;

  /// default for userHeight in m
  final double defaultUserHeight = -1;

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

  /// default unit precision
  final TraleUnitPrecision defaultUnitPrecision
    = TraleUnitPrecision.unitDefault;

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
  final DateTime defaultLatestBackupDate =
      DateTime.fromMillisecondsSinceEpoch(0);

  /// latest backup date
  final DateTime defaultLatestBackupReminderDate =
      DateTime.fromMillisecondsSinceEpoch(0);

  /// default loose mode
  final bool defaultLooseWeight = true;

  /// default show measurement hint banner
  final bool defaultShowMeasurementHintBanner = true;

  /// default reminder enabled
  final bool defaultReminderEnabled = false;

  /// default reminder days (empty = none selected)
  final List<int> defaultReminderDays = <int>[];

  /// default reminder hour
  final int defaultReminderHour = 8;

  /// default reminder minute
  final int defaultReminderMinute = 0;

  /// getter and setter for all preferences
  /// set user name
  set userName(String name) => prefs.setString('userName', name);

  /// get user name
  String get userName => prefs.getString('userName')!;

  /// set user height in cm
  set userHeight(double? height) => prefs.setDouble(
        'userHeight',
        height ?? -1,
      );

  /// get user height in cm
  double? get userHeight => prefs.getDouble('userHeight')! > 0
      ? prefs.getDouble('userHeight')!
      : null;

  /// set user target weight
  set userTargetWeight(double? weight) => prefs.setDouble(
        'userTargetWeight',
        weight ?? -1,
      );

  /// get user target weight
  double? get userTargetWeight => prefs.getDouble('userTargetWeight')! > 0
      ? prefs.getDouble('userTargetWeight')!
      : null;

  /// set if onboarding screen is shown
  set showOnBoarding(bool show) => prefs.setBool('showOnBoarding', show);

  /// get if onboarding screen is shown
  //bool get showOnBoarding => prefs.getBool('showOnBoarding')!;
  bool get showOnBoarding => false;

  /// get night mode value
  String get nightMode => prefs.getString('nightMode')!;

  /// set night mode value
  set nightMode(String nightMode) => prefs.setString('nightMode', nightMode);

  /// get isAmoled value
  bool get isAmoled => prefs.getBool('isAmoled')!;

  /// set isAmoled value
  set isAmoled(bool isAmoled) => prefs.setBool('isAmoled', isAmoled);

  /// get language value
  Language get language => prefs.getString('language')!.toLanguage();

  /// set language value
  set language(Language language) => prefs.setString(
        'language',
        language.language,
      );

  /// get theme mode
  String get theme => prefs.getString('theme')!;

  /// set theme mode
  set theme(String theme) => prefs.setString('theme', theme);

  /// get scheme variant
  String get schemeVariant => prefs.getString('schemeVariant')!;

  /// set scheme variant
  set schemeVariant(String variant) =>
      prefs.setString('schemeVariant', variant);

  /// get contrast level
  ContrastLevel get contrastLevel => prefs.getString('contrastLevel')!
    .toContrastLevel()!;

  /// set contrast level
  set contrastLevel(ContrastLevel level) => prefs.setString(
      'contrastLevel',
      level.name,
    );

  /// get unit mode
  TraleUnit get unit => prefs.getString('unit')!.toTraleUnit()!;

  /// set unit mode
  set unit(TraleUnit unit) => prefs.setString(
        'unit',
        unit.name,
      );

  /// get unit precision
  TraleUnitPrecision get unitPrecision
    => prefs.getString('unitPrecision')!.toTraleUnitPrecision()!;

  /// set unit mode
  set unitPrecision(TraleUnitPrecision precision) => prefs.setString(
    'unitPrecision',
    precision.name,
  );

  /// get interpolation strength mode
  InterpolStrength get interpolStrength =>
      prefs.getString('interpolStrength')!.toInterpolStrength()!;

  /// set interpolation strength mode
  set interpolStrength(InterpolStrength strength) => prefs.setString(
        'interpolStrength',
        strength.name,
      );

  /// get backup frequency
  BackupInterval get backupInterval =>
      prefs.getString('backupInterval')!.toBackupInterval()!;

  /// set backup frequency
  set backupInterval(BackupInterval interval) => prefs.setString(
        'backupInterval',
        interval.name,
      );

  /// get last backup date
  DateTime? get latestBackupDate {
    final DateTime latestBackup =
        DateTime.parse(prefs.getString('latestBackupDate')!);
    return latestBackup == defaultLatestBackupDate ? null : latestBackup;
  }

  /// set latest backup date
  set latestBackupDate(DateTime? date) => prefs.setString(
        'latestBackupDate',
        (date ?? defaultLatestBackupDate).toString(),
      );

  /// get last backup date
  DateTime? get latestBackupReminderDate {
    final DateTime latestBackupReminder =
        DateTime.parse(prefs.getString('latestBackupReminderDate')!);
    return latestBackupReminder == defaultLatestBackupReminderDate
        ? null
        : latestBackupReminder;
  }

  /// set latest backup date
  set latestBackupReminderDate(DateTime? date) => prefs.setString(
        'latestBackupReminderDate',
        (date ?? defaultLatestBackupReminderDate).toString(),
      );

  /// get zoom level
  ZoomLevel get zoomLevel => prefs.getInt('zoomLevel')!.toZoomLevel()!;

  /// set zoom Level
  set zoomLevel(ZoomLevel level) => prefs.setInt(
        'zoomLevel',
        level.index,
      );

  /// get first day
  TraleFirstDay get firstDay => prefs.getString('firstDay')!.toTraleFirstDay()!;

  /// set first day
  set firstDay(TraleFirstDay day) => prefs.setString(
        'firstDay',
        day.name,
      );

  /// Get date format
  TraleDatePrintFormat get datePrintFormat =>
      prefs.getString('dateFormat')!.toTraleDateFormat()!;

  /// Set date format
  set datePrintFormat(TraleDatePrintFormat format) => prefs.setString(
        'dateFormat',
        format.name,
      );

  /// Get loose mode
  bool get looseWeight => prefs.getBool('looseWeight')!;

  /// Set loose mode
  set looseWeight(bool loose) => prefs.setBool('looseWeight', loose);

  /// Get show measurement hint banner
  bool get showMeasurementHintBanner => prefs.getBool('showMeasurementHintBanner')!;

  /// Set show measurement hint banner
  set showMeasurementHintBanner(bool show) => prefs.setBool('showMeasurementHintBanner', show);

  /// Get reminder enabled
  bool get reminderEnabled => prefs.getBool('reminderEnabled')!;

  /// Set reminder enabled
  set reminderEnabled(bool enabled) => prefs.setBool('reminderEnabled', enabled);

  /// Get reminder days (ISO weekday: 1=Mon … 7=Sun)
  List<int> get reminderDays {
    final String raw = prefs.getString('reminderDays')!;
    if (raw.isEmpty) return <int>[];
    return raw.split(',').map(int.parse).toList();
  }

  /// Set reminder days
  set reminderDays(List<int> days) =>
      prefs.setString('reminderDays', days.join(','));

  /// Get reminder hour
  int get reminderHour => prefs.getInt('reminderHour')!;

  /// Set reminder hour
  set reminderHour(int hour) => prefs.setInt('reminderHour', hour);

  /// Get reminder minute
  int get reminderMinute => prefs.getInt('reminderMinute')!;

  /// Set reminder minute
  set reminderMinute(int minute) => prefs.setInt('reminderMinute', minute);

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
    if (override || !prefs.containsKey('interpolStrength')) {
      interpolStrength = defaultInterpolStrength;
    }
    if (override || !prefs.containsKey('userName')) {
      userName = defaultUserName;
    }
    if (override || !prefs.containsKey('userTargetWeight')) {
      userTargetWeight = defaultUserTargetWeight;
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
  }

  /// reset all settings
  void resetSettings() => loadDefaultSettings(override: true);
}
