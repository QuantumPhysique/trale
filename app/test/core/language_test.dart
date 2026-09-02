import 'package:flutter_test/flutter_test.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/language.dart';
import 'package:trale/l10n-gen/app_localizations.dart';

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

    test('covers every locale the app is translated into', () {
      expect(
        QPLanguage.supportedLanguages.length,
        // The system-default entry has no translation of its own.
        AppLocalizations.supportedLocales.length + 1,
      );
    });

    test('names the system default with the label it is given', () {
      final QPLanguage system = QPLanguage.system();

      expect(system.displayName('Systemsprache'), 'Systemsprache');
      expect(system.languageLong('Systemsprache'), 'Systemsprache');
    });
  });
}
