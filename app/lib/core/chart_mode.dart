import 'package:flutter/widgets.dart';
import 'package:trale/core/l10n_extension.dart';

/// How the weight curve is drawn.
enum ChartMode {
  /// The trend as a shaded curve.
  simple,

  /// The trend as a line, with the band the measurements are expected in.
  scientific,
}

/// Behaviour of [ChartMode].
extension ChartModeExtension on ChartMode {
  /// Localised name.
  String nameLong(BuildContext context) => <ChartMode, String>{
    ChartMode.simple: context.l10n.chartModeSimple,
    ChartMode.scientific: context.l10n.chartModeScientific,
  }[this]!;
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
