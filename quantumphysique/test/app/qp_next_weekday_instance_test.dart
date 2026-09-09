import 'package:flutter_test/flutter_test.dart';
import 'package:quantumphysique/quantumphysique.dart';

void main() {
  // Wednesday, 12:00.
  final DateTime wednesdayNoon = DateTime(2024, 5, 1, 12);

  test('finds the slot later this week', () {
    final DateTime next = QPNotificationService.nextWeekdayInstance(
      DateTime.friday,
      8,
      30,
      from: wednesdayNoon,
    );

    expect(next, DateTime(2024, 5, 3, 8, 30));
  });

  test('skips to next week when the slot has passed today', () {
    final DateTime next = QPNotificationService.nextWeekdayInstance(
      DateTime.wednesday,
      8,
      30,
      from: wednesdayNoon,
    );

    expect(next, DateTime(2024, 5, 8, 8, 30));
  });

  test('takes today when the slot is still ahead', () {
    final DateTime next = QPNotificationService.nextWeekdayInstance(
      DateTime.wednesday,
      20,
      0,
      from: wednesdayNoon,
    );

    expect(next, DateTime(2024, 5, 1, 20));
  });

  test('wraps across the end of the week', () {
    final DateTime next = QPNotificationService.nextWeekdayInstance(
      DateTime.monday,
      7,
      0,
      from: wednesdayNoon,
    );

    expect(next, DateTime(2024, 5, 6, 7));
  });

  test('keeps the wall-clock time across a daylight saving change', () {
    // Two days before the CET→CEST switch on 31 March 2024.
    final DateTime beforeSwitch = DateTime(2024, 3, 29, 12);

    final DateTime next = QPNotificationService.nextWeekdayInstance(
      DateTime.monday,
      6,
      0,
      from: beforeSwitch,
    );

    expect(next, DateTime(2024, 4, 1, 6));
  });
}
