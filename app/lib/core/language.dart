import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


/// tuple holding count and duration
class Language {
  /// constructor
  Language(String locale) :
    _language = locale;

  /// constructor from Locale
  Language.fromLocale(Locale locale) :
    _language = locale.languageCode;

  /// constructor from Locale
  Language.system() :
    _language = systemDefault;

   /// contains country code
  final String _language;

  /// get locale
  Locale get locale => Locale.fromSubtags(languageCode: _language);
  /// get language codec
  String get language => _language;
  /// get language name
  String languageLong(BuildContext context) => <String, String>{
    systemDefault: AppLocalizations.of(context)!.defaultLang,
    'cs': 'Český Jazyk',
    'de': 'Deutsch',
    'en': 'English',
    'es': 'Español',
    'fi': 'Suomi',
    'fr': 'Français',
    'it': 'Italiano',
    'ko': '조선말',
    'lt': 'Lietuvių',
    'nb': 'Bokmål',
    'pl': 'język polski',
    'pt': 'Português',
    'tr': 'Türkçe',
    'zh': '汉语',
  }[language] ?? 'error';

  @override
  String toString() => 'Language($language)';

  /// convert to Locale
  Locale toLocale() => Locale.fromSubtags(languageCode: language);

  /// compare with other language
  bool compareTo(Language other) => other.language == language;

  /// IANA default undetermined codec
  static const String systemDefault = 'und';
  /// list of supported locals
  static List<Language> supportedLanguages = <Language>[
    Language.system(), ...AppLocalizations.supportedLocales.map(
      (Locale loc) => Language.fromLocale(loc)
    ),
  ];
}

/// parse time count from number
extension LanguageStringParsing on String {
  /// parsing
  Language toLanguage() => Language(this);
}

/// parse time count from number
extension LanguageLocaleParsing on Locale {
  /// parsing
  Language toLanguage() => Language.fromLocale(this);
}

