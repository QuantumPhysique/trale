import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trale/core/preferences.dart';

void main() {
  test('the interpolation cache of released versions is removed', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'interpolation_cache': '{"version": 2}',
    });
    final SharedPreferences sp = await SharedPreferences.getInstance();

    Preferences.forTesting(sp);

    expect(sp.containsKey('interpolation_cache'), isFalse);
  });
}
