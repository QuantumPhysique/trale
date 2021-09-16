import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/icons.dart';

import 'package:trale/core/measurement.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/units.dart';
import 'package:trale/core/traleNotifier.dart';

///
Future<bool> showAddWeightDialog({
  required BuildContext context,
  required double weight,
  required DateTime date,
  required Box<Measurement> box,
}) async {
  TraleNotifier notifier = Provider.of<TraleNotifier>(context, listen: false);

  double _currentSliderValue = weight.toDouble() * notifier.unit.scaling;
  DateTime currentDate = date;
  final double slidermin = 70.0 * notifier.unit.scaling;
  final double slidermax = 90.0 * notifier.unit.scaling;

  final List<Widget> actions = <Widget>[
    TextButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(
        TraleTheme.of(context)!.bgFont),
      ),
      onPressed: () => Navigator.pop(context, false),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: TraleTheme.of(context)!.padding / 2,
          horizontal: TraleTheme.of(context)!.padding,
        ),
        child: Text(AppLocalizations.of(context)!.abort)
      ),
    ),
    TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          TraleTheme.of(context)!.accent),
        foregroundColor: MaterialStateProperty.all<Color>(
          TraleTheme.of(context)!.accentFont),
      ),
      onPressed: () {
        box.add(
          Measurement(
            weight: _currentSliderValue,
            date: currentDate,
          ),
        );
        Navigator.pop(context, true);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: TraleTheme.of(context)!.padding / 2,
          horizontal: TraleTheme.of(context)!.padding,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(CustomIcons.save),
            SizedBox(width: TraleTheme.of(context)!.padding),
            Text(AppLocalizations.of(context)!.save),
          ],
        )
        )
      ),
  ];

  final Widget content = StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
              title: Text(
                AppLocalizations.of(context)!.weight,
                style: Theme.of(context).textTheme.bodyText1,
              ),
              trailing: Text(
                '${_currentSliderValue.toStringAsFixed(1)} ${notifier.unit.name}',
                style: Theme.of(context).textTheme.bodyText1,
              ),
          ),
          Slider(
            value: _currentSliderValue,
            onChanged: (double newValue) {
              setState(() => _currentSliderValue = newValue);
            },
            min: slidermin,
            max: slidermax,
            divisions: ((slidermax - slidermin) * 10).toInt(),
            label: _currentSliderValue.toStringAsFixed(1),
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.date,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            trailing: Text(
              DateFormat('dd/MM/yy').format(currentDate),
              style: Theme.of(context).textTheme.bodyText1,
            ),
            onTap: () async {
              TimeOfDay currentTime = TimeOfDay.fromDateTime(currentDate);

              final DateTime? date = await showDatePicker(
                context: context,
                initialDate: currentDate,
                firstDate: currentDate.subtract(const Duration(days: 180)),
                lastDate: DateTime.now(),
              );
              if (date == null)
                return;
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

              if (time == null)
                return;
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

              if (time == null)
                return;
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

  bool accepted = await showDialog<bool>(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: TraleTheme.of(context)!.borderShape,
        contentPadding: EdgeInsets.zero,
        actionsPadding: EdgeInsets.zero,
        title: Center(
          child: Text(
            AppLocalizations.of(context)!.addWeight,
            style: Theme.of(context).textTheme.headline6,
            maxLines: 1,
          ),
        ),
        content: content,
        actions: actions
      );
    }
  ) ?? false;
  return accepted;
}