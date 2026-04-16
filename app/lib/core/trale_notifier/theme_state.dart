part of '../trale_notifier.dart';

/// Extension on [TraleNotifier] holding theme and visual display state.
extension ThemeStateExtension on TraleNotifier {
  /// getter
  ThemeMode get themeMode => prefs.nightMode.toThemeMode();

  /// setter
  set themeMode(ThemeMode mode) {
    if (mode != themeMode) {
      prefs.nightMode = mode.toCustomString();
      notify;
    }
  }

  /// get contrast level
  ContrastLevel get contrastLevel => prefs.contrastLevel;

  /// set contrast level
  set contrastLevel(ContrastLevel level) {
    if (level != contrastLevel) {
      prefs.contrastLevel = level;
      notify;
    }
  }

  /// getter
  bool get isAmoled => prefs.isAmoled;

  /// setter
  set isAmoled(bool amoled) {
    if (amoled != isAmoled) {
      prefs.isAmoled = amoled;
      notify;
    }
  }

  /// getter
  TraleCustomTheme get theme =>
      prefs.theme.toTraleCustomTheme() ??
      prefs.defaultTheme.toTraleCustomTheme()!;

  /// setter
  set theme(TraleCustomTheme newTheme) {
    if (newTheme != theme) {
      prefs.theme = newTheme.name;
      notify;
    }
  }

  /// getter
  TraleSchemeVariant get schemeVariant =>
      prefs.schemeVariant.toTraleSchemeVariant() ??
      prefs.defaultSchemeVariant.toTraleSchemeVariant()!;

  /// setter
  set schemeVariant(TraleSchemeVariant newVariant) {
    if (newVariant != schemeVariant) {
      prefs.schemeVariant = newVariant.name;
      notify;
    }
  }

  /// get zoom level
  ZoomLevel get zoomLevel => prefs.zoomLevel;

  /// choose next zoom level
  void nextZoomLevel() {
    final ZoomLevel newLevel = prefs.zoomLevel.next;
    if (newLevel != prefs.zoomLevel) {
      prefs.zoomLevel = newLevel;
      notify;
    }
  }

  /// zoomOut
  void zoomOut() {
    final ZoomLevel newLevel = prefs.zoomLevel.zoomOut;
    if (newLevel != prefs.zoomLevel) {
      prefs.zoomLevel = newLevel;
      notify;
    }
  }

  /// zoomIn
  void zoomIn() {
    final ZoomLevel newLevel = prefs.zoomLevel.zoomIn;
    if (newLevel != prefs.zoomLevel) {
      prefs.zoomLevel = newLevel;
      notify;
    }
  }
}
