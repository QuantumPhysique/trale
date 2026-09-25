import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/weight_goal.dart';

void main() {
  group('TargetRange.timeToEnter', () {
    test('a lose goal counts down to the target', () {
      expect(
        WeightGoal.lose.range(75).timeToEnter(weight: 80, slope: -0.1),
        const Duration(days: 50),
      );
    });

    test('a lose goal is reached below the target', () {
      expect(
        WeightGoal.lose.range(75).timeToEnter(weight: 74, slope: 0.1),
        const Duration(days: -1),
      );
    });

    test('a gain goal counts up to the target', () {
      expect(
        WeightGoal.gain.range(75).timeToEnter(weight: 70, slope: 0.1),
        const Duration(days: 50),
      );
    });

    test('a maintain goal is reached anywhere within 1% of its target', () {
      final TargetRange range = WeightGoal.maintain.range(100);

      expect(
        range.timeToEnter(weight: 100.9, slope: 0.1),
        const Duration(days: -1),
      );
      expect(
        range.timeToEnter(weight: 99.1, slope: -0.1),
        const Duration(days: -1),
      );
    });

    test('a maintain goal counts down to its upper bound, not its centre', () {
      expect(
        WeightGoal.maintain.range(100).timeToEnter(weight: 105, slope: -0.1),
        const Duration(days: 40),
      );
    });

    test('a maintain goal counts up to its lower bound', () {
      expect(
        WeightGoal.maintain.range(100).timeToEnter(weight: 95, slope: 0.1),
        const Duration(days: 40),
      );
    });

    test('a trend moving away never enters', () {
      expect(
        WeightGoal.maintain.range(100).timeToEnter(weight: 105, slope: 0.1),
        isNull,
      );
    });

    test('a trend flatter than 5 g/day never enters', () {
      expect(
        WeightGoal.lose.range(75).timeToEnter(weight: 80, slope: -0.004),
        isNull,
      );
    });
  });

  // Released versions stored the goal as the bool 'looseWeight', which only
  // knew lose and gain.
  group('weightGoal preference', () {
    late SharedPreferences sp;

    Future<Preferences> loadPrefs(Map<String, Object> stored) async {
      SharedPreferences.setMockInitialValues(stored);
      sp = await SharedPreferences.getInstance();
      return Preferences.forTesting(sp);
    }

    test('a stored gain direction becomes the gain goal', () async {
      final Preferences prefs = await loadPrefs(<String, Object>{
        'looseWeight': false,
      });

      expect(prefs.weightGoal, WeightGoal.gain);
      expect(sp.containsKey('looseWeight'), isFalse);
    });

    test('a stored lose direction becomes the lose goal', () async {
      final Preferences prefs = await loadPrefs(<String, Object>{
        'looseWeight': true,
      });

      expect(prefs.weightGoal, WeightGoal.lose);
      expect(sp.containsKey('looseWeight'), isFalse);
    });

    test('without a stored direction the goal is lose', () async {
      final Preferences prefs = await loadPrefs(<String, Object>{});

      expect(prefs.weightGoal, WeightGoal.lose);
    });

    test('restoring the defaults resets the goal', () async {
      final Preferences prefs = await loadPrefs(<String, Object>{
        'looseWeight': false,
      });

      prefs.loadDefaultSettings(override: true);

      expect(prefs.weightGoal, WeightGoal.lose);
    });
  });
}
