import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/icons.dart';
import 'package:flutter/material.dart';

void main() {
  group('CustomIcons', () {
    test('class exists and is not instantiable', () {
      // CustomIcons has a private constructor, so we can't instantiate it
      // We can only verify the static constants exist
      expect(CustomIcons.interpol_medium, isA<IconData>());
      expect(CustomIcons.interpol_none, isA<IconData>());
      expect(CustomIcons.interpol_strong, isA<IconData>());
      expect(CustomIcons.interpol_weak, isA<IconData>());
    });

    test('icon data has correct font family', () {
      expect(CustomIcons.interpol_medium.fontFamily, 'CustomIcons');
      expect(CustomIcons.interpol_none.fontFamily, 'CustomIcons');
      expect(CustomIcons.interpol_strong.fontFamily, 'CustomIcons');
      expect(CustomIcons.interpol_weak.fontFamily, 'CustomIcons');
    });

    test('icon data has unique code points', () {
      final codes = {
        CustomIcons.interpol_medium.codePoint,
        CustomIcons.interpol_none.codePoint,
        CustomIcons.interpol_strong.codePoint,
        CustomIcons.interpol_weak.codePoint,
      };

      // All code points should be unique
      expect(codes.length, 4);
    });

    test('icon data has expected code points', () {
      expect(CustomIcons.interpol_medium.codePoint, 0xe812);
      expect(CustomIcons.interpol_none.codePoint, 0xe813);
      expect(CustomIcons.interpol_strong.codePoint, 0xe814);
      expect(CustomIcons.interpol_weak.codePoint, 0xe815);
    });
  });
}
