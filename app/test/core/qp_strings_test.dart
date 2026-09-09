import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Words that make a string about trale rather than about any QP app.
const List<String> appSpecificWords = <String>['trale', 'weight', 'gewicht'];

void main() {
  group('qp_ vocabulary', () {
    // The qp_ keys are the strings the quantumphysique package shares between
    // apps, and adonify copies them over verbatim. One that names trale or
    // weight tracking therefore ships as-is in an app about something else —
    // it belongs in an app-owned key handed to QPStrings instead.
    test('holds nothing app-specific', () {
      final List<String> offenders = <String>[];

      for (final File arb in arbFiles()) {
        final Map<String, dynamic> strings =
            jsonDecode(arb.readAsStringSync()) as Map<String, dynamic>;
        strings.forEach((String key, dynamic value) {
          if (!key.startsWith('qp_') || value is! String) {
            return;
          }
          final String text = value.toLowerCase();
          for (final String word in appSpecificWords) {
            if (RegExp('\\b$word').hasMatch(text)) {
              offenders.add('${arb.uri.pathSegments.last}: $key = "$value"');
            }
          }
        });
      }

      expect(
        offenders,
        isEmpty,
        reason:
            'Move these to an app-owned key and pass it to QPStrings in '
            'lib/core/l10n_extension.dart, as translateSubtitle and '
            'reminderSubtitle already are.',
      );
    });
  });
}

/// Every ARB file of the app, read straight from disk.
List<File> arbFiles() => Directory('lib/l10n')
    .listSync()
    .whereType<File>()
    .where((File f) => f.path.endsWith('.arb'))
    .toList();
