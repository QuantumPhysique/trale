import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/firstDay.dart';

import 'package:trale/core/icons.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/units.dart';
import 'package:trale/widget/weightPicker.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

///
Future<bool> showAddWeightDialog({
  required BuildContext context,
  required double weight,
  required DateTime date,
  bool editMode = false,
}) async {
  final TraleNotifier notifier =
      Provider.of<TraleNotifier>(context, listen: false);

  final double initialSliderValue = weight.toDouble() / notifier.unit.scaling;
  double currentSliderValue = initialSliderValue;
  final DateTime initialDate = date;
  DateTime currentDate = initialDate;
  final MeasurementDatabase database = MeasurementDatabase();

  final Widget content = StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      final double sliderLabel =
          (currentSliderValue * notifier.unit.ticksPerStep).roundToDouble() /
              notifier.unit.ticksPerStep;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          RulerPicker(
            onValueChange: (num newValue) {
              currentSliderValue = newValue.toDouble();
              setState(() {});
            },
            width: MediaQuery.of(context).size.width - 80, // padding of dialog
            value: currentSliderValue,
            ticksPerStep: notifier.unit.ticksPerStep,
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.weight,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            trailing: Text(
              '${sliderLabel.toStringAsFixed(notifier.unit.precision)} '
              '${notifier.unit.name}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.date,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            trailing: Text(
              notifier.dateFormat(context).format(currentDate),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            onTap: () async {
              final TimeOfDay currentTime = TimeOfDay.fromDateTime(currentDate);
              DateTime? selectedDate;
              if (notifier.firstDay == TraleFirstDay.Default) {
                selectedDate = await showDatePicker(
                  context: context,
                  initialDate: currentDate,
                  firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                  lastDate: DateTime.now(),
                );
              } else {
                final List<DateTime?> selectedDates =
                    await showCalendarDatePicker2Dialog(
                      context: context,
                      config: CalendarDatePicker2WithActionButtonsConfig(
                        calendarType: CalendarDatePicker2Type.single,
                        firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                        lastDate: DateTime.now(),
                        firstDayOfWeek: notifier.firstDay.asDateTimeWeekday,
                      ),
                      dialogSize: Size(
                        MediaQuery
                            .of(context)
                            .size
                            .width * 0.85,
                        MediaQuery
                            .of(context)
                            .size
                            .height * 0.6,
                      ),
                      // see https://github.com/flutter/flutter/blob/2d17299f20f3eb164ef21bc80b8079ba293e5985/packages/flutter/lib/src/material/date_picker_theme.dart#L1117C59-L1117C98
                      borderRadius: const BorderRadius.all(
                          Radius.circular(28.0)),
                      value: [currentDate],
                    ) ??
                        [];
                selectedDate = selectedDates.firstOrNull;
              }

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
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.time,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
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
      );
    },
  );

  final bool accepted = await showDialog<bool>(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: TraleTheme.of(context)!.borderShape,
              // todo: hack to mimic m3
              backgroundColor: ElevationOverlay.colorWithOverlay(
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.primary,
                3.0,
              ),
              elevation: 0,
              contentPadding: EdgeInsets.only(
                top: TraleTheme.of(context)!.padding,
              ),
              title: Center(
                child: Text(
                  AppLocalizations.of(context)!.addWeight,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  maxLines: 1,
                ),
              ),
              content: content,
              actions: actions(
                context,
                () {
                  final bool wasInserted = database.insertMeasurement(
                    Measurement(
                      weight: currentSliderValue * notifier.unit.scaling,
                      date: currentDate,
                    ),
                  );
                  if (!wasInserted &&
                      !(editMode &&
                          currentDate == initialDate &&
                          currentSliderValue == initialSliderValue)) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          'Adding measurement was skipped. Measurement exists already.'),
                      behavior: SnackBarBehavior.floating,
                    ));
                  }
                  Navigator.pop(context, wasInserted);
                },
                enabled: true,
              ),
            );
          }) ??
      false;
  return accepted;
}

///
Future<bool> showTargetWeightDialog({
  required BuildContext context,
  required double weight,
}) async {
  final TraleNotifier notifier =
      Provider.of<TraleNotifier>(context, listen: false);

  double currentSliderValue = weight.toDouble() / notifier.unit.scaling;

  final Widget content = StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      final double sliderLabel =
          (currentSliderValue * notifier.unit.ticksPerStep).roundToDouble() /
              notifier.unit.ticksPerStep;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(
              TraleTheme.of(context)!.padding,
              0,
              TraleTheme.of(context)!.padding,
              TraleTheme.of(context)!.padding,
            ),
            child: Text(
              AppLocalizations.of(context)!.targetWeightMotivation,
              style: Theme.of(context).textTheme.bodyMedium!.apply(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              textAlign: TextAlign.justify,
            ),
          ),
          RulerPicker(
            onValueChange: (num newValue) {
              currentSliderValue = newValue.toDouble();
              setState(() {});
            },
            width: MediaQuery.of(context).size.width - 80, // padding of dialog
            value: currentSliderValue,
            ticksPerStep: notifier.unit.ticksPerStep,
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.weight,
              style: Theme.of(context).textTheme.bodyMedium!.apply(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            trailing: Text(
              '${sliderLabel.toStringAsFixed(notifier.unit.precision)} '
              '${notifier.unit.name}',
              style: Theme.of(context).textTheme.bodyMedium!.apply(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
        ],
      );
    },
  );

  final bool accepted = await showDialog<bool>(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: TraleTheme.of(context)!.borderShape,
              backgroundColor: ElevationOverlay.colorWithOverlay(
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.primary,
                3.0,
              ),
              elevation: 0,
              contentPadding: EdgeInsets.only(
                top: TraleTheme.of(context)!.padding,
              ),
              title: Center(
                child: Text(
                  AppLocalizations.of(context)!.targetWeight,
                  style: Theme.of(context).textTheme.headlineSmall!.apply(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  maxLines: 1,
                ),
              ),
              content: content,
              actions: actions(context, () {
                // In order to make our contribution to prevention, no target
                // weight below 50 kg / 110 lb / 7.9 st is possible.
                if (currentSliderValue * notifier.unit.scaling < 50) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          AppLocalizations.of(context)!.target_weight_warning),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 10),
                    ),
                  );
                } else {
                  notifier.userTargetWeight =
                      currentSliderValue * notifier.unit.scaling;
                }
                // force rebuilding linechart and widgets
                MeasurementDatabase().fireStream();
                Navigator.pop(context, true);
              }),
            );
          }) ??
      false;
  return accepted;
}

///
List<Widget> actions(BuildContext context, Function onPress,
    {bool enabled = true}) {
  return <Widget>[
    TextButton(
      onPressed: () => Navigator.pop(context, false),
      child: Container(
          padding: EdgeInsets.symmetric(
            vertical: TraleTheme.of(context)!.padding / 2,
            horizontal: TraleTheme.of(context)!.padding,
          ),
          child: Text(AppLocalizations.of(context)!.abort,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ))),
    ),
    FilledButton.icon(
      onPressed: enabled ? () => onPress() : null,
      icon: PPIcon(PhosphorIconsRegular.floppyDiskBack, context),
      label: Text(AppLocalizations.of(context)!.save,
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              )),
    ),
  ];
}
