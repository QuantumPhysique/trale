import 'package:flutter_test/flutter_test.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class _TestPrefs extends QPPreferences {
  _TestPrefs(SharedPreferences prefs) : super.forTesting(prefs);

  @override
  String get defaultThemeName => 'testTheme';
}

DateTime _atMinute(DateTime when) =>
    DateTime(when.year, when.month, when.day, when.hour, when.minute);

const QPNotificationChannel _channel = QPNotificationChannel(
  id: 'test',
  name: 'Test',
  description: 'Test channel',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeService service;
  late _TestPrefs prefs;
  late QPReminderRegistry registry;

  Future<QPReminder> schedule(
    String tag,
    DateTime when, {
    QPReminderRepeat repeat = QPReminderRepeat.once,
    String? route,
  }) => registry.schedule(
    QPReminderRequest(
      tag: tag,
      title: 'title',
      body: 'body',
      scheduledFor: when,
      channel: _channel,
      repeat: repeat,
      route: route,
    ),
  );

  setUp(() async {
    service = _FakeService();
    QPNotificationService.testInstance = service;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = _TestPrefs(await SharedPreferences.getInstance());
    registry = QPReminderRegistry()..attach(prefs);
  });

  tearDown(() {
    QPReminderRegistry().resetForTesting();
    QPNotificationService.resetInstance();
  });

  test('assigns every reminder its own notification id', () async {
    final QPReminder first = await schedule(
      'a',
      DateTime.now().add(const Duration(days: 1)),
    );
    final QPReminder second = await schedule(
      'b',
      DateTime.now().add(const Duration(days: 2)),
    );

    expect(first.id, isNot(second.id));
    expect(service.armed.map((QPReminder r) => r.id), <int>[
      first.id,
      second.id,
    ]);
  });

  test('a tag reaches the tags nested below it', () async {
    await schedule('workout:1', DateTime.now().add(const Duration(days: 1)));
    await schedule('workout:2', DateTime.now().add(const Duration(days: 2)));
    await schedule('weight', DateTime.now().add(const Duration(days: 3)));

    expect(registry.withTag('workout').length, 2);
    expect(registry.withTag('workout:1').length, 1);
    expect(registry.withTag('weight').length, 1);
  });

  test(
    'cancelTag drops the whole group from the system and the list',
    () async {
      final QPReminder monday = await schedule(
        'weight:1',
        DateTime.now().add(const Duration(days: 1)),
      );
      final QPReminder tuesday = await schedule(
        'weight:2',
        DateTime.now().add(const Duration(days: 2)),
      );
      await schedule('workout', DateTime.now().add(const Duration(days: 3)));

      await registry.cancelTag('weight');

      expect(service.cancelled, <int>[monday.id, tuesday.id]);
      expect(registry.active.map((QPReminder r) => r.tag), <String>['workout']);
    },
  );

  test('rearm replaces the previous generation under the tag', () async {
    final QPReminder old = await schedule(
      'weight:1',
      DateTime.now().add(const Duration(days: 1)),
    );
    final QPReminder other = await schedule(
      'workout:1',
      DateTime.now().add(const Duration(days: 1)),
    );

    await registry.rearm('weight', <QPReminderRequest>[
      QPReminderRequest(
        tag: 'weight:3',
        title: 'title',
        body: 'body',
        scheduledFor: DateTime.now().add(const Duration(days: 3)),
        channel: _channel,
      ),
    ]);

    expect(service.cancelled, <int>[old.id]);
    expect(registry.withTag('weight').single.tag, 'weight:3');
    expect(registry.withTag('workout').single.id, other.id);
  });

  test('rearm rejects a reminder that sits outside the tag', () async {
    expect(
      () => registry.rearm('weight', <QPReminderRequest>[
        QPReminderRequest(
          tag: 'workout:1',
          title: 'title',
          body: 'body',
          scheduledFor: DateTime.now().add(const Duration(days: 1)),
          channel: _channel,
        ),
      ]),
      throwsA(isA<AssertionError>()),
    );
  });

  test('skipping a one-shot reminder cancels it for good', () async {
    final QPReminder reminder = await schedule(
      'workout:1',
      DateTime.now().add(const Duration(days: 1)),
    );

    await registry.skipNext('workout');

    expect(service.cancelled, <int>[reminder.id]);
    expect(registry.active, isEmpty);
  });

  test('skipping a weekly reminder re-arms it a week on', () async {
    // Reminders fire on the minute, and so does the week the registry adds.
    final DateTime tomorrow = _atMinute(
      DateTime.now().add(const Duration(days: 1)),
    );
    final QPReminder reminder = await schedule(
      'weight:1',
      tomorrow,
      repeat: QPReminderRepeat.weekly,
    );

    await registry.skipNext('weight');

    expect(service.cancelled, <int>[reminder.id]);
    expect(registry.active.single.scheduledFor.difference(tomorrow).inDays, 7);
    expect(service.armed.last.id, reminder.id);
  });

  test('skipOn only touches the reminder due that day', () async {
    final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    final DateTime later = DateTime.now().add(const Duration(days: 2));
    final QPReminder due = await schedule('weight:1', tomorrow);
    await schedule('weight:2', later);

    await registry.skipOn('weight', tomorrow);

    expect(service.cancelled, <int>[due.id]);
    expect(registry.active.single.scheduledFor, later);
  });

  test('a reminder that has already fired is not skipped', () async {
    await schedule(
      'weight:1',
      DateTime.now().subtract(const Duration(days: 1)),
      repeat: QPReminderRepeat.weekly,
    );
    service.cancelled.clear();

    await registry.skipOn('weight', DateTime.now());

    expect(service.cancelled, isEmpty);
  });

  test(
    'a weekly reminder whose slot passed moves on to the next week',
    () async {
      final DateTime lastWeek = DateTime.now().subtract(
        const Duration(days: 8),
      );
      await schedule('weight:1', lastWeek, repeat: QPReminderRepeat.weekly);

      final QPReminder pruned = registry.active.single;

      expect(pruned.scheduledFor.isAfter(DateTime.now()), isTrue);
      expect(pruned.scheduledFor.weekday, lastWeek.weekday);
    },
  );

  test('a one-shot reminder that has fired is forgotten', () async {
    await schedule(
      'weight:1',
      DateTime.now().subtract(const Duration(days: 1)),
    );

    expect(registry.active, isEmpty);
  });

  test('the armed reminders survive a restart', () async {
    final QPReminder reminder = await schedule(
      'weight:1',
      DateTime.now().add(const Duration(days: 1)),
      repeat: QPReminderRepeat.weekly,
      route: '/addWeight',
    );

    QPReminderRegistry().resetForTesting();
    registry = QPReminderRegistry()..attach(prefs);

    expect(registry.active.single, reminder);
  });
}
