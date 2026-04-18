import 'package:flutter_test/flutter_test.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Concrete subclass for testing the abstract [QPPreferences].
class _TestPrefs extends QPPreferences {
  _TestPrefs(SharedPreferences prefs) : super.forTesting(prefs);

  @override
  String get defaultThemeName => 'testTheme';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QPPreferences.loadDefaultSettings', () {
    late SharedPreferences prefs;
    late _TestPrefs testPrefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      prefs = await SharedPreferences.getInstance();
      testPrefs = _TestPrefs(prefs);
    });

    test('writes nightMode default when key absent', () {
      expect(prefs.getString('qp_nightMode'), 'auto');
    });

    test('writes isAmoled default when key absent', () {
      expect(prefs.getBool('qp_isAmoled'), false);
    });

    test('writes theme default when key absent', () {
      expect(prefs.getString('qp_theme'), 'testTheme');
    });

    test('writes showOnBoarding default when key absent', () {
      expect(prefs.getBool('qp_showOnBoarding'), true);
    });

    test('writes showChangelog default when key absent', () {
      expect(prefs.getBool('qp_showChangelog'), true);
    });

    test('writes reminderEnabled default when key absent', () {
      expect(prefs.getBool('qp_reminderEnabled'), false);
    });

    test('writes reminderHour default when key absent', () {
      expect(prefs.getInt('qp_reminderHour'), 8);
    });

    test('writes reminderMinute default when key absent', () {
      expect(prefs.getInt('qp_reminderMinute'), 0);
    });

    test('does not overwrite existing value', () async {
      await prefs.setString('qp_nightMode', 'dark');
      // Re-apply defaults — the stored value should survive.
      testPrefs.loadDefaultSettings();
      expect(prefs.getString('qp_nightMode'), 'dark');
    });

    test('override=true resets existing value to default', () async {
      await prefs.setString('qp_nightMode', 'dark');
      testPrefs.loadDefaultSettings(override: true);
      expect(prefs.getString('qp_nightMode'), 'auto');
    });
  });

  group('QPPreferences._migrateFromLegacyKeys', () {
    test('copies old key to new qp_ key when new key is absent', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'nightMode': 'dark',
      });
      final SharedPreferences sp = await SharedPreferences.getInstance();

      // Create prefs via base constructor (triggers loadPreferences→migrate).
      // We can't call loadPreferences directly in tests, so we verify via
      // forTesting and a manual migration check.
      // Manually verify logic: old key present, new key absent → copy.
      expect(sp.containsKey('nightMode'), isTrue);
      expect(sp.containsKey('qp_nightMode'), isFalse);

      // Run migration via loadPreferences (async).
      await QPPreferences.migrateForTesting(sp);

      expect(sp.getString('qp_nightMode'), 'dark');
    });

    test(
      'does not overwrite new key when both old and new keys exist',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'nightMode': 'dark',
          'qp_nightMode': 'light',
        });
        final SharedPreferences sp = await SharedPreferences.getInstance();

        await QPPreferences.migrateForTesting(sp);

        // The new key should keep its original value.
        expect(sp.getString('qp_nightMode'), 'light');
      },
    );

    test('leaves old key intact after migration', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'nightMode': 'dark',
      });
      final SharedPreferences sp = await SharedPreferences.getInstance();
      await QPPreferences.migrateForTesting(sp);

      expect(sp.containsKey('nightMode'), isTrue);
    });
  });

  group('QPPreferences.resetSettings', () {
    test('resets all keys back to defaults', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences sp = await SharedPreferences.getInstance();
      final _TestPrefs p = _TestPrefs(sp);

      // Change a setting, then reset.
      p.nightMode = 'dark';
      expect(sp.getString('qp_nightMode'), 'dark');

      p.resetSettings();
      expect(sp.getString('qp_nightMode'), 'auto');
    });
  });
}
