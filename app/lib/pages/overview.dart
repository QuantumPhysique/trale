import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/measurementInterpolation.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/animate_in_effect.dart';
import 'package:trale/widget/calendar_view.dart';
import 'package:trale/widget/fade_in_effect.dart';
import 'package:trale/widget/ioWidgets.dart';
import 'package:trale/widget/linechart.dart';
import 'package:trale/widget/statsWidgets.dart';
import 'package:trale/screens/daily_entry_screen.dart';
import 'package:trale/database/database_helper.dart';
import 'package:trale/models/daily_entry.dart';


class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});
  @override
  _OverviewScreen createState() => _OverviewScreen();
}

class _OverviewScreen extends State<OverviewScreen> {
  final GlobalKey<ScaffoldState> key = GlobalKey();
  bool popupShown = false;
  late bool loadedFirst;
  Set<DateTime> _entryDates = {};

  @override
  void initState() {
    super.initState();
    loadedFirst = true;
    _refreshEntryDates();

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

  Future<void> _refreshEntryDates() async {
    final List<DailyEntry> entries = await DatabaseHelper.instance.getAllEntries();
    if (mounted) {
      setState(() {
        _entryDates = entries.map((e) => e.date).toSet();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final MeasurementDatabase database = MeasurementDatabase();
    final MeasurementInterpolation ip = MeasurementInterpolation();

    final int animationDurationInMilliseconds =
        TraleTheme.of(context)!.transitionDuration.slow.inMilliseconds;
    final int firstDelayInMilliseconds =
        TraleTheme.of(context)!.transitionDuration.normal.inMilliseconds;

    final TraleNotifier notifier = Provider.of<TraleNotifier>(context);

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
            child: CalendarView(
              measurements: snapshot.data ?? <Measurement>[],
              entryDates: _entryDates,
              onDateSelected: (DateTime date) async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DailyEntryScreen(initialDate: date),
                  ),
                );
                 if (result == true) {
                   _refreshEntryDates();
                 }
              },
            ),
          ),
          FadeInEffect(
            durationInMilliseconds: animationDurationInMilliseconds,
            delayInMilliseconds: firstDelayInMilliseconds,
            child: CustomLineChart(
              loadedFirst: loadedFirst,
              ip: ip,
              key: ValueKey<List<Measurement>>(
                  snapshot.data ?? <Measurement>[]),
            ),
          ),
          const SizedBox(height: 80.0),
        ],
      );
    }

    Widget overviewScreenWrapper(BuildContext context,
        AsyncSnapshot<List<Measurement>> snapshot) {
      final List<Measurement> data = snapshot.data ?? <Measurement>[];

      if (data.isNotEmpty) {
        return overviewScreen(context, snapshot);
      }

      return Container(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: <Widget>[
            Expanded(
              child: FadeInEffect(
                durationInMilliseconds: animationDurationInMilliseconds,
                delayInMilliseconds: firstDelayInMilliseconds,
                child: CalendarView(
                  shouldFillViewport: true,
                  measurements: data,
                  entryDates: _entryDates,
                  onDateSelected: (DateTime date) async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DailyEntryScreen(initialDate: date),
                      ),
                    );
                    _refreshEntryDates();
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Tap a date above to add an entry.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return StreamBuilder<List<Measurement>>(
      initialData: database.measurements,
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
