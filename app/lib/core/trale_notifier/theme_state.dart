part of '../trale_notifier.dart';

/// Extension on [TraleNotifier] holding theme and visual display state.
///
/// [themeMode], [isAmoled], [contrastLevel], [schemeVariant] are now inherited
/// from [QPNotifier] / [QPThemeStateExtension].
extension ThemeStateExtension on TraleNotifier {
  /// Current active [QPCustomTheme].
  QPCustomTheme get theme =>
      _prefs.themeName.toQPCustomTheme() ??
      _prefs.defaultThemeName.toQPCustomTheme()!;

  /// Sets the active palette theme.
  set theme(QPCustomTheme newTheme) {
    if (newTheme != theme) {
      _prefs.themeName = newTheme.name;
      notify;
    }
  }

  /// Current zoom level.
  ZoomLevel get zoomLevel => _prefs.zoomLevel;

  /// Advance to the next zoom level.
  void nextZoomLevel() {
    final ZoomLevel newLevel = _prefs.zoomLevel.next;
    if (newLevel != _prefs.zoomLevel) {
      _prefs.zoomLevel = newLevel;
      notify;
    }
  }

  /// Zoom out one step.
  void zoomOut() {
    final ZoomLevel newLevel = _prefs.zoomLevel.zoomOut;
    if (newLevel != _prefs.zoomLevel) {
      _prefs.zoomLevel = newLevel;
      notify;
    }
  }

  /// Zoom in one step.
  void zoomIn() {
    final ZoomLevel newLevel = _prefs.zoomLevel.zoomIn;
    if (newLevel != _prefs.zoomLevel) {
      _prefs.zoomLevel = newLevel;
      notify;
    }
  }
}
