import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:quantumphysique/src/preferences/qp_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Test doubles
// ---------------------------------------------------------------------------

class _TestPrefs extends QPPreferences {
  _TestPrefs(SharedPreferences prefs) : super.forTesting(prefs);

  @override
  String get defaultThemeName => 'testTheme';
}

class _TestNotifier extends QPNotifier {
  _TestNotifier(_TestPrefs prefs) : super(prefs);

  @override
  Color get seedColor => Colors.blue;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<(_TestNotifier, SharedPreferences)> _build([
  Map<String, Object> initial = const <String, Object>{},
]) async {
  SharedPreferences.setMockInitialValues(initial);
  final SharedPreferences sp = await SharedPreferences.getInstance();
  final _TestPrefs prefs = _TestPrefs(sp);
  return (_TestNotifier(prefs), sp);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QPNotifier.themeMode', () {
    test('returns ThemeMode.system for default "auto" setting', () async {
      final (_TestNotifier notifier, _) = await _build();
      expect(notifier.themeMode, ThemeMode.system);
    });

    test('returns ThemeMode.dark when nightMode is "on"', () async {
      final (_TestNotifier notifier, _) = await _build(<String, Object>{
        'qp_nightMode': 'on',
      });
      expect(notifier.themeMode, ThemeMode.dark);
    });

    test('returns ThemeMode.light when nightMode is "off"', () async {
      final (_TestNotifier notifier, _) = await _build(<String, Object>{
        'qp_nightMode': 'off',
      });
      expect(notifier.themeMode, ThemeMode.light);
    });

    test('setter round-trip persists and reads back', () async {
      final (_TestNotifier notifier, SharedPreferences sp) = await _build();
      notifier.themeMode = ThemeMode.dark;
      expect(sp.getString('qp_nightMode'), 'on');
      expect(notifier.themeMode, ThemeMode.dark);

      notifier.themeMode = ThemeMode.light;
      expect(sp.getString('qp_nightMode'), 'off');
      expect(notifier.themeMode, ThemeMode.light);
    });

    test('setter does not notify when value unchanged', () async {
      final (_TestNotifier notifier, _) = await _build();
      int notifications = 0;
      notifier.addListener(() => notifications++);

      notifier.themeMode = ThemeMode.system; // same as default
      expect(notifications, 0);
    });
  });

  group('QPNotifier.language', () {
    test('default language is system', () async {
      final (_TestNotifier notifier, _) = await _build();
      expect(notifier.language.compareTo(QPLanguage.system()), isTrue);
    });

    test('setter persists language preference', () async {
      final (_TestNotifier notifier, SharedPreferences sp) = await _build();
      final QPLanguage english = QPLanguage('en');
      notifier.language = english;
      expect(sp.getString('qp_language'), isNotNull);
    });
  });

  group('QPNotifier.showChangelog', () {
    test('default is true', () async {
      final (_TestNotifier notifier, _) = await _build();
      expect(notifier.showChangelog, isTrue);
    });

    test('can be set to false', () async {
      final (_TestNotifier notifier, SharedPreferences sp) = await _build();
      notifier.showChangelog = false;
      expect(sp.getBool('qp_showChangelog'), isFalse);
      expect(notifier.showChangelog, isFalse);
    });
  });

  group('QPNotifier.factoryReset', () {
    test('resets changed settings back to defaults', () async {
      final (_TestNotifier notifier, SharedPreferences sp) = await _build();

      // Change a few settings.
      notifier.themeMode = ThemeMode.dark;
      notifier.showChangelog = false;
      expect(sp.getString('qp_nightMode'), 'on');

      // Reset.
      await notifier.factoryReset();

      expect(notifier.themeMode, ThemeMode.system);
      expect(notifier.showChangelog, isTrue);
    });
  });

  group('QPNotifier.firstDay', () {
    test('default is QPFirstDay.Default', () async {
      final (_TestNotifier notifier, _) = await _build();
      expect(notifier.firstDay, QPFirstDay.Default);
    });

    test('setter round-trip', () async {
      final (_TestNotifier notifier, _) = await _build();
      notifier.firstDay = QPFirstDay.monday;
      expect(notifier.firstDay, QPFirstDay.monday);
    });
  });

  group('QPNotifier.datePrintFormat', () {
    test('default is QPDateFormat.systemDefault', () async {
      final (_TestNotifier notifier, _) = await _build();
      expect(notifier.datePrintFormat, QPDateFormat.systemDefault);
    });

    test('setter round-trip', () async {
      final (_TestNotifier notifier, _) = await _build();
      notifier.datePrintFormat = QPDateFormat.yyyyMMdd;
      expect(notifier.datePrintFormat, QPDateFormat.yyyyMMdd);
    });
  });

  group('QPNotifier.reminderHour', () {
    test('default is 8', () async {
      final (_TestNotifier notifier, _) = await _build();
      expect(notifier.reminderHour, 8);
    });

    test('setter persists hour', () async {
      final (_TestNotifier notifier, SharedPreferences sp) = await _build();
      notifier.reminderHour = 17;
      expect(sp.getInt('qp_reminderHour'), 17);
      expect(notifier.reminderHour, 17);
    });
  });
}
