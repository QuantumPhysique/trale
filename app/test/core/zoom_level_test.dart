import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/zoomLevel.dart';

void main() {
  group('ZoomLevel', () {
    test('enum values exist', () {
      expect(ZoomLevel.values.length, 6);
      expect(ZoomLevel.values, contains(ZoomLevel.two));
      expect(ZoomLevel.values, contains(ZoomLevel.six));
      expect(ZoomLevel.values, contains(ZoomLevel.year));
      expect(ZoomLevel.values, contains(ZoomLevel.twoYear));
      expect(ZoomLevel.values, contains(ZoomLevel.fourYear));
      expect(ZoomLevel.values, contains(ZoomLevel.all));
    });
  });

  group('ZoomLevelExtension', () {
    test('name returns correct string', () {
      expect(ZoomLevel.two.name, 'two');
      expect(ZoomLevel.six.name, 'six');
      expect(ZoomLevel.year.name, 'year');
      expect(ZoomLevel.twoYear.name, 'twoYear');
      expect(ZoomLevel.fourYear.name, 'fourYear');
      expect(ZoomLevel.all.name, 'all');
    });

    test('next cycles through zoom levels', () {
      expect(ZoomLevel.two.next, isNot(ZoomLevel.two));
      expect(ZoomLevel.all.next, ZoomLevel.two);
    });

    test('zoomOut increases zoom level', () {
      expect(ZoomLevel.two.zoomOut.index, greaterThanOrEqualTo(ZoomLevel.two.index));
      expect(ZoomLevel.all.zoomOut, ZoomLevel.all); // Already at max
    });

    test('zoomIn decreases zoom level', () {
      expect(ZoomLevel.six.zoomIn.index, lessThanOrEqualTo(ZoomLevel.six.index));
      expect(ZoomLevel.two.zoomIn, ZoomLevel.two); // Already at min
    });
  });

  group('ZoomLevelParsing', () {
    test('toZoomLevel converts valid integers', () {
      expect(0.toZoomLevel(), ZoomLevel.two);
      expect(1.toZoomLevel(), ZoomLevel.six);
      expect(2.toZoomLevel(), ZoomLevel.year);
      expect(3.toZoomLevel(), ZoomLevel.twoYear);
      expect(4.toZoomLevel(), ZoomLevel.fourYear);
      expect(5.toZoomLevel(), ZoomLevel.all);
    });

    test('toZoomLevel returns null for invalid integers', () {
      expect((-1).toZoomLevel(), isNull);
      expect(6.toZoomLevel(), isNull);
      expect(100.toZoomLevel(), isNull);
    });
  });
}
