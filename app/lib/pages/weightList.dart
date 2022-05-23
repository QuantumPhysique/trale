import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:trale/core/icons.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/widget/addWeightDialog.dart';
import 'package:trale/widget/shapedSlidableAction.dart';

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
      return ShapedSlidableAction(
        //label: AppLocalizations.of(context)!.edit,
        //backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        //foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
        //icon: CustomIcons.edit,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
        icon: CustomIcons.edit,
        tooltip: AppLocalizations.of(context)!.edit,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
        ),
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

    List<Slidable> listOfMeasurements = measurements.map(
      (SortedMeasurement currentMeasurement) {
        double padding = 0;
        return Slidable(
          groupTag: groupTag,
          startActionPane: ActionPane(
            motion: CustomMotion(
                onOpen: () {
                  setState(() {
                    padding = 10;
                  });
                  print(padding);
                },
                onClose: () {
                  setState(() {
                    padding = 0;
                  });
                  print(padding);
                },
                motionWidget: const DrawerMotion(),
            ),
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
              AnimatedContainer(
                duration: TraleTheme.of(context)!.transitionDuration.normal,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                  vertical: padding,
                ),
                //color: Theme.of(context).colorScheme.background,
                width: MediaQuery
                    .of(context)
                    .size
                    .width
                    - 2 * TraleTheme.of(context)!.padding,
                height: 50 + 2 * padding,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: listOfMeasurements,
              ),
            ),
          )
        ),
      ),
    );
  }
}
