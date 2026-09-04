import 'package:flutter_test/flutter_test.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trale/core/measurement_database.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/reminders.dart';

import '../helpers/service_locator.dart';

/// Notification service that records what it was asked to do instead of
/// talking to the platform.
class _FakeService extends QPNotificationService {
  _FakeService() : super.forTesting();

  final List<QPReminder> armed = <QPReminder>[];
  final List<int> cancelled = <int>[];

  @override
  Future<void> arm(QPReminder reminder) async => armed.add(reminder);

  @override
  Future<void> cancel(int id) async => cancelled.add(id);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeService service;

  Future<void> seedPrefs(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    final Preferences prefs = Preferences.forTesting(
      await SharedPreferences.getInstance(),
    );
    ServiceLocator.registerForTesting(
      prefs: prefs,
      db: MeasurementDatabase.forTestingWithData(),
    );
    QPReminderRegistry().attach(prefs);
  }

  setUp(() {
    service = _FakeService();
    QPNotificationService.testInstance = service;
  });

  tearDown(() {
    QPReminderRegistry().resetForTesting();
    QPNotificationService.resetInstance();
    // Not ServiceLocator.reset(): rebuilding MeasurementInterpolation reads
    // the Hive box these tests never open.
    Preferences.resetInstance();
    MeasurementDatabase.resetInstance();
  });

  Future<void> reschedule() => rescheduleWeightReminders(
    title: 'Time to weigh in!',
    body: 'You have not logged your weight today.',
  );

  test(
    'arms one weekly reminder per selected day, routed to the dialog',
    () async {
      await seedPrefs(<String, Object>{
        'qp_reminderEnabled': true,
        'qp_reminderDays': '1,4',
        'qp_reminderHour': 20,
        'qp_reminderMinute': 30,
      });

      await reschedule();

      expect(service.armed, hasLength(2));
      for (final QPReminder reminder in service.armed) {
        expect(reminder.repeat, QPReminderRepeat.weekly);
        expect(reminder.route, addWeightRoute);
        expect(reminder.scheduledFor.hour, 20);
        expect(reminder.scheduledFor.minute, 30);
      }
      expect(
        service.armed.map((QPReminder r) => r.scheduledFor.weekday),
        containsAll(<int>[DateTime.monday, DateTime.thursday]),
      );
    },
  );

  test('arms nothing while reminders are switched off', () async {
    await seedPrefs(<String, Object>{
      'qp_reminderEnabled': false,
      'qp_reminderDays': '1,4',
    });

    await reschedule();

    expect(service.armed, isEmpty);
  });

  test('drops the ids of pre-registry builds once', () async {
    await seedPrefs(<String, Object>{'qp_reminderEnabled': false});

    await reschedule();

    expect(service.cancelled, <int>[1001, 1002, 1003, 1004, 1005, 1006, 1007]);
    expect(Preferences().legacyReminderIdsCleared, isTrue);

    service.cancelled.clear();
    await reschedule();

    expect(service.cancelled, isEmpty);
  });
}
