import 'package:flutter_test/flutter_test.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/language.dart';

void main() {
  group('supported languages', () {
    setUp(initLanguages);

    // Arabic shipped without a name in `QPLanguage.nativeNames`, so the
    // language settings menu listed it as "error". Adding a translation is the
    // moment that gap opens, and this is what closes it: a new `app_xx.arb`
    // lands in `supportedLocales`, and this test fails until its native name
    // is added too.
    test('every supported locale has a native name', () {
      final List<String> unnamed = <String>[
        for (final QPLanguage language in QPLanguage.supportedLanguages)
          if (language.displayName('System default') == null) language.language,
      ];

      expect(
        unnamed,
        isEmpty,
        reason:
            'Add the native name of each language listed above to '
            'QPLanguage.nativeNames in the quantumphysique package.',
      );
    });
  });
}
