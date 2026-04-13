import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/icons.dart';
import 'package:trale/core/measurement_database.dart';
import 'package:trale/core/measurement_stats.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/stats_range.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/trale_notifier.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/dialog.dart';
import 'package:trale/widget/tile_group.dart';

/// Shows a dialog to select the stats range and optional custom dates.
Future<bool> showStatsRangeDialog({required BuildContext context}) async {
  final Preferences prefs = Preferences();
  final MeasurementDatabase db = MeasurementDatabase();
  final TraleNotifier notifier = Provider.of<TraleNotifier>(
    context,
    listen: false,
  );

  StatsRange selectedRange = prefs.statsRange;
  DateTime? customFrom = prefs.statsRangeFrom;
  DateTime? customTo = prefs.statsRangeTo;

  final Widget content = StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      final double padding = TraleTheme.of(context)!.padding;
      final Color tileColor = Theme.of(context).colorScheme.surfaceContainerLow;
      final bool isCustom = selectedRange == StatsRange.custom;

      // Resolve effective dates for the selected range
      final ({DateTime? from, DateTime? to}) resolvedDates;
      if (isCustom) {
        resolvedDates = (from: customFrom, to: customTo);
      } else {
        resolvedDates = selectedRange.dates;
      }
      final DateTime effectiveFrom = resolvedDates.from ?? db.firstDate;
      final DateTime effectiveTo = resolvedDates.to ?? DateTime.now();

      final String fromStr = notifier.dateFormat(context).format(effectiveFrom);
      final String toStr = notifier.dateFormat(context).format(effectiveTo);

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          WidgetGroup(
            title: AppLocalizations.of(context)!.statsRange,
            children: <Widget>[
              RadioGroup<StatsRange>(
                groupValue: selectedRange,
                onChanged: (StatsRange? value) {
                  if (value != null) {
                    setState(() => selectedRange = value);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (final StatsRange range in StatsRange.values)
                      GroupedRadioListTile<StatsRange>(
                        color: tileColor,
                        title: Text(range.nameLong(context)),
                        value: range,
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: padding),
          WidgetGroup(
            title: AppLocalizations.of(context)!.dates,
            children: <Widget>[
              if (isCustom)
                GroupedText(
                  color: tileColor,
                  text: Text(
                    AppLocalizations.of(context)!.customDateHint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              GroupedListTile(
                color: tileColor,
                enabled: isCustom,
                leading: PPIcon(PhosphorIconsDuotone.calendar, context),
                title: Text(AppLocalizations.of(context)!.from),
                trailing: Text(
                  fromStr,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isCustom ? null : Theme.of(context).disabledColor,
                  ),
                ),
                onTap: isCustom
                    ? () async {
                        final DateTime now = DateTime.now();
                        final DateTime lastDate = customTo != null
                            ? customTo!.subtract(const Duration(days: 1))
                            : now;
                        final DateTime? selected = await showDatePicker(
                          context: context,
                          initialDate: customFrom ?? db.firstDate,
                          firstDate: db.firstDate,
                          lastDate: lastDate,
                        );
                        if (selected != null) {
                          setState(() => customFrom = selected);
                        }
                      }
                    : null,
                onLongPress: isCustom
                    ? () => setState(() => customFrom = null)
                    : null,
              ),
              GroupedListTile(
                color: tileColor,
                enabled: isCustom,
                leading: PPIcon(PhosphorIconsDuotone.calendarCheck, context),
                title: Text(AppLocalizations.of(context)!.to),
                trailing: Text(
                  toStr,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isCustom ? null : Theme.of(context).disabledColor,
                  ),
                ),
                onTap: isCustom
                    ? () async {
                        final DateTime now = DateTime.now();
                        final DateTime firstDate = customFrom != null
                            ? customFrom!.add(const Duration(days: 1))
                            : db.firstDate;
                        final DateTime? selected = await showDatePicker(
                          context: context,
                          initialDate: customTo ?? now,
                          firstDate: firstDate,
                          lastDate: now,
                        );
                        if (selected != null) {
                          setState(() => customTo = selected);
                        }
                      }
                    : null,
                onLongPress: isCustom
                    ? () => setState(() => customTo = null)
                    : null,
              ),
            ],
          ),
        ],
      );
    },
  );

  final bool accepted =
      await showDialog<bool>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return DialogM3E(
            title: AppLocalizations.of(context)!.statsRange,
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: content,
            ),
            actions: <Widget>[
              FilledButton.icon(
                onPressed: () => Navigator.pop(context, false),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerLow,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                ),
                icon: PPIcon(PhosphorIconsRegular.x, context),
                label: Text(
                  AppLocalizations.of(context)!.abort,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () {
                  prefs.statsRange = selectedRange;
                  if (selectedRange == StatsRange.custom) {
                    prefs.statsRangeFrom = customFrom;
                    prefs.statsRangeTo = customTo;
                  }
                  MeasurementStats().reinit();
                  MeasurementDatabase().fireStream();
                  Navigator.pop(context, true);
                },
                icon: PPIcon(PhosphorIconsFill.floppyDiskBack, context),
                label: Text(
                  AppLocalizations.of(context)!.save,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          );
        },
      ) ??
      false;
  return accepted;
}
