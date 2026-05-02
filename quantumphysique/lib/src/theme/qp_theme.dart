import 'dart:ui';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quantumphysique/src/notifier/qp_notifier.dart';
import 'package:quantumphysique/src/types/contrast.dart';
import 'package:quantumphysique/src/types/scheme_variant.dart';
import 'package:quantumphysique/src/types/strings.dart';
import 'package:quantumphysique/src/utils/qp_color_utils.dart';

/// Holds the resolved colour + brightness parameters for one side of the
/// theme (light / dark / amoled) and exposes the corresponding [ThemeData]
/// together with shared layout constants.
class QPTheme {
  /// Default constructor.
  QPTheme({
    required this.seedColor,
    required this.brightness,
    required this.schemeVariant,
    this.isAmoled = false,
    this.contrast = 0.0,
  });

  /// Returns a copy with the given fields replaced.
  QPTheme copyWith({
    Brightness? brightness,
    Color? seedColor,
    bool? isAmoled,
    double? contrast,
    DynamicSchemeVariant? schemeVariant,
  }) {
    return QPTheme(
      brightness: brightness ?? this.brightness,
      seedColor: seedColor ?? this.seedColor,
      isAmoled: isAmoled ?? this.isAmoled,
      contrast: contrast ?? this.contrast,
      schemeVariant: schemeVariant ?? this.schemeVariant,
    );
  }

  /// Returns the [QPTheme] matching the current [Theme.of(context)] brightness,
  /// driven by the nearest [QPNotifier] in the widget tree.
  ///
  /// Returns `null` when no [QPNotifier] is registered.
  static QPTheme? of(BuildContext context) {
    final QPNotifier? notifier = Provider.of<QPNotifier?>(
      context,
      listen: false,
    );
    if (notifier == null) {
      return null;
    }
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    if (isLight) {
      return QPTheme(
        seedColor: notifier.seedColor,
        brightness: Brightness.light,
        schemeVariant: notifier.schemeVariant.toDynamicSchemeVariant,
        contrast: notifier.contrastLevel.contrast,
      );
    }
    if (notifier.isAmoled) {
      return QPTheme(
        seedColor: notifier.seedColor,
        brightness: Brightness.dark,
        schemeVariant: notifier.schemeVariant.toDynamicSchemeVariant,
        contrast: notifier.contrastLevel.contrast,
        isAmoled: true,
      );
    }
    return QPTheme(
      seedColor: notifier.seedColor,
      brightness: Brightness.dark,
      schemeVariant: notifier.schemeVariant.toDynamicSchemeVariant,
      contrast: notifier.contrastLevel.contrast,
    );
  }

  /// Seed colour used for [ColorScheme] generation.
  late Color seedColor;

  /// Light or dark.
  late Brightness brightness;

  /// Material 3 dynamic colour scheme variant.
  late DynamicSchemeVariant schemeVariant;

  /// Whether AMOLED pure-black dark mode is active.
  late bool isAmoled;

  /// Contrast level in the range `[-1.0, 1.0]`.
  late double contrast;

  // ── Layout constants ────────────────────────────────────────────────────────

  /// Standard card / dialog border radius in logical pixels.
  double get borderRadius => 16;

  /// Inner (chip / badge) border radius in logical pixels.
  double get innerBorderRadius => 4;

  /// Bento card border radius in logical pixels.
  double get bentoBorderRadius => 32;

  /// [ShapeBorder] matching [borderRadius].
  final RoundedRectangleBorder borderShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  );

  /// [ShapeBorder] matching [innerBorderRadius].
  final RoundedRectangleBorder innerBorderShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(4),
  );

  /// [ShapeBorder] matching [bentoBorderRadius].
  final RoundedRectangleBorder bentoBorderShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(32),
  );

  /// Standard content padding in logical pixels.
  final double padding = 16;

  /// Padding inside a bento grid cell.
  final double bentoPadding = 8;

  /// Spacing between two adjacent elements.
  final double space = 2;

  /// Durations used for page / widget transitions.
  final QPTransitionDuration transitionDuration = const QPTransitionDuration(
    100,
    200,
    500,
  );

  /// How long a [SnackBar] stays visible.
  final Duration snackbarDuration = const Duration(seconds: 5);

  // ── Colour helpers ──────────────────────────────────────────────────────────

  /// Whether [brightness] is [Brightness.dark].
  bool get isDark => brightness == Brightness.dark;

  /// Returns [clr] after applying a surface-overlay at [elevation].
  Color colorOfElevation(double elevation, Color clr) => Color.alphaBlend(
    qpFontColor(clr).withValues(alpha: qpOverlayOpacity(elevation)),
    clr,
  );

  /// Surface at elevation 24.
  Color get bgShade1 => bgElevated(24);

  /// Surface at elevation 6.
  Color get bgShade2 => bgElevated(6);

  /// Surface at elevation 2.
  Color get bgShade3 => bgElevated(2);

  /// Surface at elevation 1.
  Color get bgShade4 => bgElevated(1);

  /// Returns the surface colour elevated by [elevation].
  Color bgElevated(double elevation) =>
      colorOfElevation(elevation, themeData.colorScheme.surface);

  /// Header colour for dialogs (elevated in dark mode).
  Color? get dialogHeaderColor => isDark
      ? qpColorElevated(
          themeData.dialogTheme.backgroundColor!,
          themeData.dialogTheme.elevation!,
        )
      : themeData.dialogTheme.backgroundColor;

  /// Body colour for dialogs (slightly elevated in dark mode).
  Color get dialogColor => isDark
      ? qpColorElevated(
          themeData.dialogTheme.backgroundColor!,
          themeData.dialogTheme.elevation! / 4,
        )
      : bgShade3;

  /// Top-to-bottom gradient over the app background.
  LinearGradient get bgGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[themeData.colorScheme.surface, bgShade4],
  );

  /// Threshold used to decide whether [seedColor] is achromatic.
  final double colorThreshold = 25 / 255;

  /// `true` when [seedColor] is a shade of grey (triggers monochrome scheme).
  bool get isGrey =>
      (seedColor.r - seedColor.g).abs() < colorThreshold &&
      (seedColor.g - seedColor.b).abs() < colorThreshold &&
      (seedColor.r - seedColor.b).abs() < colorThreshold;

  /// Fully configured [ThemeData] for this [QPTheme].
  ThemeData get themeData {
    ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
      contrastLevel: contrast,
      dynamicSchemeVariant: isGrey
          ? DynamicSchemeVariant.monochrome
          : schemeVariant,
    ).harmonized();
    if (isAmoled && brightness == Brightness.dark) {
      colorScheme = colorScheme.copyWith(surface: Colors.black).harmonized();
    }
    final TextTheme txtTheme = ThemeData.from(colorScheme: colorScheme)
        .textTheme
        .apply(
          fontFamily: 'RobotoFlex',
          fontFamilyFallback: <String>['Roboto', 'Noto Sans'],
        );
    const ListTileThemeData listTileThemeData = ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    );
    // ignore: deprecated_member_use
    const SliderThemeData sliderTheme = SliderThemeData(year2023: false);
    const CardThemeData cardTheme = CardThemeData(
      shadowColor: Colors.transparent,
    );
    // ignore: deprecated_member_use
    const ProgressIndicatorThemeData progressIndicatorTheme =
        // ignore: deprecated_member_use
        ProgressIndicatorThemeData(year2023: false);
    return ThemeData.from(
      textTheme: txtTheme,
      colorScheme: colorScheme,
      useMaterial3: true,
    ).copyWith(
      listTileTheme: listTileThemeData,
      sliderTheme: sliderTheme,
      cardTheme: cardTheme,
      progressIndicatorTheme: progressIndicatorTheme,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Returns an AMOLED copy of this theme (pure-black background).
  QPTheme get amoled => copyWith(isAmoled: true);
}

// ── QPCustomTheme ─────────────────────────────────────────────────────────────

/// Built-in colour palettes available to all quantumphysique-based apps.
enum QPCustomTheme {
  /// Dynamically matches the Android 12+ system accent colour.
  system,

  /// Blue — the default palette.
  water,

  /// Deep pink / berry.
  berry,

  /// Warm sand / amber-brown.
  sand,

  /// Vivid red / fire.
  fire,

  /// Citrus yellow.
  lemon,

  /// Forest green.
  forest,

  /// Plum purple.
  plum,

  /// Teal.
  teal,

  /// Coffee brown.
  coffee,

  /// Bright amber.
  amber,
}

/// Behaviour for [QPCustomTheme].
extension QPCustomThemeExtension on QPCustomTheme {
  /// Static seed colour — does not require a [BuildContext].
  ///
  /// For [QPCustomTheme.system] this returns [Colors.black]; the actual
  /// dynamic colour is resolved at runtime via [QPNotifier.systemSeedColor].
  Color get seed => <QPCustomTheme, Color>{
    QPCustomTheme.system: Colors.black,
    QPCustomTheme.fire: const Color(0xFFb52528),
    QPCustomTheme.lemon: const Color(0xFF626200),
    QPCustomTheme.sand: const Color(0xFF7e5700),
    QPCustomTheme.water: const Color(0xFF0161a3),
    QPCustomTheme.forest: const Color(0xFF006e11),
    QPCustomTheme.berry: const Color(0xff8b4463),
    QPCustomTheme.plum: const Color(0xff8e4585),
    QPCustomTheme.teal: const Color(0xff008080),
    QPCustomTheme.coffee: const Color(0xff6F4E37),
    QPCustomTheme.amber: const Color(0xffFFBF00),
  }[this]!;

  /// Resolves the seed colour at runtime, honouring the system palette for
  /// [QPCustomTheme.system].
  Color seedColor(BuildContext context) {
    if (this == QPCustomTheme.system) {
      final QPNotifier notifier = Provider.of<QPNotifier>(
        context,
        listen: false,
      );
      return notifier.systemColorsAvailable
          ? notifier.systemSeedColor
          : Colors.black;
    }
    return seed;
  }

  /// Reads the current contrast level from the nearest [QPNotifier].
  double contrast(BuildContext context) =>
      Provider.of<QPNotifier>(context, listen: false).contrastLevel.contrast;

  /// Reads the current [DynamicSchemeVariant] from the nearest [QPNotifier].
  DynamicSchemeVariant schemeVariant(BuildContext context) =>
      Provider.of<QPNotifier>(
        context,
        listen: false,
      ).schemeVariant.toDynamicSchemeVariant;

  /// Builds the light-mode [QPTheme] for this palette.
  QPTheme light(BuildContext context) => QPTheme(
    seedColor: seedColor(context),
    brightness: Brightness.light,
    schemeVariant: schemeVariant(context),
    contrast: contrast(context),
  );

  /// Builds the dark-mode [QPTheme] for this palette.
  QPTheme dark(BuildContext context) => QPTheme(
    seedColor: seedColor(context),
    brightness: Brightness.dark,
    schemeVariant: schemeVariant(context),
    contrast: contrast(context),
  );

  /// Builds the AMOLED dark-mode [QPTheme] for this palette.
  QPTheme amoled(BuildContext context) => dark(context).amoled;

  /// The enum-value name without the class prefix.
  String get name => toString().split('.').last;
}

/// Parses a stored string back to a [QPCustomTheme].
extension QPCustomThemeParsing on String {
  /// Returns the matching [QPCustomTheme], or `null` if unrecognised.
  QPCustomTheme? toQPCustomTheme() {
    for (final QPCustomTheme theme in QPCustomTheme.values) {
      if (this == theme.name) {
        return theme;
      }
    }
    return null;
  }
}

// ── ThemeMode utilities ───────────────────────────────────────────────────────

/// The canonical ordered list of [ThemeMode] values used in QP apps.
const List<ThemeMode> orderedThemeModes = <ThemeMode>[
  ThemeMode.light,
  ThemeMode.system,
  ThemeMode.dark,
];

/// Parses the storage string representation back to a [ThemeMode].
extension QPThemeModeParsing on String {
  /// Converts the stored string (`'on'` / `'off'` / `'auto'`) to [ThemeMode].
  ThemeMode toThemeMode() => <String, ThemeMode>{
    'on': ThemeMode.dark,
    'off': ThemeMode.light,
    'auto': ThemeMode.system,
  }[this]!;
}

/// Encodes a [ThemeMode] to/from storage strings and provides display helpers.
extension QPThemeModeEncoding on ThemeMode {
  /// Converts this [ThemeMode] to its storage string.
  String toStorageString() => <ThemeMode, String>{
    ThemeMode.dark: 'on',
    ThemeMode.light: 'off',
    ThemeMode.system: 'auto',
  }[this]!;

  /// Returns the localised display name using [QPStrings].
  String nameLong(QPStrings strings) => <ThemeMode, String>{
    ThemeMode.dark: strings.darkModeDark,
    ThemeMode.light: strings.darkModeLight,
    ThemeMode.system: strings.darkModeAuto,
  }[this]!;

  /// Duotone icon for this [ThemeMode].
  IconData get icon => <ThemeMode, IconData>{
    ThemeMode.light: PhosphorIconsDuotone.sun,
    ThemeMode.dark: PhosphorIconsDuotone.moon,
    ThemeMode.system: PhosphorIconsDuotone.cloudSun,
  }[this]!;

  /// Filled icon for this [ThemeMode] (selected state).
  IconData get activeIcon => <ThemeMode, IconData>{
    ThemeMode.light: PhosphorIconsFill.sun,
    ThemeMode.dark: PhosphorIconsFill.moon,
    ThemeMode.system: PhosphorIconsFill.cloudSun,
  }[this]!;
}

// ── QPThemeExtension ──────────────────────────────────────────────────────────

/// A [ThemeExtension] that carries the shared QP layout padding value.
@immutable
class QPThemeExtension extends ThemeExtension<QPThemeExtension> {
  /// Creates a [QPThemeExtension].
  const QPThemeExtension({required this.padding});

  /// The global padding value in logical pixels.
  final double? padding;

  /// Returns a [TextTheme] coloured for use on a [ColorScheme.primaryContainer].
  TextTheme primaryContainerTextTheme(BuildContext context) =>
      Theme.of(context).textTheme.apply(
        bodyColor: Theme.of(context).colorScheme.onPrimaryContainer,
        displayColor: Theme.of(context).colorScheme.onPrimaryContainer,
        decorationColor: Theme.of(context).colorScheme.onPrimaryContainer,
      );

  @override
  QPThemeExtension copyWith({double? padding}) =>
      QPThemeExtension(padding: padding ?? this.padding);

  @override
  QPThemeExtension lerp(ThemeExtension<QPThemeExtension>? other, double t) {
    if (other is! QPThemeExtension) {
      return this;
    }
    return QPThemeExtension(padding: lerpDouble(padding, other.padding, t));
  }
}
