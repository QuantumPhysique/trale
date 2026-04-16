part of '../stats_widgets.dart';

/// Converts a weight value to a display string.
String weightToString(BuildContext context, double? d) {
  return d == null
      ? '--'
      : Provider.of<TraleNotifier>(context).unit.weightToString(
          d,
          Provider.of<TraleNotifier>(context).unitPrecision,
          showUnit: false,
        );
}

/// Converts a double value to a display string.
String doubleToString(double? d) {
  return d == null ? '--' : d.toStringAsFixed(1);
}
