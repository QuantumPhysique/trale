import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/theme.dart';
import 'package:flutter/material.dart';

void main() {
  group('getFontColor', () {
    test('returns white for dark colors', () {
      final darkColor = Color(0xFF000000); // Black
      expect(getFontColor(darkColor), Colors.white);
    });

    test('returns black for light colors', () {
      final lightColor = Color(0xFFFFFFFF); // White
      expect(getFontColor(lightColor), Colors.black);
    });

    test('inverse parameter inverts behavior', () {
      final darkColor = Color(0xFF000000);
      expect(getFontColor(darkColor, inverse: false), Colors.black);

      final lightColor = Color(0xFFFFFFFF);
      expect(getFontColor(lightColor, inverse: false), Colors.white);
    });
  });

  group('isDarkColor', () {
    test('returns true for dark colors', () {
      expect(isDarkColor(Color(0xFF000000)), true); // Black
      expect(isDarkColor(Color(0xFF333333)), true); // Dark grey
    });

    test('returns false for light colors', () {
      expect(isDarkColor(Color(0xFFFFFFFF)), false); // White
      expect(isDarkColor(Color(0xFFCCCCCC)), false); // Light grey
    });

    test('uses luminance calculation', () {
      // Test the threshold at 140
      final Color darkThreshold = Color.fromARGB(255, 139, 139, 139);
      final Color lightThreshold = Color.fromARGB(255, 141, 141, 141);

      expect(isDarkColor(darkThreshold), true);
      expect(isDarkColor(lightThreshold), false);
    });
  });

  group('overlayOpacity', () {
    test('returns correct opacity for different elevations', () {
      expect(overlayOpacity(0), closeTo(0.02, 0.01));
      expect(overlayOpacity(1), closeTo(0.051, 0.01));
      expect(overlayOpacity(2), closeTo(0.069, 0.01));
      expect(overlayOpacity(6), closeTo(0.108, 0.01));
      expect(overlayOpacity(24), closeTo(0.164, 0.01));
    });

    test('opacity increases with elevation', () {
      final opacity1 = overlayOpacity(1);
      final opacity5 = overlayOpacity(5);
      final opacity10 = overlayOpacity(10);

      expect(opacity1 < opacity5, true);
      expect(opacity5 < opacity10, true);
    });
  });

  group('colorElevated', () {
    test('adds overlay to color', () {
      final baseColor = Color(0xFF0000FF); // Blue
      final elevated = colorElevated(baseColor, 6);

      // The elevated color should be different from the base color
      expect(elevated, isNot(equals(baseColor)));
    });

    test('higher elevation creates more overlay', () {
      final baseColor = Color(0xFF0000FF);
      final elevated6 = colorElevated(baseColor, 6);
      final elevated24 = colorElevated(baseColor, 24);

      // Can't easily compare color values directly, but they should be different
      expect(elevated6, isNot(equals(elevated24)));
    });
  });

  group('TransitionDuration', () {
    test('constructor sets durations', () {
      final duration = TransitionDuration(100, 200, 500);

      expect(duration.fast.inMilliseconds, 100);
      expect(duration.normal.inMilliseconds, 200);
      expect(duration.slow.inMilliseconds, 500);
    });

    test('returns Duration objects', () {
      final duration = TransitionDuration(150, 300, 600);

      expect(duration.fast, isA<Duration>());
      expect(duration.normal, isA<Duration>());
      expect(duration.slow, isA<Duration>());
    });
  });

  group('TraleTheme', () {
    test('constructor creates theme', () {
      final theme = TraleTheme(
        seedColor: Colors.blue,
        brightness: Brightness.light,
        schemeVariant: DynamicSchemeVariant.tonalSpot,
      );

      expect(theme.seedColor, Colors.blue);
      expect(theme.brightness, Brightness.light);
      expect(theme.isAmoled, false);
      expect(theme.contrast, 0.0);
    });

    test('copyWith creates new theme with changes', () {
      final theme = TraleTheme(
        seedColor: Colors.blue,
        brightness: Brightness.light,
        schemeVariant: DynamicSchemeVariant.tonalSpot,
      );

      final copied = theme.copyWith(brightness: Brightness.dark);

      expect(copied.brightness, Brightness.dark);
      expect(copied.seedColor, Colors.blue);
    });

    test('borderRadius returns correct value', () {
      final theme = TraleTheme(
        seedColor: Colors.blue,
        brightness: Brightness.light,
        schemeVariant: DynamicSchemeVariant.tonalSpot,
      );

      expect(theme.borderRadius, 16.0);
      expect(theme.innerBorderRadius, 4.0);
    });

    test('padding returns correct value', () {
      final theme = TraleTheme(
        seedColor: Colors.blue,
        brightness: Brightness.light,
        schemeVariant: DynamicSchemeVariant.tonalSpot,
      );

      expect(theme.padding, 16.0);
    });

    test('space returns correct value', () {
      final theme = TraleTheme(
        seedColor: Colors.blue,
        brightness: Brightness.light,
        schemeVariant: DynamicSchemeVariant.tonalSpot,
      );

      expect(theme.space, 2.0);
    });

    test('transitionDuration has correct values', () {
      final theme = TraleTheme(
        seedColor: Colors.blue,
        brightness: Brightness.light,
        schemeVariant: DynamicSchemeVariant.tonalSpot,
      );

      expect(theme.transitionDuration.fast.inMilliseconds, 100);
      expect(theme.transitionDuration.normal.inMilliseconds, 200);
      expect(theme.transitionDuration.slow.inMilliseconds, 500);
    });

    test('snackbarDuration has correct value', () {
      final theme = TraleTheme(
        seedColor: Colors.blue,
        brightness: Brightness.light,
        schemeVariant: DynamicSchemeVariant.tonalSpot,
      );

      expect(theme.snackbarDuration.inSeconds, 5);
    });

    test('isDark checks brightness', () {
      final lightTheme = TraleTheme(
        seedColor: Colors.blue,
        brightness: Brightness.light,
        schemeVariant: DynamicSchemeVariant.tonalSpot,
      );
      final darkTheme = TraleTheme(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
        schemeVariant: DynamicSchemeVariant.tonalSpot,
      );

      expect(lightTheme.isDark, false);
      expect(darkTheme.isDark, true);
    });

    test('isGrey detects grey colors', () {
      final greyTheme = TraleTheme(
        seedColor: Color(0xFF808080),
        brightness: Brightness.light,
        schemeVariant: DynamicSchemeVariant.tonalSpot,
      );
      final colorTheme = TraleTheme(
        seedColor: Colors.blue,
        brightness: Brightness.light,
        schemeVariant: DynamicSchemeVariant.tonalSpot,
      );

      expect(greyTheme.isGrey, true);
      expect(colorTheme.isGrey, false);
    });

    test('amoled creates amoled version', () {
      final theme = TraleTheme(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
        schemeVariant: DynamicSchemeVariant.tonalSpot,
      );

      final amoledTheme = theme.amoled;

      expect(amoledTheme.isAmoled, true);
      expect(amoledTheme.seedColor, Colors.blue);
    });

    test('themeData returns ThemeData', () {
      final theme = TraleTheme(
        seedColor: Colors.blue,
        brightness: Brightness.light,
        schemeVariant: DynamicSchemeVariant.tonalSpot,
      );

      final themeData = theme.themeData;

      expect(themeData, isA<ThemeData>());
      expect(themeData.brightness, Brightness.light);
    });
  });

  group('TraleCustomTheme', () {
    test('enum values exist', () {
      expect(TraleCustomTheme.values.length, 11);
      expect(TraleCustomTheme.values, contains(TraleCustomTheme.system));
      expect(TraleCustomTheme.values, contains(TraleCustomTheme.water));
      expect(TraleCustomTheme.values, contains(TraleCustomTheme.berry));
    });

    test('name returns correct string', () {
      expect(TraleCustomTheme.water.name, 'water');
      expect(TraleCustomTheme.fire.name, 'fire');
      expect(TraleCustomTheme.forest.name, 'forest');
    });
  });

  group('CustomThemeParsing', () {
    test('toTraleCustomTheme converts valid strings', () {
      expect('water'.toTraleCustomTheme(), TraleCustomTheme.water);
      expect('fire'.toTraleCustomTheme(), TraleCustomTheme.fire);
      expect('berry'.toTraleCustomTheme(), TraleCustomTheme.berry);
    });

    test('toTraleCustomTheme returns null for invalid strings', () {
      expect('invalid'.toTraleCustomTheme(), isNull);
      expect(''.toTraleCustomTheme(), isNull);
      expect('WATER'.toTraleCustomTheme(), isNull);
    });
  });

  group('orderedThemeModes', () {
    test('contains all theme modes', () {
      expect(orderedThemeModes.length, 3);
      expect(orderedThemeModes, contains(ThemeMode.light));
      expect(orderedThemeModes, contains(ThemeMode.system));
      expect(orderedThemeModes, contains(ThemeMode.dark));
    });
  });

  group('CustomThemeModeParsing', () {
    test('toThemeMode converts valid strings', () {
      expect('on'.toThemeMode(), ThemeMode.dark);
      expect('off'.toThemeMode(), ThemeMode.light);
      expect('auto'.toThemeMode(), ThemeMode.system);
    });
  });

  group('CustomThemeModeEncoding', () {
    test('toCustomString converts ThemeMode to string', () {
      expect(ThemeMode.dark.toCustomString(), 'on');
      expect(ThemeMode.light.toCustomString(), 'off');
      expect(ThemeMode.system.toCustomString(), 'auto');
    });
  });

  group('TraleSchemeVariant', () {
    test('enum values exist', () {
      expect(TraleSchemeVariant.values.length, 7);
      expect(TraleSchemeVariant.values, contains(TraleSchemeVariant.expressive));
      expect(TraleSchemeVariant.values, contains(TraleSchemeVariant.material));
      expect(TraleSchemeVariant.values, contains(TraleSchemeVariant.neutral));
    });

    test('name returns correct string', () {
      expect(TraleSchemeVariant.material.name, 'material');
      expect(TraleSchemeVariant.vibrant.name, 'vibrant');
      expect(TraleSchemeVariant.neutral.name, 'neutral');
    });
  });

  group('TraleSchemeVariantExtension', () {
    test('schemeVariant returns correct DynamicSchemeVariant', () {
      expect(
        TraleSchemeVariant.material.schemeVariant,
        DynamicSchemeVariant.tonalSpot,
      );
      expect(
        TraleSchemeVariant.vibrant.schemeVariant,
        DynamicSchemeVariant.vibrant,
      );
      expect(
        TraleSchemeVariant.neutral.schemeVariant,
        DynamicSchemeVariant.neutral,
      );
    });
  });

  group('TraleSchemeVariantParsing', () {
    test('toTraleSchemeVariant converts valid strings', () {
      expect('material'.toTraleSchemeVariant(), TraleSchemeVariant.material);
      expect('vibrant'.toTraleSchemeVariant(), TraleSchemeVariant.vibrant);
      expect('neutral'.toTraleSchemeVariant(), TraleSchemeVariant.neutral);
    });

    test('toTraleSchemeVariant returns null for invalid strings', () {
      expect('invalid'.toTraleSchemeVariant(), isNull);
      expect(''.toTraleSchemeVariant(), isNull);
      expect('MATERIAL'.toTraleSchemeVariant(), isNull);
    });
  });

  group('TraleThemeExtension', () {
    test('constructor creates extension', () {
      const extension = TraleThemeExtension(padding: 20.0);
      expect(extension.padding, 20.0);
    });

    test('copyWith creates new extension with changes', () {
      const extension = TraleThemeExtension(padding: 20.0);
      final copied = extension.copyWith(padding: 25.0);

      expect(copied.padding, 25.0);
    });

    test('copyWith without parameters keeps original value', () {
      const extension = TraleThemeExtension(padding: 20.0);
      final copied = extension.copyWith();

      expect(copied.padding, 20.0);
    });

    test('lerp interpolates between extensions', () {
      const extension1 = TraleThemeExtension(padding: 10.0);
      const extension2 = TraleThemeExtension(padding: 20.0);

      final lerped = extension1.lerp(extension2, 0.5);

      expect(lerped.padding, closeTo(15.0, 0.01));
    });

    test('lerp handles null other', () {
      const extension = TraleThemeExtension(padding: 10.0);
      final lerped = extension.lerp(null, 0.5);

      expect(lerped, equals(extension));
    });
  });
}
