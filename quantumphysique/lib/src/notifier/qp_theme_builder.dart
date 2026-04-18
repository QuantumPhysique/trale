import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:quantumphysique/src/types/contrast.dart';
import 'package:quantumphysique/src/types/scheme_variant.dart';

/// Builds a [ThemeData] from the given parameters.
///
/// This is the canonical theme-building function shared by all
/// quantumphysique-based apps. It uses [ColorScheme.fromSeed] with
/// Material 3 and applies the app's font family.
ThemeData buildQPThemeData({
  required Color seedColor,
  required Brightness brightness,
  required QPSchemeVariant schemeVariant,
  required QPContrast contrast,
  bool isAmoled = false,
  bool isGrey = false,
}) {
  ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
    contrastLevel: contrast.contrast,
    dynamicSchemeVariant: isGrey
        ? DynamicSchemeVariant.monochrome
        : schemeVariant.toDynamicSchemeVariant,
  ).harmonized();

  if (isAmoled && brightness == Brightness.dark) {
    colorScheme = colorScheme.copyWith(surface: Colors.black).harmonized();
  }

  final TextTheme txtTheme = ThemeData.from(colorScheme: colorScheme).textTheme
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
