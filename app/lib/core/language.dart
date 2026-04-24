import 'package:flutter/material.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/l10n-gen/app_localizations.dart';

/// Backward-compat alias: [Language] is now [QPLanguage].
typedef Language = QPLanguage;

/// Populates [Language.supportedLanguages] from
/// [AppLocalizations.supportedLocales].
///
/// Call once before the language settings page is shown (e.g. in [main]).
void initLanguages() {
  Language.supportedLanguages = <Language>[
    Language.system(),
    // Deduplicate locales by tag string before constructing Language objects.
    ...<String>{
      for (final Locale loc in AppLocalizations.supportedLocales)
        _tagFromLocale(loc),
    }.map(Language.new),
  ];
}

String _tagFromLocale(Locale l) {
  final List<String> parts = <String>[
    l.languageCode,
    if (l.scriptCode != null && l.scriptCode!.isNotEmpty) l.scriptCode!,
    if (l.countryCode != null && l.countryCode!.isNotEmpty) l.countryCode!,
  ];
  return parts.join('-');
}

/// Converts a BCP-47 [String] tag to a [Language] (= [QPLanguage]).
extension LanguageStringParsing on String {
  /// Returns a [Language] for this BCP-47 tag.
  Language toLanguage() => Language(this);
}

/// Converts a [Locale] to a [Language] (= [QPLanguage]).
extension LanguageLocaleParsing on Locale {
  /// Returns a [Language] wrapping this locale.
  Language toLanguage() => Language.fromLocale(this);
}
