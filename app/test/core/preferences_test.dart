import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/backupInterval.dart';
import 'package:trale/core/contrast.dart';
import 'package:trale/core/firstDay.dart';
import 'package:trale/core/interpolation.dart';
import 'package:trale/core/language.dart';
import 'package:trale/core/printFormat.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/units.dart';
import 'package:trale/core/zoomLevel.dart';

void main() {
  group('Preferences', () {
    test('singleton instance is consistent', () {
      final prefs1 = Preferences();
      final prefs2 = Preferences();

      expect(prefs1, same(prefs2));
    });

    test('default values are defined', () {
      final prefs = Preferences();

      // Test all default values exist
      expect(prefs.defaultUserName, isA<String>());
      expect(prefs.defaultUserTargetWeight, isA<double>());
      expect(prefs.defaultUserWeight, isA<double>());
      expect(prefs.defaultUserHeight, isA<double>());
      expect(prefs.defaultShowOnboarding, isA<bool>());
      expect(prefs.defaultNightMode, isA<String>());
      expect(prefs.defaultIsAmoled, isA<bool>());
      expect(prefs.defaultLanguage, isA<Language>());
      expect(prefs.defaultTheme, isA<String>());
      expect(prefs.defaultSchemeVariant, isA<String>());
      expect(prefs.defaultContrastLevel, isA<ContrastLevel>());
      expect(prefs.defaultUnit, isA<TraleUnit>());
      expect(prefs.defaultInterpolStrength, isA<InterpolStrength>());
      expect(prefs.defaultZoomLevel, isA<ZoomLevel>());
    });

    test('default userName is empty string', () {
      final prefs = Preferences();
      expect(prefs.defaultUserName, '');
    });

    test('default userTargetWeight is -1', () {
      final prefs = Preferences();
      expect(prefs.defaultUserTargetWeight, -1);
    });

    test('default userWeight is 70', () {
      final prefs = Preferences();
      expect(prefs.defaultUserWeight, 70);
    });

    test('default userHeight is -1', () {
      final prefs = Preferences();
      expect(prefs.defaultUserHeight, -1);
    });

    test('default showOnboarding is true', () {
      final prefs = Preferences();
      expect(prefs.defaultShowOnboarding, true);
    });

    test('default nightMode is auto', () {
      final prefs = Preferences();
      expect(prefs.defaultNightMode, 'auto');
    });

    test('default isAmoled is false', () {
      final prefs = Preferences();
      expect(prefs.defaultIsAmoled, false);
    });

    test('default language is system', () {
      final prefs = Preferences();
      expect(prefs.defaultLanguage.language, Language.systemDefault);
    });

    test('default theme is water', () {
      final prefs = Preferences();
      expect(prefs.defaultTheme, TraleCustomTheme.water.name);
    });

    test('default schemeVariant is material', () {
      final prefs = Preferences();
      expect(prefs.defaultSchemeVariant, TraleSchemeVariant.material.name);
    });

    test('default contrastLevel is normal', () {
      final prefs = Preferences();
      expect(prefs.defaultContrastLevel, ContrastLevel.normal);
    });

    test('default unit is kg', () {
      final prefs = Preferences();
      expect(prefs.defaultUnit, TraleUnit.kg);
    });

    test('default interpolStrength is medium', () {
      final prefs = Preferences();
      expect(prefs.defaultInterpolStrength, InterpolStrength.medium);
    });

    test('default zoomLevel is all', () {
      final prefs = Preferences();
      expect(prefs.defaultZoomLevel, ZoomLevel.all);
    });

    test('loaded getter returns Future or null', () {
      final prefs = Preferences();
      expect(prefs.loaded, anyOf(isNull, isA<Future<void>>()));
    });

    // Note: We cannot easily test loadPreferences() without mocking SharedPreferences
    // That would require additional test packages like mockito or shared_preferences_test
    // The core default values are tested above, which covers the essential functionality
  });
}
