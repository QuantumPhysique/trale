import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/widget/linechart.dart';
import 'package:trale/widget/statsWidgets.dart';


class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});
  @override
  _OverviewScreen createState() => _OverviewScreen();
}

class _OverviewScreen extends State<OverviewScreen> {
  final GlobalKey<ScaffoldState> key = GlobalKey();
  final Duration animationDuration = const Duration(milliseconds: 500);
  bool popupShown = false;
  late bool loadedFirst;

  @override
  void initState() {
    super.initState();
    loadedFirst = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (loadedFirst) {
        loadedFirst = false;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final MeasurementDatabase database = MeasurementDatabase();
    final List<SortedMeasurement> measurements = database.sortedMeasurements;

    final SizedBox lineChart = SizedBox(
      height: MediaQuery.of(context).size.height / 3,
      width: MediaQuery.of(context).size.width,
      child: Card(
        shape: TraleTheme.of(context)!.borderShape,
        color: Theme.of(context).colorScheme.surface,
        margin: EdgeInsets.symmetric(
          horizontal: TraleTheme.of(context)!.padding,
        ),
        child: CustomLineChart(loadedFirst: loadedFirst)
      ),
    );

    final SizedBox dummyChart = SizedBox(
      height: MediaQuery.of(context).size.height / 3,
      width: MediaQuery.of(context).size.width,
      child: Card(
        shape: TraleTheme.of(context)!.borderShape,
        margin: EdgeInsets.symmetric(
          horizontal: TraleTheme.of(context)!.padding,
        ),
        child: Center(
          child: RichText(
            text: TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: AppLocalizations.of(context)!.intro1,
                ),
                const WidgetSpan(
                  child: Icon(CustomIcons.add),
                  alignment: PlaceholderAlignment.middle,
                ),
                TextSpan(
                  text: AppLocalizations.of(context)!.intro2,
                ),
              ],
              style: Theme.of(context).textTheme.bodyText1,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    final Container overviewScreen = Container(
      height: MediaQuery.of(context).size.height
        - kToolbarHeight - kBottomNavigationBarHeight,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const StatsWidgets(visible: true),
          lineChart,
        ],
      ),
    );

    return SafeArea(
      key: key,
      child: measurements.isNotEmpty
          ? overviewScreen
          : dummyChart,
    );
  }
}
