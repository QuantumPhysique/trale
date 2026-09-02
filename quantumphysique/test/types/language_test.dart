import 'package:flutter_test/flutter_test.dart';
import 'package:quantumphysique/quantumphysique.dart';

void main() {
  const String defaultLabel = 'System default';

  group('QPLanguage.displayName', () {
    test('resolves a plain language code', () {
      expect(QPLanguage('de').displayName(defaultLabel), 'Deutsch');
    });

    test('prefers the scripted tag over the bare language code', () {
      expect(QPLanguage('zh').displayName(defaultLabel), '汉语');
      expect(QPLanguage('zh-Hant').displayName(defaultLabel), '繁體中文');
    });

    test('falls back to the language code for an unlisted region', () {
      expect(QPLanguage('de-AT').displayName(defaultLabel), 'Deutsch');
    });

    test('labels the system default', () {
      expect(QPLanguage.system().displayName(defaultLabel), defaultLabel);
    });

    test('returns null for a language it has no name for', () {
      expect(QPLanguage('xx').displayName(defaultLabel), isNull);
    });
  });

  group('QPLanguage.languageLong', () {
    // A missing name used to render as the literal string "error" in the
    // language settings menu. Showing the tag keeps an oversight legible
    // instead of looking like a crash.
    test('falls back to the tag rather than an error string', () {
      expect(QPLanguage('xx').languageLong(defaultLabel), 'xx');
      expect(QPLanguage('xx-Latn').languageLong(defaultLabel), 'xx-Latn');
    });

    test('uses the native name when there is one', () {
      expect(QPLanguage('ar').languageLong(defaultLabel), 'العربية');
    });
  });
}
