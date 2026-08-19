import 'package:flutter_test/flutter_test.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// UTC offsets [location] applies across a year from [from], sampled every
/// six hours so daylight saving transitions are caught.
List<Duration> _offsetsOverAYear(tz.Location location, DateTime from) {
  final List<Duration> offsets = <Duration>[];
  for (int hours = 0; hours <= 365 * 24; hours += 6) {
    final DateTime instant = from.add(Duration(hours: hours));
    offsets.add(location.timeZone(instant.millisecondsSinceEpoch).offset);
  }
  return offsets;
}

void main() {
  setUpAll(tz.initializeTimeZones);

  group('QPNotificationService.resolveLocalLocation', () {
    test('does not fall back to UTC for a CEST device', () {
      // Regression (adonify #29): `DateTime.timeZoneName` reports "CEST",
      // which is not a database entry. The old code caught that miss and
      // then compared a Duration against an int of milliseconds, so no
      // location ever matched and `tz.local` silently became UTC — every
      // reminder fired exactly two hours late.
      final tz.Location berlin = tz.getLocation('Europe/Berlin');
      final DateTime cestNow = tz.TZDateTime(berlin, 2026, 8, 19, 12);
      expect(cestNow.timeZoneName, 'CEST');

      final tz.Location resolved = QPNotificationService.resolveLocalLocation(
        cestNow,
      );

      expect(resolved.name, isNot(anyOf('UTC', 'Etc/UTC')));
      expect(
        resolved.timeZone(cestNow.millisecondsSinceEpoch).offset,
        const Duration(hours: 2),
      );
    });

    test('resolved zone tracks the device zone for a full year', () {
      for (final String name in <String>[
        'Europe/Berlin',
        'America/New_York',
        'Asia/Kolkata',
        'Australia/Sydney',
        'America/Sao_Paulo',
        'Asia/Tehran',
        'UTC',
      ]) {
        final tz.Location device = tz.getLocation(name);
        final DateTime now = tz.TZDateTime(device, 2026, 1, 15, 9);

        final tz.Location resolved = QPNotificationService.resolveLocalLocation(
          now,
        );

        expect(
          _offsetsOverAYear(resolved, now),
          _offsetsOverAYear(device, now),
          reason: '$name resolved to ${resolved.name}, whose offsets diverge',
        );
      }
    });

    test('rejects an abbreviation that resolves but carries wrong rules', () {
      // "EST" *is* a database entry, but a fixed UTC-5 zone that never
      // observes daylight saving. Trusting the reported name outright would
      // put every US-Eastern reminder an hour out for half the year.
      final tz.Location newYork = tz.getLocation('America/New_York');
      final DateTime estNow = tz.TZDateTime(newYork, 2026, 1, 15, 9);
      expect(estNow.timeZoneName, 'EST');

      final tz.Location resolved = QPNotificationService.resolveLocalLocation(
        estNow,
      );

      final int summer = DateTime.utc(2026, 7, 1, 16).millisecondsSinceEpoch;
      expect(resolved.timeZone(summer).offset, const Duration(hours: -4));
      expect(
        tz.getLocation('EST').timeZone(summer).offset,
        const Duration(hours: -5),
        reason: 'the naive name lookup would have been an hour off',
      );
    });

    test('a scheduled wall-clock time keeps the device offset', () {
      final tz.Location berlin = tz.getLocation('Europe/Berlin');
      final DateTime cestNow = tz.TZDateTime(berlin, 2026, 8, 19, 12);

      final tz.Location resolved = QPNotificationService.resolveLocalLocation(
        cestNow,
      );

      // A reminder set for 20:00 must be scheduled as 18:00 UTC, not 20:00.
      final tz.TZDateTime scheduled = tz.TZDateTime(
        resolved,
        2026,
        8,
        19,
        20,
        0,
      );
      expect(scheduled.toUtc(), DateTime.utc(2026, 8, 19, 18, 0));
    });
  });
}
