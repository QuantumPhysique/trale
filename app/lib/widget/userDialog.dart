// ignore_for_file: file_names
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/font.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/core/measurement.dart';
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
            title: AppLocalizations.of(innerContext)!.user,
          ),
          SizedBox(height: TraleTheme.of(innerContext)!.padding),
          TargetWeightGroup(
            notifier: notifier,
            onRefresh: () => setState(() {}),
            title: AppLocalizations.of(innerContext)!.targetWeight,
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
          LooseWeightListTile(color: tileColor),
          // Target weight value
          GroupedListTile(
            color: tileColor,
            leading: PPIcon(PhosphorIconsDuotone.scales, context),
            title: Text(AppLocalizations.of(context)!.targetWeight),
            trailing: Text(
              notifier.userTargetWeight != null
                  ? notifier.unit.weightToString(
                      notifier.userTargetWeight!,
                      notifier.unitPrecision,
                    )
                  : AppLocalizations.of(context)!.addTargetWeight,
              style: Theme.of(context).textTheme.bodyLarge,
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
          // Target date
          if (notifier.userTargetWeight != null)
            _TargetDateTile(
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

/// Target date tile matching the addWeightDialog style.
class _TargetDateTile extends StatelessWidget {
  const _TargetDateTile({
    required this.notifier,
    required this.tileColor,
    required this.onRefresh,
  });

  final TraleNotifier notifier;
  final Color tileColor;
  final VoidCallback onRefresh;

  /// Find measurement weight on a specific date, or null.
  double? _weightOnDate(DateTime date) {
    final MeasurementDatabase db = MeasurementDatabase();
    for (final Measurement m in db.measurements) {
      if (date.sameDay(m.date)) {
        return m.weight;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime? targetDate = notifier.userTargetWeightDate;

    return GroupedListTile(
      color: tileColor,
      leading: PPIcon(PhosphorIconsDuotone.calendarCheck, context),
      title: Text(AppLocalizations.of(context)!.targetWeightDate),
      trailing: Text(
        targetDate != null
            ? notifier.dateFormat(context).format(targetDate)
            : AppLocalizations.of(context)!.addTargetWeightDate,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      onTap: () async {
        final DateTime? selectedDate = await showDatePicker(
          context: context,
          initialDate: targetDate ?? now.add(const Duration(days: 90)),
          firstDate: now,
          lastDate: now.add(const Duration(days: 365 * 5)),
        );
        if (selectedDate == null) {
          return;
        }

        // Check if a start weight is available.
        double? startWeight = _weightOnDate(now);
        DateTime startDate = now;

        if (startWeight == null) {
          // No measurement today — prompt user to add one.
          if (!context.mounted) {
            return;
          }
          final MeasurementDatabase db = MeasurementDatabase();
          final double fallbackWeight = db.nMeasurements > 0
              ? db.measurements.first.weight
              : Preferences().defaultUserWeight;

          DateTime? savedDate;
          double? savedWeight;
          final bool added = await showAddWeightDialog(
            context: context,
            weight: fallbackWeight,
            date: now,
            message: AppLocalizations.of(context)!.targetWeightPrompt,
            onSaved: (DateTime d, double w) {
              savedDate = d;
              savedWeight = w;
            },
          );
          if (!added || savedDate == null || savedWeight == null) {
            return;
          }
          startDate = savedDate!;
          startWeight = savedWeight!;
        }

        notifier.userTargetWeightDate = selectedDate;
        notifier.userTargetWeightSetDate = startDate;
        notifier.userTargetWeightSetWeight = startWeight;
        MeasurementDatabase().fireStream();
        onRefresh();
      },
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

  /// Find measurement weight on a specific date, or null.
  double? _weightOnDate(DateTime date) {
    final MeasurementDatabase db = MeasurementDatabase();
    for (final Measurement m in db.measurements) {
      if (date.sameDay(m.date)) {
        return m.weight;
      }
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
      leading: PPIcon(
        notifier.looseWeight
            ? PhosphorIconsDuotone.trendDown
            : PhosphorIconsDuotone.trendUp,
        context,
      ),
      title: Text(AppLocalizations.of(context)!.targetWeightRate),
      trailing: Text(rateText, style: Theme.of(context).textTheme.bodyLarge),
      onTap: () async {
        final DateTime now = DateTime.now();

        // Ensure a start weight exists before setting rate.
        double? startWeight = _weightOnDate(now);
        DateTime startDate = now;

        if (startWeight == null) {
          if (!context.mounted) {
            return;
          }
          final MeasurementDatabase db = MeasurementDatabase();
          final double fallbackWeight = db.nMeasurements > 0
              ? db.measurements.first.weight
              : Preferences().defaultUserWeight;

          DateTime? savedDate;
          double? savedWeight;
          final bool added = await showAddWeightDialog(
            context: context,
            weight: fallbackWeight,
            date: now,
            message: AppLocalizations.of(context)!.targetWeightPrompt,
            onSaved: (DateTime d, double w) {
              savedDate = d;
              savedWeight = w;
            },
          );
          if (!added || savedDate == null || savedWeight == null) {
            return;
          }
          startDate = savedDate!;
          startWeight = savedWeight!;
        } else {
          // Use latest measurement as starting point
          final MeasurementDatabase db = MeasurementDatabase();
          if (db.nMeasurements > 0) {
            startDate = db.measurements.first.date;
            startWeight = db.measurements.first.weight;
          }
        }

        if (!context.mounted) {
          return;
        }

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
                final AppLocalizations l10n = AppLocalizations.of(context)!;

                return AlertDialog(
                  titlePadding: EdgeInsets.all(TraleTheme.of(context)!.padding),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: TraleTheme.of(context)!.padding,
                    vertical: TraleTheme.of(context)!.padding,
                  ),
                  actionsPadding: EdgeInsets.symmetric(
                    horizontal: TraleTheme.of(context)!.padding,
                    vertical: TraleTheme.of(context)!.padding - 4,
                  ),
                  actionsAlignment: MainAxisAlignment.spaceBetween,
                  title: Center(
                    child: Text(
                      l10n.targetWeightRate,
                      style: Theme.of(context)
                          .textTheme
                          .emphasized
                          .headlineSmall!
                          .apply(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                      maxLines: 1,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      WidgetGroup(
                        children: <Widget>[
                          GroupedWidget(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: TraleTheme.of(context)!.padding,
                                  ),
                                  child: Text(
                                    '${isLosingWeight ? '-' : '+'}'
                                    '${sliderValue.toStringAsFixed(2)} '
                                    '${notifier.unit.name}'
                                    '${l10n.perWeek}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall,
                                  ),
                                ),
                                Slider(
                                  value: sliderValue,
                                  min: 0.1 / unitScaling,
                                  max: 2.0 / unitScaling,
                                  divisions: 19,
                                  label:
                                      '${isLosingWeight ? '-' : '+'}'
                                      '${sliderValue.toStringAsFixed(2)}',
                                  onChanged: (double value) {
                                    setState(() {
                                      sliderValue = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          GroupedWidget(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: TraleTheme.of(context)!.padding,
                                ),
                                child: Text(
                                  '${l10n.targetWeightDate}'
                                  ': $dateStr',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.targetWeightRateAdvice,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(l10n.abort),
                    ),
                    FilledButton(
                      onPressed: () {
                        final double signed = isLosingWeight
                            ? -sliderValue
                            : sliderValue;
                        Navigator.pop(dialogContext, signed * unitScaling);
                      },
                      child: Text(l10n.save),
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
            notifier.userTargetWeightSetDate = startDate;
            notifier.userTargetWeightSetWeight = startWeight;
            MeasurementDatabase().fireStream();
            onRefresh();
          }
        }
      },
    );
  }
}
