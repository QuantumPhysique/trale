import 'package:shared_preferences/shared_preferences.dart';

import 'package:trale/core/interpolation.dart';
import 'package:trale/core/language.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/units.dart';


/// Class to coordinate shared preferences access
class Preferences {
  /// singleton constructor
  factory Preferences() => _instance;

  /// single instance creation
  Preferences._internal(){
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
  /// default for nightMode setting
  final String defaultNightMode = 'auto';
  /// default for isAmoled
  final bool defaultIsAmoled = false;
  /// default language
  final Language defaultLanguage = Language.system();
  /// default for theme
  final String defaultTheme = TraleCustomTheme.fire.name;
  /// default unit
  final TraleUnit defaultUnit = TraleUnit.kg;
  /// default interpolation strength
  final InterpolStrength defaultInterpolStrength = InterpolStrength.medium;

  /// getter and setter for all preferences
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
    'language', language.language,
  );
  /// get theme mode
  String get theme => prefs.getString('theme')!;
  /// set theme mode
  set theme(String theme) => prefs.setString('theme', theme);
  /// get unit mode
  TraleUnit get unit => prefs.getString('unit')!.toTraleUnit()!;
  /// set unit mode
  set unit(TraleUnit unit) => prefs.setString(
      'unit', unit.name,
  );
  /// get interpolation strength mode
  InterpolStrength get interpolStrength
    => prefs.getString('interpolStrength')!.toInterpolStrength()!;
  /// set interpolation strength mode
  set interpolStrength(InterpolStrength strength) => prefs.setString(
    'interpolStrength', strength.name,
  );

  /// set default settings /or reset to default
  void loadDefaultSettings({bool override=false}) {
    if (override || !prefs.containsKey('nightMode'))
      nightMode = defaultNightMode;
    if (override || !prefs.containsKey('isAmoled'))
      isAmoled = defaultIsAmoled;
    if (override || !prefs.containsKey('language'))
      language = defaultLanguage;
    if (override || !prefs.containsKey('theme'))
      theme = defaultTheme;
    if (override || !prefs.containsKey('unit'))
      unit = defaultUnit;
    if (override || !prefs.containsKey('interpolStrength'))
      interpolStrength = defaultInterpolStrength;
  }

  /// reset all settings
  void resetSettings() => loadDefaultSettings(override: true);
}
