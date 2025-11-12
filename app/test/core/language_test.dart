import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/language.dart';

void main() {
  group('Language', () {
    test('constructor creates language from tag', () {
      final lang = Language('en');
      expect(lang.language, 'en');
    });

    test('fromLocale creates language from Locale', () {
      final locale = const Locale('de');
      final lang = Language.fromLocale(locale);
      expect(lang.language, 'de');
    });

    test('system creates default language', () {
      final lang = Language.system();
      expect(lang.language, Language.systemDefault);
    });

    test('locale returns Locale object', () {
      final lang = Language('fr');
      expect(lang.locale, isA<Locale>());
      expect(lang.locale.languageCode, 'fr');
    });

    test('toLocale returns Locale object', () {
      final lang = Language('es');
      final locale = lang.toLocale();
      expect(locale, isA<Locale>());
      expect(locale.languageCode, 'es');
    });

    test('compareTo compares languages correctly', () {
      final lang1 = Language('en');
      final lang2 = Language('en');
      final lang3 = Language('de');

      expect(lang1.compareTo(lang2), true);
      expect(lang1.compareTo(lang3), false);
    });

    test('toString returns correct format', () {
      final lang = Language('it');
      expect(lang.toString(), 'Language(it)');
    });

    test('handles language with script code', () {
      final lang = Language('zh-Hans');
      expect(lang.language, 'zh-Hans');
    });

    test('handles language with country code', () {
      final lang = Language('en-US');
      expect(lang.language, 'en-US');
    });

    test('handles language with script and country code', () {
      final lang = Language('zh-Hans-CN');
      expect(lang.language, 'zh-Hans-CN');
    });

    test('systemDefault constant is correct', () {
      expect(Language.systemDefault, 'und');
    });

    test('supportedLanguages includes system default', () {
      expect(
        Language.supportedLanguages.any((l) => l.language == Language.systemDefault),
        true,
      );
    });

    test('supportedLanguages is not empty', () {
      expect(Language.supportedLanguages.isNotEmpty, true);
    });
  });

  group('LanguageStringParsing', () {
    test('toLanguage converts string to Language', () {
      final lang = 'en'.toLanguage();
      expect(lang, isA<Language>());
      expect(lang.language, 'en');
    });

    test('toLanguage handles complex tags', () {
      final lang = 'zh-Hans'.toLanguage();
      expect(lang.language, 'zh-Hans');
    });
  });

  group('LanguageLocaleParsing', () {
    test('toLanguage converts Locale to Language', () {
      final locale = const Locale('fr');
      final lang = locale.toLanguage();
      expect(lang, isA<Language>());
      expect(lang.language, 'fr');
    });

    test('toLanguage handles Locale with country code', () {
      final locale = const Locale('en', 'US');
      final lang = locale.toLanguage();
      expect(lang.language, 'en-US');
    });
  });

  group('_toTag helper', () {
    test('converts simple locale to tag', () {
      final lang = Language('en');
      expect(lang.language, 'en');
    });

    test('converts locale with script to tag', () {
      final locale = const Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hans',
      );
      final lang = Language.fromLocale(locale);
      expect(lang.language, 'zh-Hans');
    });

    test('converts locale with country to tag', () {
      final locale = const Locale.fromSubtags(
        languageCode: 'en',
        countryCode: 'US',
      );
      final lang = Language.fromLocale(locale);
      expect(lang.language, 'en-US');
    });

    test('converts locale with script and country to tag', () {
      final locale = const Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hant',
        countryCode: 'TW',
      );
      final lang = Language.fromLocale(locale);
      expect(lang.language, 'zh-Hant-TW');
    });
  });

  group('_localeFromTag helper', () {
    test('parses simple language tag', () {
      final lang = Language('en');
      expect(lang.locale.languageCode, 'en');
      expect(lang.locale.scriptCode, isNull);
      expect(lang.locale.countryCode, isNull);
    });

    test('parses tag with script code', () {
      final lang = Language('zh-Hans');
      expect(lang.locale.languageCode, 'zh');
      expect(lang.locale.scriptCode, 'Hans');
      expect(lang.locale.countryCode, isNull);
    });

    test('parses tag with country code', () {
      final lang = Language('en-US');
      expect(lang.locale.languageCode, 'en');
      expect(lang.locale.scriptCode, isNull);
      expect(lang.locale.countryCode, 'US');
    });

    test('parses tag with script and country code', () {
      final lang = Language('zh-Hant-TW');
      expect(lang.locale.languageCode, 'zh');
      expect(lang.locale.scriptCode, 'Hant');
      expect(lang.locale.countryCode, 'TW');
    });
  });
}
