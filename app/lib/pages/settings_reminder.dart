import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/core/notificationService.dart';
import 'package:trale/core/stringExtension.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/customScrollViewSnapping.dart';
import 'package:trale/widget/tile_group.dart';

/// Settings sub-page for configuring weight-logging reminders.
class ReminderSettingsPage extends StatefulWidget {
  /// Constructor.
  const ReminderSettingsPage({super.key});

  @override
  State<ReminderSettingsPage> createState() => _ReminderSettingsPageState();
}

class _ReminderSettingsPageState extends State<ReminderSettingsPage> {
  /// Reschedule notifications based on current notifier state.
  Future<void> _applySchedule(TraleNotifier notifier) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final NotificationService ns = NotificationService();

    if (notifier.reminderEnabled && notifier.reminderDays.isNotEmpty) {
      await ns.rescheduleFromPreferences(
        title: l10n.reminderNotificationTitle,
        body: l10n.reminderNotificationBody,
      );
    } else {
      await ns.cancelAllReminders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final TraleNotifier notifier = Provider.of<TraleNotifier>(context);
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    // Day labels – use DateFormat.E() for locale-aware short names
    // (Mon, Tue… / Mo, Di…).
    final String locale = Localizations.localeOf(context).toString();

    /// Map ISO weekday (1-7) → short display label.
    String dayLabel(int isoDay) {
      // Build a DateTime for the given ISO weekday (DateTime.monday == 1).
      // 2024-01-01 is a Monday, so adding (isoDay - 1) gives the right day.
      final DateTime ref = DateTime(2024, 1, isoDay);
      return DateFormat.E(locale).format(ref);
    }

    // Build the ordered list of ISO weekdays starting from the user's
    // configured first day.
    final MaterialLocalizations mloc = MaterialLocalizations.of(context);
    final int firstDayIndex = mloc.firstDayOfWeekIndex; // 0=Sun…6=Sat
    final int firstIsoDay = firstDayIndex == 0 ? 7 : firstDayIndex;
    final List<int> orderedDays = <int>[
      for (int i = 0; i < 7; i++) (firstIsoDay - 1 + i) % 7 + 1,
    ];

    final List<int> selectedDays = notifier.reminderDays;

    final List<Widget> sliverList = <Widget>[
      // ── Enable / disable toggle ──────────────────────────────────────
      WidgetGroup(
        title: l10n.reminderTitle,
        children: <Widget>[
          GroupedListTile(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            contentPadding: EdgeInsets.symmetric(
              horizontal: TraleTheme.of(context)!.padding,
            ),
            leading: PPIcon(Icons.notifications_active_outlined, context),
            title: Text(
              l10n.reminderEnable.inCaps,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            subtitle: Text(
              l10n.reminderEnableSubtitle.inCaps,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: Switch(
              value: notifier.reminderEnabled,
              onChanged: (bool value) async {
                if (value) {
                  final NotificationService ns = NotificationService();
                  final bool granted = await ns.requestPermission();
                  if (!granted) {
                    return;
                  }
                  await ns.requestExactAlarmPermission();
                }
                notifier.reminderEnabled = value;
                await _applySchedule(notifier);
              },
            ),
          ),
        ],
      ),

      // ── Day picker + time picker (only when enabled) ─────────────────
      if (notifier.reminderEnabled) ...<Widget>[
        WidgetGroup(
          title: l10n.reminderDaysTitle,
          direction: Axis.horizontal,
          scrollable: true,
          children: <Widget>[
            for (final int day in orderedDays)
              GroupedChip(
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
        WidgetGroup(
          title: l10n.reminderTimeTitle,
          children: <Widget>[
            GroupedListTile(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              contentPadding: EdgeInsets.symmetric(
                horizontal: TraleTheme.of(context)!.padding,
              ),
              title: Text(
                l10n.reminderTimeLabel.inCaps,
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
        SizedBox(height: 0.5 * TraleTheme.of(context)!.padding),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: TraleTheme.of(context)!.padding,
          ),
          child: Text(
            l10n.reminderExplanation,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    ];

    return Scaffold(
      body: SliverAppBarSnap(
        title: l10n.reminderTitle.inCaps,
        sliverlist: sliverList,
      ),
    );
  }
}
