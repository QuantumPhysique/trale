import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// How often a [QPReminder] fires.
enum QPReminderRepeat {
  /// Fires once and is then forgotten.
  once,

  /// Fires every week at the weekday and time it was armed for.
  weekly,
}

/// The Android notification channel a [QPReminder] is posted on.
@immutable
class QPNotificationChannel {
  /// Creates a channel description.
  const QPNotificationChannel({
    required this.id,
    required this.name,
    required this.description,
    this.importance = Importance.high,
  });

  /// Restores a channel from [json].
  factory QPNotificationChannel.fromJson(Map<String, dynamic> json) =>
      QPNotificationChannel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        importance: Importance.values.byName(json['importance'] as String),
      );

  /// Channel id as registered with Android.
  final String id;

  /// User-visible channel name.
  final String name;

  /// User-visible channel description.
  final String description;

  /// Importance of the notifications posted on this channel.
  final Importance importance;

  /// Serialises the channel.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'description': description,
    'importance': importance.name,
  };

  @override
  bool operator ==(Object other) =>
      other is QPNotificationChannel &&
      other.id == id &&
      other.name == name &&
      other.description == description &&
      other.importance == importance;

  @override
  int get hashCode => Object.hash(id, name, description, importance);
}

/// The named route a tapped reminder opens.
@immutable
class QPReminderRoute {
  /// Creates a route request.
  const QPReminderRoute(this.name, [this.arguments]);

  /// Route name, as registered by the app.
  final String name;

  /// Argument handed to the route, e.g. the id of the item to show.
  final String? arguments;

  @override
  bool operator ==(Object other) =>
      other is QPReminderRoute &&
      other.name == name &&
      other.arguments == arguments;

  @override
  int get hashCode => Object.hash(name, arguments);
}

/// A notification armed for a point in time.
///
/// Built by [QPReminderRegistry.schedule], which assigns [id] and records the
/// result so the reminder can be cancelled or skipped later.
@immutable
class QPReminder {
  /// Creates a reminder.
  const QPReminder({
    required this.id,
    required this.tag,
    required this.title,
    required this.body,
    required this.scheduledFor,
    required this.channel,
    this.repeat = QPReminderRepeat.once,
    this.route,
    this.routeArguments,
  });

  /// Restores a reminder from [json].
  factory QPReminder.fromJson(Map<String, dynamic> json) => QPReminder(
    id: json['id'] as int,
    tag: json['tag'] as String,
    title: json['title'] as String,
    body: json['body'] as String,
    scheduledFor: DateTime.parse(json['scheduledFor'] as String),
    channel: QPNotificationChannel.fromJson(
      json['channel'] as Map<String, dynamic>,
    ),
    repeat: QPReminderRepeat.values.byName(json['repeat'] as String),
    route: json['route'] as String?,
    routeArguments: json['routeArguments'] as String?,
  );

  /// Notification id this reminder is armed under.
  final int id;

  /// Groups the reminders that belong together, e.g. `weight` or `workout:7`.
  ///
  /// Everything that cancels or skips reminders addresses them by tag.
  final String tag;

  /// Title of the notification.
  final String title;

  /// Message shown below the title.
  final String body;

  /// Local wall-clock instant the reminder fires at.
  final DateTime scheduledFor;

  /// Channel the notification is posted on.
  final QPNotificationChannel channel;

  /// Whether the reminder fires once or every week.
  final QPReminderRepeat repeat;

  /// Named route opened when the notification is tapped.
  final String? route;

  /// Argument handed to [route].
  final String? routeArguments;

  /// The route a tap opens, or `null` when the reminder only opens the app.
  QPReminderRoute? get tapRoute =>
      route == null ? null : QPReminderRoute(route!, routeArguments);

  /// Copy of this reminder firing at [scheduledFor] instead.
  QPReminder withScheduledFor(DateTime scheduledFor) => QPReminder(
    id: id,
    tag: tag,
    title: title,
    body: body,
    scheduledFor: scheduledFor,
    channel: channel,
    repeat: repeat,
    route: route,
    routeArguments: routeArguments,
  );

  /// Serialises the reminder.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'tag': tag,
    'title': title,
    'body': body,
    'scheduledFor': scheduledFor.toIso8601String(),
    'channel': channel.toJson(),
    'repeat': repeat.name,
    'route': route,
    'routeArguments': routeArguments,
  };

  @override
  bool operator ==(Object other) =>
      other is QPReminder &&
      other.id == id &&
      other.tag == tag &&
      other.title == title &&
      other.body == body &&
      other.scheduledFor == scheduledFor &&
      other.channel == channel &&
      other.repeat == repeat &&
      other.route == route &&
      other.routeArguments == routeArguments;

  @override
  int get hashCode => Object.hash(
    id,
    tag,
    title,
    body,
    scheduledFor,
    channel,
    repeat,
    route,
    routeArguments,
  );
}
