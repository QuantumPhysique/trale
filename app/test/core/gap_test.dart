import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/gap.dart';

void main() {
  group('GapListExtension', () {
    test('addGap adds gaps between widgets vertically', () {
      final list = <Widget>[
        const Text('Widget 1'),
        const Text('Widget 2'),
        const Text('Widget 3'),
      ];

      final result = list.addGap(
        padding: 10.0,
        direction: Axis.vertical,
      );

      // The implementation inserts gaps at positions: length, length-1, ..., 0
      // For 3 widgets with offset=0: inserts at 3, 2, 1, 0 = 4 gaps + 3 widgets = 7 total
      expect(result.length, 7); // 3 widgets + 4 gaps
      expect(result[0], isA<SizedBox>()); // Gap at start
      expect(result[1], isA<Text>());
      expect(result[2], isA<SizedBox>());
      expect(result[3], isA<Text>());

      // Check gap dimensions
      final gap = result[0] as SizedBox;
      expect(gap.height, 10.0);
      expect(gap.width, 0.0);
    });

    test('addGap adds gaps between widgets horizontally', () {
      final list = <Widget>[
        const Text('Widget 1'),
        const Text('Widget 2'),
      ];

      final result = list.addGap(
        padding: 20.0,
        direction: Axis.horizontal,
      );

      // For 2 widgets with offset=0: inserts at 2, 1, 0 = 3 gaps + 2 widgets = 5 total
      expect(result.length, 5); // 2 widgets + 3 gaps

      // Check gap dimensions
      final gap = result[0] as SizedBox;
      expect(gap.height, 0.0);
      expect(gap.width, 20.0);
    });

    test('addGap with offset skips gaps at start and end', () {
      final list = <Widget>[
        const Text('Widget 1'),
        const Text('Widget 2'),
        const Text('Widget 3'),
      ];

      final result = list.addGap(
        padding: 10.0,
        direction: Axis.vertical,
        offset: 1,
      );

      // With offset 1: inserts at positions 2, 1 = 2 gaps + 3 widgets = 5 total
      expect(result.length, 5); // 3 widgets + 2 gaps
      expect(result[0], isA<Text>()); // No gap at start
    });

    test('addGap handles empty list', () {
      final list = <Widget>[];

      final result = list.addGap(
        padding: 10.0,
        direction: Axis.vertical,
      );

      // Empty list stays empty (no gaps can be inserted)
      expect(result.length, 0);
    });

    test('addGap handles single widget', () {
      final list = <Widget>[const Text('Widget 1')];

      final result = list.addGap(
        padding: 10.0,
        direction: Axis.vertical,
      );

      // For 1 widget with offset=0: inserts at 1, 0 = 2 gaps + 1 widget = 3 total
      expect(result.length, 3);
    });
  });

  group('DividerListExtension', () {
    test('addDivider adds dividers between widgets', () {
      final list = <Widget>[
        const Text('Widget 1'),
        const Text('Widget 2'),
        const Text('Widget 3'),
      ];

      list.addDivider(padding: 15.0);

      // Should have original widgets + dividers between them
      expect(list.length, 5); // 3 widgets + 2 dividers
      expect(list[0], isA<Text>());
      expect(list[1], isA<Divider>());
      expect(list[2], isA<Text>());
      expect(list[3], isA<Divider>());
      expect(list[4], isA<Text>());

      // Check divider height
      final divider = list[1] as Divider;
      expect(divider.height, 15.0);
    });

    test('addDivider handles two widgets', () {
      final list = <Widget>[
        const Text('Widget 1'),
        const Text('Widget 2'),
      ];

      list.addDivider(padding: 10.0);

      expect(list.length, 3); // 2 widgets + 1 divider
    });

    test('addDivider handles single widget', () {
      final list = <Widget>[const Text('Widget 1')];

      list.addDivider(padding: 10.0);

      expect(list.length, 1); // No dividers added for single widget
      expect(list[0], isA<Text>());
    });

    test('addDivider handles empty list', () {
      final list = <Widget>[];

      list.addDivider(padding: 10.0);

      expect(list.length, 0);
    });
  });
}
