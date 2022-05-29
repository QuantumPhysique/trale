import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/icons.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/units.dart';
import 'package:trale/widget/weightPicker.dart';


///
Future<bool> showAddWeightDialog({
  required BuildContext context,
  required double weight,
  required DateTime date,
}) async {
  final TraleNotifier notifier =
    Provider.of<TraleNotifier>(context, listen: false);

  double _currentSliderValue = weight.toDouble() / notifier.unit.scaling;
  DateTime currentDate = date;
  final MeasurementDatabase database = MeasurementDatabase();


  final Widget content = StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      final double _sliderLabel = (
        _currentSliderValue * notifier.unit.ticksPerStep
      ).roundToDouble() / notifier.unit.ticksPerStep;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          RulerPicker(
            onValueChange: (num newValue) {
              setState(() => _currentSliderValue = newValue.toDouble());
            },
            width: MediaQuery.of(context).size.width - 80,  // padding of dialog
            value: _currentSliderValue,
            ticksPerStep: notifier.unit.ticksPerStep,
          ),
          ListTile(
              title: Text(
                AppLocalizations.of(context)!.weight,
                style: Theme.of(context).textTheme.bodyText1,
              ),
              trailing: Text(
                '${_sliderLabel.toStringAsFixed(notifier.unit.precision)} '
                '${notifier.unit.name}',
                style: Theme.of(context).textTheme.bodyText1,
              ),
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.date,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            trailing: Text(
              notifier.dateFormat(context).format(currentDate),
              style: Theme.of(context).textTheme.bodyText1,
            ),
            onTap: () async {
              final TimeOfDay currentTime = TimeOfDay.fromDateTime(currentDate);
              final DateTime? date = await showDatePicker(
                context: context,
                initialDate: currentDate,
                firstDate: DateTime(currentDate.year - 2),
                lastDate: DateTime.now(),
              );
              if (date == null) {
                return;
              }
              currentDate = DateTime(
                date.year,
                date.month,
                date.day,
                currentTime.hour,
                currentTime.minute,
              );
              setState(() {});

              final TimeOfDay? time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(currentDate),
              );

              if (time == null) {
                return;
              }
              currentDate = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );
              setState(() {});
            },
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.time,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            trailing: Text(
              DateFormat.Hm().format(currentDate),
              style: Theme.of(context).textTheme.bodyText1,
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
        actionsPadding: EdgeInsets.zero,
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
              database.insertMeasurement(
                Measurement(
                  weight: _currentSliderValue,
                  date: currentDate,
                ),
              );
              Navigator.pop(context, true);
            }
        ),
      );
    }
  ) ?? false;
  return accepted;
}


///
Future<bool> showTargetWeightDialog({
  required BuildContext context,
  required double weight,
}) async {
  final TraleNotifier notifier =
  Provider.of<TraleNotifier>(context, listen: false);
  double _currentSliderValue = weight.toDouble() / notifier.unit.scaling;

  final Widget content = StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      final double _sliderLabel = (
          _currentSliderValue * notifier.unit.ticksPerStep
      ).roundToDouble() / notifier.unit.ticksPerStep;
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
              setState(() => _currentSliderValue = newValue.toDouble());
            },
            width: MediaQuery.of(context).size.width - 80,  // padding of dialog
            value: _currentSliderValue,
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
              '${_sliderLabel.toStringAsFixed(notifier.unit.precision)} '
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
          actionsPadding: EdgeInsets.zero,
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
          actions: actions(
            context,
            () {
              notifier.userTargetWeight = _currentSliderValue;
              // force rebuilding linechart and widgets
              MeasurementDatabase().fireStream();
              Navigator.pop(context, true);
            }
          ),
        );
      }
  ) ?? false;
  return accepted;
}


///
List<Widget> actions(BuildContext context, Function onPress) {
  return <Widget>[
    TextButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(
          Theme.of(context).colorScheme.onBackground,
        ),
      ),
      onPressed: () => Navigator.pop(context, false),
      child: Container(
          padding: EdgeInsets.symmetric(
            vertical: TraleTheme.of(context)!.padding / 2,
            horizontal: TraleTheme.of(context)!.padding,
          ),
          child: Text(
            AppLocalizations.of(context)!.abort,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            )
          )
      ),
    ),

    TextButton.icon(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
            Theme.of(context).colorScheme.primary,
          ),
          foregroundColor: MaterialStateProperty.all<Color>(
            Theme.of(context).colorScheme.onPrimary,
          ),
          // todo: remove once m3 updated button theme
          padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.fromLTRB(16, 0, 24, 0),
          ),
        ),
        onPressed: () => onPress(),
        icon: const Icon(CustomIcons.save),
        label: Text(
          AppLocalizations.of(context)!.save,
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
          )
        ),
    ),
];
}