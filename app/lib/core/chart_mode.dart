/// How the weight curve is drawn.
enum ChartMode {
  /// The trend as a shaded curve.
  simple,

  /// The trend as a line, with the band the measurements are expected in.
  scientific,
}

/// Convert a string to a [ChartMode].
extension ChartModeParsing on String {
  /// The [ChartMode] named by this string, or null.
  ChartMode? toChartMode() {
    for (final ChartMode mode in ChartMode.values) {
      if (this == mode.name) {
        return mode;
      }
    }
    return null;
  }
}
