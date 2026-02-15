import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/measurementInterpolation.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/animate_in_effect.dart';
import 'package:trale/widget/animation_replay_scope.dart';
import 'package:trale/widget/emptyChart.dart';
import 'package:trale/widget/ioWidgets.dart';
import 'package:trale/widget/linechart.dart';
import 'package:trale/widget/statsWidgets.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key, this.tabController});

  /// Optional tab controller to replay animations on tab switch.
  final TabController? tabController;

  @override
  _OverviewScreen createState() => _OverviewScreen();
}

class _OverviewScreen extends State<OverviewScreen>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> key = GlobalKey();
  bool popupShown = false;
  late bool loadedFirst;
  late final Stream<List<Measurement>> _measurementStream;
  final AnimationReplayController _replayController =
      AnimationReplayController();

  /// Whether this tab is currently the nearest visible tab.
  bool _isActive = true;

  @override
  bool get wantKeepAlive => true;

  void _onTabAnimationTick() {
    final double value = widget.tabController!.animation!.value;
    // Tab 0 "owns" the range [0, 0.1).
    final bool nowActive = value < 0.1;
    if (nowActive && !_isActive) {
      // We just entered this tab's zone – fire immediately.
      final SlideDirection dir = value > 0
          ? SlideDirection
                .fromLeft // coming from a tab on the right
          : SlideDirection.fromRight; // fallback (app launch / settings)
      _replayController.replay(dir: dir);
    }
    _isActive = nowActive;
  }

  @override
  void initState() {
    super.initState();
    loadedFirst = true;
    _measurementStream = MeasurementDatabase().streamController.stream;
    _isActive = (widget.tabController?.index ?? 0) == 0;
    widget.tabController?.animation?.addListener(_onTabAnimationTick);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (loadedFirst && mounted) {
        loadedFirst = false;
        final TraleNotifier traleNotifier = Provider.of<TraleNotifier>(
          context,
          listen: false,
        );
        if (traleNotifier.showBackupReminder) {
          final ScaffoldMessengerState sm = ScaffoldMessenger.of(context);
          sm.showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.backupReminder),
              behavior: SnackBarBehavior.fixed,
              duration: TraleTheme.of(context)!.snackbarDuration,
              action: SnackBarAction(
                label: AppLocalizations.of(context)!.backupReminderButton,
                onPressed: () => exportBackup(context),
              ),
              persist: false,
            ),
          );
          traleNotifier.latestBackupReminderDate = DateTime.now();
        }
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    widget.tabController?.animation?.removeListener(_onTabAnimationTick);
    _replayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final MeasurementInterpolation ip = MeasurementInterpolation();

    final int animationDurationInMilliseconds = TraleTheme.of(
      context,
    )!.transitionDuration.slow.inMilliseconds;

    final TraleNotifier notifier = Provider.of<TraleNotifier>(context);

    Widget overviewScreen(
      BuildContext context,
      AsyncSnapshot<List<Measurement>> snapshot,
    ) {
      // Use measurements count as stable key to avoid recreating widgets on navigation
      final int measurementCount = snapshot.data?.length ?? 0;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AnimatedStatsWidgets(key: ValueKey<int>(measurementCount)),
          AnimateInEffect(
            durationInMilliseconds: animationDurationInMilliseconds,
            child: CustomLineChart(
              loadedFirst: loadedFirst,
              ip: ip,
              key: ValueKey<int>(measurementCount),
            ),
          ),
          const SizedBox(height: 80.0),
        ],
      );
    }

    Widget overviewScreenWrapper(
      BuildContext context,
      AsyncSnapshot<List<Measurement>> snapshot,
    ) {
      final MeasurementDatabase database = MeasurementDatabase();
      final List<SortedMeasurement> measurements = database.sortedMeasurements;

      return measurements.isNotEmpty
          ? overviewScreen(context, snapshot)
          : defaultEmptyChart(context: context, overviewScreen: true);
    }

    return AnimationReplayScope(
      controller: _replayController,
      child: StreamBuilder<List<Measurement>>(
        stream: _measurementStream,
        builder:
            (BuildContext context, AsyncSnapshot<List<Measurement>> snapshot) =>
                SafeArea(
                  key: key,
                  child: overviewScreenWrapper(context, snapshot),
                ),
      ),
    );
  }
}
