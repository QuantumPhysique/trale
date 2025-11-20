import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:trale/l10n-gen/app_localizations.dart';

class Language {
  Language(String tag)
    : _locale = _localeFromTag(tag);

  Language.fromLocale(Locale locale)
    : _locale = locale;

  Language.system()
    : _locale = const Locale.fromSubtags(languageCode: systemDefault);

  final Locale _locale;

  Locale get locale => _locale;

  // Full BCP‑47 tag, e.g., "zh-Hans", "en-US", "und"
  String get language => _toTag(_locale);

  /// contains country code
  String languageLong(BuildContext context) {
    final String tag = language;
    final String base = _locale.languageCode;

    // Prefer exact tag; fall back to base language name.
    const Map<String, String> namesByTag = <String, String>{
      'zh-Hans': '简体中文',
      'zh-Hant': '繁體中文',
    };

    final Map<String, String> namesByBase = <String, String>{
      systemDefault: AppLocalizations.of(context)!.defaultLang,
      'bg': 'български език',
      'cs': 'Čeština',
      'de': 'Deutsch',
      'en': 'English',
      'es': 'Español',
      'et': 'Eesti keel',
      'fi': 'Suomi',
      'fr': 'Français',
      'hr': 'Hrvatski',
      'it': 'Italiano',
      'ko': '조선말',
      'lt': 'Lietuvių',
      'nb': 'Bokmål',
      'nl': 'Nederlands',
      'pl': 'Język polski',
      'pt': 'Português',
      'ru': 'Русский',
      'sk': 'Slovenčina',
      'sl': 'Slovenščina',
      'ta': 'தமிழ்',
      'tr': 'Türkçe',
      'uk': 'Українська мова',
      'vi': 'Tiếng Việt',
      'zh': '汉语',
    };

    return namesByTag[tag] ?? namesByBase[base] ?? 'error';
  }

  @override
  String toString() => 'Language($language)';

  /// convert to Locale
  Locale toLocale() => _locale;

  /// compare with other language
  bool compareTo(Language other) => other.language == language;

  /// IANA default undetermined codec
  static const String systemDefault = 'und';
  /// list of supported locals
  static List<Language> supportedLanguages = <Language>[
    Language.system(),
    // Use a Set of tags to avoid duplicates after tagging.
    ...<String>{
      for (final Locale loc in AppLocalizations.supportedLocales) _toTag(loc),
    }.map(Language.new),
  ];
}

// Helpers to build/parse BCP‑47 tags.
String _toTag(Locale l) {
  final List<String> parts = <String>[
    l.languageCode,
    if (l.scriptCode != null && l.scriptCode!.isNotEmpty) l.scriptCode!,
    if (l.countryCode != null && l.countryCode!.isNotEmpty) l.countryCode!,
  ];
  return parts.join('-');
}

/// parse time count from number
Locale _localeFromTag(String tag) {
  final List<String> p = tag.split('-');
  // Detect script (titlecased, length 4) vs region (length 2-3).
  String? script;
  String? region;
  if (p.length >= 2) {
    if (p[1].length == 4) {
      script = p[1];
      if (p.length >= 3) {
        region = p[2];
      }
    } else {
      region = p[1];
    }
  }
  return Locale.fromSubtags(languageCode: p[0], scriptCode: script, countryCode: region);
}

// Extensions unchanged API for callers.
extension LanguageStringParsing on String {
  /// parsing
  Language toLanguage() => Language(this);
}

/// parse time count from number
extension LanguageLocaleParsing on Locale {
  /// parsing
  Language toLanguage() => Language.fromLocale(this);
}