// ignore_for_file: deprecated_member_use

import 'package:flutter_test/flutter_test.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:material_ui/material_ui.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:quantumphysique/src/notifier/qp_theme_builder.dart';

// ---------------------------------------------------------------------------
// Test doubles
// ---------------------------------------------------------------------------

/// A core palette shaped like an Android "Expressive" theme: the tertiary hue
/// is rotated far away from the primary, and the neutrals are warm and much
/// more chromatic than the ones [ColorScheme.fromSeed] would derive.
///
/// Re-seeding from the primary colour cannot reproduce any of that, which is
/// exactly what these tests pin down.
CorePalette _osPalette() => CorePalette.fromList(<int>[
  ...TonalPalette.of(280, 48).asList,
  ...TonalPalette.of(280, 24).asList,
  ...TonalPalette.of(150, 32).asList,
  ...TonalPalette.of(40, 12).asList,
  ...TonalPalette.of(40, 16).asList,
]);

ColorScheme _scheme(
  QPSystemColors colors, {
  Brightness brightness = Brightness.light,
  double contrastLevel = 0.0,
}) => colors.toColorScheme(
  brightness: brightness,
  contrastLevel: contrastLevel,
  variant: DynamicSchemeVariant.tonalSpot,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('QPSystemColors.fromCorePalette', () {
    test('keeps the system primary exactly instead of re-deriving it', () {
      final CorePalette core = _osPalette();
      final ColorScheme scheme = _scheme(QPSystemColors.fromCorePalette(core));

      expect(scheme.primary.toARGB32(), core.primary.get(40));
      expect(
        scheme.primary.toARGB32(),
        isNot(
          ColorScheme.fromSeed(seedColor: scheme.primary).primary.toARGB32(),
        ),
      );
    });

    test('uses the system tertiary palette, not one derived from the '
        'primary', () {
      final CorePalette core = _osPalette();
      final ColorScheme scheme = _scheme(QPSystemColors.fromCorePalette(core));
      final ColorScheme reSeeded = ColorScheme.fromSeed(
        seedColor: scheme.primary,
      );

      expect(scheme.tertiary.toARGB32(), core.tertiary.get(40));
      expect(scheme.tertiary.toARGB32(), isNot(reSeeded.tertiary.toARGB32()));
    });

    test('resolves the surface container roles from the system neutral '
        'palette', () {
      final CorePalette core = _osPalette();
      final ColorScheme scheme = _scheme(QPSystemColors.fromCorePalette(core));
      final ColorScheme reSeeded = ColorScheme.fromSeed(
        seedColor: scheme.primary,
      );

      // The regression this whole change exists for: dynamic_color leaves
      // these seeded, so they used to come out byte-identical to reSeeded.
      expect(scheme.surfaceContainerLow.toARGB32(), core.neutral.get(96));
      expect(
        scheme.surfaceContainerLow.toARGB32(),
        isNot(reSeeded.surfaceContainerLow.toARGB32()),
      );
      expect(
        scheme.surfaceContainerHigh.toARGB32(),
        isNot(reSeeded.surfaceContainerHigh.toARGB32()),
      );
    });

    test('still honours the contrast level', () {
      final QPSystemColors colors = QPSystemColors.fromCorePalette(
        _osPalette(),
      );

      expect(
        _scheme(colors, contrastLevel: 0.5).onSurface,
        isNot(_scheme(colors).onSurface),
      );
      expect(
        _scheme(colors, contrastLevel: 0.5).primary,
        isNot(_scheme(colors).primary),
      );
    });

    test('reports the accent colour as tone 40 of the system primary', () {
      final CorePalette core = _osPalette();

      expect(
        QPSystemColors.fromCorePalette(core).accentColor.toARGB32(),
        core.primary.get(40),
      );
      expect(QPSystemColors.fromCorePalette(core).hasPalettes, isTrue);
    });
  });

  group('QPSystemColors.fromAccent', () {
    test('falls back to a seeded scheme on accent-only platforms', () {
      const Color accent = Color(0xFF6750A4);
      final ColorScheme scheme = _scheme(
        const QPSystemColors.fromAccent(accent),
      );
      final ColorScheme expected = ColorScheme.fromSeed(seedColor: accent);

      expect(scheme.primary, expected.primary);
      expect(scheme.surface, expected.surface);
      expect(scheme.surfaceContainerLow, expected.surfaceContainerLow);
      expect(scheme.outline, expected.outline);
    });

    test('reports no palettes', () {
      const QPSystemColors colors = QPSystemColors.fromAccent(
        Color(0xFF6750A4),
      );

      expect(colors.hasPalettes, isFalse);
      expect(colors.accentColor, const Color(0xFF6750A4));
    });
  });

  group('buildQPThemeData', () {
    test('uses the system palettes when they are passed in', () {
      final CorePalette core = _osPalette();
      final ThemeData theme = buildQPThemeData(
        seedColor: Colors.black,
        brightness: Brightness.light,
        schemeVariant: QPSchemeVariant.material,
        contrast: QPContrast.normal,
        systemColors: QPSystemColors.fromCorePalette(core),
      );

      expect(theme.colorScheme.primary.toARGB32(), core.primary.get(40));
    });

    test('ignores the monochrome fallback on the system path', () {
      final CorePalette core = _osPalette();
      final ThemeData theme = buildQPThemeData(
        // A grey seed would force DynamicSchemeVariant.monochrome on the
        // seeded path; the system path must not be flattened by it.
        seedColor: Colors.black,
        brightness: Brightness.light,
        schemeVariant: QPSchemeVariant.material,
        contrast: QPContrast.normal,
        isGrey: true,
        systemColors: QPSystemColors.fromCorePalette(core),
      );

      expect(theme.colorScheme.primary.toARGB32(), core.primary.get(40));
    });

    test('still applies AMOLED on top of the system palettes', () {
      final ThemeData theme = buildQPThemeData(
        seedColor: Colors.black,
        brightness: Brightness.dark,
        schemeVariant: QPSchemeVariant.material,
        contrast: QPContrast.normal,
        isAmoled: true,
        systemColors: QPSystemColors.fromCorePalette(_osPalette()),
      );

      expect(theme.colorScheme.surface, Colors.black);
    });
  });
}
