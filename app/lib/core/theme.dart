import 'dart:math' as math;
import 'dart:ui';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/contrast.dart';

import 'package:trale/core/traleNotifier.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/main.dart';

/// get color (black or white) with maximal constrast or minimal (inverse=false)
Color getFontColor(Color color, {bool inverse = true}) {
  return isDarkColor(color) == inverse ? Colors.white : Colors.black;
}

/// check if color is closer to black or white
bool isDarkColor(Color color) {
  final double luminance =
      0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
  return luminance < 140;
}

/// return opacity corresponding to elevation
/// https://material.io/design/color/dark-theme.html
double overlayOpacity(double elevation) =>
    (4.5 * math.log(elevation + 1) + 2) / 100.0;

/// overlay color with elevation
Color colorElevated(Color color, double elevation) => Color.alphaBlend(
  getFontColor(color).withOpacity(overlayOpacity(elevation)),
  color,
);

/// Class holding three different transition durations
class TransitionDuration {
  /// constructor
  TransitionDuration(this._fast, this._normal, this._slow);

  /// get duration of fast transition
  Duration get fast => Duration(milliseconds: _fast);

  /// get duration of normal transition
  Duration get normal => Duration(milliseconds: _normal);

  /// get duration of slow transition
  Duration get slow => Duration(milliseconds: _slow);

  /// length of durations in ms
  final int _fast;

  /// length of durations in ms
  final int _normal;

  /// length of durations in ms
  final int _slow;
}

/// Theme class for Adonify app
/// 
/// Supports Material 3 Expressive color system with the following color roles:
/// - Fixed colors (primaryFixed, secondaryFixed, tertiaryFixed)
/// - Fixed dim colors (primaryFixedDim, secondaryFixedDim, tertiaryFixedDim)
/// - On fixed colors (onPrimaryFixed, onSecondaryFixed, onTertiaryFixed)
/// - On fixed variant colors (onPrimaryFixedVariant, onSecondaryFixedVariant, onTertiaryFixedVariant)
/// 
/// Reference: https://m3.material.io/styles/color/roles
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
    final TraleApp? result = context.findAncestorWidgetOfExactType<TraleApp>();
    return Theme.of(context).brightness == Brightness.light
        ? result?.traleNotifier.theme.light(context)
        : (result != null && result.traleNotifier.isAmoled)
        ? result.traleNotifier.theme.amoled(context)
        : result?.traleNotifier.theme.dark(context);
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

  /// Border shape
  final RoundedRectangleBorder borderShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  );
  final RoundedRectangleBorder innerBorderShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(4),
  );

  /// Padding value
  final double padding = 16;

  /// Space value between two elements
  final double space = 2;

  /// if true make background true black
  late bool isAmoled;

  /// contrast level
  late double contrast;

  /// get transition durations
  final TransitionDuration transitionDuration = TransitionDuration(
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
    getFontColor(clr).withValues(alpha: overlayOpacity(elevation)),
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
      ? colorElevated(
          themeData.dialogTheme.backgroundColor!,
          themeData.dialogTheme.elevation!,
        )
      : themeData.dialogTheme.backgroundColor;

  /// get background color of dialog
  Color get dialogColor => isDark
      ? colorElevated(
          themeData.dialogTheme.backgroundColor!,
          themeData.dialogTheme.elevation! / 4,
        )
      : bgShade3;

  // ============================================================================
  // Material 3 Expressive Color System Support
  // ============================================================================
  // The following getters provide access to the Material 3 Expressive color roles
  // as documented at https://m3.material.io/styles/color/roles
  //
  // Usage example:
  // ```dart
  // Container(
  //   color: TraleTheme.of(context).primaryFixed,
  //   child: Text(
  //     'Fixed color text',
  //     style: TextStyle(color: TraleTheme.of(context).onPrimaryFixed),
  //   ),
  // )
  // ```
  // ============================================================================
  
  /// Fixed primary color from Material 3 Expressive system
  /// Remains consistent across light/dark themes
  Color get primaryFixed => themeData.colorScheme.primaryFixed;
  
  /// Fixed secondary color from Material 3 Expressive system
  /// Remains consistent across light/dark themes
  Color get secondaryFixed => themeData.colorScheme.secondaryFixed;
  
  /// Fixed tertiary color from Material 3 Expressive system
  /// Remains consistent across light/dark themes
  Color get tertiaryFixed => themeData.colorScheme.tertiaryFixed;
  
  /// Dimmed version of primaryFixed
  Color get primaryFixedDim => themeData.colorScheme.primaryFixedDim;
  
  /// Dimmed version of secondaryFixed
  Color get secondaryFixedDim => themeData.colorScheme.secondaryFixedDim;
  
  /// Dimmed version of tertiaryFixed
  Color get tertiaryFixedDim => themeData.colorScheme.tertiaryFixedDim;
  
  /// Text color for primaryFixed backgrounds
  Color get onPrimaryFixed => themeData.colorScheme.onPrimaryFixed;
  
  /// Text color for secondaryFixed backgrounds
  Color get onSecondaryFixed => themeData.colorScheme.onSecondaryFixed;
  
  /// Text color for tertiaryFixed backgrounds
  Color get onTertiaryFixed => themeData.colorScheme.onTertiaryFixed;
  
  /// Alternative text color for primaryFixed (lower emphasis)
  Color get onPrimaryFixedVariant => themeData.colorScheme.onPrimaryFixedVariant;
  
  /// Alternative text color for secondaryFixed (lower emphasis)
  Color get onSecondaryFixedVariant => themeData.colorScheme.onSecondaryFixedVariant;
  
  /// Alternative text color for tertiaryFixed (lower emphasis)
  Color get onTertiaryFixedVariant => themeData.colorScheme.onTertiaryFixedVariant;

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

    const SliderThemeData sliderTheme = SliderThemeData(year2023: false);

    const CardThemeData cardTheme = CardThemeData(
      shadowColor: Colors.transparent,
    );

    const ProgressIndicatorThemeData progressIndicatorTheme =
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
  const TraleThemeExtension({@required this.padding});

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

/// extension of theme
extension ColorTextThemeExtension on TextStyle {
  TextStyle onSecondaryContainer(BuildContext context) =>
      copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer);
  TextStyle onSurface(BuildContext context) =>
      copyWith(color: Theme.of(context).colorScheme.onSurface);
  TextStyle onSurfaceVariant(BuildContext context) =>
      copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
}

/// enum of all DynamicSchemeVariants
enum TraleSchemeVariant {
  /// expressive colors
  expressive,

  /// material
  material,

  /// neutral colors
  neutral,

  /// vibrant colors
  vibrant,

  /// monochrome
  monochrome,

  /// content similar to fidelity but matches seed color
  seed,

  /// material2 colors
  material2,
}

/// extend adonisThemes with adding AdonisTheme attributes
extension TraleSchemeVariantExtension on TraleSchemeVariant {
  /// get seed color of theme
  DynamicSchemeVariant get schemeVariant =>
      <TraleSchemeVariant, DynamicSchemeVariant>{
        TraleSchemeVariant.material: DynamicSchemeVariant.tonalSpot,
        TraleSchemeVariant.material2: DynamicSchemeVariant.fidelity,
        TraleSchemeVariant.neutral: DynamicSchemeVariant.neutral,
        TraleSchemeVariant.vibrant: DynamicSchemeVariant.vibrant,
        TraleSchemeVariant.expressive: DynamicSchemeVariant.expressive,
        TraleSchemeVariant.monochrome: DynamicSchemeVariant.monochrome,
        TraleSchemeVariant.seed: DynamicSchemeVariant.content,
      }[this]!;

  /// get string expression
  String get name => toString().split('.').last;
}

/// convert string to type
extension TraleSchemeVariantParsing on String {
  /// convert string to trale scheme variant
  TraleSchemeVariant? toTraleSchemeVariant() {
    for (final TraleSchemeVariant variant in TraleSchemeVariant.values) {
      if (this == variant.name) {
        return variant;
      }
    }
    return null;
  }
}
