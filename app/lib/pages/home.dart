import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/changelog.dart';
import 'package:trale/core/l10n_extension.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurement_database.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/pages/measurement_screen.dart';
import 'package:trale/pages/overview.dart';
import 'package:trale/pages/settings_overview.dart';
import 'package:trale/pages/stat_screen.dart';
import 'package:trale/widget/add_weight_dialog.dart';
import 'package:trale/widget/user_dialog.dart';

/// home scaffold
class Home extends StatefulWidget {
  /// constructor
  const Home({super.key});
  @override
  /// create state
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _popupShown = false;

  Future<void> _onFABPressed() async {
    final MeasurementDatabase database = MeasurementDatabase();
    final List<SortedMeasurement> measurements = database.sortedMeasurements;
    setState(() {
      _popupShown = true;
    });
    await showAddWeightDialog(
      context: context,
      weight: measurements.isNotEmpty
          ? measurements.first.measurement.weight.toDouble()
          : Preferences().defaultUserWeight,
      date: DateTime.now(),
    );
    setState(() {
      _popupShown = false;
    });
  }

  void _onPostInit(BuildContext ctx) {
    if (Preferences().showChangelog) {
      Preferences().showChangelog = false;
      showQPChangelog(ctx, changelog);
    }
  }

  @override
  Widget build(BuildContext context) {
    return QPHomePage(
      tabs: <QPHomeTab>[
        QPHomeTab(
          icon: PPIcon(PhosphorIconsDuotone.lineSegments, context),
          selectedIcon: PPIcon(PhosphorIconsFill.lineSegments, context),
          label: context.l10n.home,
          buildContent: (TabController tc) => OverviewScreen(tabController: tc),
        ),
        QPHomeTab(
          icon: PPIcon(PhosphorIconsDuotone.trophy, context),
          selectedIcon: PPIcon(PhosphorIconsFill.trophy, context),
          label: context.l10n.achievements,
          buildContent: (TabController tc) => StatsScreen(tabController: tc),
        ),
        QPHomeTab(
          icon: PPIcon(PhosphorIconsDuotone.archive, context),
          selectedIcon: PPIcon(PhosphorIconsFill.archive, context),
          label: context.l10n.measurements,
          buildContent: (TabController tc) =>
              MeasurementScreen(tabController: tc),
        ),
      ],
      settingsPageBuilder: (_) => const SettingsOverviewPage(),
      onUserPressed: () => showUserDialog(context: context),
      onFABPressed: _popupShown ? null : _onFABPressed,
      fabOnFirstTabOnly: true,
      fabTooltip: context.l10n.addWeight,
      onPostInit: _onPostInit,
    );
  }
}
