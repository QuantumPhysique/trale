import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/stats_range.dart';

void main() {
  group('StatsRange', () {
    test('name returns enum value name', () {
      expect(StatsRange.all.name, 'all');
      expect(StatsRange.sinceTarget.name, 'sinceTarget');
      expect(StatsRange.lastYear.name, 'lastYear');
      expect(StatsRange.custom.name, 'custom');
    });
  });

  group('StatsRangeParsing', () {
    test('valid string converts to StatsRange', () {
      expect('all'.toStatsRange(), StatsRange.all);
      expect('sinceTarget'.toStatsRange(), StatsRange.sinceTarget);
      expect('lastYear'.toStatsRange(), StatsRange.lastYear);
      expect('custom'.toStatsRange(), StatsRange.custom);
    });

    test('invalid string returns null', () {
      expect('invalid'.toStatsRange(), isNull);
      expect(''.toStatsRange(), isNull);
    });
  });

  group('StatsRange.dates', () {
    test('all returns null from and to', () {
      final ({DateTime? from, DateTime? to}) dates = StatsRange.all.dates;
      expect(dates.from, isNull);
      expect(dates.to, isNull);
    });

    test('lastYear returns dates spanning one year', () {
      final ({DateTime? from, DateTime? to}) dates = StatsRange.lastYear.dates;
      expect(dates.from, isNotNull);
      expect(dates.to, isNotNull);
      final int daysDiff = dates.to!.difference(dates.from!).inDays;
      expect(daysDiff, closeTo(365, 1));
    });
  });
}
