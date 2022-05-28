import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
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
  });

  /// copyWith constructor
  TraleTheme copyWith({
    Brightness? brightness,
    Color? seedColor,
    bool? isAmoled,
  }) {
    return TraleTheme(
      brightness: brightness ?? this.brightness,
      seedColor: seedColor ?? this.seedColor,
      isAmoled: isAmoled ?? this.isAmoled,
    );
  }

  /// Get current AdonisTheme
  static TraleTheme? of(BuildContext context) {
    final TraleApp? result =
    context.findAncestorWidgetOfExactType<TraleApp>();
    return Theme.of(context).brightness == Brightness.light
      ? result?.traleNotifier.theme.light
      : (result != null && result.traleNotifier.isAmoled)
        ? result.traleNotifier.theme.amoled
        : result?.traleNotifier.theme.dark;
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
  /// Get border radius
  double get borderRadius => 16;

  final TransitionDuration transitionDuration =
    TransitionDuration(100, 200, 500);

  /// get background gradient
  LinearGradient get bgGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[themeData.colorScheme.background, bgShade4],
  );

  /// if dark mode enabled
  bool get isDark => brightness == Brightness.dark;

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
  /// 2 elevation shade of bg
  Color get bgShade4 => bgElevated(1);
  /// get elevated shade of bg
  Color bgElevated(double elevation) => colorOfElevation(
      elevation, themeData.colorScheme.background
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

  /// get corresponding ThemeData
  ThemeData get themeData {
    // Color txtColor = txtTheme.bodyText1.color;
    ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    ).harmonized();
    if (isAmoled) {
      colorScheme = colorScheme.copyWith(background: Colors.black).harmonized();
    }

    // Create a TextTheme and ColorScheme, that we can use to generate ThemeData
    final TextTheme txtTheme = ThemeData.from(
      colorScheme: colorScheme,
    ).textTheme.apply(fontFamily: 'Quicksand');

    /// icon theme data
    // final IconThemeData iconTheme = IconThemeData(
    //   color: bgFont,
    //   opacity: 0.8,
    //   size: 24.0
    // );

    // final FloatingActionButtonThemeData FABTheme =
    //   FloatingActionButtonThemeData(
    //     foregroundColor: accentFont,
    //     backgroundColor: accent,
    //     elevation: 6,
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    //   );

    // final SnackBarThemeData snackBarTheme = SnackBarThemeData(
    //   backgroundColor: bgElevated(67108864),
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.vertical(
    //       top: Radius.circular(borderRadius)
    //     ),
    //   )
    // );

    // final DialogTheme dialogTheme = DialogTheme(
    //   elevation: 24,
    //   backgroundColor: bg,
    //   shape: borderShape,
    //   titleTextStyle: txtTheme.headline6,
    //   contentTextStyle:txtTheme.bodyText2,
    // );

    // const BottomAppBarTheme bottomAppBarTheme = BottomAppBarTheme(
    //   elevation: 8,
    // );

    // final AppBarTheme appBarTheme = AppBarTheme(
    //   color: bg,
    //   elevation: 0,
    //   iconTheme: iconTheme,
    // );

    // const PageTransitionsTheme pageTransitionsTheme = PageTransitionsTheme(
    //   builders: <TargetPlatform, PageTransitionsBuilder>{
    //     TargetPlatform.android: ZoomPageTransitionsBuilder(),
    //   },
    // );

    // final ButtonThemeData buttonTheme = ButtonThemeData(
    //   shape: borderShape,
    // );

    // final ButtonStyle buttonStyle = ButtonStyle(
    //   shape: MaterialStateProperty.resolveWith(
    //     (Set<MaterialState> states) => borderShape
    //   ),
    // );

    // final TextButtonThemeData textButtonTheme = TextButtonThemeData(
    //   style: buttonStyle,
    // );
    // final ElevatedButtonThemeData elevatedButtonThemeData =
    //   ElevatedButtonThemeData(
    //     style: buttonStyle,
    // );
    // final OutlinedButtonThemeData outlinedButtonThemeData =
    //   OutlinedButtonThemeData(
    //     style: buttonStyle,
    // );
    // const CardTheme cardTheme = CardTheme(
    //   elevation: 2,
    // );

    /// Now that we have ColorScheme and TextTheme, we can create the ThemeData
    final ThemeData theme = ThemeData.from(
      textTheme: txtTheme,
      colorScheme: colorScheme,
      useMaterial3: true,
    ).copyWith(
      toggleableActiveColor: colorScheme.primary,
    );

    //    .copyWith(
    //      useMaterial3: true,
    //      appBarTheme: appBarTheme,
    //      bottomAppBarTheme: bottomAppBarTheme,
    //      cardTheme: cardTheme,
    //      buttonTheme: buttonTheme,
    //      dialogTheme: dialogTheme,
    //      elevatedButtonTheme: elevatedButtonThemeData,
    //      floatingActionButtonTheme: FABTheme,
    //      highlightColor: accent,
    //      iconTheme: iconTheme,
    //      outlinedButtonTheme: outlinedButtonThemeData,
    //      pageTransitionsTheme: pageTransitionsTheme,
    //      snackBarTheme: snackBarTheme,
    //      textButtonTheme: textButtonTheme,
    //      toggleableActiveColor: accent,
    //      unselectedWidgetColor: bgFontLight,
    //    );

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
  Color get seedColor => <TraleCustomTheme, Color>{
    TraleCustomTheme.fire: const Color(0xFFb52528),
    TraleCustomTheme.lemon: const Color(0xFF626200),
    TraleCustomTheme.sand: const Color(0xFF7e5700),
    TraleCustomTheme.water: const Color(0xFF0161a3),
    TraleCustomTheme.forest: const Color(0xFF006e11),
    TraleCustomTheme.berry: const Color(0xff8b4463),
    TraleCustomTheme.plum: const Color(0xff8e4585),
  }[this]!;

  /// get corresponding light theme
  TraleTheme get light => TraleTheme(
    seedColor: seedColor, brightness: Brightness.light,
  );

  /// get corresponding light theme
  TraleTheme get dark => TraleTheme(
    seedColor: seedColor, brightness: Brightness.dark,
  );

  /// get amoled dark theme
  TraleTheme get amoled => dark.amoled;

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