/// BCP-47 language wrapper used by QP apps.
library;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/widgets.dart';

/// Wrapper around a [Locale] representing a user-selectable language.
class QPLanguage {
  /// Creates a [QPLanguage] from a BCP-47 tag.
  QPLanguage(String tag) : _locale = _localeFromTag(tag);

  /// Creates a [QPLanguage] from an existing [Locale].
  QPLanguage.fromLocale(Locale locale) : _locale = locale;

  /// Creates a [QPLanguage] representing the system default.
  QPLanguage.system()
    : _locale = const Locale.fromSubtags(languageCode: systemDefault);

  final Locale _locale;

  /// The locale this language represents.
  Locale get locale => _locale;

  /// The BCP-47 tag for this language (e.g. "zh-Hans", "en").
  String get language => _toTag(_locale);

  /// Native names of the languages QP can label, keyed by BCP-47 tag.
  ///
  /// Entries with a script (`zh-Hans`) win over the bare language code (`zh`),
  /// which is why both live in one map: [displayName] looks up the full tag
  /// first and falls back to the language code.
  ///
  /// A language only reaches the settings menu through [supportedLanguages],
  /// which each app fills from its own translations. So shipping a new
  /// translation means adding its name here as well — guard that with a test
  /// over the app's supported locales, or the entry falls back to its bare tag.
  static const Map<String, String> nativeNames = <String, String>{
    'zh-Hans': '简体中文',
    'zh-Hant': '繁體中文',
    'ar': 'العربية',
    'bg': 'български език',
    'ca': 'Català',
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
    'sq': 'Shqip',
    'ta': 'தமிழ்',
    'tr': 'Türkçe',
    'uk': 'Українська мова',
    'vi': 'Tiếng Việt',
    'zh': '汉语',
  };

  /// Display name for this language, or `null` when [nativeNames] has none.
  ///
  /// [defaultLabel] is the string to show for the system-default option (e.g.
  /// "System default"). Pass it from [QPStrings.defaultLangLabel].
  ///
  /// Returning `null` rather than a placeholder is what lets an app assert in
  /// a test that every language it ships can actually be named.
  String? displayName(String defaultLabel) {
    if (_locale.languageCode == systemDefault) {
      return defaultLabel;
    }
    return nativeNames[language] ?? nativeNames[_locale.languageCode];
  }

  /// Human-readable display name for this language.
  ///
  /// Falls back to the BCP-47 tag when no name is known, so a language whose
  /// name was forgotten reads as "ar" instead of as an error message.
  String languageLong(String defaultLabel) =>
      displayName(defaultLabel) ?? language;

  @override
  String toString() => 'QPLanguage($language)';

  /// Convert to [Locale].
  Locale toLocale() => _locale;

  /// Compare with [other]; returns `true` when they represent the same language.
  bool compareTo(QPLanguage other) => other.language == language;

  /// IANA "undetermined" code — used for the system-default entry.
  static const String systemDefault = 'und';

  /// Mutable list of supported languages; set at app startup.
  static List<QPLanguage> supportedLanguages = <QPLanguage>[
    QPLanguage.system(),
  ];
}

// ── BCP-47 tag helpers ────────────────────────────────────────────────────────

String _toTag(Locale l) {
  final List<String> parts = <String>[
    l.languageCode,
    if (l.scriptCode != null && l.scriptCode!.isNotEmpty) l.scriptCode!,
    if (l.countryCode != null && l.countryCode!.isNotEmpty) l.countryCode!,
  ];
  return parts.join('-');
}

Locale _localeFromTag(String tag) {
  final List<String> p = tag.split('-');
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
  return Locale.fromSubtags(
    languageCode: p[0],
    scriptCode: script,
    countryCode: region,
  );
}

// ── String / Locale parsing extensions ───────────────────────────────────────

/// Parse a [String] (BCP-47 tag) to a [QPLanguage].
extension QPLanguageStringParsing on String {
  /// Returns a [QPLanguage] from this BCP-47 tag.
  QPLanguage toQPLanguage() => QPLanguage(this);
}

/// Parse a [Locale] to a [QPLanguage].
extension QPLanguageLocaleParsing on Locale {
  /// Returns a [QPLanguage] wrapping this locale.
  QPLanguage toQPLanguage() => QPLanguage.fromLocale(this);
}
