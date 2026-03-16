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

  /// define actions with single button
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
        _GroupedFormFieldTile(
          color: tileColor,
          icon: PhosphorIconsDuotone.user,
          keyboardType: TextInputType.name,
          hintText: AppLocalizations.of(context)!.addUserName,
          labelText: AppLocalizations.of(context)!.name.inCaps,
          initialValue: notifier.userName,
          onChanged: (String value) {
            notifier.userName = value;
          },
        ),
        _GroupedFormFieldTile(
          color: tileColor,
          icon: PhosphorIconsDuotone.arrowsVertical,
          fieldKey: ValueKey<Object>((
            notifier.heightUnit,
            notifier.userHeight,
          )),
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
          hintText: notifier.heightUnit == TraleUnitHeight.imperial
              ? '5\'11"'
              : AppLocalizations.of(context)!.addHeight,
          suffixText: notifier.heightUnit.suffixText,
          labelText: AppLocalizations.of(context)!.height.inCaps,
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
    final MeasurementDatabase db = MeasurementDatabase();

    final bool canEnable = !db.isEmpty;

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
          enabled: canEnable,
          trailing: Switch(
            value: enabled,
            onChanged: canEnable
                ? (bool value) {
                    notifier.targetWeightEnabled = value;
                    MeasurementDatabase().fireStream();
                    onRefresh();
                  }
                : null,
          ),
        ),

        // ── Expanded target weight settings (only when enabled) ─────
        if (enabled) ...<Widget>[
          // Target weight value
          _GroupedFormFieldTile(
            color: tileColor,
            icon: PhosphorIconsDuotone.scales,
            fieldKey: ValueKey<double?>(notifier.userTargetWeight),
            readOnly: true,
            initialValue: notifier.userTargetWeight != null
                ? notifier.unit.weightToString(
                    notifier.userTargetWeight!,
                    notifier.unitPrecision,
                  )
                : AppLocalizations.of(context)!.addTargetWeightDate,
            labelText: AppLocalizations.of(context)!.targetWeight,
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
            _GroupedFormFieldTile(
              color: tileColor,
              icon: PhosphorIconsDuotone.calendarCheck,
              fieldKey: ValueKey<DateTime?>(notifier.userTargetWeightDate),
              readOnly: true,
              initialValue: notifier.userTargetWeightDate != null
                  ? notifier
                        .dateFormat(context)
                        .format(notifier.userTargetWeightDate!)
                  : AppLocalizations.of(context)!.addTargetWeightDate,
              labelText: AppLocalizations.of(context)!.targetWeightDate,
              onTap: () async {
                await showTargetWeightDateDialog(context: context);
                notifier.notify;
                onRefresh();
              },
            ),
        ],
      ],
    );
  }
}

/// Reusable tile wrapping [GroupedListTile] with a styled [TextFormField].
class _GroupedFormFieldTile extends StatelessWidget {
  const _GroupedFormFieldTile({
    required this.color,
    required this.icon,
    required this.labelText,
    this.fieldKey,
    this.hintText,
    this.suffixText,
    this.initialValue,
    this.keyboardType,
    this.inputFormatters,
    this.readOnly = false,
    this.onChanged,
    this.onEditingComplete,
    this.onTap,
  });

  final Color color;
  final IconData icon;
  final String labelText;
  final Key? fieldKey;
  final String? hintText;
  final String? suffixText;
  final String? initialValue;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.titleSmall!
        .copyWith(color: Theme.of(context).colorScheme.onSurface);
    return GroupedListTile(
      color: color,
      dense: false,
      leading: PPIcon(icon, context),
      title: TextFormField(
        key: fieldKey,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        readOnly: readOnly,
        maxLines: 1,
        initialValue: initialValue,
        style: textStyle,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintStyle: textStyle,
          hintText: hintText,
          hintMaxLines: 2,
          suffixText: suffixText,
          labelText: labelText,
        ),
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        onTap: onTap,
      ),
      onTap: () {},
    );
  }
}

/// Shows a dialog to set the target date via synced rate, target date,
/// and start date fields.
///
/// The rate is controlled with -/+ icon buttons and an editable text field.
/// Changing any of the three fields recalculates the others.
Future<bool> showTargetWeightDateDialog({required BuildContext context}) async {
  final TraleNotifier notifier = Provider.of<TraleNotifier>(
    context,
    listen: false,
  );
  final MeasurementDatabase db = MeasurementDatabase();
  final double? targetWeight = notifier.userTargetWeight;
  if (targetWeight == null || db.isEmpty) {
    return false;
  }

  final double unitScaling = notifier.unit.scaling;
  // 0.1 for kg/lb, 0.05 for st
  final double step = 1.0 / notifier.unit.ticksPerStep;
  const int decimals = 2;

  // ── Initialise from notifier or latest measurement ──────────────
  final Measurement latestMeasurement = db.latestMeasurement;
  DateTime initDate =
      notifier.userTargetWeightSetDate ?? latestMeasurement.date;
  double initWeight =
      notifier.userTargetWeightSetWeight ?? latestMeasurement.weight;
  DateTime? targetDate = notifier.userTargetWeightDate;

  // ── Helpers ─────────────────────────────────────────────────────
  double snapToStep(double v) {
    double snapped = (v / step).round() * step;
    if (snapped < step) {
      snapped = step;
    }
    return snapped;
  }

  DateTime? calcTargetDate(double absRateDisplay) {
    final double absRateKg = absRateDisplay * unitScaling;
    if (absRateKg < 0.01) {
      return null;
    }
    final double weightDiff = (targetWeight - initWeight).abs();
    final double weeks = weightDiff / absRateKg;
    final int days = (weeks * 7).round();
    if (days <= 0) {
      return null;
    }
    return initDate.add(Duration(days: days));
  }

  double calcRateFromDates(DateTime target) {
    final int totalDays = target.difference(initDate).inDays;
    if (totalDays <= 0) {
      return step;
    }
    final double totalWeeks = totalDays / 7.0;
    final double raw =
        (targetWeight - initWeight).abs() / totalWeeks / unitScaling;
    // Round to 2 decimal places instead of snapping to step grid.
    return double.parse(raw.toStringAsFixed(decimals));
  }

  // ── Initial rate (positive, in display units) ───────────────────
  double rateDisplayAbs;
  if (targetDate != null) {
    rateDisplayAbs = calcRateFromDates(targetDate);
  } else {
    rateDisplayAbs = snapToStep(0.5 / unitScaling);
  }
  targetDate ??= calcTargetDate(rateDisplayAbs);

  bool targetDateEnabled = true;

  final TextEditingController rateController = TextEditingController(
    text: rateDisplayAbs.toStringAsFixed(decimals),
  );

  // ── Build dialog content ────────────────────────────────────────
  final Widget content = StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      final Color tileColor = Theme.of(context).colorScheme.surfaceContainerLow;

      final String targetDateStr = targetDate != null
          ? notifier.dateFormat(context).format(targetDate!)
          : '--';
      final String initDateStr = notifier.dateFormat(context).format(initDate);

      void syncFromRate() {
        targetDate = calcTargetDate(rateDisplayAbs);
      }

      void syncFromTargetDate() {
        if (targetDate != null) {
          rateDisplayAbs = calcRateFromDates(targetDate!);
          rateController.text = rateDisplayAbs.toStringAsFixed(decimals);
        }
      }

      void syncFromInitDate() {
        if (targetDate != null) {
          rateDisplayAbs = calcRateFromDates(targetDate!);
          rateController.text = rateDisplayAbs.toStringAsFixed(decimals);
        }
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // ── Advice text ─────────────────────────────────────────
          WidgetGroup(
            children: <Widget>[
              GroupedWidget(
                color: tileColor,
                child: Padding(
                  padding: EdgeInsets.all(TraleTheme.of(context)!.padding),
                  child: Text(
                    AppLocalizations.of(context)!.targetWeightRateAdvice,
                    style: Theme.of(context).textTheme.bodyMedium!.apply(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
              GroupedListTile(
                color: tileColor,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: TraleTheme.of(context)!.padding,
                ),
                leading: PPIcon(PhosphorIconsDuotone.calendarCheck, context),
                title: Text(
                  AppLocalizations.of(context)!.targetWeightDate,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                subtitle: Text(
                  AppLocalizations.of(context)!.targetWeightDateSubtitle,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                trailing: Switch(
                  value: targetDateEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      targetDateEnabled = value;
                    });
                  },
                ),
              ),
            ],
          ),
          if (targetDateEnabled) ...<Widget>[
            SizedBox(height: TraleTheme.of(context)!.padding),
            WidgetGroup(
              children: <Widget>[
                GroupedWidget(
                  color: Theme.of(context).colorScheme.secondary,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.only(
                      top: 0.75 * TraleTheme.of(context)!.padding,
                      bottom: 0.5 * TraleTheme.of(context)!.padding,
                    ),
                    child: Text(
                      '${AppLocalizations.of(context)!.targetWeightRate} '
                      '(${notifier.unit.name}'
                      '${AppLocalizations.of(context)!.perWeek})',
                      style: Theme.of(context)
                          .textTheme
                          .emphasized
                          .headlineSmall
                          ?.apply(
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                    ),
                  ),
                ),
                GroupedWidget(
                  color: tileColor,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: TraleTheme.of(context)!.padding,
                      horizontal: TraleTheme.of(context)!.padding,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: TraleTheme.of(context)!.padding,
                      children: <Widget>[
                        IconButton.filledTonal(
                          onPressed: () {
                            setState(() {
                              rateDisplayAbs = snapToStep(
                                ((rateDisplayAbs / step).floor() - 1) * step,
                              );
                              rateController.text = rateDisplayAbs
                                  .toStringAsFixed(decimals);
                              syncFromRate();
                            });
                          },
                          icon: PPIcon(PhosphorIconsBold.minus, context),
                        ),
                        IntrinsicWidth(
                          child: TextField(
                            controller: rateController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ),
                            ],
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.monospace.titleLarge,
                            decoration: InputDecoration(
                              // filled: true,
                              // fillColor: Theme.of(
                              //   context,
                              // ).colorScheme.secondaryContainer,
                              // border: OutlineInputBorder(
                              //   borderRadius: BorderRadius.circular(
                              //     TraleTheme.of(context)!.borderRadius,
                              //   ),
                              //   borderSide: BorderSide.none,
                              // ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: TraleTheme.of(context)!.padding / 2,
                                vertical: TraleTheme.of(context)!.padding / 2,
                              ),
                            ),
                            onChanged: (String value) {
                              final double? parsed = double.tryParse(value);
                              if (parsed != null && parsed > 0) {
                                setState(() {
                                  rateDisplayAbs = parsed;
                                  syncFromRate();
                                });
                              }
                            },
                          ),
                        ),
                        IconButton.filledTonal(
                          onPressed: () {
                            setState(() {
                              rateDisplayAbs = snapToStep(
                                ((rateDisplayAbs / step).ceil() + 1) * step,
                              );
                              rateController.text = rateDisplayAbs
                                  .toStringAsFixed(decimals);
                              syncFromRate();
                            });
                          },
                          icon: PPIcon(PhosphorIconsBold.plus, context),
                        ),
                      ],
                    ),
                  ),
                ),
                GroupedListTile(
                  color: tileColor,
                  leading: PPIcon(PhosphorIconsDuotone.calendarCheck, context),
                  title: Text(AppLocalizations.of(context)!.targetWeightDate),
                  trailing: Text(
                    targetDateStr,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  onTap: () async {
                    final DateTime now = DateTime.now();
                    final DateTime? selected = await showDatePicker(
                      context: context,
                      initialDate:
                          targetDate ?? now.add(const Duration(days: 90)),
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 365 * 5)),
                    );
                    if (selected != null) {
                      setState(() {
                        targetDate = selected;
                        syncFromTargetDate();
                      });
                    }
                  },
                ),
                GroupedListTile(
                  color: tileColor,
                  leading: PPIcon(PhosphorIconsDuotone.calendar, context),
                  title: Text(AppLocalizations.of(context)!.startDate),
                  trailing: Text(
                    initDateStr,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  onTap: () async {
                    final DateTime? selected = await showDatePicker(
                      context: context,
                      initialDate: initDate,
                      firstDate: db.firstDate,
                      lastDate: db.lastDate,
                      selectableDayPredicate: (DateTime date) =>
                          db.existsMeasurementOnDate(date),
                    );
                    if (selected != null) {
                      final Measurement? m = db.measurementOnDate(selected);
                      if (m != null) {
                        setState(() {
                          initDate = selected;
                          initWeight = m.weight;
                          syncFromInitDate();
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ],
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
            title: AppLocalizations.of(context)!.targetWeightDate,
            content: content,
            actions: _dialogActions(context, () {
              if (targetDateEnabled && targetDate != null) {
                notifier.userTargetWeightDate = targetDate;
                notifier.userTargetWeightSetDate = initDate;
                notifier.userTargetWeightSetWeight = initWeight;
              } else {
                notifier.userTargetWeightDate = null;
                notifier.userTargetWeightSetDate = null;
                notifier.userTargetWeightSetWeight = null;
              }
              MeasurementDatabase().fireStream();
              Navigator.pop(context, true);
            }),
          );
        },
      ) ??
      false;
  rateController.dispose();
  return accepted;
}

// TODO: this is a copy of addWeightDialog actions, should be refactored to
// avoid duplication
/// Generate action buttons for M3E dialog
List<Widget> _dialogActions(
  BuildContext context,
  Function onPress, {
  bool enabled = true,
}) {
  return <Widget>[
    FilledButton.icon(
      onPressed: () => Navigator.pop(context, false),
      style: FilledButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      icon: PPIcon(PhosphorIconsRegular.x, context),
      label: Text(
        AppLocalizations.of(context)!.abort,
        style: Theme.of(context).textTheme.labelLarge!.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        textAlign: TextAlign.end,
      ),
    ),
    FilledButton.icon(
      onPressed: enabled ? () => onPress() : null,
      icon: PPIcon(PhosphorIconsFill.floppyDiskBack, context),
      label: Text(
        AppLocalizations.of(context)!.save,
        style: Theme.of(context).textTheme.labelLarge!.copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        textAlign: TextAlign.end,
      ),
    ),
  ];
}
