import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:trale/core/icons.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/textSize.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/widget/addWeightDialog.dart';
import 'package:trale/widget/animate_in_effect.dart';
import 'package:trale/widget/weightListTile.dart';

class WeightList extends StatefulWidget {
  const WeightList({
    super.key,
    this.durationInMilliseconds = 1000,
    this.delayInMilliseconds = 0,
    this.keepAlive = false,
  });

  final int durationInMilliseconds;
  final int delayInMilliseconds;
  final bool keepAlive;

  @override
  _WeightList createState() => _WeightList();
}

class _WeightList extends State<WeightList>{
  double heightFactor = 1.5;

  @override
  Widget build(BuildContext context) {
    double height = heightFactor
        * sizeOfText(text: '10', context: context).height;
    final MeasurementDatabase database = MeasurementDatabase();
    final List<SortedMeasurement> measurements = database.sortedMeasurements;
    const String groupTag = 'groupTag';

    Widget deleteAction(SortedMeasurement currentMeasurement) {
      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(
              left: TraleTheme.of(context)!.padding / 2,
              right: TraleTheme.of(context)!.padding,
          ),
          child: SlidableAction(
              // label: AppLocalizations.of(context)!.delete,
              backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
              borderRadius: BorderRadius.circular(
                  TraleTheme.of(context)!.borderRadius
              ),
              icon: CustomIcons.delete,
              onPressed: (BuildContext context) {
                database.deleteMeasurement(currentMeasurement);
                setState(() {});
                final SnackBar snackBar = SnackBar(
                  content: const Text('Measurement was deleted'),
                  behavior: SnackBarBehavior.floating,
                  width: MediaQuery.of(context).size.width / 3 * 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(
                              TraleTheme.of(context)!.borderRadius
                          )
                      )
                  ),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      database.insertMeasurement(
                          currentMeasurement.measurement
                      );
                      setState(() {});
                    },
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
          ),
        ),
      );
    }

    Widget editAction(SortedMeasurement currentMeasurement) {
      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(
            right: TraleTheme.of(context)!.padding / 2,
            left: TraleTheme.of(context)!.padding,
          ),
          child: SlidableAction(
  //      label: AppLocalizations.of(context)!.edit,
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
            borderRadius: BorderRadius.circular(
                TraleTheme.of(context)!.borderRadius
            ),
            icon: CustomIcons.edit,
            onPressed: (BuildContext context) async {
              final bool changed = await showAddWeightDialog(
                context: context,
                weight: currentMeasurement.measurement.weight,
                date: currentMeasurement.measurement.date,
              );
              if (changed) {
                database.deleteMeasurement(currentMeasurement);
                setState(() {});
              }
            },
          ),
        ),
      );
    }

    ActionPane actionPane(SortedMeasurement m) =>  ActionPane(
      motion: const DrawerMotion(),
      extentRatio: 0.5,
      children: <Widget>[
        editAction(m),
        deleteAction(m),
      ],
    );


    Widget listTileMeasurement (SortedMeasurement m)
      =>  Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                //color: Theme.of(context).colorScheme.background,
                width: MediaQuery.of(context).size.width,
                height: height,
                child: AutoSizeText(
                  m.measurement.measureToString(
                    context, ws: 12,
                  ),
                  style: Theme.of(context).textTheme.bodyText1
                      ?.apply(fontFamily: 'Courier'),
                ),
              ),
            ],
      );

    double getIntervalStart(int i) {
      const int maximalShownListTile = 15;
      if (maximalShownListTile < measurements.length) {
        return <double>[i / maximalShownListTile, 1].reduce(min).toDouble();
      } else {
        return i / measurements.length;
      }
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: TraleTheme.of(context)!.padding),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: measurements.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int i) {
        return AnimateInEffect(
          keepAlive: widget.keepAlive,
          durationInMilliseconds: widget.durationInMilliseconds,
          delayInMilliseconds: widget.delayInMilliseconds,
          intervalStart: getIntervalStart(i),
          child: WeightListTile(
            measurement: measurements[i],
            offset: Offset(-MediaQuery.of(context).size.width / 2, 0),
            durationInMilliseconds: widget.delayInMilliseconds,
          ),
        );
      },
    );

  }
}
