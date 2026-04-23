import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Returns [Colors.white] or [Colors.black] for maximum contrast against
/// [color].  Set [inverse] to `false` to return the colour with *minimum*
/// contrast instead.
Color qpFontColor(Color color, {bool inverse = true}) =>
    qpIsDarkColor(color) == inverse ? Colors.white : Colors.black;

/// Returns `true` if [color] is perceptually closer to black than white,
/// using ITU-R BT.601 luminance coefficients.
bool qpIsDarkColor(Color color) {
  final double luminance =
      0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
  return luminance < 140;
}

/// Returns the overlay opacity for [elevation] following the Material Design
/// dark-theme specification.
///
/// See https://material.io/design/color/dark-theme.html
double qpOverlayOpacity(double elevation) =>
    (4.5 * math.log(elevation + 1) + 2) / 100.0;

/// Blends a white or black overlay on top of [color] at the given [elevation].
Color qpColorElevated(Color color, double elevation) => Color.alphaBlend(
  qpFontColor(color).withValues(alpha: qpOverlayOpacity(elevation)),
  color,
);

/// Three canonical animation durations used throughout a QP app.
class QPTransitionDuration {
  /// Creates a [QPTransitionDuration].
  ///
  /// All values are in milliseconds.
  const QPTransitionDuration(this._fast, this._normal, this._slow);

  /// Duration of a fast (snappy) transition.
  Duration get fast => Duration(milliseconds: _fast);

  /// Duration of a normal transition.
  Duration get normal => Duration(milliseconds: _normal);

  /// Duration of a slow (deliberate) transition.
  Duration get slow => Duration(milliseconds: _slow);

  final int _fast;
  final int _normal;
  final int _slow;
}
