import 'dart:ui';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quantumphysique/quantumphysique.dart';

import 'package:trale/core/trale_notifier.dart';
import 'package:trale/l10n-gen/app_localizations.dart';

/// Theme class for Adonify app
class TraleTheme {
  /// Default constructor
  TraleTheme({
    required this.seedColor,
    required this.brightness,
    required this.schemeVariant,
    this.isAmoled = false,
    this.contrast = 0.0,
  });

  /// copyWith constructor
  TraleTheme copyWith({
    Brightness? brightness,
    Color? seedColor,
    bool? isAmoled,
    double? contrast,
    DynamicSchemeVariant? schemeVariant,
  }) {
    return TraleTheme(
      brightness: brightness ?? this.brightness,
      seedColor: seedColor ?? this.seedColor,
      isAmoled: isAmoled ?? this.isAmoled,
      contrast: contrast ?? this.contrast,
      schemeVariant: schemeVariant ?? this.schemeVariant,
    );
  }

  /// Get current AdonisTheme
  static TraleTheme? of(BuildContext context) {
    final TraleNotifier? notifier = Provider.of<TraleNotifier?>(
      context,
      listen: false,
    );
    if (notifier == null) {
      return null;
    }
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return isLight
        ? notifier.theme.light(context)
        : notifier.isAmoled
        ? notifier.theme.amoled(context)
        : notifier.theme.dark(context);
  }

  /// seed color
  late Color seedColor;

  /// if dark mode on
  late Brightness brightness;

  /// scheme variant
  late DynamicSchemeVariant schemeVariant;

  /// Get border radius
  double get borderRadius => 16;

  /// Get inner border radius
  double get innerBorderRadius => 4;

  /// Get bento border radius
  double get bentoBorderRadius => 32;

  /// Border shape
  final RoundedRectangleBorder borderShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  );

  /// Inner border shape
  final RoundedRectangleBorder innerBorderShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(4),
  );

  /// bento shape
  final RoundedRectangleBorder bentoBorderShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(32),
  );

  /// Padding value
  final double padding = 16;

  /// Padding bento grid
  final double bentoPadding = 8;

  /// Space value between two elements
  final double space = 2;

  /// if true make background true black
  late bool isAmoled;

  /// contrast level
  late double contrast;

  /// get transition durations
  final QPTransitionDuration transitionDuration = const QPTransitionDuration(
    100,
    200,
    500,
  );

  /// get duration of snackbar
  final Duration snackbarDuration = const Duration(seconds: 5);

  /// get background gradient
  LinearGradient get bgGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[themeData.colorScheme.surface, bgShade4],
  );

  /// if dark mode enabled
  bool get isDark => brightness == Brightness.dark;

  /// get elevated shade of clr
  Color colorOfElevation(double elevation, Color clr) => Color.alphaBlend(
    qpFontColor(clr).withValues(alpha: qpOverlayOpacity(elevation)),
    clr,
  );

  /// 24 elevation shade of bg
  Color get bgShade1 => bgElevated(24);

  /// 6 elevation shade of bg
  Color get bgShade2 => bgElevated(6);

  /// 2 elevation shade of bg
  Color get bgShade3 => bgElevated(2);

  /// 2 elevation shade of bg
  Color get bgShade4 => bgElevated(1);

  /// get elevated shade of bg
  Color bgElevated(double elevation) =>
      colorOfElevation(elevation, themeData.colorScheme.surface);

  /// get header color of dialog
  Color? get dialogHeaderColor => isDark
      ? qpColorElevated(
          themeData.dialogTheme.backgroundColor!,
          themeData.dialogTheme.elevation!,
        )
      : themeData.dialogTheme.backgroundColor;

  /// get background color of dialog
  Color get dialogColor => isDark
      ? qpColorElevated(
          themeData.dialogTheme.backgroundColor!,
          themeData.dialogTheme.elevation! / 4,
        )
      : bgShade3;

  /// color threshold for grey
  final double colorThreshold = 25 / 255;

  /// get if seed color is shade of grey
  bool get isGrey =>
      (seedColor.r - seedColor.g).abs() < colorThreshold &&
      (seedColor.g - seedColor.b).abs() < colorThreshold &&
      (seedColor.r - seedColor.b).abs() < colorThreshold;

  /// get corresponding ThemeData
  ThemeData get themeData {
    // Color txtColor = txtTheme.bodyText1.color;
    ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
      contrastLevel: contrast,
      dynamicSchemeVariant: isGrey
          ? DynamicSchemeVariant.monochrome
          : schemeVariant,
    ).harmonized();
    if (isAmoled) {
      colorScheme = colorScheme.copyWith(surface: Colors.black).harmonized();
    }

    // Create a TextTheme and ColorScheme, that we can use to generate ThemeData
    final TextTheme txtTheme = ThemeData.from(colorScheme: colorScheme)
        .textTheme
        .apply(
          fontFamily: 'RobotoFlex',
          fontFamilyFallback: <String>['Roboto', 'Noto Sans'],
        );

    final ListTileThemeData listTileThemeData = ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );

    // ignore: deprecated_member_use
    const SliderThemeData sliderTheme = SliderThemeData(year2023: false);

    const CardThemeData cardTheme = CardThemeData(
      shadowColor: Colors.transparent,
    );

    const ProgressIndicatorThemeData progressIndicatorTheme =
        // ignore: deprecated_member_use
        ProgressIndicatorThemeData(year2023: false);

    /// Now that we have ColorScheme and TextTheme, we can create the ThemeData
    final ThemeData theme =
        ThemeData.from(
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
              // Set the predictive back transitions for Android.
              TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
            },
          ),
        );

    /// Return the themeData which MaterialApp can now use
    return theme;
  }

  /// return amoled version with true black
  TraleTheme get amoled {
    return copyWith(isAmoled: true);
  }
}

/// defining all themes
enum TraleCustomTheme {
  /// system theme A12+
  system,

  /// blue theme
  water,

  /// berry theme
  berry,

  /// sand theme
  sand,

  /// red theme
  fire,

  /// blue yellow theme
  lemon,

  /// greenish theme
  forest,

  /// plum theme
  plum,

  /// teal theme
  teal,

  /// coffee theme
  coffee,

  /// amber theme
  amber,
}

/// extend adonisThemes with adding AdonisTheme attributes
extension TraleCustomThemeExtension on TraleCustomTheme {
  /// Static seed color without context.
  ///
  /// For [TraleCustomTheme.system] returns [Colors.black]; the actual system
  /// color is supplied at runtime via [TraleNotifier.seedColor] which checks
  /// [QPNotifier.systemSeedColor].
  Color get seed => <TraleCustomTheme, Color>{
    TraleCustomTheme.system: Colors.black,
    TraleCustomTheme.fire: const Color(0xFFb52528),
    TraleCustomTheme.lemon: const Color(0xFF626200),
    TraleCustomTheme.sand: const Color(0xFF7e5700),
    TraleCustomTheme.water: const Color(0xFF0161a3),
    TraleCustomTheme.forest: const Color(0xFF006e11),
    TraleCustomTheme.berry: const Color(0xff8b4463),
    TraleCustomTheme.plum: const Color(0xff8e4585),
    TraleCustomTheme.teal: const Color(0xff008080),
    TraleCustomTheme.coffee: const Color(0xff6F4E37),
    TraleCustomTheme.amber: const Color(0xffFFBF00),
  }[this]!;

  /// get seed color of theme
  Color seedColor(BuildContext context) => <TraleCustomTheme, Color>{
    TraleCustomTheme.system:
        Provider.of<TraleNotifier>(context, listen: false).systemColorsAvailable
        ? Provider.of<TraleNotifier>(context, listen: false).systemSeedColor
        : const Color(0xFF000000),
    TraleCustomTheme.fire: const Color(0xFFb52528),
    TraleCustomTheme.lemon: const Color(0xFF626200),
    TraleCustomTheme.sand: const Color(0xFF7e5700),
    TraleCustomTheme.water: const Color(0xFF0161a3),
    TraleCustomTheme.forest: const Color(0xFF006e11),
    TraleCustomTheme.berry: const Color(0xff8b4463),
    TraleCustomTheme.plum: const Color(0xff8e4585),
    TraleCustomTheme.teal: const Color(0xff008080),
    TraleCustomTheme.coffee: const Color(0xff6F4E37),
    TraleCustomTheme.amber: const Color(0xffFFBF00),
  }[this]!;

  /// get contrast level
  double contrast(BuildContext context) =>
      Provider.of<TraleNotifier>(context, listen: false).contrastLevel.contrast;

  /// Get the [DynamicSchemeVariant] for the current notifier.
  DynamicSchemeVariant schemeVariant(BuildContext context) =>
      Provider.of<TraleNotifier>(
        context,
        listen: false,
      ).schemeVariant.schemeVariant;

  /// get corresponding light theme
  TraleTheme light(BuildContext context) => TraleTheme(
    seedColor: seedColor(context),
    brightness: Brightness.light,
    schemeVariant: schemeVariant(context),
    contrast: contrast(context),
  );

  /// get corresponding light theme
  TraleTheme dark(BuildContext context) => TraleTheme(
    seedColor: seedColor(context),
    brightness: Brightness.dark,
    schemeVariant: schemeVariant(context),
    contrast: contrast(context),
  );

  /// get amoled dark theme
  TraleTheme amoled(BuildContext context) => dark(context).amoled;

  /// get string expression
  String get name => toString().split('.').last;
}

/// convert string to type
extension CustomThemeParsing on String {
  /// convert number to difficulty
  TraleCustomTheme? toTraleCustomTheme() {
    for (final TraleCustomTheme theme in TraleCustomTheme.values) {
      if (this == theme.name) {
        return theme;
      }
    }
    return null;
  }
}

/// Ordered list of available theme modes.
final List<ThemeMode> orderedThemeModes = <ThemeMode>[
  ThemeMode.light,
  ThemeMode.system,
  ThemeMode.dark,
];

/// convert string to ThemeMode
extension CustomThemeModeParsing on String {
  /// convert string
  ThemeMode toThemeMode() => <String, ThemeMode>{
    'on': ThemeMode.dark,
    'off': ThemeMode.light,
    'auto': ThemeMode.system,
  }[this]!;
}

/// convert ThemeMode to String
extension CustomThemeModeEncoding on ThemeMode {
  /// convert Thememode
  String toCustomString() => <ThemeMode, String>{
    ThemeMode.dark: 'on',
    ThemeMode.light: 'off',
    ThemeMode.system: 'auto',
  }[this]!;

  /// get international name
  String nameLong(BuildContext context) => <ThemeMode, String>{
    ThemeMode.dark: AppLocalizations.of(context)!.darkmode,
    ThemeMode.light: AppLocalizations.of(context)!.lightmode,
    ThemeMode.system: AppLocalizations.of(context)!.systemmode,
  }[this]!;

  /// get icon
  IconData get icon => <ThemeMode, IconData>{
    ThemeMode.light: PhosphorIconsDuotone.sun,
    ThemeMode.dark: PhosphorIconsDuotone.moon,
    ThemeMode.system: PhosphorIconsDuotone.cloudSun,
  }[this]!;

  /// get icon
  IconData get activeIcon => <ThemeMode, IconData>{
    ThemeMode.light: PhosphorIconsFill.sun,
    ThemeMode.dark: PhosphorIconsFill.moon,
    ThemeMode.system: PhosphorIconsFill.cloudSun,
  }[this]!;
}

/// extension of theme
@immutable
class TraleThemeExtension extends ThemeExtension<TraleThemeExtension> {
  /// constructor
  const TraleThemeExtension({required this.padding});

  /// global padding parameter
  final double? padding;

  /// create getter for onPrimaryContainer textTheme
  TextTheme primaryContainerTextTheme(BuildContext context) =>
      Theme.of(context).textTheme.apply(
        bodyColor: Theme.of(context).colorScheme.onPrimaryContainer,
        displayColor: Theme.of(context).colorScheme.onPrimaryContainer,
        decorationColor: Theme.of(context).colorScheme.onPrimaryContainer,
      );

  @override
  TraleThemeExtension copyWith({double? padding}) {
    return TraleThemeExtension(padding: padding ?? this.padding);
  }

  @override
  TraleThemeExtension lerp(
    ThemeExtension<TraleThemeExtension>? other,
    double t,
  ) {
    if (other is! TraleThemeExtension) {
      return this;
    }
    return TraleThemeExtension(padding: lerpDouble(padding, other.padding, t));
  }
}

/// Backward-compat alias: [TraleSchemeVariant] is now [QPSchemeVariant].
typedef TraleSchemeVariant = QPSchemeVariant;

/// Shim: preserve the legacy [TraleSchemeVariant.schemeVariant] getter name
/// (was [TraleSchemeVariantExtension.schemeVariant]; now delegates to
/// [QPSchemeVariantExtension.toDynamicSchemeVariant]).
extension TraleSchemeVariantShim on TraleSchemeVariant {
  /// Returns the [DynamicSchemeVariant] for this entry.
  DynamicSchemeVariant get schemeVariant => toDynamicSchemeVariant;
}

/// Bridge: convert a stored [String] to [TraleSchemeVariant]
/// (= [QPSchemeVariant]).
extension TraleSchemeVariantParsing on String {
  /// Convert a serialised name to [TraleSchemeVariant],
  /// or `null` if unrecognised.
  TraleSchemeVariant? toTraleSchemeVariant() => toQPSchemeVariant();
}
