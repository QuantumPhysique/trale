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
}
