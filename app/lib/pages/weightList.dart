import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:trale/core/icons.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/units.dart';
import 'package:trale/pages/about.dart';
import 'package:trale/pages/faq.dart';
import 'package:trale/pages/overview.dart';
import 'package:trale/pages/settings.dart';
import 'package:trale/widget/addWeightDialog.dart';
import 'package:trale/widget/appDrawer.dart';
import 'package:trale/widget/linechart.dart';
import 'package:trale/widget/routeTransition.dart';
import 'package:trale/widget/statsWidgets.dart';

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
    final String groupTag = 'groupTag';

    ListView listOfView = ListView.builder(
        clipBehavior: Clip.antiAlias,
        itemCount: measurements.length,
        itemBuilder: (BuildContext context, int index) {
          final SortedMeasurement currentMeasurement
          = measurements[index];
          Widget deleteAction() {
            return SlidableAction(
                label: AppLocalizations.of(context)!.delete,
                backgroundColor: Theme.of(context).colorScheme.primary,
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
          Widget editAction() {
            return SlidableAction(
              label: AppLocalizations.of(context)!.edit,
              backgroundColor: TraleTheme.of(context)!.bgShade3,
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
          return Slidable(
            groupTag: groupTag,
            startActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.4,
              children: <Widget>[
                deleteAction(),
                editAction(),
              ],
            ),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.4,
              children: <Widget>[
                editAction(),
                deleteAction()
              ],
            ),
            closeOnScroll: true,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  color: TraleTheme.of(context)!.isDark
                      ? TraleTheme.of(context)!.bgShade2
                      : Theme.of(context).colorScheme.background,
                  width: MediaQuery.of(context).size.width
                      - 2 * TraleTheme.of(context)!.padding,
                  height: 40.0,
                  child: Text(
                    currentMeasurement.measurement.measureToString(
                      context, ws: 12,
                    ),
                    style: Theme.of(context).textTheme
                        .bodyText1?.apply(fontFamily: 'Courier'),
                  ),
                ),
              ],
            ),
          );
        }
    );

    return Container(child: listOfView);
  }
}
