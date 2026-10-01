part of '../preferences.dart';

/// Extension grouping display_prefs settings on [Preferences].
///
/// [firstDay] and [datePrintFormat] are now owned by
/// [QPDisplayPrefsExtension] on [QPPreferences].
extension DisplayPrefsExtension on Preferences {
  /// get zoom level
  ZoomLevel get zoomLevel => prefs.getInt('zoomLevel')!.toZoomLevel()!;

  /// set zoom Level
  set zoomLevel(ZoomLevel level) => prefs.setInt('zoomLevel', level.index);

  /// get chart mode
  ChartMode get chartMode => prefs.getString('chartMode')!.toChartMode()!;

  /// set chart mode
  set chartMode(ChartMode mode) => prefs.setString('chartMode', mode.name);
}
