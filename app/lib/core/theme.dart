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
double overlayOpacity(double elevation)
  => (4.5 * math.log(elevation + 1) + 2) / 100.0;


/// overlay color with elevation
Color colorElevated(Color color, double elevation) => Color.alphaBlend(
  getFontColor(color).withOpacity(overlayOpacity(elevation)), color,
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
class TraleTheme {
  /// Default constructor
  TraleTheme({
    required this.seedColor,
    required this.brightness,
    this.isAmoled=false,
    this.contrast=0.0,
  });

  /// copyWith constructor
  TraleTheme copyWith({
    Brightness? brightness,
    Color? seedColor,
    bool? isAmoled,
    double? contrast,
  }) {
    return TraleTheme(
      brightness: brightness ?? this.brightness,
      seedColor: seedColor ?? this.seedColor,
      isAmoled: isAmoled ?? this.isAmoled,
      contrast: contrast ?? this.contrast,
    );
  }

  /// Get current AdonisTheme
  static TraleTheme? of(BuildContext context) {
    final TraleApp? result =
    context.findAncestorWidgetOfExactType<TraleApp>();
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
  /// Border shape
  final RoundedRectangleBorder borderShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  );
  /// Padding value
  final double padding = 16;
  /// if true make background true black
  late bool isAmoled;
  /// contrast level
  late double contrast;
  /// Get border radius
  double get borderRadius => 16;

  /// get transition durations
  final TransitionDuration transitionDuration =
    TransitionDuration(100, 200, 500);

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
    getFontColor(clr).withValues(
        alpha: overlayOpacity(elevation)
    ), clr,
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
  Color bgElevated(double elevation) => colorOfElevation(
      elevation, themeData.colorScheme.surface
  );

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

  /// color threshold for grey
  final double colorThreshold = 15 / 255;

  /// get if seed color is shade of grey
  bool get isGrey => (seedColor.r - seedColor.g).abs() < colorThreshold
      && (seedColor.g - seedColor.b).abs() < colorThreshold;

  /// get corresponding ThemeData
  ThemeData get themeData {
    // Color txtColor = txtTheme.bodyText1.color;
    ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
      contrastLevel: contrast,
      dynamicSchemeVariant: isGrey
        ? DynamicSchemeVariant.fidelity
        : DynamicSchemeVariant.tonalSpot,
    ).harmonized();
    if (isAmoled) {
      colorScheme = colorScheme.copyWith(surface: Colors.black).harmonized();
    }

    // Create a TextTheme and ColorScheme, that we can use to generate ThemeData
    final TextTheme txtTheme = ThemeData.from(
      colorScheme: colorScheme,
    ).textTheme.apply(fontFamily: 'Lexend');

    final ListTileThemeData listTileThemeData = ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );

    const SliderThemeData sliderTheme = SliderThemeData(
      year2023: false,
    );

    const CardThemeData cardTheme = CardThemeData(
      shadowColor: Colors.transparent,
    );

    const ProgressIndicatorThemeData progressIndicatorTheme =
      ProgressIndicatorThemeData(year2023: false);

    /// Now that we have ColorScheme and TextTheme, we can create the ThemeData
    final ThemeData theme = ThemeData.from(
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
  TraleTheme get amoled{
    return copyWith(isAmoled: true);
  }
}


/// defining all workout difficulties
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
  }[this]!;

  /// get contrast level
  double contrast(BuildContext context) =>
    Provider.of<TraleNotifier>(context, listen: false).contrastLevel.contrast;

  /// get corresponding light theme
  TraleTheme light(BuildContext context) => TraleTheme(
    seedColor: seedColor(context),
    brightness: Brightness.light,
    contrast: contrast(context),
  );

  /// get corresponding light theme
  TraleTheme dark(BuildContext context) => TraleTheme(
    seedColor: seedColor(context),
    brightness: Brightness.dark,
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
  String nameLong (BuildContext context) => <ThemeMode, String>{
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
  const TraleThemeExtension({
    @required this.padding,
  });

  /// global padding parameter
  final double? padding;

  /// create getter for onPrimaryContainer textTheme
  TextTheme primaryContainerTextTheme (BuildContext context) =>
    Theme.of(context).textTheme.apply(
      bodyColor: Theme.of(context).colorScheme.onPrimaryContainer,
      displayColor: Theme.of(context).colorScheme.onPrimaryContainer,
      decorationColor: Theme.of(context).colorScheme.onPrimaryContainer,
    );

  @override
  TraleThemeExtension copyWith({double? padding}) {
    return TraleThemeExtension(
      padding: padding ?? this.padding,
    );
  }

  @override
  TraleThemeExtension lerp(
      ThemeExtension<TraleThemeExtension>? other, double t,
  ) {
    if (other is! TraleThemeExtension) {
      return this;
    }
    return TraleThemeExtension(
      padding: lerpDouble(padding, other.padding, t)
    );
  }
}

/// extension of theme
extension ColorTextThemeExtension on TextStyle {
  TextStyle onSecondaryContainer(BuildContext context) => copyWith(
    color: Theme.of(context).colorScheme.onSecondaryContainer,
  );
  TextStyle onSurface(BuildContext context) => copyWith(
    color: Theme.of(context).colorScheme.onSurface,
  );
  TextStyle onSurfaceVariant(BuildContext context) => copyWith(
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );
}