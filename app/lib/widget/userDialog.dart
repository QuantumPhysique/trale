// ignore_for_file: file_names
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/icons.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/stringExtension.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/units.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/addWeightDialog.dart';
import 'package:trale/widget/dialog.dart';
import 'package:trale/widget/tile_group.dart';

///
Future<bool> showUserDialog({required BuildContext context}) async {
  final TraleNotifier notifier = Provider.of<TraleNotifier>(
    context,
    listen: false,
  );

  final Widget content = StatefulBuilder(
    builder: (BuildContext innerContext, StateSetter setState) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          UserDetailsGroup(
            notifier: notifier,
            onRefresh: () => setState(() {}),
          ),
          SizedBox(height: TraleTheme.of(innerContext)!.padding),
          TargetWeightGroup(
            notifier: notifier,
            onRefresh: () => setState(() {}),
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
            title: AppLocalizations.of(context)!.userDialogTitle,
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: content,
            ),
            actions: actions(context, () {
              Navigator.pop(context, true);
            }),
          );
        },
      ) ??
      false;
  return accepted;
}

///
List<Widget> actions(
  BuildContext context,
  Function onPress, {
  bool enabled = true,
}) {
  return <Widget>[
    FilledButton.icon(
      onPressed: enabled ? () => onPress() : null,
      icon: PPIcon(PhosphorIconsRegular.arrowLeft, context),
      label: Text(AppLocalizations.of(context)!.back),
    ),
  ];
}

/// Tile to toggle between losing and gaining weight.
class LooseWeightListTile extends StatelessWidget {
  /// constructor
  const LooseWeightListTile({super.key, this.color});

  /// Optional background color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color tileColor =
        color ?? Theme.of(context).colorScheme.surfaceContainerLow;
    return GroupedSwitchListTile(
      color: tileColor,
      dense: true,
      leading: PPIcon(
        Provider.of<TraleNotifier>(context).looseWeight
            ? PhosphorIconsDuotone.trendDown
            : PhosphorIconsDuotone.trendUp,
        context,
      ),
      title: Text(
        Provider.of<TraleNotifier>(context).looseWeight
            ? AppLocalizations.of(context)!.looseWeight
            : AppLocalizations.of(context)!.gainWeight,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      subtitle: Text(
        AppLocalizations.of(context)!.looseWeightSubtitle,
        style: Theme.of(context).textTheme.labelSmall,
      ),
      value: !Provider.of<TraleNotifier>(context).looseWeight,
      onChanged: (bool? loose) {
        if (loose == null) {
          return;
        }
        Provider.of<TraleNotifier>(context, listen: false).looseWeight = !loose;
      },
    );
  }
}

/// A grouped set of user-detail input fields.
class UserDetailsGroup extends StatelessWidget {
  /// Creates a [UserDetailsGroup].
  const UserDetailsGroup({
    super.key,
    required this.notifier,
    required this.onRefresh,
    this.title,
    this.backgroundColor,
  });

  /// The notifier providing user settings.
  final TraleNotifier notifier;

  /// Callback invoked when a field changes.
  final VoidCallback onRefresh;

  /// Optional title displayed above the group.
  final String? title;

  /// Optional background color.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final Color tileColor =
        backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerLow;
    return WidgetGroup(
      title: title,
      children: <Widget>[
        GroupedListTile(
          color: tileColor,
          dense: false,
          leading: PPIcon(PhosphorIconsDuotone.user, context),
          title: TextFormField(
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              hintText: AppLocalizations.of(context)!.addUserName,
              hintMaxLines: 2,
              labelText: AppLocalizations.of(context)!.name.inCaps,
            ),
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            initialValue: notifier.userName,
            onChanged: (String value) {
              notifier.userName = value;
            },
          ),
          onTap: () {},
        ),
        LooseWeightListTile(color: tileColor),
        GroupedListTile(
          color: tileColor,
          dense: false,
          leading: PPIcon(PhosphorIconsDuotone.arrowsVertical, context),
          title: TextFormField(
            key: ValueKey<Object>((notifier.heightUnit, notifier.userHeight)),
            keyboardType: notifier.heightUnit == TraleUnitHeight.metric
                ? TextInputType.number
                : TextInputType.text,
            inputFormatters: notifier.heightUnit == TraleUnitHeight.metric
                ? <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'^[1-9][0-9]*')),
                  ]
                : <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'''[0-9'″" ]''')),
                  ],
            decoration: InputDecoration(
              border: InputBorder.none,
              hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              hintText: notifier.heightUnit == TraleUnitHeight.imperial
                  ? '5\'11"'
                  : AppLocalizations.of(context)!.addHeight,
              suffixText: notifier.heightUnit.suffixText,
              labelText: AppLocalizations.of(context)!.height.inCaps,
            ),
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            initialValue: notifier.userHeight != null
                ? notifier.heightUnit.heightToString(notifier.userHeight!)
                : null,
            onChanged: (String value) {
              final double? newHeight = notifier.heightUnit.parseHeight(value);
              if (newHeight != null) {
                notifier.userHeight = newHeight;
              }
            },
            onEditingComplete: () {
              onRefresh();
            },
          ),
          onTap: () {},
        ),
      ],
    );
  }
}

/// Target weight settings group with enable/disable toggle.
///
/// When disabled, only the toggle is shown. When enabled, the group expands
/// to show target weight, starting date, target date (side by side), rate,
/// and the lose/gain weight toggle.
class TargetWeightGroup extends StatelessWidget {
  /// Creates a [TargetWeightGroup].
  const TargetWeightGroup({
    super.key,
    required this.notifier,
    required this.onRefresh,
    this.title,
    this.backgroundColor,
  });

  /// The notifier providing user settings.
  final TraleNotifier notifier;

  /// Callback invoked when a field changes.
  final VoidCallback onRefresh;

  /// Optional title displayed above the group.
  final String? title;

  /// Optional background color.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final Color tileColor =
        backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerLow;
    final bool enabled = notifier.targetWeightEnabled;

    return WidgetGroup(
      title: title,
      children: <Widget>[
        // ── Enable / disable toggle ─────────────────────────────────
        GroupedListTile(
          color: tileColor,
          contentPadding: EdgeInsets.symmetric(
            horizontal: TraleTheme.of(context)!.padding,
          ),
          leading: PPIcon(PhosphorIconsDuotone.target, context),
          title: Text(
            AppLocalizations.of(context)!.targetWeightEnabled,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Text(
            AppLocalizations.of(context)!.targetWeightEnabledSubtitle,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          trailing: Switch(
            value: enabled,
            onChanged: (bool value) {
              notifier.targetWeightEnabled = value;
              MeasurementDatabase().fireStream();
              onRefresh();
            },
          ),
        ),

        // ── Expanded target weight settings (only when enabled) ─────
        if (enabled) ...<Widget>[
          // Target weight value
          GroupedListTile(
            color: tileColor,
            dense: false,
            leading: PPIcon(PhosphorIconsDuotone.scales, context),
            title: TextFormField(
              key: ValueKey<double?>(notifier.userTargetWeight),
              readOnly: true,
              initialValue: notifier.userTargetWeight != null
                  ? notifier.unit.weightToString(
                      notifier.userTargetWeight!,
                      notifier.unitPrecision,
                    )
                  : AppLocalizations.of(context)!.addTargetWeight,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              maxLines: 1,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                labelText: AppLocalizations.of(context)!.targetWeight,
              ),
              onTap: () async {
                await showTargetWeightDialog(
                  context: context,
                  weight:
                      notifier.userTargetWeight ??
                      Preferences().defaultUserWeight,
                );
                notifier.notify;
                onRefresh();
              },
            ),
          ),
          // Starting date + Target date (side by side)
          if (notifier.userTargetWeight != null)
            _DateRow(
              notifier: notifier,
              tileColor: tileColor,
              onRefresh: onRefresh,
            ),
          // Rate (kg/week)
          if (notifier.userTargetWeight != null)
            _TargetWeightRateTile(
              notifier: notifier,
              tileColor: tileColor,
              onRefresh: onRefresh,
            ),
        ],
      ],
    );
  }
}

/// Row showing starting date and target date side by side.
class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.notifier,
    required this.tileColor,
    required this.onRefresh,
  });

  final TraleNotifier notifier;
  final Color tileColor;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime startDate = notifier.userTargetWeightSetDate ?? now;
    final DateTime? targetDate = notifier.userTargetWeightDate;

    return GroupedWidget(
      color: tileColor,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: TraleTheme.of(context)!.padding,
          vertical: TraleTheme.of(context)!.padding * 0.5,
        ),
        child: Row(
          children: <Widget>[
            // Starting date
            Expanded(
              child: _DateTile(
                icon: PhosphorIconsDuotone.calendarBlank,
                label: AppLocalizations.of(context)!.startingDate,
                dateText: notifier.dateFormat(context).format(startDate),
                onTap: () async {
                  final DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: startDate,
                    firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                    lastDate: now,
                  );
                  if (selectedDate != null) {
                    notifier.userTargetWeightSetDate = selectedDate;
                    // Also update the set weight to the latest measurement
                    // if not already set
                    if (notifier.userTargetWeightSetWeight == null) {
                      final MeasurementDatabase db = MeasurementDatabase();
                      if (db.nMeasurements > 0) {
                        notifier.userTargetWeightSetWeight =
                            db.measurements.first.weight;
                      }
                    }
                    MeasurementDatabase().fireStream();
                    onRefresh();
                  }
                },
              ),
            ),
            SizedBox(width: TraleTheme.of(context)!.padding),
            // Target date
            Expanded(
              child: _DateTile(
                icon: PhosphorIconsDuotone.calendarCheck,
                label: AppLocalizations.of(context)!.targetWeightDate,
                dateText: targetDate != null
                    ? notifier.dateFormat(context).format(targetDate)
                    : AppLocalizations.of(context)!.addTargetWeightDate,
                onTap: () async {
                  final DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate:
                        targetDate ?? now.add(const Duration(days: 90)),
                    firstDate: now,
                    lastDate: now.add(const Duration(days: 365 * 5)),
                  );
                  if (selectedDate != null) {
                    notifier.userTargetWeightDate = selectedDate;
                    // Ensure a starting date is set
                    notifier.userTargetWeightSetDate ??= now;
                    if (notifier.userTargetWeightSetWeight == null) {
                      final MeasurementDatabase db = MeasurementDatabase();
                      if (db.nMeasurements > 0) {
                        notifier.userTargetWeightSetWeight =
                            db.measurements.first.weight;
                      }
                    }
                    MeasurementDatabase().fireStream();
                    onRefresh();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A compact date display with icon, label, and tappable date text.
class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.icon,
    required this.label,
    required this.dateText,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String dateText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                icon,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            dateText,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Widget that shows the kg/week rate and allows the user to set either
/// the rate or the target date (calculating the other accordingly).
class _TargetWeightRateTile extends StatelessWidget {
  const _TargetWeightRateTile({
    required this.notifier,
    required this.tileColor,
    required this.onRefresh,
  });

  final TraleNotifier notifier;
  final Color tileColor;
  final VoidCallback onRefresh;

  /// Calculate kg/week from target weight, set weight, and dates.
  double? _calculateRatePerWeek() {
    final double? targetWeight = notifier.userTargetWeight;
    final DateTime? targetDate = notifier.userTargetWeightDate;
    final DateTime setDate = notifier.userTargetWeightSetDate ?? DateTime.now();
    final double? setWeight =
        notifier.userTargetWeightSetWeight ?? _latestMeasuredWeight();

    if (targetWeight == null || targetDate == null || setWeight == null) {
      return null;
    }

    final int totalDays = targetDate.difference(setDate).inDays;
    if (totalDays <= 0) {
      return null;
    }

    final double totalWeeks = totalDays / 7.0;
    final double weightDiff = targetWeight - setWeight;
    return weightDiff / totalWeeks;
  }

  /// Calculate target date from a given rate (kg/week).
  DateTime? _calculateDateFromRate(double ratePerWeek) {
    final double? targetWeight = notifier.userTargetWeight;
    final DateTime setDate = notifier.userTargetWeightSetDate ?? DateTime.now();
    final double? setWeight =
        notifier.userTargetWeightSetWeight ?? _latestMeasuredWeight();

    if (targetWeight == null || setWeight == null || ratePerWeek.abs() < 0.01) {
      return null;
    }

    final double weightDiff = targetWeight - setWeight;
    final double weeks = weightDiff / ratePerWeek;
    final int days = (weeks * 7).round();
    if (days <= 0) {
      return null;
    }
    return setDate.add(Duration(days: days));
  }

  /// Get latest measured weight from database.
  double? _latestMeasuredWeight() {
    final MeasurementDatabase db = MeasurementDatabase();
    if (db.nMeasurements > 0) {
      return db.measurements.first.weight;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final double? ratePerWeek = _calculateRatePerWeek();
    final double unitScaling = notifier.unit.scaling;

    String rateText;
    if (ratePerWeek != null) {
      final double displayRate = ratePerWeek / unitScaling;
      rateText =
          '${displayRate.toStringAsFixed(2)} ${notifier.unit.name}'
          '${AppLocalizations.of(context)!.perWeek}';
    } else {
      rateText = '--';
    }

    return GroupedListTile(
      color: tileColor,
      dense: false,
      leading: PPIcon(PhosphorIconsDuotone.trendDown, context),
      title: TextFormField(
        key: ValueKey<double?>(ratePerWeek),
        readOnly: true,
        initialValue: rateText,
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        maxLines: 1,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          labelText: AppLocalizations.of(context)!.targetWeightRate,
        ),
        onTap: () async {
          final double? currentRate = ratePerWeek;
          final double initialRate = currentRate != null
              ? currentRate / unitScaling
              : -0.5 / unitScaling;

          final double? newRate = await showDialog<double>(
            context: context,
            builder: (BuildContext dialogContext) {
              double sliderValue = initialRate.abs();
              // Clamp to reasonable range
              if (sliderValue < 0.1 / unitScaling) {
                sliderValue = 0.1 / unitScaling;
              }
              if (sliderValue > 2.0 / unitScaling) {
                sliderValue = 2.0 / unitScaling;
              }

              return StatefulBuilder(
                builder: (BuildContext ctx, StateSetter setState) {
                  final bool isLosingWeight = notifier.looseWeight;
                  final double signedRate = isLosingWeight
                      ? -sliderValue
                      : sliderValue;
                  final DateTime? estimatedDate = _calculateDateFromRate(
                    signedRate * unitScaling,
                  );
                  final String dateStr = estimatedDate != null
                      ? notifier.dateFormat(context).format(estimatedDate)
                      : '--';

                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.targetWeightRate),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '${sliderValue.toStringAsFixed(2)} '
                          '${notifier.unit.name}'
                          '${AppLocalizations.of(context)!.perWeek}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        Slider(
                          value: sliderValue,
                          min: 0.1 / unitScaling,
                          max: 2.0 / unitScaling,
                          divisions: 19,
                          label: sliderValue.toStringAsFixed(2),
                          onChanged: (double value) {
                            setState(() {
                              sliderValue = value;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${AppLocalizations.of(context)!.targetWeightDate}: '
                          '$dateStr',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(AppLocalizations.of(context)!.abort),
                      ),
                      FilledButton(
                        onPressed: () {
                          final double signed = isLosingWeight
                              ? -sliderValue
                              : sliderValue;
                          Navigator.pop(dialogContext, signed * unitScaling);
                        },
                        child: Text(AppLocalizations.of(context)!.save),
                      ),
                    ],
                  );
                },
              );
            },
          );

          if (newRate != null) {
            final DateTime? newDate = _calculateDateFromRate(newRate);
            if (newDate != null) {
              notifier.userTargetWeightDate = newDate;
              MeasurementDatabase().fireStream();
              onRefresh();
            }
          }
        },
      ),
    );
  }
}
