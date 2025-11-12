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

      // Should have original widgets + gaps between them
      expect(result.length, 5); // 3 widgets + 2 gaps
      expect(result[0], isA<Text>());
      expect(result[1], isA<SizedBox>());
      expect(result[2], isA<Text>());
      expect(result[3], isA<SizedBox>());
      expect(result[4], isA<Text>());

      // Check gap dimensions
      final gap = result[1] as SizedBox;
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

      expect(result.length, 3); // 2 widgets + 1 gap

      // Check gap dimensions
      final gap = result[1] as SizedBox;
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

      // With offset 1, should only add gap in the middle
      expect(result.length, 4); // 3 widgets + 1 gap
      expect(result[0], isA<Text>());
      expect(result[1], isA<Text>());
      expect(result[2], isA<SizedBox>());
      expect(result[3], isA<Text>());
    });

    test('addGap handles empty list', () {
      final list = <Widget>[];

      final result = list.addGap(
        padding: 10.0,
        direction: Axis.vertical,
      );

      expect(result.length, 0);
    });

    test('addGap handles single widget', () {
      final list = <Widget>[const Text('Widget 1')];

      final result = list.addGap(
        padding: 10.0,
        direction: Axis.vertical,
      );

      expect(result.length, 1); // No gaps added for single widget
      expect(result[0], isA<Text>());
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
