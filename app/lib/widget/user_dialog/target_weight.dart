part of '../user_dialog.dart';

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
            context.l10n.targetWeightEnabled,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Text(
            context.l10n.targetWeightEnabledSubtitle,
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
                : context.l10n.addTargetWeightDate,
            labelText: context.l10n.targetWeight,
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
                  : context.l10n.addTargetWeightDate,
              labelText: context.l10n.targetWeightDate,
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
  final MeasurementInterpolation ip = MeasurementInterpolation();
  final Measurement latestMeasurement = db.latestMeasurement;
  DateTime initDate =
      notifier.userTargetWeightSetDate ?? latestMeasurement.date;
  double initWeight =
      ip.measurementForDay(initDate) ?? latestMeasurement.weight;
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
                    context.l10n.targetWeightRateAdvice,
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
                  context.l10n.targetWeightDate,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                subtitle: Text(
                  context.l10n.targetWeightDateSubtitle,
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
                      '${context.l10n.targetWeightRate} '
                      '(${notifier.unit.name}'
                      '${context.l10n.perWeek})',
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
                  title: Text(context.l10n.targetWeightDate),
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
                  title: Text(context.l10n.startDate),
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
                      selectableDayPredicate: ip.hasMeasurementOnDay,
                    );
                    if (selected != null) {
                      final double? w = ip.measurementForDay(selected);
                      if (w != null) {
                        setState(() {
                          initDate = selected;
                          initWeight = w;
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
            title: context.l10n.targetWeightDate,
            content: content,
            actions: _dialogActions(context, () {
              if (targetDateEnabled && targetDate != null) {
                notifier.userTargetWeightDate = targetDate;
                notifier.userTargetWeightSetDate = initDate;
              } else {
                notifier.userTargetWeightDate = null;
                notifier.userTargetWeightSetDate = null;
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
        context.l10n.abort,
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
        context.l10n.save,
        style: Theme.of(context).textTheme.labelLarge!.copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        textAlign: TextAlign.end,
      ),
    ),
  ];
}
