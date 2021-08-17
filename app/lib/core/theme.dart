import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:trale/main.dart';


/// get color (black or white) with maximal constrast or minimal (inverse=false)
Color getFontColor(Color color, {bool inverse = true}) {
  return isDarkColor(color) == inverse ? Colors.white : Colors.black;
}

/// check if color is closer to black or white
bool isDarkColor(Color color) {
  final double luminance =
      0.2126 * color.red + 0.7152 * color.green + 0.0722 * color.blue;
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

/// Theme class for Adonify app
class TraleTheme {
  /// Default constructor
  TraleTheme({
    required this.accent,
    required this.isDark,
    Color? bg,
    Color? bgFont,
    Color? accentFont,
    Color? bgFontLight,
    Color? accentFontLight,
    double? borderRadius,
    double? padding,
  }) {
    // this.isDark = isDark
    //   ?? ThemeData.estimateBrightnessForColor(bg) == Brightness.dark;

    final Color accentBlend = accent.withAlpha(isDark ? 4 : 2);
    this.bg = bg ??
      (isDark
        ? Color.alphaBlend(accentBlend, const Color(0xFF121212))
        : Color.alphaBlend(accentBlend, Colors.white));

    this.bgFont = bgFont ?? getFontColor(this.bg);
    this.accentFont = accentFont ?? getFontColor(accent);

    this.bgFontLight = bgFontLight ?? Color.alphaBlend(
        getFontColor(this.bgFont, inverse: false).withAlpha(18),
        this.bgFont,
    );
    this.accentFontLight = accentFontLight ?? Color.alphaBlend(
        getFontColor(this.accentFont, inverse: false).withAlpha(18),
        this.bgFont,
    );

    borderShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
    );

    this.padding = padding ?? 16;
  }

  /// copyWith constructor
  TraleTheme copyWith({
    bool? isDark,
    Color? accent,
    Color? bg,
    Color? bgFont,
    Color? bgFontLight,
    Color? accentFont,
    Color? accentFontLight,
    double? borderRadius,
    double? padding,
  }) {
    return TraleTheme(
      isDark: isDark ?? this.isDark,
      accent: accent ?? this.accent,
      bg: bg ?? this.bg,
      bgFont: bgFont ?? this.bgFont,
      accentFont: accentFont ?? this.accentFont,
      bgFontLight: bgFontLight ?? this.bgFontLight,
      accentFontLight: accentFontLight ?? this.accentFontLight,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
    );
  }

  /// Get current AdonisTheme
  static TraleTheme? of(BuildContext context) {
    assert(context != null);
    final TraleApp? result =
    context.findAncestorWidgetOfExactType<TraleApp>();
    return Theme.of(context).brightness == Brightness.light
      ? result?.traleNotifier.theme.light
      : (result != null && result.traleNotifier.isAmoled)
        ? result.traleNotifier.theme.amoled
        : result?.traleNotifier.theme.dark;
  }

  /// background color
  late Color bg;
  /// accent color
  late Color accent;
  /// background color font
  late Color bgFont;
  /// accent color font
  late Color accentFont;
  /// if dark mode on
  late bool isDark;
  /// Light background font color
  late Color bgFontLight;
  /// Light accent font color
  late Color accentFontLight;
  /// Border shape
  late RoundedRectangleBorder borderShape;
  /// Padding value
  late double padding;
  /// Get border radius
  double get borderRadius => borderShape.borderRadius.resolve(
    TextDirection.ltr,
  ).bottomLeft.x;


//  /// return dark mode
//  bool get GetIsDark => this.isDark;
//  set SetIsDark(bool variable) {
//    this.isDark = variable;
//  }
  /// get elevated shade of clr
  Color colorOfElevation(double elevation, Color clr) => Color.alphaBlend(
    getFontColor(clr).withOpacity(overlayOpacity(elevation)), clr,
  );
  /// 24 elevation shade of bg
  Color get bgShade1 => bgElevated(24);
  /// 6 elevation shade of bg
  Color get bgShade2 => bgElevated(6);
  /// 2 elevation shade of bg
  Color get bgShade3 => bgElevated(2);
  /// get elevated shade of bg
  Color bgElevated(double elevation) => colorOfElevation(elevation, bg);

  /// return animation duration
  Duration get transitionDuration => const Duration(milliseconds: 300);

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

  /// get corresponding ThemeData
  ThemeData get themeData {
    // Create a TextTheme and ColorScheme, that we can use to generate ThemeData
    final TextTheme txtTheme = (
      isDark ? ThemeData.dark() : ThemeData.light()
    ).textTheme.apply(
      fontFamily: 'Quicksand',
      bodyColor: bgFont,
      displayColor: bgFont,
      decorationColor: bgFontLight,
    );
    final TextTheme accentTxtTheme = txtTheme.copyWith().apply(
      displayColor: accentFont,
      bodyColor: accentFont,
    );

    // Color txtColor = txtTheme.bodyText1.color;
    final ColorScheme colorScheme = ColorScheme(
      // Decide how you want to apply your own custom them, to the MaterialApp
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: accent,
        primaryVariant: accent,
        secondary: accent,
        secondaryVariant: accent,
        background: bg,
        surface: bg,
        onBackground: bgFont,
        onSurface: bgFont,
        onError: Colors.white,
        onPrimary: accentFont,
        onSecondary: accentFont,
        error: Colors.red.shade400,
    );

    /// icon theme data
    final IconThemeData iconTheme = IconThemeData(
      color: bgFont,
      opacity: 0.8,
      size: 24.0
    );

    final IconThemeData accentIconTheme = iconTheme.copyWith(
      color: accentFont,
    );

    final FloatingActionButtonThemeData FABTheme =
      FloatingActionButtonThemeData(
        foregroundColor: accentFont,
        backgroundColor: accent,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      );

    final SnackBarThemeData snackBarTheme = SnackBarThemeData(
      backgroundColor: bgElevated(67108864),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(borderRadius)
        ),
      )
    );

    final DialogTheme dialogTheme = DialogTheme(
      elevation: 24,
      backgroundColor: bg,
      shape: borderShape,
      titleTextStyle: txtTheme.headline6,
      contentTextStyle:txtTheme.bodyText2,
    );

    const BottomAppBarTheme bottomAppBarTheme = BottomAppBarTheme(
      elevation: 8,
    );

    final AppBarTheme appBarTheme = AppBarTheme(
      color: bg,
      elevation: 0,
      iconTheme: iconTheme,
    );

    const PageTransitionsTheme pageTransitionsTheme = PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
      },
    );

    final ButtonThemeData buttonTheme = ButtonThemeData(
      shape: borderShape,
    );

    final ButtonStyle buttonStyle = ButtonStyle(
      shape: MaterialStateProperty.resolveWith(
        (Set<MaterialState> states) => borderShape
      ),
    );

    final TextButtonThemeData textButtonTheme = TextButtonThemeData(
      style: buttonStyle,
    );
    final ElevatedButtonThemeData elevatedButtonThemeData =
      ElevatedButtonThemeData(
        style: buttonStyle,
    );
    final OutlinedButtonThemeData outlinedButtonThemeData =
      OutlinedButtonThemeData(
        style: buttonStyle,
    );

    /// Now that we have ColorScheme and TextTheme, we can create the ThemeData
    final ThemeData theme = ThemeData.from(
        textTheme: txtTheme,
        colorScheme: colorScheme)
        .copyWith(
          appBarTheme: appBarTheme,
          accentIconTheme: accentIconTheme,
          accentTextTheme: accentTxtTheme,
          bottomAppBarTheme: bottomAppBarTheme,
          buttonColor: accent,
          buttonTheme: buttonTheme,
          cursorColor: accent,
          dialogTheme: dialogTheme,
          elevatedButtonTheme: elevatedButtonThemeData,
          floatingActionButtonTheme: FABTheme,
          highlightColor: accent,
          iconTheme: iconTheme,
          outlinedButtonTheme: outlinedButtonThemeData,
          pageTransitionsTheme: pageTransitionsTheme,
          snackBarTheme: snackBarTheme,
          textButtonTheme: textButtonTheme,
          toggleableActiveColor: accent,
          unselectedWidgetColor: bgFontLight,
        );

    /// Return the themeData which MaterialApp can now use
    return theme;
  }

  /// return amoled version with true black
  TraleTheme get amoled{
    return copyWith(bg: Colors.black);
  }
}

/// Light Theme
/// Find material value shade with
/// http://mcg.mbitson.com/#!?mcgpalette0=%230084bf
TraleTheme waterLightTheme = TraleTheme(
    isDark: false,
    accent: const Color(0xFF1063a3),//const Color(0xFF2696c9),//const Color(0xFF4a8cb1), //const Color(0xFFF54149),
  );

/// Dark theme should use 200 values colors only
/// To create them from individual colors use
/// https://material.io/design/color/the-color-system.html#tools-for-picking-colors
TraleTheme waterDarkTheme = TraleTheme(
    isDark: true,
    accent: const Color(0xFF80c2df),//const Color(0xFF95d6e7), //const Color(0xFFF54149),
);

/// Alternative Theme
TraleTheme marineLightTheme = TraleTheme(
  isDark: false,
  bg: const Color(0xFF1d3557),
  accent: const Color(0xFFe63946),
  bgFont: const Color(0xFFf1faee),
);
/// Alternative Theme
TraleTheme marineDarkTheme = TraleTheme(
  isDark: true,
  bg: const Color(0xFF0f1c2e),
  accent: const Color(0xFFe6606b),
  bgFont: const Color(0xFFf1faee),
);
/// Alternative Theme
TraleTheme forestLightTheme = TraleTheme(
  isDark: false,
  bg: const Color(0xFFfbfffb),
  accent: const Color(0xFF1a535c),
);
/// Alternative Theme
TraleTheme forestDarkTheme = TraleTheme(
  isDark: true,
  bg: const Color(0xFF0d2b30),
  accent: const Color(0xFF50BDCE),
);
/// Alternative Theme
TraleTheme powerLightTheme = TraleTheme(
  isDark: false,
  bg: const Color(0xFFffffff),
  accent: const Color(0xFFfca311),
);
/// Alternative Theme
TraleTheme powerDarkTheme = TraleTheme(
  isDark: true,
  bg: const Color(0xFF14213D),
  accent: const Color(0xFFf8b03c),
);
/// Alternative Theme
TraleTheme sandLightTheme = TraleTheme(
  isDark: false,
  bg: const Color(0xFF292625),
  accent: const Color(0xFFd4ad70),
);
/// Alternative Theme
TraleTheme sandDarkTheme = TraleTheme(
  isDark: true,
  bg: const Color(0xFF151413),
  accent: const Color(0xFFd9b981),
);
/// Alternative Theme
TraleTheme fireLightTheme = TraleTheme(
  isDark: false,
  accent: const Color(0xFFc55959),
);
/// Alternative Theme
TraleTheme fireDarkTheme = TraleTheme(
  isDark: true,
  accent: const Color(0xFFCD7171),
);


/// defining all workout difficulties
enum TraleCustomTheme {
  /// red theme
  fire,
  /// blue yellow theme
  power,
  /// blue theme
  water,
  /// Blue dark theme
  marine,
  /// greenish theme
  forest,
  /// sand theme
  sand,
}

/// extend adonisThemes with adding AdonisTheme attributes
extension TraleCustomThemeExtension on TraleCustomTheme {
  /// get corresponding light theme
  TraleTheme get light => <TraleCustomTheme, TraleTheme>{
    TraleCustomTheme.marine: marineLightTheme,
    TraleCustomTheme.power: powerLightTheme,
    TraleCustomTheme.forest: forestLightTheme,
    TraleCustomTheme.water: waterLightTheme,
    TraleCustomTheme.fire: fireLightTheme,
    TraleCustomTheme.sand: sandLightTheme,
  }[this]!;

  /// get corresponding dark theme
  TraleTheme get dark => <TraleCustomTheme, TraleTheme>{
    TraleCustomTheme.marine: marineDarkTheme,
    TraleCustomTheme.power: powerDarkTheme,
    TraleCustomTheme.forest: forestDarkTheme,
    TraleCustomTheme.water: waterDarkTheme,
    TraleCustomTheme.fire: fireDarkTheme,
    TraleCustomTheme.sand: sandDarkTheme,
  }[this]!;

  /// get amoled dark theme
  TraleTheme get amoled => dark.amoled;

  /// get string expression
  String get name => toString().split('.').last;
}

/// convert string to type
extension CustomThemeParsing on String {
  /// convert number to difficulty
  TraleCustomTheme? toTraleCustomTheme() {
    for (TraleCustomTheme theme in TraleCustomTheme.values)
      if (this == theme.name)
        return theme;
    return null;
  }
}

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
}