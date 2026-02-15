import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Add monospace text styles to TextThemes default
///
/// Usage:
///    thof.textTheme.monospace.bodyMedium
extension MonospaceExtension on TextTheme {
  /// Returns a copy of this [TextTheme] with the RobotoMono font family.
  TextTheme get monospace => apply(fontFamily: 'RobotoMono');
}

extension _TextThemeMap on TextTheme {
  TextTheme _withFontVariations(List<ui.FontVariation> variations) {
    TextStyle? ap(TextStyle? s) => s?.copyWith(fontVariations: variations);
    return TextTheme(
      displayLarge: ap(displayLarge),
      displayMedium: ap(displayMedium),
      displaySmall: ap(displaySmall),
      headlineLarge: ap(headlineLarge),
      headlineMedium: ap(headlineMedium),
      headlineSmall: ap(headlineSmall),
      titleLarge: ap(titleLarge),
      titleMedium: ap(titleMedium),
      titleSmall: ap(titleSmall),
      bodyLarge: ap(bodyLarge),
      bodyMedium: ap(bodyMedium),
      bodySmall: ap(bodySmall),
      labelLarge: ap(labelLarge),
      labelMedium: ap(labelMedium),
      labelSmall: ap(labelSmall),
    );
  }
}

/// Extension to create emphasized text styles using variable-font axes.
extension EmphasizedExtension on TextTheme {
  /// Returns an emphasized copy of this [TextTheme].
  TextTheme get emphasized => _withFontVariations(const <ui.FontVariation>[
    ui.FontVariation('wght', 700),
    ui.FontVariation('slnt', -5),
    ui.FontVariation('GRAD', 50),
    ui.FontVariation('wdth', 50),
    ui.FontVariation('XOPQ', 100),
    ui.FontVariation('YOPQ', 25),
    ui.FontVariation('YTUC', 760),
    ui.FontVariation('YTCL', 440),
    ui.FontVariation('YTAS', 760),
    ui.FontVariation('YTDE', -220),
    ui.FontVariation('YTFI', 760),
  ]);
}
