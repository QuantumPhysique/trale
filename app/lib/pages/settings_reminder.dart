import 'package:flutter/material.dart';
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

    // Day labels – use MaterialLocalizations so they respect the locale.
    final MaterialLocalizations mloc = MaterialLocalizations.of(context);
    // narrowWeekdays is indexed 0=Sun…6=Sat, ISO weekday 1=Mon…7=Sun.
    final List<String> narrowDays = mloc.narrowWeekdays;

    /// Map ISO weekday (1-7) → display label.
    String dayLabel(int isoDay) {
      // Convert ISO weekday to MaterialLocalizations index:
      // ISO 1=Mon → index 1, … ISO 7=Sun → index 0.
      final int index = isoDay % 7;
      return narrowDays[index];
    }

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
            leading: PPIcon(
              Icons.notifications_active_outlined,
              context,
            ),
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
                  if (!granted) return;
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
          children: <Widget>[
            GroupedWidget(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: TraleTheme.of(context)!.padding,
                  vertical: TraleTheme.of(context)!.padding,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    for (int day = 1; day <= 7; day++)
                      _DayChip(
                        label: dayLabel(day),
                        selected: selectedDays.contains(day),
                        onSelected: (bool selected) {
                          final List<int> updated =
                              List<int>.from(selectedDays);
                          if (selected) {
                            updated.add(day);
                          } else {
                            updated.remove(day);
                          }
                          updated.sort();
                          notifier.reminderDays = updated;
                          _applySchedule(notifier);
                        },
                      ),
                  ],
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
              horizontal: TraleTheme.of(context)!.padding),
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

/// A single selectable day-of-week chip.
class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      shape: const CircleBorder(),
      padding: const EdgeInsets.all(8),
      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: selected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
      selectedColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
    );
  }
}
