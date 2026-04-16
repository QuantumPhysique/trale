part of '../preferences.dart';

/// Extension grouping display_prefs settings on [Preferences].
extension DisplayPrefsExtension on Preferences {
  /// get zoom level
  ZoomLevel get zoomLevel => prefs.getInt('zoomLevel')!.toZoomLevel()!;

  /// set zoom Level
  set zoomLevel(ZoomLevel level) => prefs.setInt('zoomLevel', level.index);

  /// get first day
  TraleFirstDay get firstDay => prefs.getString('firstDay')!.toTraleFirstDay()!;

  /// set first day
  set firstDay(TraleFirstDay day) => prefs.setString('firstDay', day.name);

  /// Get date format
  TraleDatePrintFormat get datePrintFormat =>
      prefs.getString('dateFormat')!.toTraleDateFormat()!;

  /// Set date format
  set datePrintFormat(TraleDatePrintFormat format) =>
      prefs.setString('dateFormat', format.name);

}
