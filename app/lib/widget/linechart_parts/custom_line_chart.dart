part of '../linechart.dart';

/// Custom line chart widget for trale.
class CustomLineChart extends StatefulWidget {
  /// Constructor.
  const CustomLineChart({
    required this.loadedFirst,
    required this.ip,
    this.isPreview = false,
    this.relativeHeight = 0.33,
    this.axisLabelColor,
    this.interpolationLineColor,
    this.interpolationBelowAreaColor,
    this.measurementLineColor,
    this.measurementDotStrokeColor,
    this.targetWeightLineColor,
    this.targetWeightLabelTextColor,
    this.targetWeightLabelBackgroundColor,
    this.targetRangeColor,
    this.backgroundColor,
    this.chartPadding,
    this.chartMargin,
    super.key,
  });

  /// Whether data was loaded initially.
  final bool loadedFirst;

  /// Whether chart is in preview mode.
  final bool isPreview;

  /// Measurement interpolation data.
  final MeasurementInterpolationBaseclass ip;

  /// Relative height of the chart.
  final double relativeHeight;

  /// Axis label color.
  final Color? axisLabelColor;

  /// Interpolation line color.
  final Color? interpolationLineColor;

  /// Area color below interpolation.
  final Color? interpolationBelowAreaColor;

  /// Measurement line color.
  final Color? measurementLineColor;

  /// Measurement dot stroke color.
  final Color? measurementDotStrokeColor;

  /// Target weight line color.
  final Color? targetWeightLineColor;

  /// Target weight label text color.
  final Color? targetWeightLabelTextColor;

  /// Target weight label background color.
  final Color? targetWeightLabelBackgroundColor;

  /// Maintain range band color.
  final Color? targetRangeColor;

  /// Chart background color.
  final Color? backgroundColor;

  /// Custom padding inside the chart card. Defaults to
  /// `EdgeInsets.fromLTRB(margin, 2*margin, margin, margin)`.
  final EdgeInsetsGeometry? chartPadding;

  /// Custom margin around the chart card. Defaults to
  /// `EdgeInsets.symmetric(horizontal: padding)`.
  final EdgeInsetsGeometry? chartMargin;

  @override
  State<CustomLineChart> createState() => _CustomLineChartState();
}

/// The spots [from] to [to] of the curve, both included, and for a part
/// beyond the measurements, the side facing away from them.
typedef _CurvePart = ({int from, int to, Alignment? awayFromData});

class _CustomLineChartState extends State<CustomLineChart>
    with SingleTickerProviderStateMixin {
  /// Dash pattern of the curve where it is projected beyond the measurements.
  static const List<int> _projectionDashArray = <int>[4, 6];

  /// Opacity of the projected area and band next to the measurements,
  /// relative to the fitted part, fading to [_projectionFadedOpacity] at the
  /// far end.
  static const double _projectionOpacity = 0.6;

  /// See [_projectionOpacity].
  static const double _projectionFadedOpacity = 0.15;

  /// The fill of a projected part, lighter than [color] and fading out
  /// [awayFromData]; null for the fitted part, which is filled with [color].
  static Gradient? _projectionFade(Color color, Alignment? awayFromData) =>
      awayFromData == null
      ? null
      : LinearGradient(
          begin: -awayFromData,
          end: awayFromData,
          colors: <Color>[
            color.withValues(alpha: color.a * _projectionOpacity),
            color.withValues(alpha: color.a * _projectionFadedOpacity),
          ],
        );

  // Animation targets (where the viewport will end up).
  late double minX;
  late double maxX;

  // Current animated viewport values – driven by [_viewAnim].
  // Both the LineChart viewport and the tooltip centre are derived from these,
  // so they are always in perfect sync with zero double-animation.
  late double _curMinX;
  late double _curMaxX;
  double _fromMinX = 0;
  double _fromMaxX = 0;

  bool _showTooltip = false;
  Timer? _tooltipTimer;

  late AnimationController _viewAnim;

  void _onViewAnimTick() {
    final double t = Curves.easeOut.transform(_viewAnim.value);
    setState(() {
      _curMinX = _fromMinX + (minX - _fromMinX) * t;
      _curMaxX = _fromMaxX + (maxX - _fromMaxX) * t;
    });
  }

  /// Animate the viewport from the current visual position to [newMinX]/[newMaxX].
  void _animateTo(double newMinX, double newMaxX) {
    _viewAnim.stop();
    _fromMinX = _curMinX;
    _fromMaxX = _curMaxX;
    minX = newMinX;
    maxX = newMaxX;
    _viewAnim.forward(from: 0.0);
  }

  /// Snap the viewport instantly to [newMinX]/[newMaxX] (no animation).
  void _snapTo(double newMinX, double newMaxX) {
    _viewAnim.stop();
    minX = newMinX;
    maxX = newMaxX;
    _curMinX = newMinX;
    _curMaxX = newMaxX;
    _fromMinX = newMinX;
    _fromMaxX = newMaxX;
  }

  ({double minX, double maxX}) _resolveViewport(Preferences prefs) {
    // The zoom window is derived from the user's measurements, so a chart of
    // them follows it, even as a preview. Only sample data is shown in full.
    if (widget.ip is! MeasurementInterpolation) {
      final ml.Vector times = widget.ip.times;
      if (times.isNotEmpty) {
        return (minX: times.first, maxX: times.last);
      }
    }

    final double newMinX = prefs.zoomLevel.minX;
    final double newMaxX = prefs.zoomLevel.maxX;
    if (newMinX <= newMaxX) {
      return (minX: newMinX, maxX: newMaxX);
    }

    final double now = DateTime.now().millisecondsSinceEpoch.toDouble();
    return (minX: now, maxX: now);
  }

  @override
  void dispose() {
    _tooltipTimer?.cancel();
    _viewAnim.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final Preferences prefs = Preferences();
    final ({double minX, double maxX}) viewport = _resolveViewport(prefs);
    final double initMinX = viewport.minX;
    final double initMaxX = viewport.maxX;
    minX = initMinX;
    maxX = initMaxX;
    _curMinX = initMinX;
    _curMaxX = initMaxX;
    _fromMinX = initMinX;
    _fromMaxX = initMaxX;
    _viewAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(_onViewAnimTick);
  }

  @override
  void didUpdateWidget(covariant CustomLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPreview != widget.isPreview || oldWidget.ip != widget.ip) {
      final Preferences prefs = Preferences();
      final ({double minX, double maxX}) viewport = _resolveViewport(prefs);
      final double newMinX = viewport.minX;
      final double newMaxX = viewport.maxX;
      _snapTo(newMinX, newMaxX);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final MeasurementInterpolationBaseclass ip = widget.ip;

    // load times
    final ({ml.Vector times, ml.Vector measurements}) msData = ip.measured();
    final ml.Vector msTimes = msData.times;
    final ml.Vector interpolTimes = ip.times;

    // scale to unit
    // A unit change fires no measurement stream, so the chart listens itself.
    final double unitScaling = context.select<TraleNotifier, double>(
      (TraleNotifier notifier) => notifier.unit.scaling,
    );
    final bool scientific = context.select<TraleNotifier, bool>(
      (TraleNotifier notifier) => notifier.chartMode == ChartMode.scientific,
    );
    final bool showBand = scientific && ip.hasBand && !widget.loadedFirst;

    final ml.Vector ms = widget.loadedFirst
        ? ml.Vector.filled(
            msData.measurements.length,
            msData.measurements.mean(),
          )
        : msData.measurements;
    final ml.Vector interpol = widget.loadedFirst
        ? ml.Vector.filled(ip.weights.length, ip.weights.mean())
        : ip.weights;

    final TextStyle labelTextStyle = theme.textTheme.monospace.bodySmall!.apply(
      color: widget.axisLabelColor ?? colorScheme.onSurface,
    );
    final Size textSize = sizeOfText(
      text: '1234',
      context: context,
      style: labelTextStyle,
    );
    const double margin = QPLayout.padding;

    List<FlSpot> vectorsToFlSpot(ml.Vector times, ml.Vector weights) {
      return <FlSpot>[
        for (int idx = 0; idx < times.length; idx++)
          FlSpot(times[idx], weights[idx] / unitScaling),
      ];
    }

    final TraleNotifier notifier = Provider.of<TraleNotifier>(
      context,
      listen: false,
    );
    final double? targetWeight = notifier.effectiveTargetWeight;
    final TargetRange? maintainRange =
        notifier.weightGoal == WeightGoal.maintain
        ? notifier.effectiveTargetRange
        : null;
    final DateTime? targetWeightDate = notifier.effectiveTargetWeightDate;
    final DateTime? effectiveSetDate = notifier.targetWeightEnabled
        ? notifier.userTargetWeightSetDate
        : null;
    final double? effectiveSetWeight = notifier.targetWeightEnabled
        ? notifier.userTargetWeightSetWeight
        : null;

    final Color interpolationLineColor =
        widget.interpolationLineColor ??
        (scientific ? colorScheme.secondary : Colors.transparent);
    final Color interpolationBelowAreaColor =
        widget.interpolationBelowAreaColor ?? colorScheme.secondaryContainer;
    final Color measurementLineColor =
        widget.measurementLineColor ?? colorScheme.primary;
    final Color measurementDotStrokeColor =
        widget.measurementDotStrokeColor ?? Colors.transparent;
    final Color targetWeightLineColor =
        widget.targetWeightLineColor ?? colorScheme.tertiary;
    final Color targetWeightLabelTextColor =
        widget.targetWeightLabelTextColor ?? colorScheme.onSurface;
    final Color targetWeightLabelBackgroundColor =
        widget.targetWeightLabelBackgroundColor ??
        colorScheme.surfaceContainerLow;
    final Color targetRangeColor =
        widget.targetRangeColor ?? colorScheme.surfaceContainerHigh;
    final Color tooltipLineColor = colorScheme.tertiary;

    final List<FlSpot> measurements = vectorsToFlSpot(msTimes, ms);
    final List<FlSpot> measurementsInterpol = vectorsToFlSpot(
      interpolTimes,
      interpol,
    );
    final List<FlSpot> predictiveLower = showBand
        ? vectorsToFlSpot(interpolTimes, ip.bandLower)
        : <FlSpot>[];
    final List<FlSpot> predictiveUpper = showBand
        ? vectorsToFlSpot(interpolTimes, ip.bandUpper)
        : <FlSpot>[];

    // The curve is fitted between the first and the last measurement; before
    // and after, the model runs on without data. Neighbouring parts share the
    // spot where they meet.
    final int firstFitted = measurementsInterpol.indexWhere(
      (FlSpot e) => e.x >= msTimes.first,
    );
    final int lastFitted = measurementsInterpol.lastIndexWhere(
      (FlSpot e) => e.x <= msTimes.last,
    );
    final List<_CurvePart> curveParts = <_CurvePart>[
      if (firstFitted > 0)
        (from: 0, to: firstFitted, awayFromData: Alignment.centerLeft),
      (from: firstFitted, to: lastFitted, awayFromData: null),
      if (lastFitted < measurementsInterpol.length - 1)
        (
          from: lastFitted,
          to: measurementsInterpol.length - 1,
          awayFromData: Alignment.centerRight,
        ),
    ];

    final int indexFirst = measurements.lastIndexWhere(
      (FlSpot e) => e.x < _curMinX,
    );
    final int indexLast =
        measurements.indexWhere((FlSpot e) => e.x > _curMaxX) + 1;
    final List<FlSpot> shownData = measurements.sublist(
      indexFirst == -1 ? 0 : indexFirst,
      (indexLast == -1 ||
              indexLast >= measurements.length ||
              indexLast <
                  indexFirst // TODO(pb): this includes -1 ?
                  )
          ? measurements.length
          : indexLast,
    );

    // Without dots in view, the range of all dots. The band counts only
    // between the first and the last dot: beyond them it widens.
    final double bandFrom = max(_curMinX, msTimes.first);
    final double bandTo = min(_curMaxX, msTimes.last);
    final ({double minY, double maxY}) yRange = _chartYRange(<double>[
      for (final FlSpot e in shownData.isEmpty ? measurements : shownData) e.y,
      for (int i = 0; i < predictiveLower.length; i++)
        if (predictiveLower[i].x >= bandFrom &&
            predictiveLower[i].x <= bandTo) ...<double>[
          predictiveLower[i].y,
          predictiveUpper[i].y,
        ],
    ]);
    final double minY = yRange.minY;
    final double maxY = yRange.maxY;

    /// Build the x-tick label widget for a given [time] (ms since epoch).
    /// For January 1st, shows the month name and the year in bold below it.
    Widget time2xtickwidget(double time) {
      final DateTime date = DateTime.fromMillisecondsSinceEpoch(time.toInt());
      final String locale = Localizations.localeOf(context).languageCode;
      final int interval =
          (max<double>(_curMaxX - _curMinX, 1) / (24 * 3600 * 1000) ~/ 6)
              .toInt();
      if (date.day == 1 && date.month == 1) {
        // January 1st: year on top row, month on bottom row
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            AutoSizeText(
              DateFormat('yyyy', locale).format(date),
              style: labelTextStyle.copyWith(fontWeight: FontWeight.bold),
            ),
            AutoSizeText(
              DateFormat('MMM', locale).format(date),
              style: labelTextStyle,
            ),
          ],
        );
      } else if (date.day == 1) {
        // First of month – align to bottom to match the 'Jan' row position
        if ((interval <= 45) ||
            (interval > 45 && interval < 75 && date.month % 2 == 1) ||
            (interval >= 75 && interval < 120 && date.month % 3 == 1) ||
            (interval >= 120 && date.month % 6 == 1)) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: AutoSizeText(
              DateFormat('MMM', locale).format(date),
              style: labelTextStyle,
            ),
          );
        }
        return const SizedBox.shrink();
      } else if (date.month !=
              date.add(Duration(days: interval ~/ 1.5)).month ||
          (_curMaxX - date.millisecondsSinceEpoch <
              const Duration(days: 1).inMilliseconds)) {
        return const SizedBox.shrink();
      } else if (date.day % interval == 0 && date.day - interval ~/ 1.5 > 0) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: AutoSizeText(date.day.toString(), style: labelTextStyle),
        );
      }
      return const SizedBox.shrink();
    }

    AxisTitles bottomTitles() {
      return AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: textSize.height * 2,
          interval: 24 * 3600 * 1000, // days
          getTitlesWidget: (double time, TitleMeta titleMeta) {
            if (time == titleMeta.min || time == titleMeta.max) {
              return const SizedBox.shrink();
            }
            return time2xtickwidget(time);
          },
        ),
      );
    }

    AxisTitles leftTitles() {
      return AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: textSize.width,
          interval: max<int>((maxY - minY) ~/ 4, 1).toDouble(),
          getTitlesWidget: (double weight, TitleMeta titleMeta) =>
              AutoSizeText(weight.toStringAsFixed(0), style: labelTextStyle),
        ),
      );
    }

    Widget lineChart(double minX, double maxX, double minY, double maxY) {
      // centerX is derived directly from the animated viewport values, so
      // the tooltip spot is always in sync with the visible chart centre.
      int centerInterpolIdx = 0;
      if (measurementsInterpol.isNotEmpty) {
        final double centerX = (minX + maxX) / 2;
        double minDist = double.infinity;
        for (int i = 0; i < measurementsInterpol.length; i++) {
          final double dist = (measurementsInterpol[i].x - centerX).abs();
          if (dist < minDist) {
            minDist = dist;
            centerInterpolIdx = i;
          }
        }
      }

      // Dot radius – same formula used for measurement dots.
      final double dotRadius =
          max<double>(5 - (maxX - minX) / (90 * 24 * 3600 * 1000), 1.0) + 0.4;

      final bool showTooltip =
          !widget.isPreview && _showTooltip && measurementsInterpol.isNotEmpty;
      // The part holding the tooltip; at a shared spot, the later part.
      final int tooltipPart = curveParts.lastIndexWhere(
        (_CurvePart part) => part.from <= centerInterpolIdx,
      );

      // Build the curve bars once so we can reference them in both
      // lineBarsData and showingTooltipIndicators.
      final List<LineChartBarData> curveBars = <LineChartBarData>[
        for (int i = 0; i < curveParts.length; i++)
          LineChartBarData(
            spots: measurementsInterpol.sublist(
              curveParts[i].from,
              curveParts[i].to + 1,
            ),
            showingIndicators: showTooltip && i == tooltipPart
                ? <int>[centerInterpolIdx - curveParts[i].from]
                : <int>[],
            isCurved: true,
            color: interpolationLineColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dashArray: curveParts[i].awayFromData == null
                ? null
                : _projectionDashArray,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: !scientific,
              color: curveParts[i].awayFromData == null
                  ? interpolationBelowAreaColor
                  : null,
              gradient: _projectionFade(
                interpolationBelowAreaColor,
                curveParts[i].awayFromData,
              ),
            ),
          ),
      ];

      // fl_chart paints range annotations before it clips to the plot area,
      // so the band has to be cut to the visible y-range here.
      final double bandLower = max(
        (maintainRange?.lower ?? 0) / unitScaling,
        minY.floorToDouble(),
      );
      final double bandUpper = min(
        (maintainRange?.upper ?? 0) / unitScaling,
        maxY.ceilToDouble(),
      );
      final bool showTargetRange =
          maintainRange != null &&
          bandLower < bandUpper &&
          !widget.isPreview &&
          ip.db.measurements.isNotEmpty;

      LineChartBarData bandEdge(List<FlSpot> spots) => LineChartBarData(
        spots: spots,
        isCurved: true,
        color: Colors.transparent,
        barWidth: 0,
        dotData: const FlDotData(show: false),
      );

      final List<LineChartBarData> lineBars = <LineChartBarData>[
        ...curveBars,
        LineChartBarData(
          spots: measurements,
          isCurved: false,
          color: measurementLineColor,
          barWidth: 0,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter:
                (
                  FlSpot spot,
                  double percent,
                  LineChartBarData barData,
                  int index,
                ) => FlDotCirclePainter(
                  radius:
                      max<double>(
                        5 - (maxX - minX) / (90 * 24 * 3600 * 1000),
                        1.0,
                      ) +
                      0.4,
                  color: measurementLineColor,
                  strokeColor: measurementDotStrokeColor,
                  strokeWidth: 0.2,
                ),
          ),
        ),
        // Target weight line segments
        if (targetWeight != null &&
            !widget.isPreview &&
            targetWeightDate != null &&
            effectiveSetDate != null &&
            effectiveSetWeight != null)
          for (final List<FlSpot> segment in _buildTargetWeightSegments(
            setDateMs: effectiveSetDate.millisecondsSinceEpoch.toDouble(),
            setWeight: effectiveSetWeight / unitScaling,
            targetDateMs: targetWeightDate.millisecondsSinceEpoch.toDouble(),
            targetWeight: targetWeight / unitScaling,
            chartMaxX: maxX,
            chartMinX: minX,
          ))
            LineChartBarData(
              spots: segment,
              isCurved: false,
              color: targetWeightLineColor,
              barWidth: 2,
              isStrokeCapRound: true,
              dashArray: <int>[8, 6],
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
              aboveBarData: BarAreaData(show: false),
            ),
        // The band, a lower and an upper edge for each part of the curve.
        if (showBand)
          for (final _CurvePart part in curveParts) ...<LineChartBarData>[
            bandEdge(predictiveLower.sublist(part.from, part.to + 1)),
            bandEdge(predictiveUpper.sublist(part.from, part.to + 1)),
          ],
      ];
      final int firstBandEdge = lineBars.length - 2 * curveParts.length;

      return LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: minY.floorToDouble(),
          maxY: maxY.ceilToDouble(),
          showingTooltipIndicators: showTooltip
              ? <ShowingTooltipIndicators>[
                  ShowingTooltipIndicators(<LineBarSpot>[
                    LineBarSpot(
                      curveBars[tooltipPart],
                      tooltipPart,
                      measurementsInterpol[centerInterpolIdx],
                    ),
                  ]),
                ]
              : <ShowingTooltipIndicators>[],
          lineTouchData: widget.isPreview
              ? const LineTouchData(enabled: false)
              : LineTouchData(
                  enabled: false,
                  handleBuiltInTouches: false,
                  getTouchedSpotIndicator:
                      (LineChartBarData barData, List<int> spotIndexes) =>
                          spotIndexes
                              .map(
                                (int index) => TouchedSpotIndicatorData(
                                  FlLine(
                                    color: tooltipLineColor,
                                    strokeWidth: 2,
                                  ),
                                  FlDotData(
                                    getDotPainter:
                                        (
                                          FlSpot spot,
                                          double percent,
                                          LineChartBarData barData,
                                          int index,
                                        ) => FlDotCirclePainter(
                                          radius: dotRadius,
                                          color: tooltipLineColor,
                                          strokeColor: tooltipLineColor,
                                          strokeWidth: 0.2,
                                        ),
                                  ),
                                ),
                              )
                              .toList(),
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => colorScheme.surfaceContainerHigh,
                    fitInsideHorizontally: true,
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    getTooltipItems: (List<LineBarSpot> touchedSpots) =>
                        touchedSpots.map((LineBarSpot spot) {
                          final DateTime date =
                              DateTime.fromMillisecondsSinceEpoch(
                                spot.x.toInt(),
                              );
                          return LineTooltipItem(
                            notifier.dayFormat(context).format(date),
                            theme.textTheme.bodySmall!.copyWith(
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                            children: <TextSpan>[
                              TextSpan(
                                text:
                                    // ignore: lines_longer_than_80_chars
                                    '\n${notifier.unit.weightToString(spot.y * unitScaling, notifier.unitPrecision)}',
                                style: theme.textTheme.bodySmall!.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: bottomTitles(),
            leftTitles: leftTitles(),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            show: true,
          ),
          clipData: const FlClipData.all(),
          rangeAnnotations: RangeAnnotations(
            horizontalRangeAnnotations: <HorizontalRangeAnnotation>[
              if (showTargetRange)
                HorizontalRangeAnnotation(
                  y1: bandLower,
                  y2: bandUpper,
                  color: targetRangeColor,
                ),
            ],
          ),
          extraLinesData: ExtraLinesData(
            extraLinesOnTop: true,
            horizontalLines: <HorizontalLine>[
              if (targetWeight != null &&
                  !widget.isPreview &&
                  ip.db.measurements.isNotEmpty) ...<HorizontalLine>[
                // Visible dashed line when no target date is set
                if (targetWeightDate == null || effectiveSetWeight == null)
                  HorizontalLine(
                    y: targetWeight / unitScaling,
                    color: targetWeightLineColor,
                    strokeWidth: 2,
                    dashArray: <int>[8, 6],
                    label: HorizontalLineLabel(show: false),
                  ),
                // Label clamped to visible y-range so it never disappears
                HorizontalLine(
                  y: (targetWeight / unitScaling).clamp(
                    minY.floorToDouble(),
                    maxY.ceilToDouble(),
                  ),
                  color: Colors.transparent,
                  strokeWidth: 0,
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: ip.db.measurements.first.weight > targetWeight
                        ? Alignment.bottomRight
                        : Alignment.topRight,
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    style: theme.textTheme.bodySmall!.apply(
                      color: targetWeightLabelTextColor,
                      // Blend the label into the band it sits on.
                      backgroundColor: showTargetRange
                          ? targetRangeColor
                          : targetWeightLabelBackgroundColor,
                    ),
                    labelResolver: (HorizontalLine line) =>
                        ' ${context.l10n.targetWeightShort}',
                  ),
                ),
              ],
            ],
          ),
          lineBarsData: lineBars,
          betweenBarsData: <BetweenBarsData>[
            if (showBand)
              for (int i = 0; i < curveParts.length; i++)
                BetweenBarsData(
                  fromIndex: firstBandEdge + 2 * i,
                  toIndex: firstBandEdge + 2 * i + 1,
                  color: curveParts[i].awayFromData == null
                      ? interpolationBelowAreaColor
                      : null,
                  gradient: _projectionFade(
                    interpolationBelowAreaColor,
                    curveParts[i].awayFromData,
                  ),
                ),
          ],
        ),
        duration: Duration.zero,
        curve: Curves.easeOut,
      );
    }

    // void scaleUpdate(ScaleUpdateDetails details) {
    //   if (!widget.isPreview) {
    //     setState(() {
    //       final double scale = (1 - details.horizontalScale) / 50;
    //       if (scale.isNegative) {
    //         if (maxX - minX > 1000 * 3600 * 24 * 7 * 2) {
    //           minX -= (maxX - minX) * scale;
    //           maxX += (maxX - minX) * scale;
    //         }
    //       } else {
    //         if (maxX - minX < 1000 * 3600 * 24 * 7 * 12) {
    //           if (minX - (maxX - minX) * scale > msTimes.first) {
    //             minX -= (maxX - minX) * scale;
    //           }
    //           if (maxX + (maxX - minX) * scale <
    //               DateTime.now().millisecondsSinceEpoch.toDouble()) {
    //             maxX += (maxX - minX) * scale;
    //           }
    //         }
    //       }
    //     });
    //   }
    // }

    void dragUpdate(DragUpdateDetails dragUpdDet) {
      if (!widget.isPreview) {
        _tooltipTimer?.cancel();
        _showTooltip = true;
        final double primDelta =
            (dragUpdDet.primaryDelta ?? 0.0) * (maxX - minX) / 100;
        final double range = maxX - minX;
        final double dataMaxX =
            interpolTimes.last > DateTime.now().millisecondsSinceEpoch
            ? interpolTimes.last
            : DateTime.now().millisecondsSinceEpoch.toDouble();
        // Allow scrolling until the first/last interpolation point is
        // centred in the visible window.
        final double allowedMaxX = dataMaxX + range / 2;
        final double allowedMinX = interpolTimes.first - range / 2;
        final double newMaxX = (maxX - primDelta).clamp(
          allowedMinX + range,
          allowedMaxX,
        );
        _snapTo(newMaxX - range, newMaxX);
        setState(() {});
      }
    }

    void dragEnd(DragEndDetails details) {
      if (!widget.isPreview) {
        final double velocity = details.primaryVelocity ?? 0.0;
        if (velocity.abs() > 50) {
          final double range = maxX - minX;
          final double dataMaxX =
              interpolTimes.last > DateTime.now().millisecondsSinceEpoch
              ? interpolTimes.last
              : DateTime.now().millisecondsSinceEpoch.toDouble();
          final double allowedMaxX = dataMaxX + range / 2;
          final double allowedMinX = interpolTimes.first - range / 2;
          // Convert pixel velocity to chart-coordinate fling distance.
          // Uses the same scale factor as dragUpdate (range / 100 per pixel).
          final double flingDelta = -velocity * (range / 100) * 0.3;
          final double newMaxX = (maxX + flingDelta).clamp(
            allowedMinX + range,
            allowedMaxX,
          );
          _animateTo(newMaxX - range, newMaxX);
        }
        _tooltipTimer?.cancel();
        _tooltipTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() => _showTooltip = false);
          }
        });
      }
    }

    void doubleTap() {
      if (!widget.isPreview) {
        notifier.nextZoomLevel();
        _animateTo(notifier.zoomLevel.minX, notifier.zoomLevel.maxX);
      }
    }

    return Column(
      children: <Widget>[
        Card(
          color: widget.backgroundColor,
          shape: QPTheme.of(context)!.borderShape,
          margin:
              widget.chartMargin ??
              const EdgeInsets.symmetric(horizontal: QPLayout.padding),
          child: Container(
            height: MediaQuery.of(context).size.height * widget.relativeHeight,
            width: MediaQuery.of(context).size.width,
            padding:
                widget.chartPadding ??
                const EdgeInsets.fromLTRB(margin, 2 * margin, margin, margin),
            child: GestureDetector(
              onDoubleTap: doubleTap,
              //onScaleUpdate: scaleUpdate,
              onHorizontalDragUpdate: dragUpdate,
              onHorizontalDragEnd: dragEnd,
              onHorizontalDragCancel: () {
                _tooltipTimer?.cancel();
                _tooltipTimer = Timer(const Duration(seconds: 3), () {
                  if (mounted) {
                    setState(() => _showTooltip = false);
                  }
                });
              },
              child: lineChart(_curMinX, _curMaxX, minY, maxY),
            ),
          ),
        ),
        if (!widget.isPreview)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: QPLayout.padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                QPWidgetGroup(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    QPGroupedWidget(
                      child: IconButton(
                        onPressed: notifier.zoomLevel == ZoomLevel.all
                            ? null
                            : () {
                                notifier.zoomOut();
                                _animateTo(
                                  notifier.zoomLevel.minX,
                                  notifier.zoomLevel.maxX,
                                );
                              },
                        icon: PPIcon(
                          PhosphorIconsDuotone.magnifyingGlassMinus,
                          context,
                        ),
                      ),
                    ),
                    QPGroupedWidget(
                      child: IconButton(
                        onPressed: notifier.zoomLevel == ZoomLevel.one
                            ? null
                            : () {
                                notifier.zoomIn();
                                _animateTo(
                                  notifier.zoomLevel.minX,
                                  notifier.zoomLevel.maxX,
                                );
                              },
                        icon: PPIcon(
                          PhosphorIconsDuotone.magnifyingGlassPlus,
                          context,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
