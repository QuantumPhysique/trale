/// Color scheme variant enum for [QPPreferences] / [QPNotifier].
library;

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

/// All available dynamic color scheme variants.
enum QPSchemeVariant {
  /// Expressive colors
  expressive,

  /// Material tonal spot (default)
  material,

  /// Neutral colors
  neutral,

  /// Vibrant colors
  vibrant,

  /// Monochrome
  monochrome,

  /// Content — similar to fidelity but matches seed color
  seed,

  /// Material 2 fidelity
  material2,
}

/// Extend [QPSchemeVariant] with conversion helpers.
extension QPSchemeVariantExtension on QPSchemeVariant {
  /// The corresponding [DynamicSchemeVariant] used by Material color utilities.
  DynamicSchemeVariant get toDynamicSchemeVariant =>
      const <QPSchemeVariant, DynamicSchemeVariant>{
        QPSchemeVariant.material: DynamicSchemeVariant.tonalSpot,
        QPSchemeVariant.material2: DynamicSchemeVariant.fidelity,
        QPSchemeVariant.neutral: DynamicSchemeVariant.neutral,
        QPSchemeVariant.vibrant: DynamicSchemeVariant.vibrant,
        QPSchemeVariant.expressive: DynamicSchemeVariant.expressive,
        QPSchemeVariant.monochrome: DynamicSchemeVariant.monochrome,
        QPSchemeVariant.seed: DynamicSchemeVariant.content,
      }[this]!;

  /// Serialization name (enum value name).
  String get name => toString().split('.').last;
}

/// Parse a [String] to [QPSchemeVariant].
extension QPSchemeVariantParsing on String {
  /// Returns the matching [QPSchemeVariant], or `null` if not found.
  QPSchemeVariant? toQPSchemeVariant() {
    for (final QPSchemeVariant variant in QPSchemeVariant.values) {
      if (this == variant.name) {
        return variant;
      }
    }
    return null;
  }
}
