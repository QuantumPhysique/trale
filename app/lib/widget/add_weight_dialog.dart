import 'dart:async';

import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/l10n_extension.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurement_database.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/trale_notifier.dart';
import 'package:trale/core/unit_precision.dart';
import 'package:trale/core/units.dart';
import 'package:trale/core/weight_goal.dart';
import 'package:trale/widget/weight_picker.dart';

/// Content padding shared by the two weight dialogs.
///
/// The ruler's stepper buttons already sit their usual
/// [QPLayout.smallPadding] away from the ruler above, so the dialog
/// contributes only the other half of the [QPLayout.padding] used as inner
/// padding elsewhere, e.g. on the stats screen. Without the override the two
/// would stack and the gap below the ruler would be more than twice as wide
/// as everywhere else.
const EdgeInsets _weightDialogContentPadding = EdgeInsets.only(
  left: QPLayout.padding,
  top: QPLayout.padding,
  right: QPLayout.padding,
  bottom: QPLayout.smallPadding,
);

/// Actions padding shared by the two weight dialogs.
///
/// Repeats [QPDialog]'s own default, which the content override above would
/// otherwise leave looking lopsided.
const EdgeInsets _weightDialogActionsPadding = EdgeInsets.only(
  left: QPLayout.padding,
  right: QPLayout.padding,
  bottom: QPLayout.padding - QPLayout.smallPadding / 2,
);

///
Future<bool> showAddWeightDialog({
  required BuildContext context,
  required double weight,
  required DateTime date,
  bool editMode = false,
  String? message,
  void Function(DateTime date, double weight)? onSaved,
}) async {
  final TraleNotifier notifier = Provider.of<TraleNotifier>(
    context,
    listen: false,
  );

  final double initialSliderValue = weight.toDouble() / notifier.unit.scaling;
  double currentSliderValue = initialSliderValue;
  final DateTime initialDate = date;
  DateTime currentDate = initialDate;
  final MeasurementDatabase database = MeasurementDatabase();

  final Widget content = StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (message != null)
            Padding(
              padding: const EdgeInsets.only(bottom: QPLayout.padding),
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium!.apply(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          QPWidgetGroup(
            children: <Widget>[
              QPGroupedListTile(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                leading: PPIcon(PhosphorIconsDuotone.calendar, context),
                title: Text(context.l10n.date),
                trailing: Text(
                  notifier.dateFormat(context).format(currentDate),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                onTap: () async {
                  final TimeOfDay currentTime = TimeOfDay.fromDateTime(
                    currentDate,
                  );
                  final DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: currentDate,
                    firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                    lastDate: DateTime.now(),
                  );

                  if (selectedDate == null) {
                    return;
                  }

                  currentDate = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    currentTime.hour,
                    currentTime.minute,
                  );

                  if (!context.mounted) {
                    return;
                  }
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(currentDate),
                  );

                  if (time == null) {
                    return;
                  }
                  currentDate = DateTime(
                    currentDate.year,
                    currentDate.month,
                    currentDate.day,
                    time.hour,
                    time.minute,
                  );
                  setState(() {});
                },
              ),
              QPGroupedListTile(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                title: Text(context.l10n.time),
                leading: PPIcon(PhosphorIconsDuotone.clock, context),
                trailing: Text(
                  DateFormat.Hm().format(currentDate),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                onTap: () async {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(currentDate),
                  );

                  if (time == null) {
                    return;
                  }
                  currentDate = DateTime(
                    currentDate.year,
                    currentDate.month,
                    currentDate.day,
                    time.hour,
                    time.minute,
                  );
                  setState(() {});
                },
              ),
            ],
          ),
          const SizedBox(height: QPLayout.padding),
          RulerPicker(
            onValueChange: (num newValue) {
              currentSliderValue = newValue.toDouble();
              setState(() {});
            },
            height: 0.15 * MediaQuery.of(context).size.height,
            value: currentSliderValue,
            ticksPerStep:
                notifier.unitPrecision.ticksPerStep ??
                notifier.unit.ticksPerStep,
          ),
        ],
      );
    },
  );

  final bool accepted =
      await showDialog<bool>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return QPDialog(
            title: context.l10n.addWeight,
            content: SingleChildScrollView(child: content),
            contentPadding: _weightDialogContentPadding,
            actionsPadding: _weightDialogActionsPadding,
            actions: actions(context, () async {
              final bool wasInserted = await database.insertMeasurement(
                Measurement(
                  weight: currentSliderValue * notifier.unit.scaling,
                  date: currentDate,
                ),
              );
              if (!context.mounted) {
                return;
              }
              if (!wasInserted &&
                  !(editMode &&
                      currentDate == initialDate &&
                      currentSliderValue == initialSliderValue)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Adding measurement was skipped. '
                      'Measurement exists already.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
              if (wasInserted && onSaved != null) {
                onSaved(
                  currentDate,
                  currentSliderValue * notifier.unit.scaling,
                );
              }
              Navigator.pop(context, wasInserted);
            }, enabled: true),
          );
        },
      ) ??
      false;
  return accepted;
}

/// Opens the add-weight dialog for today, prefilled with the latest weight.
Future<bool> showTodaysAddWeightDialog(BuildContext context) {
  final List<SortedMeasurement> measurements =
      MeasurementDatabase().sortedMeasurements;
  return showAddWeightDialog(
    context: context,
    weight: measurements.isNotEmpty
        ? measurements.first.measurement.weight.toDouble()
        : Preferences().defaultUserWeight,
    date: DateTime.now(),
  );
}

/// Route content that opens the add-weight dialog and pops once it closes.
///
/// Pushed by a tapped weight reminder. It draws nothing itself so the screen
/// the user was last on stays visible behind the dialog.
class AddWeightOverlay extends StatefulWidget {
  /// Constructor.
  const AddWeightOverlay({super.key});

  @override
  State<AddWeightOverlay> createState() => _AddWeightOverlayState();
}

class _AddWeightOverlayState extends State<AddWeightOverlay> {
  @override
  void initState() {
    super.initState();
    // The route's own overlay entry is not mounted before the first frame,
    // so the dialog would have nothing to push itself onto.
    WidgetsBinding.instance.addPostFrameCallback((_) => _openDialog());
  }

  Future<void> _openDialog() async {
    await showTodaysAddWeightDialog(context);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

///
Future<bool> showTargetWeightDialog({
  required BuildContext context,
  required double weight,
}) async {
  final TraleNotifier notifier = Provider.of<TraleNotifier>(
    context,
    listen: false,
  );

  final double initialSliderValue = weight / notifier.unit.scaling;
  double currentSliderValue = initialSliderValue;
  WeightGoal goal = notifier.weightGoal;

  final Widget content = StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      final Color tileColor = Theme.of(context).colorScheme.surfaceContainerLow;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          QPWidgetGroup(
            children: <Widget>[
              QPGroupedWidget(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(QPLayout.padding),
                  child: Text(
                    context.l10n.targetWeightMotivation,
                    style: Theme.of(context).textTheme.bodyMedium!.apply(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: QPLayout.padding),
          RulerPicker(
            onValueChange: (num newValue) {
              currentSliderValue = newValue.toDouble();
              setState(() {});
            },
            height: 0.15 * MediaQuery.of(context).size.height,
            value: currentSliderValue,
            // Same grid as the add weight dialog, so that the precision
            // setting reaches both rulers and the typed value can always be
            // shown by the ruler it is entered on.
            ticksPerStep:
                notifier.unitPrecision.ticksPerStep ??
                notifier.unit.ticksPerStep,
          ),
          // No gap here: the stepper row below the ruler already brings its
          // own bottom margin, which adds up to the usual QPLayout.padding.
          QPWidgetGroup(
            children: <Widget>[
              QPGroupedListTile(
                color: tileColor,
                dense: true,
                leading: PPIcon(goal.icon, context),
                title: Text(
                  goal.nameLong(context),
                  style: Theme.of(context).textTheme.bodyLarge,
                  maxLines: 1,
                ),
                subtitle: Text(
                  context.l10n.weightGoalSubtitle,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              QPGroupedWidget(
                color: tileColor,
                child: Padding(
                  padding: const EdgeInsets.all(QPLayout.smallPadding),
                  child: QPButtonGroup<WeightGoal>(
                    expanded: true,
                    items: WeightGoal.values,
                    selected: goal,
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    tooltipBuilder: (WeightGoal value) =>
                        value.nameLong(context),
                    labelBuilder:
                        (BuildContext context, WeightGoal value, bool active) =>
                            Icon(value.selectorIcon(active: active)),
                    onSelected: (WeightGoal value) =>
                        setState(() => goal = value),
                  ),
                ),
              ),
              if (goal == WeightGoal.maintain)
                QPGroupedListTile(
                  color: tileColor,
                  dense: true,
                  title: Text(
                    context.l10n.targetRange,
                    style: Theme.of(context).textTheme.bodyLarge,
                    maxLines: 1,
                  ),
                  trailing: Text(
                    notifier.unit.maintainTargetToString(
                      currentSliderValue * notifier.unit.scaling,
                      notifier.unitPrecision,
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
            ],
          ),
        ],
      );
    },
  );

  final bool accepted =
      await showDialog<bool>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return QPDialog(
            title: context.l10n.targetWeight,
            content: SingleChildScrollView(child: content),
            contentPadding: _weightDialogContentPadding,
            actionsPadding: _weightDialogActionsPadding,
            actions: actions(context, () {
              // In order to make our contribution to prevention, no target
              // weight below 50 kg / 110 lb / 7.9 st is possible.

              double minWeight;
              if (notifier.userHeight != null) {
                // /100 is to convert userHeight from cm to m
                // Here, the minWeight corresponds to BMI=18.5
                minWeight =
                    18.5 *
                    (notifier.userHeight! / 100) *
                    (notifier.userHeight! / 100);
              } else {
                minWeight = 50;
              }
              // For the maintain goal the lower end of its range counts.
              final double centre = currentSliderValue * notifier.unit.scaling;
              final double lowestTarget = goal == WeightGoal.maintain
                  ? goal.range(centre).lower
                  : centre;
              if (lowestTarget < minWeight) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.target_weight_warning),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 10),
                  ),
                );
              } else if (notifier.userTargetWeight == null ||
                  currentSliderValue != initialSliderValue ||
                  goal != notifier.weightGoal) {
                // Only a changed goal restarts it, and with it "since goal".
                notifier.userTargetWeight = centre;
                notifier.weightGoal = goal;
                notifier.userTargetWeightSetDate = DateTime.now();
              }
              // force rebuilding linechart and widgets
              MeasurementDatabase().fireStream();
              Navigator.pop(context, true);
            }),
          );
        },
      ) ??
      false;
  return accepted;
}

///
List<Widget> actions(
  BuildContext context,
  Function onPress, {
  bool enabled = true,
}) {
  return <Widget>[
    QPDialogAction(
      onPressed: () => Navigator.pop(context, false),
      icon: PhosphorIconsRegular.x,
      label: context.l10n.abort,
    ),
    QPDialogAction(
      onPressed: enabled ? () => onPress() : null,
      icon: PhosphorIconsFill.floppyDiskBack,
      label: context.l10n.save,
      isPrimary: true,
    ),
  ];
}
