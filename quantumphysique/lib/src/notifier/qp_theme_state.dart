part of 'qp_notifier.dart';

/// Extension on [QPNotifier] holding theme and visual state.
extension QPThemeStateExtension on QPNotifier {
  /// Whether the seed color is a shade of grey (triggers monochrome scheme).
  bool get _isSeedGrey {
    const double threshold = 25 / 255;
    final Color c = seedColor;
    return (c.r - c.g).abs() < threshold &&
        (c.g - c.b).abs() < threshold &&
        (c.r - c.b).abs() < threshold;
  }

  /// Current theme mode.
  ThemeMode get themeMode => prefs.nightMode.toThemeMode();

  /// Sets the theme mode.
  set themeMode(ThemeMode mode) {
    if (mode != themeMode) {
      prefs.nightMode = mode.toStorageString();
      notify;
    }
  }

  /// Whether AMOLED pure-black dark mode is enabled.
  bool get isAmoled => prefs.isAmoled;

  /// Sets the AMOLED flag.
  set isAmoled(bool value) {
    if (value != isAmoled) {
      prefs.isAmoled = value;
      notify;
    }
  }

  /// Current contrast level.
  QPContrast get contrastLevel => prefs.contrastLevel;

  /// Sets the contrast level.
  set contrastLevel(QPContrast level) {
    if (level != contrastLevel) {
      prefs.contrastLevel = level;
      notify;
    }
  }

  /// Current scheme variant.
  QPSchemeVariant get schemeVariant =>
      prefs.schemeVariant.toQPSchemeVariant() ??
      prefs.defaultSchemeVariant.toQPSchemeVariant()!;

  /// Sets the scheme variant.
  set schemeVariant(QPSchemeVariant variant) {
    if (variant != schemeVariant) {
      prefs.schemeVariant = variant.name;
      notify;
    }
  }

  /// Light [ThemeData] built from current settings.
  ThemeData get lightTheme => buildQPThemeData(
    seedColor: seedColor,
    brightness: Brightness.light,
    schemeVariant: schemeVariant,
    contrast: contrastLevel,
    isGrey: _isSeedGrey,
  );

  /// Dark [ThemeData] built from current settings.
  ThemeData get darkTheme => buildQPThemeData(
    seedColor: seedColor,
    brightness: Brightness.dark,
    schemeVariant: schemeVariant,
    contrast: contrastLevel,
    isAmoled: isAmoled,
    isGrey: _isSeedGrey,
  );
}
