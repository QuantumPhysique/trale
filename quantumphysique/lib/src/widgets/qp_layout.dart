/// Layout constants shared across all QP widgets.
library;

import 'package:flutter/material.dart';

/// Shared layout constants for QP apps.
///
/// These values are intentionally constant to allow compile-time inlining.
/// Trale's [TraleTheme] carries the same numeric values — having a single
/// source of truth here avoids a runtime [InheritedWidget] lookup for what
/// are purely static geometry values.
class QPLayout {
  QPLayout._();

  /// Default screen / card padding (16 dp).
  static const double padding = 16;

  /// Gap between bento grid cells (8 dp).
  static const double bentoPadding = 8;

  /// Thin divider gap between stacked tiles (2 dp).
  static const double space = 2;

  /// Card corner radius (16 dp).
  static const double borderRadius = 16;

  /// Tile / chip inner corner radius (4 dp).
  static const double innerBorderRadius = 4;

  /// Bento card corner radius (32 dp).
  static const double bentoBorderRadius = 32;

  /// Standard card border shape.
  static RoundedRectangleBorder get borderShape =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius));

  /// Inner tile / chip border shape.
  static RoundedRectangleBorder get innerBorderShape => RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(innerBorderRadius),
  );

  /// Bento card border shape.
  static RoundedRectangleBorder get bentoBorderShape => RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(bentoBorderRadius),
  );

  /// Fast transition duration (100 ms).
  static const Duration transitionFast = Duration(milliseconds: 100);

  /// Normal transition duration (200 ms).
  static const Duration transitionNormal = Duration(milliseconds: 200);

  /// Slow transition duration (500 ms).
  static const Duration transitionSlow = Duration(milliseconds: 500);
}
