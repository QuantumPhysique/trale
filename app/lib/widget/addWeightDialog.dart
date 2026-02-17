// ignore_for_file: file_names
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/unit_precision.dart';
import 'package:trale/core/units.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/dialog.dart';
import 'package:trale/widget/tile_group.dart';
import 'package:trale/widget/weight_picker.dart';

///
Future<bool> showAddWeightDialog({
  required BuildContext context,
  required double weight,
  required DateTime date,
  bool editMode = false,
}) async {
  final TraleNotifier notifier = Provider.of<TraleNotifier>(
    context,
    listen: false,
  );

  final double initialSliderValue = weight.toDouble() / notifier.unit.scaling;
  double currentSliderValue = initialSliderValue;
  final DateTime initialDate = date;
  DateTime currentDate = initialDate;
  final MeasurementDatabase database = MeasurementDatabase();

  final Widget content = StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          WidgetGroup(
            children: <Widget>[
              GroupedListTile(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                leading: PPIcon(PhosphorIconsDuotone.calendar, context),
                title: Text(AppLocalizations.of(context)!.date),
                trailing: Text(
                  notifier.dateFormat(context).format(currentDate),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                onTap: () async {
                  final TimeOfDay currentTime = TimeOfDay.fromDateTime(
                    currentDate,
                  );
                  final DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: currentDate,
                    firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                    lastDate: DateTime.now(),
                  );

                  if (selectedDate == null) {
                    return;
                  }

                  currentDate = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    currentTime.hour,
                    currentTime.minute,
                  );

                  if (!context.mounted) {
                    return;
                  }
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(currentDate),
                  );

                  if (time == null) {
                    return;
                  }
                  currentDate = DateTime(
                    currentDate.year,
                    currentDate.month,
                    currentDate.day,
                    time.hour,
                    time.minute,
                  );
                  setState(() {});
                },
              ),
              GroupedListTile(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                title: Text(AppLocalizations.of(context)!.time),
                leading: PPIcon(PhosphorIconsDuotone.clock, context),
                trailing: Text(
                  DateFormat.Hm().format(currentDate),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                onTap: () async {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(currentDate),
                  );

                  if (time == null) {
                    return;
                  }
                  currentDate = DateTime(
                    currentDate.year,
                    currentDate.month,
                    currentDate.day,
                    time.hour,
                    time.minute,
                  );
                  setState(() {});
                },
              ),
            ],
          ),
          SizedBox(height: TraleTheme.of(context)!.padding),
          RulerPicker(
            onValueChange: (num newValue) {
              currentSliderValue = newValue.toDouble();
              setState(() {});
            },
            height: 0.15 * MediaQuery.of(context).size.height,
            value: currentSliderValue,
            ticksPerStep:
                notifier.unitPrecision.ticksPerStep ??
                notifier.unit.ticksPerStep,
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
            title: AppLocalizations.of(context)!.addWeight,
            content: content,
            actions: actions(context, () async {
              final bool wasInserted = await database.insertMeasurement(
                Measurement(
                  weight: currentSliderValue * notifier.unit.scaling,
                  date: currentDate,
                ),
              );
              if (!context.mounted) {
                return;
              }
              if (!wasInserted &&
                  !(editMode &&
                      currentDate == initialDate &&
                      currentSliderValue == initialSliderValue)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Adding measurement was skipped. '
                      'Measurement exists already.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
              Navigator.pop(context, wasInserted);
            }, enabled: true),
          );
        },
      ) ??
      false;
  return accepted;
}

///
Future<bool> showTargetWeightDialog({
  required BuildContext context,
  required double weight,
}) async {
  final TraleNotifier notifier = Provider.of<TraleNotifier>(
    context,
    listen: false,
  );

  double currentSliderValue = weight.toDouble() / notifier.unit.scaling;

  final Widget content = StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          WidgetGroup(
            children: <Widget>[
              GroupedWidget(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: EdgeInsets.all(TraleTheme.of(context)!.padding),
                  child: Text(
                    AppLocalizations.of(context)!.targetWeightMotivation,
                    style: Theme.of(context).textTheme.bodyMedium!.apply(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: TraleTheme.of(context)!.padding),
          RulerPicker(
            onValueChange: (num newValue) {
              currentSliderValue = newValue.toDouble();
              setState(() {});
            },
            height: 0.15 * MediaQuery.of(context).size.height,
            value: currentSliderValue,
            ticksPerStep: notifier.unit.ticksPerStep,
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
            title: AppLocalizations.of(context)!.targetWeight,
            content: content,
            actions: actions(context, () {
              // In order to make our contribution to prevention, no target
              // weight below 50 kg / 110 lb / 7.9 st is possible.

              double minWeight;
              if (notifier.userHeight != null) {
                // /100 is to convert userHeight from cm to m
                // Here, the minWeight corresponds to BMI=18.5
                minWeight =
                    18.5 *
                    (notifier.userHeight! / 100) *
                    (notifier.userHeight! / 100);
              } else {
                minWeight = 50;
              }
              if (currentSliderValue * notifier.unit.scaling < minWeight) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.target_weight_warning,
                    ),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 10),
                  ),
                );
              } else {
                notifier.userTargetWeight =
                    currentSliderValue * notifier.unit.scaling;
                // Save the date and weight when the target was set
                notifier.userTargetWeightSetDate = DateTime.now();
                final MeasurementDatabase db = MeasurementDatabase();
                if (db.nMeasurements > 0) {
                  notifier.userTargetWeightSetWeight =
                      db.measurements.first.weight;
                }
              }
              // force rebuilding linechart and widgets
              MeasurementDatabase().fireStream();
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
