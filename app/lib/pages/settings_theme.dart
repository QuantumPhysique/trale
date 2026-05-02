import 'package:flutter/material.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/l10n_extension.dart';

/// Trale theme settings page.
///
/// Delegates entirely to [QPThemeSettingsPage].
class ThemeSettingsPage extends StatelessWidget {
  /// Constructor.
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return QPThemeSettingsPage(strings: qpStringsFromL10n(context.l10n));
  }
}
