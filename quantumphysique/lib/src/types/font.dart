/// TextTheme extensions used across QP apps.
library;

import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Returns a copy of this [TextTheme] with the RobotoMono font family.
extension MonospaceExtension on TextTheme {
  /// A monospace variant of this text theme.
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

/// Color-applying extensions on [TextStyle].
extension ColorTextThemeExtension on TextStyle {
  /// Returns a copy with [ColorScheme.onSecondaryContainer] color.
  TextStyle onSecondaryContainer(BuildContext context) =>
      copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer);

  /// Returns a copy with [ColorScheme.onSurface] color.
  TextStyle onSurface(BuildContext context) =>
      copyWith(color: Theme.of(context).colorScheme.onSurface);

  /// Returns a copy with [ColorScheme.onSurfaceVariant] color.
  TextStyle onSurfaceVariant(BuildContext context) =>
      copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
}

/// Returns an emphasized copy of this [TextTheme] using variable-font axes.
extension EmphasizedExtension on TextTheme {
  /// An emphasized (bold + slanted + condensed) variant of this text theme.
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
