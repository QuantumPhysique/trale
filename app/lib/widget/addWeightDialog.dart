import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import 'package:trale/core/measurement.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/widget/coloredContainer.dart';

///
Future<bool> showAddWeightDialog({
  required BuildContext context,
  required double weight,
  required DateTime date,
  required Box<Measurement> box,
}) async {
  double _currentSliderValue = weight.toDouble();
  DateTime currentDate = date;
  double slidermin = 70.0;
  double slidermax = 90.0;

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
        child: Text(AppLocalizations.of(context)!.save)
        )
      ),
  ];

  final Widget content = StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
            title: Text('weight'),
            trailing: Text(_currentSliderValue.toString()),
        ),
        Slider(
          value: _currentSliderValue,
          onChanged: (double newValue) {
            setState(() => _currentSliderValue = newValue);
          },
          min: slidermin,
          max: slidermax,
          divisions: ((slidermax - slidermin) * 10).toInt(),
          label: _currentSliderValue.toString(),
        ),
        ListTile(
            title: Text('date'),
            trailing: Text(DateFormat('dd/MM/yy').format(currentDate))
        ),
        ListTile(
            title: Text('time'),
            trailing: Text(DateFormat.Hms().format(currentDate))
        ),
      ],
    );
  });

  bool accepted = await showDialog<bool>(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: TraleTheme.of(context)!.borderShape,
        contentPadding: EdgeInsets.zero,
        actionsPadding: EdgeInsets.zero,
        title: Text(
          AppLocalizations.of(context)!.addWeight,
          style: Theme.of(context).textTheme.headline6,
          maxLines: 1,
        ),
        content: content,
        actions: actions
      );
    }
  ) ?? false;
  return accepted;
}