import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:trale/core/icons.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/widget/addWeightDialog.dart';

class WeightList extends StatefulWidget {
  const WeightList({super.key});
  @override
  _OverviewScreen createState() => _OverviewScreen();
}

class _OverviewScreen extends State<WeightList> {
  @override
  Widget build(BuildContext context) {

    final MeasurementDatabase database = MeasurementDatabase();
    final List<SortedMeasurement> measurements = database.sortedMeasurements;
    const String groupTag = 'groupTag';

    Widget deleteAction(SortedMeasurement currentMeasurement) {
      return SlidableAction(
          label: AppLocalizations.of(context)!.delete,
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
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
      );
    }

    Widget editAction(SortedMeasurement currentMeasurement) {
      return SlidableAction(
        label: AppLocalizations.of(context)!.edit,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
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
      );
    }

    final List<Slidable> listOfMeasurements = measurements.map(
      (SortedMeasurement currentMeasurement) {
        return Slidable(
          groupTag: groupTag,
          startActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.75,
            children: <Widget>[
              deleteAction(currentMeasurement),
              editAction(currentMeasurement),
            ],
          ),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.75,
            children: <Widget>[
              editAction(currentMeasurement),
              deleteAction(currentMeasurement)
            ],
          ),
          closeOnScroll: true,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                //color: Theme.of(context).colorScheme.background,
                width: MediaQuery
                    .of(context)
                    .size
                    .width
                    - 2 * TraleTheme.of(context)!.padding,
                height: 50.0,
                child: Text(
                  currentMeasurement.measurement.measureToString(
                    context, ws: 12,
                  ),
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyText1
                      ?.apply(fontFamily: 'Courier'),
                ),
              ),
            ],
          ),
        );
      }
    ).toList();


    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width
            - 2 * TraleTheme.of(context)!.padding,
        height: measurements.length * 50.0
            + 2 * TraleTheme.of(context)!.padding,
        padding: EdgeInsets.symmetric(
            vertical: TraleTheme.of(context)!.padding
        ),
        child: Card(
          shape: TraleTheme.of(context)!.borderShape,
          color: Theme.of(context).colorScheme.surface,
          margin: EdgeInsets.symmetric(
            horizontal: TraleTheme.of(context)!.padding,
          ),
          child: SlidableAutoCloseBehavior(
            child: ClipRRect(
              borderRadius:
                TraleTheme.of(context)!.borderShape.borderRadius.resolve(
                  Directionality.of(context)
                ),
              child: StreamBuilder<List<Measurement>>(
                stream: database.streamController.stream,
                builder: (
                  BuildContext context,
                  AsyncSnapshot<List<Measurement>> snapshot,
                ) => Column(
                  key: ValueKey<List<Measurement>>(
                      snapshot.data ?? <Measurement>[],
                  ),
                  children: listOfMeasurements,
                ),
              ),
            ),
          )
        ),
      ),
    );
  }
}
