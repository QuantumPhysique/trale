import 'package:dynamic_color/dynamic_color.dart';
import 'package:material_ui/material_ui.dart';
import 'package:quantumphysique/src/theme/qp_system_colors.dart';
import 'package:quantumphysique/src/types/contrast.dart';
import 'package:quantumphysique/src/types/scheme_variant.dart';

/// Builds a [ThemeData] from the given parameters.
///
/// This is the canonical theme-building function shared by all
/// quantumphysique-based apps. It uses [ColorScheme.fromSeed] with
/// Material 3 and applies the app's font family.
///
/// Pass [systemColors] to build the scheme from the palettes the operating
/// system reported instead of seeding it from [seedColor]. [contrast] still
/// applies on that path; [isGrey] does not.
ThemeData buildQPThemeData({
  required Color seedColor,
  required Brightness brightness,
  required QPSchemeVariant schemeVariant,
  required QPContrast contrast,
  bool isAmoled = false,
  bool isGrey = false,
  QPSystemColors? systemColors,
}) {
  // [isGrey] only ever fires for the achromatic fallback seed, which is used
  // exactly when there are no system colours to work from — so the monochrome
  // override must not reach the system path and flatten a genuinely
  // low-chroma system palette.
  ColorScheme colorScheme =
      (systemColors != null
              ? systemColors.toColorScheme(
                  brightness: brightness,
                  contrastLevel: contrast.contrast,
                  variant: schemeVariant.toDynamicSchemeVariant,
                )
              : ColorScheme.fromSeed(
                  seedColor: seedColor,
                  brightness: brightness,
                  contrastLevel: contrast.contrast,
                  dynamicSchemeVariant: isGrey
                      ? DynamicSchemeVariant.monochrome
                      : schemeVariant.toDynamicSchemeVariant,
                ))
          .harmonized();

  if (isAmoled && brightness == Brightness.dark) {
    colorScheme = colorScheme.copyWith(surface: Colors.black).harmonized();
  }

  final TextTheme txtTheme = ThemeData.from(colorScheme: colorScheme).textTheme
      .apply(
        fontFamily: 'packages/quantumphysique/RobotoFlex',
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
