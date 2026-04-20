import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quantumphysique/src/notifier/qp_notifier.dart';
import 'package:quantumphysique/src/types/icons.dart';
import 'package:quantumphysique/src/types/string_extension.dart';
import 'package:quantumphysique/src/types/strings.dart';
import 'package:quantumphysique/src/widgets/qp_layout.dart';
import 'package:quantumphysique/src/widgets/sliver_app_bar_snap.dart';
import 'package:quantumphysique/src/widgets/tile_group/tile_group.dart';

/// Settings page for configuring reminder notifications.
///
/// The page manages UI only. Pass [onScheduleChanged] to trigger actual
/// notification scheduling whenever settings change.
class QPNotificationsSettingsPage extends StatefulWidget {
  /// Creates a [QPNotificationsSettingsPage].
  const QPNotificationsSettingsPage({
    required this.strings,
    this.onScheduleChanged,
    this.onRequestPermission,
    this.onRequestExactAlarmPermission,
    super.key,
  });

  /// Localised strings.
  final QPStrings strings;

  /// Called after any reminder setting changes so the app can reschedule or
  /// cancel notifications.
  final Future<void> Function(QPNotifier notifier)? onScheduleChanged;

  /// Called to request notification permission. Returns `true` if granted.
  final Future<bool> Function()? onRequestPermission;

  /// Called to request exact-alarm permission. Returns `true` if granted.
  final Future<bool> Function()? onRequestExactAlarmPermission;

  @override
  State<QPNotificationsSettingsPage> createState() =>
      _QPNotificationsSettingsPageState();
}

class _QPNotificationsSettingsPageState
    extends State<QPNotificationsSettingsPage> {
  Future<void> _applySchedule(QPNotifier notifier) async {
    await widget.onScheduleChanged?.call(notifier);
  }

  @override
  Widget build(BuildContext context) {
    final QPNotifier notifier = Provider.of<QPNotifier>(context);
    final String locale = Localizations.localeOf(context).toString();

    String dayLabel(int isoDay) {
      final DateTime ref = DateTime(2024, 1, isoDay);
      return DateFormat.E(locale).format(ref);
    }

    final MaterialLocalizations mloc = MaterialLocalizations.of(context);
    final int firstDayIndex = mloc.firstDayOfWeekIndex; // 0=Sun…6=Sat
    final int firstIsoDay = firstDayIndex == 0 ? 7 : firstDayIndex;
    final List<int> orderedDays = <int>[
      for (int i = 0; i < 7; i++) (firstIsoDay - 1 + i) % 7 + 1,
    ];

    final List<int> selectedDays = notifier.reminderDays;

    final List<Widget> sliverList = <Widget>[
      QPWidgetGroup(
        title: widget.strings.reminderTitle,
        children: <Widget>[
          QPGroupedListTile(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: QPLayout.padding,
            ),
            leading: PPIcon(PhosphorIconsDuotone.bellRinging, context),
            title: Text(
              widget.strings.reminderEnabled.inCaps,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            subtitle: Text(
              widget.strings.reminderSubtitle.inCaps,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: Switch(
              value: notifier.reminderEnabled,
              onChanged: (bool value) async {
                if (value) {
                  final bool granted =
                      await widget.onRequestPermission?.call() ?? true;
                  if (!granted) {
                    return;
                  }
                  await widget.onRequestExactAlarmPermission?.call();
                }
                notifier.reminderEnabled = value;
                await _applySchedule(notifier);
              },
            ),
          ),
        ],
      ),
      if (notifier.reminderEnabled) ...<Widget>[
        QPWidgetGroup(
          title: widget.strings.reminderDays,
          direction: Axis.horizontal,
          scrollable: true,
          children: <Widget>[
            for (final int day in orderedDays)
              QPGroupedChip(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                selected: selectedDays.contains(day),
                onSelected: (bool selected) {
                  final List<int> updated = List<int>.from(selectedDays);
                  if (selected) {
                    updated.add(day);
                  } else {
                    updated.remove(day);
                  }
                  updated.sort();
                  notifier.reminderDays = updated;
                  _applySchedule(notifier);
                },
                child: Text(
                  dayLabel(day),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: selectedDays.contains(day)
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: selectedDays.contains(day)
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
        QPWidgetGroup(
          title: widget.strings.reminderTime,
          children: <Widget>[
            QPGroupedListTile(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: QPLayout.padding,
              ),
              title: Text(
                widget.strings.reminderTime.inCaps,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              trailing: TextButton(
                onPressed: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: notifier.reminderTime,
                  );
                  if (picked != null) {
                    notifier.reminderTime = picked;
                    await _applySchedule(notifier);
                  }
                },
                child: Text(
                  notifier.reminderTime.format(context),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ];

    return Scaffold(
      body: QPSliverAppBarSnap(
        title: widget.strings.reminderTitle,
        sliverlist: sliverList,
      ),
    );
  }
}
