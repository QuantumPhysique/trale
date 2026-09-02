import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:material_ui/material_ui.dart';

/// The colours the operating system reports for the "system" palette.
///
/// Android 12+ exposes a full core palette — five 13-tone [TonalPalette]s
/// (primary, secondary, tertiary, neutral, neutralVariant) that together
/// describe the user's Material You theme, including the wallpaper style they
/// picked in Android 13+. macOS, Windows and Linux expose only a single accent
/// [Color].
///
/// [QPSystemColors] wraps whichever of the two the platform provided and turns
/// it into a [ColorScheme] via [toColorScheme]. When the full palettes are
/// available they are used verbatim, so surfaces, outlines and the secondary
/// and tertiary colours match the system instead of being re-derived from the
/// accent colour alone.
class QPSystemColors {
  /// Wraps the five tonal palettes reported by Android.
  QPSystemColors.fromCorePalette(
    // ignore: deprecated_member_use
    CorePalette core,
  ) : _palettes = _QPPalettes(
        primary: core.primary,
        secondary: core.secondary,
        tertiary: core.tertiary,
        neutral: core.neutral,
        neutralVariant: core.neutralVariant,
      ),
      _accent = null;

  /// Wraps the single accent colour reported by macOS, Windows or Linux.
  ///
  /// There are no palettes to work from on those platforms, so
  /// [toColorScheme] falls back to seeding a scheme from [accent].
  const QPSystemColors.fromAccent(Color accent)
    : _palettes = null,
      _accent = accent;

  final _QPPalettes? _palettes;
  final Color? _accent;

  /// Whether the platform reported a full set of tonal palettes.
  ///
  /// `false` on the accent-colour-only platforms.
  bool get hasPalettes => _palettes != null;

  /// The system accent colour.
  ///
  /// Tone 40 of the system primary palette when [hasPalettes], otherwise the
  /// accent colour the platform reported.
  Color get accentColor {
    final _QPPalettes? palettes = _palettes;
    return palettes == null ? _accent! : Color(palettes.primary.get(40));
  }

  /// Builds the [ColorScheme] for the given [brightness].
  ///
  /// When [hasPalettes], every role is resolved from a [DynamicScheme] built
  /// on the system's own palettes, which keeps [contrastLevel] working. The
  /// [variant] still applies — with the palettes fixed by the system it only
  /// changes how a few roles pick their tone.
  ///
  /// Roles are layered on top of [ColorScheme.fromSeed] rather than passed to
  /// the unnamed constructor so that any role a future Flutter adds falls back
  /// to a sensible seeded value instead of a wrong default. The deprecated
  /// `background`, `onBackground` and `surfaceVariant` roles are deliberately
  /// left seeded; nothing reads them.
  ColorScheme toColorScheme({
    required Brightness brightness,
    required double contrastLevel,
    required DynamicSchemeVariant variant,
  }) {
    final _QPPalettes? palettes = _palettes;
    if (palettes == null) {
      return ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: brightness,
        contrastLevel: contrastLevel,
        dynamicSchemeVariant: variant,
      );
    }

    final DynamicScheme scheme = DynamicScheme(
      sourceColorHct: Hct.fromInt(palettes.primary.get(40)),
      variant: _mcuVariant(variant),
      isDark: brightness == Brightness.dark,
      contrastLevel: contrastLevel,
      primaryPalette: palettes.primary,
      secondaryPalette: palettes.secondary,
      tertiaryPalette: palettes.tertiary,
      neutralPalette: palettes.neutral,
      neutralVariantPalette: palettes.neutralVariant,
    );
    Color of(DynamicColor role) => Color(role.getArgb(scheme));

    return ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: brightness,
      contrastLevel: contrastLevel,
      dynamicSchemeVariant: variant,
      primary: of(MaterialDynamicColors.primary),
      onPrimary: of(MaterialDynamicColors.onPrimary),
      primaryContainer: of(MaterialDynamicColors.primaryContainer),
      onPrimaryContainer: of(MaterialDynamicColors.onPrimaryContainer),
      primaryFixed: of(MaterialDynamicColors.primaryFixed),
      primaryFixedDim: of(MaterialDynamicColors.primaryFixedDim),
      onPrimaryFixed: of(MaterialDynamicColors.onPrimaryFixed),
      onPrimaryFixedVariant: of(MaterialDynamicColors.onPrimaryFixedVariant),
      secondary: of(MaterialDynamicColors.secondary),
      onSecondary: of(MaterialDynamicColors.onSecondary),
      secondaryContainer: of(MaterialDynamicColors.secondaryContainer),
      onSecondaryContainer: of(MaterialDynamicColors.onSecondaryContainer),
      secondaryFixed: of(MaterialDynamicColors.secondaryFixed),
      secondaryFixedDim: of(MaterialDynamicColors.secondaryFixedDim),
      onSecondaryFixed: of(MaterialDynamicColors.onSecondaryFixed),
      onSecondaryFixedVariant: of(
        MaterialDynamicColors.onSecondaryFixedVariant,
      ),
      tertiary: of(MaterialDynamicColors.tertiary),
      onTertiary: of(MaterialDynamicColors.onTertiary),
      tertiaryContainer: of(MaterialDynamicColors.tertiaryContainer),
      onTertiaryContainer: of(MaterialDynamicColors.onTertiaryContainer),
      tertiaryFixed: of(MaterialDynamicColors.tertiaryFixed),
      tertiaryFixedDim: of(MaterialDynamicColors.tertiaryFixedDim),
      onTertiaryFixed: of(MaterialDynamicColors.onTertiaryFixed),
      onTertiaryFixedVariant: of(MaterialDynamicColors.onTertiaryFixedVariant),
      error: of(MaterialDynamicColors.error),
      onError: of(MaterialDynamicColors.onError),
      errorContainer: of(MaterialDynamicColors.errorContainer),
      onErrorContainer: of(MaterialDynamicColors.onErrorContainer),
      outline: of(MaterialDynamicColors.outline),
      outlineVariant: of(MaterialDynamicColors.outlineVariant),
      surface: of(MaterialDynamicColors.surface),
      onSurface: of(MaterialDynamicColors.onSurface),
      surfaceDim: of(MaterialDynamicColors.surfaceDim),
      surfaceBright: of(MaterialDynamicColors.surfaceBright),
      surfaceContainerLowest: of(MaterialDynamicColors.surfaceContainerLowest),
      surfaceContainerLow: of(MaterialDynamicColors.surfaceContainerLow),
      surfaceContainer: of(MaterialDynamicColors.surfaceContainer),
      surfaceContainerHigh: of(MaterialDynamicColors.surfaceContainerHigh),
      surfaceContainerHighest: of(
        MaterialDynamicColors.surfaceContainerHighest,
      ),
      onSurfaceVariant: of(MaterialDynamicColors.onSurfaceVariant),
      inverseSurface: of(MaterialDynamicColors.inverseSurface),
      onInverseSurface: of(MaterialDynamicColors.inverseOnSurface),
      inversePrimary: of(MaterialDynamicColors.inversePrimary),
      shadow: of(MaterialDynamicColors.shadow),
      scrim: of(MaterialDynamicColors.scrim),
      surfaceTint: of(MaterialDynamicColors.surfaceTint),
    );
  }

  /// Maps Flutter's [DynamicSchemeVariant] to the equivalent [Variant].
  static Variant _mcuVariant(DynamicSchemeVariant variant) => switch (variant) {
    DynamicSchemeVariant.tonalSpot => Variant.tonalSpot,
    DynamicSchemeVariant.fidelity => Variant.fidelity,
    DynamicSchemeVariant.content => Variant.content,
    DynamicSchemeVariant.monochrome => Variant.monochrome,
    DynamicSchemeVariant.neutral => Variant.neutral,
    DynamicSchemeVariant.vibrant => Variant.vibrant,
    DynamicSchemeVariant.expressive => Variant.expressive,
    DynamicSchemeVariant.rainbow => Variant.rainbow,
    DynamicSchemeVariant.fruitSalad => Variant.fruitSalad,
  };
}

/// The five tonal palettes that make up a system theme.
class _QPPalettes {
  const _QPPalettes({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.neutral,
    required this.neutralVariant,
  });

  final TonalPalette primary;
  final TonalPalette secondary;
  final TonalPalette tertiary;
  final TonalPalette neutral;
  final TonalPalette neutralVariant;
}
