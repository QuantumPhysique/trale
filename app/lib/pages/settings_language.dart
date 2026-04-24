import 'package:flutter/material.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/l10n_extension.dart';

/// Trale language settings page.
///
/// Thin wrapper around [QPLanguageSettingsPage] that supplies trale-specific
/// strings, app name, and translation URL.
class LanguageSettingsPage extends StatelessWidget {
  /// Constructor.
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return QPLanguageSettingsPage(
      strings: qpStringsFromL10n(context.l10n),
      appName: 'trale',
      translationUrl: 'https://hosted.weblate.org/engage/trale/',
    );
  }
}
