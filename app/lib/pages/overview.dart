import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/measurementInterpolation.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/animate_in_effect.dart';
import 'package:trale/widget/emptyChart.dart';
import 'package:trale/widget/fade_in_effect.dart';
import 'package:trale/widget/ioWidgets.dart';
import 'package:trale/widget/linechart.dart';
import 'package:trale/widget/statsWidgets.dart';


class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});
  @override
  _OverviewScreen createState() => _OverviewScreen();
}

class _OverviewScreen extends State<OverviewScreen> {
  final GlobalKey<ScaffoldState> key = GlobalKey();
  bool popupShown = false;
  late bool loadedFirst;

  @override
  void initState() {
    super.initState();
    loadedFirst = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (loadedFirst) {
        loadedFirst = false;
        final TraleNotifier traleNotifier = Provider.of<TraleNotifier>(
          context, listen: false,
        );
        if (traleNotifier.showBackupReminder) {
          final ScaffoldMessengerState sm = ScaffoldMessenger.of(context);
          sm.showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.backupReminder,
              ),
              behavior: SnackBarBehavior.fixed,
              duration: TraleTheme.of(context)!.snackbarDuration,
              action: SnackBarAction(
                label: AppLocalizations.of(context)!.backupReminderButton,
                onPressed: () => exportBackup(context),
              ),
            ),
          );
          traleNotifier.latestBackupReminderDate = DateTime.now();
        }
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final MeasurementDatabase database = MeasurementDatabase();
    final MeasurementInterpolation ip = MeasurementInterpolation();

    final int animationDurationInMilliseconds =
        TraleTheme.of(context)!.transitionDuration.slow.inMilliseconds;
    final int firstDelayInMilliseconds =
        TraleTheme.of(context)!.transitionDuration.normal.inMilliseconds;

    Widget overviewScreen(BuildContext context,
        AsyncSnapshot<List<Measurement>> snapshot) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AnimateInEffect(
            durationInMilliseconds: animationDurationInMilliseconds,
            delayInMilliseconds: firstDelayInMilliseconds,
            child: StatsWidgets(
              visible: true,
              key: ValueKey<List<Measurement>>(snapshot.data
                                               ?? <Measurement>[]),
            ),
          ),
          FadeInEffect(
            durationInMilliseconds: animationDurationInMilliseconds,
            delayInMilliseconds: firstDelayInMilliseconds,
            child: SizedBox(
              height: MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.width,
              child: Card(
                shape: TraleTheme.of(context)!.borderShape,
                margin: EdgeInsets.symmetric(
                  horizontal: TraleTheme.of(context)!.padding,
                ),
                child: CustomLineChart(
                  loadedFirst: loadedFirst,
                  ip: ip,
                  key: ValueKey<List<Measurement>>(
                      snapshot.data ?? <Measurement>[]),
                )
              ),
            ),
          ),
          const SizedBox(height: 80.0),
        ],
      );
    }

    Widget overviewScreenWrapper(BuildContext context,
        AsyncSnapshot<List<Measurement>> snapshot) {
      final MeasurementDatabase database = MeasurementDatabase();
      final List<SortedMeasurement> measurements = database.sortedMeasurements;

      return measurements.isNotEmpty
          ? overviewScreen(context, snapshot)
          : defaultEmptyChart(context: context, overviewScreen: true);
    }

    return StreamBuilder<List<Measurement>>(
      stream: database.streamController.stream,
      builder: (
          BuildContext context, AsyncSnapshot<List<Measurement>> snapshot,
      ) => SafeArea(
        key: key,
        child: overviewScreenWrapper(context, snapshot),
      )
    );
  }
}
