part of '../user_dialog.dart';

/// Target weight settings group with enable/disable toggle.
///
/// When disabled, only the toggle is shown. When enabled, the group expands
/// to show the target weight, or the target range of the maintain goal, and
/// for the other goals the target date.
class TargetWeightGroup extends StatelessWidget {
  /// Creates a [TargetWeightGroup].
  const TargetWeightGroup({
    super.key,
    required this.notifier,
    required this.onRefresh,
    this.title,
    this.backgroundColor,
  });

  /// The notifier providing user settings.
  final TraleNotifier notifier;

  /// Callback invoked when a field changes.
  final VoidCallback onRefresh;

  /// Optional title displayed above the group.
  final String? title;

  /// Optional background color.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final Color tileColor =
        backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerLow;
    final bool enabled = notifier.targetWeightEnabled;
    final bool maintaining = notifier.weightGoal == WeightGoal.maintain;
    final MeasurementDatabase db = MeasurementDatabase();

    final bool canEnable = !db.isEmpty;

    return QPWidgetGroup(
      title: title,
      children: <Widget>[
        // ── Enable / disable toggle ─────────────────────────────────
        QPGroupedListTile(
          color: tileColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: QPLayout.padding,
          ),
          leading: PPIcon(PhosphorIconsDuotone.target, context),
          title: Text(
            context.l10n.targetWeightEnabled,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Text(
            context.l10n.targetWeightEnabledSubtitle,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          enabled: canEnable,
          trailing: Switch(
            value: enabled,
            onChanged: canEnable
                ? (bool value) {
                    notifier.targetWeightEnabled = value;
                    MeasurementDatabase().fireStream();
                    onRefresh();
                  }
                : null,
          ),
        ),

        // ── Expanded target weight settings (only when enabled) ─────
        if (enabled) ...<Widget>[
          // Target weight value
          _GroupedFormFieldTile(
            color: tileColor,
            icon: PhosphorIconsDuotone.scales,
            fieldKey: ValueKey<String>(
              '${notifier.userTargetWeight} ${notifier.weightGoal.name}',
            ),
            readOnly: true,
            initialValue: notifier.userTargetWeight == null
                ? context.l10n.addTargetWeight
                : maintaining
                ? notifier.unit.maintainTargetToString(
                    notifier.userTargetWeight!,
                    notifier.unitPrecision,
                  )
                : notifier.unit.weightToString(
                    notifier.userTargetWeight!,
                    notifier.unitPrecision,
                  ),
            labelText: maintaining
                ? context.l10n.targetRange
                : context.l10n.targetWeight,
            onTap: () async {
              await showTargetWeightDialog(
                context: context,
                // A new target starts at the trend the goals are judged by,
                // so that a maintain goal starts inside its range.
                weight:
                    notifier.userTargetWeight ??
                    (db.isEmpty
                        ? Preferences().defaultUserWeight
                        : MeasurementInterpolation().interpolationForDay(
                            db.lastDate,
                          )!),
              );
              notifier.notify;
              onRefresh();
            },
          ),
          // Target date
          if (notifier.userTargetWeight != null && !maintaining)
            _GroupedFormFieldTile(
              color: tileColor,
              icon: PhosphorIconsDuotone.calendarCheck,
              fieldKey: ValueKey<DateTime?>(notifier.userTargetWeightDate),
              readOnly: true,
              initialValue: notifier.userTargetWeightDate != null
                  ? notifier
                        .dateFormat(context)
                        .format(notifier.userTargetWeightDate!)
                  : context.l10n.addTargetWeightDate,
              labelText: context.l10n.targetWeightDate,
              onTap: () async {
                await showTargetWeightDateDialog(context: context);
                notifier.notify;
                onRefresh();
              },
            ),
        ],
      ],
    );
  }
}

/// Shows a dialog to set the target date via synced rate, target date,
/// and start date fields.
///
/// The rate is the weekly change as a share of the weight, picked on a slider
/// whose track marks how demanding each rate is. Changing any of the three
/// fields recalculates the others.
Future<bool> showTargetWeightDateDialog({required BuildContext context}) async {
  final TraleNotifier notifier = Provider.of<TraleNotifier>(
    context,
    listen: false,
  );
  final MeasurementDatabase db = MeasurementDatabase();
  final double? targetWeight = notifier.userTargetWeight;
  if (targetWeight == null || db.isEmpty) {
    return false;
  }

  final double unitScaling = notifier.unit.scaling;
  final WeightGoal goal = notifier.weightGoal;
  final ({double min, double max}) rateRange = goal.weeklyRateRange;

  // ── Initialise from notifier or latest measurement ──────────────
  final MeasurementInterpolation ip = MeasurementInterpolation();
  final Measurement latestMeasurement = db.latestMeasurement;
  DateTime initDate =
      notifier.userTargetWeightSetDate ?? latestMeasurement.date;
  double initWeight =
      ip.measurementForDay(initDate) ?? latestMeasurement.weight;
  DateTime? targetDate = notifier.userTargetWeightDate;
  double rate = goal.defaultWeeklyRate;

  // ── Helpers ─────────────────────────────────────────────────────
  String percent(double weeklyRate) =>
      '${(weeklyRate * 100).toStringAsFixed(2)}%';

  void syncFromRate() {
    targetDate = TargetPlan.fromRate(
      start: initDate,
      startWeight: initWeight,
      target: targetWeight,
      weeklyRate: rate,
    )?.end;
  }

  void syncFromTargetDate() {
    final TargetPlan plan = TargetPlan(
      start: initDate,
      startWeight: initWeight,
      end: targetDate!,
      target: targetWeight,
    );
    // A target date on or before the start keeps the previous rate.
    if (plan.days > 0) {
      rate = plan.weeklyRate;
    }
  }

  void syncFromStart() {
    if (targetDate == null) {
      syncFromRate();
    } else {
      syncFromTargetDate();
    }
  }

  syncFromStart();

  bool targetDateEnabled = true;

  // ── Build dialog content ────────────────────────────────────────
  final Widget content = StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      final ColorScheme colorScheme = Theme.of(context).colorScheme;
      final TextTheme textTheme = Theme.of(context).textTheme;
      final Color tileColor = colorScheme.surfaceContainerLow;
      final TargetPace pace = goal.paceOf(rate);
      final Color paceColor = pace.color(colorScheme);

      final String targetDateStr = targetDate != null
          ? notifier.dateFormat(context).format(targetDate!)
          : '--';
      final String initDateStr = notifier.dateFormat(context).format(initDate);
      final String weeklyChangeStr =
          '${(initWeight * rate / unitScaling).toStringAsFixed(2)} → '
          '${(targetWeight * rate / unitScaling).toStringAsFixed(2)} '
          '${notifier.unit.name}${context.l10n.perWeek}';

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // ── Advice text ─────────────────────────────────────────
          QPWidgetGroup(
            children: <Widget>[
              QPGroupedWidget(
                color: tileColor,
                child: Padding(
                  padding: const EdgeInsets.all(QPLayout.padding),
                  child: Text(
                    context.l10n.targetWeightRateAdvice,
                    style: textTheme.bodyMedium!.apply(
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
              QPGroupedListTile(
                color: tileColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: QPLayout.padding,
                ),
                leading: PPIcon(PhosphorIconsDuotone.calendarCheck, context),
                title: Text(
                  context.l10n.targetWeightDate,
                  style: textTheme.bodyLarge,
                ),
                subtitle: Text(
                  context.l10n.targetWeightDateSubtitle,
                  style: textTheme.labelSmall,
                ),
                trailing: Switch(
                  value: targetDateEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      targetDateEnabled = value;
                    });
                  },
                ),
              ),
            ],
          ),
          if (targetDateEnabled) ...<Widget>[
            const SizedBox(height: QPLayout.padding),
            QPWidgetGroup(
              children: <Widget>[
                QPGroupedWidget(
                  color: colorScheme.secondary,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.only(
                      top: (QPLayout.padding + QPLayout.smallPadding) / 2,
                      bottom: QPLayout.smallPadding,
                    ),
                    child: Text(
                      '${context.l10n.targetWeightRate} '
                      '(%${context.l10n.perWeek})',
                      style: textTheme.emphasized.headlineSmall?.apply(
                        color: colorScheme.onSecondary,
                      ),
                    ),
                  ),
                ),
                QPGroupedWidget(
                  color: tileColor,
                  child: Padding(
                    padding: const EdgeInsets.all(QPLayout.padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: <Widget>[
                            Text(
                              percent(rate),
                              style: textTheme.monospace.titleLarge,
                            ),
                            const Spacer(),
                            Text(
                              pace.nameLong(context),
                              style: textTheme.emphasized.titleMedium?.apply(
                                color: paceColor,
                              ),
                            ),
                          ],
                        ),
                        Text(weeklyChangeStr, style: textTheme.labelSmall),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            // The pace track splits the gapped 2024 track.
                            // ignore: deprecated_member_use
                            year2023: false,
                            trackShape: _PaceTrackShape(
                              goal: goal,
                              pace: pace,
                              colorScheme: colorScheme,
                              innerRadius: QPTheme.of(
                                context,
                              )!.innerBorderRadius,
                            ),
                            thumbColor: paceColor,
                            tickMarkShape: SliderTickMarkShape.noTickMark,
                          ),
                          child: Slider(
                            value: rate.clamp(rateRange.min, rateRange.max),
                            min: rateRange.min,
                            max: rateRange.max,
                            divisions:
                                ((rateRange.max - rateRange.min) /
                                        weeklyRateStep)
                                    .round(),
                            semanticFormatterCallback: percent,
                            onChanged: (double value) {
                              setState(() {
                                rate = value;
                                syncFromRate();
                              });
                            },
                          ),
                        ),
                        Text(
                          pace.description(context),
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                QPGroupedListTile(
                  color: tileColor,
                  leading: PPIcon(PhosphorIconsDuotone.calendarCheck, context),
                  title: Text(context.l10n.targetWeightDate),
                  trailing: Text(targetDateStr, style: textTheme.bodyLarge),
                  onTap: () async {
                    final DateTime now = DateTime.now();
                    final DateTime? selected = await showDatePicker(
                      context: context,
                      initialDate:
                          targetDate ?? now.add(const Duration(days: 90)),
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 365 * 5)),
                    );
                    if (selected != null) {
                      setState(() {
                        targetDate = selected;
                        syncFromTargetDate();
                      });
                    }
                  },
                ),
                QPGroupedListTile(
                  color: tileColor,
                  leading: PPIcon(PhosphorIconsDuotone.calendar, context),
                  title: Text(context.l10n.startDate),
                  trailing: Text(initDateStr, style: textTheme.bodyLarge),
                  onTap: () async {
                    final DateTime? selected = await showDatePicker(
                      context: context,
                      initialDate: initDate,
                      firstDate: db.firstDate,
                      lastDate: db.lastDate,
                      selectableDayPredicate: ip.hasMeasurementOnDay,
                    );
                    if (selected != null) {
                      final double? w = ip.measurementForDay(selected);
                      if (w != null) {
                        setState(() {
                          initDate = selected;
                          initWeight = w;
                          syncFromStart();
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ],
      );
    },
  );

  return await showDialog<bool>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return QPDialog(
            title: context.l10n.targetWeightDate,
            content: SingleChildScrollView(child: content),
            actions: <Widget>[
              QPDialogAction(
                onPressed: () => Navigator.pop(context, false),
                icon: PhosphorIconsRegular.x,
                label: context.l10n.abort,
              ),
              QPDialogAction(
                onPressed: () {
                  if (targetDateEnabled && targetDate != null) {
                    notifier.userTargetWeightDate = targetDate;
                    notifier.userTargetWeightSetDate = initDate;
                  } else {
                    notifier.userTargetWeightDate = null;
                    notifier.userTargetWeightSetDate = null;
                  }
                  MeasurementDatabase().fireStream();
                  Navigator.pop(context, true);
                },
                icon: PhosphorIconsFill.floppyDiskBack,
                label: context.l10n.save,
                isPrimary: true,
              ),
            ],
          );
        },
      ) ??
      false;
}

/// Slider track split into the [TargetPace]s of [goal], with [pace]
/// highlighted.
class _PaceTrackShape extends SliderTrackShape with BaseSliderTrackShape {
  const _PaceTrackShape({
    required this.goal,
    required this.pace,
    required this.colorScheme,
    required this.innerRadius,
  });

  /// Goal whose paces are shown.
  final WeightGoal goal;

  /// Pace of the current value.
  final TargetPace pace;

  /// Colours of the paces.
  final ColorScheme colorScheme;

  /// Corner radius where the track is split.
  final double innerRadius;

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    final Rect track = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final ({double min, double max}) range = goal.weeklyRateRange;
    final Map<TargetPace, double> paceFrom = goal.paceFrom;
    final double thumbGap = sliderTheme.trackGap!;
    final Radius outer = Radius.circular(track.height / 2);
    final Radius inner = Radius.circular(innerRadius);

    final Canvas canvas = context.canvas..save();
    double thumbX = thumbCenter.dx;
    // Painted left to right; right-to-left text mirrors the canvas.
    if (textDirection == TextDirection.rtl) {
      canvas
        ..translate(track.left + track.right, 0)
        ..scale(-1, 1);
      thumbX = track.left + track.right - thumbX;
    }

    double xOf(double rate) =>
        track.left +
        track.width *
            ((rate - range.min) / (range.max - range.min)).clamp(0.0, 1.0);

    void paintPiece(
      double left,
      double right,
      Radius leftRadius,
      Radius rightRadius,
      Color color,
    ) {
      if (right > left) {
        canvas.drawRRect(
          RRect.fromLTRBAndCorners(
            left,
            track.top,
            right,
            track.bottom,
            topLeft: leftRadius,
            bottomLeft: leftRadius,
            topRight: rightRadius,
            bottomRight: rightRadius,
          ),
          Paint()..color = color,
        );
      }
    }

    for (final TargetPace band in TargetPace.values) {
      final bool first = band == TargetPace.values.first;
      final bool last = band == TargetPace.values.last;
      // Paces are parted like grouped tiles.
      final double left = first
          ? track.left
          : xOf(paceFrom[band]!) + QPLayout.space / 2;
      final double right = last
          ? track.right
          : xOf(paceFrom[TargetPace.values[band.index + 1]]!) -
                QPLayout.space / 2;
      final Color color = band == pace
          ? band.color(colorScheme)
          : band.containerColor(colorScheme);
      // Split around the thumb like the default gapped track.
      final double beforeThumb = min(right, thumbX - thumbGap);
      final double afterThumb = max(left, thumbX + thumbGap);
      paintPiece(
        left,
        beforeThumb,
        first ? outer : inner,
        last && beforeThumb == right ? outer : inner,
        color,
      );
      paintPiece(
        afterThumb,
        right,
        first && afterThumb == left ? outer : inner,
        last ? outer : inner,
        color,
      );
    }
    canvas.restore();
  }
}
