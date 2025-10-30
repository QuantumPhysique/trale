import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:intl/intl.dart';
import 'package:ml_linalg/linalg.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/core/measurementInterpolation.dart';
import 'package:trale/core/textSize.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/units.dart';
import 'package:trale/core/zoomLevel.dart';
import 'package:trale/l10n-gen/app_localizations.dart';


class CustomLineChart extends StatefulWidget {
  const CustomLineChart({
    required this.loadedFirst,
    required this.ip,
    this.isPreview = false,
    this.relativeHeight = 0.33,
    this.axisLabelColor,
    this.interpolationLineColor,
    this.interpolationBelowAreaColor,
    this.interpolationAboveAreaColor,
    this.measurementLineColor,
    this.measurementDotStrokeColor,
    this.targetWeightLineColor,
    this.targetWeightLabelTextColor,
    this.targetWeightLabelBackgroundColor,
    this.backgroundColor,
    super.key,
  });

  final bool loadedFirst;
  final bool isPreview;
  final MeasurementInterpolationBaseclass ip;

  final double relativeHeight;
  final Color? axisLabelColor;
  final Color? interpolationLineColor;
  final Color? interpolationBelowAreaColor;
  final Color? interpolationAboveAreaColor;
  final Color? measurementLineColor;
  final Color? measurementDotStrokeColor;
  final Color? targetWeightLineColor;
  final Color? targetWeightLabelTextColor;
  final Color? targetWeightLabelBackgroundColor;
  final Color? backgroundColor;

  @override
  _CustomLineChartState createState() => _CustomLineChartState();
}

class _CustomLineChartState extends State<CustomLineChart> {
  late double minX;
  late double maxX;
  @override
  void initState() {
    super.initState();
    final TraleNotifier notifier = TraleNotifier();
    minX = widget.isPreview
      ? widget.ip.timesDisplay.first
      : notifier.zoomLevel.minX;
    maxX = widget.isPreview
      ? widget.ip.timesDisplay.last
      : notifier.zoomLevel.maxX;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final MeasurementInterpolationBaseclass ip = widget.ip;

    // load times
    final Vector msTimes = ip.times_measured;
    final Vector interpolTimes = ip.timesDisplay;

    // scale to unit
    final double unitScaling = Provider.of<TraleNotifier>(
      context, listen: false
    ).unit.scaling;

    final Vector ms = widget.loadedFirst
      ? Vector.filled(
          ip.weights_measured.length,
          ip.weights_measured.mean(),
        )
      : ip.weights_measured;
    final Vector interpol = widget.loadedFirst
        ? Vector.filled(
          ip.weightsDisplay.length,
           ip.weightsDisplay.sum() / ip.isNotExtrapolated.sum(),
        )
        : ip.weightsDisplay;

    final TextStyle labelTextStyle =
      theme.textTheme.bodySmall!.apply(
        fontFamily: 'CourierPrime',
        color: widget.axisLabelColor ?? colorScheme.onSurface,
      );
    final Size textSize = sizeOfText(
      text: '1234',
      context: context,
      style: labelTextStyle,
    );
    final double margin = TraleTheme.of(context)!.padding;

    List<FlSpot> vectorsToFlSpot (Vector times, Vector weights) {
      return <FlSpot>[
        for (int idx = 0; idx < times.length; idx++)
          FlSpot(times[idx], weights[idx] / unitScaling)
      ];
    }

    final TraleNotifier notifier = TraleNotifier();
    final double? targetWeight = notifier.userTargetWeight;

    final Color interpolationLineColor =
        widget.interpolationLineColor ?? Colors.transparent;
    final Color interpolationBelowAreaColor =
        widget.interpolationBelowAreaColor ??
            colorScheme.primaryContainer.withAlpha(155);
    final Color interpolationAboveAreaColor =
        widget.interpolationAboveAreaColor ??
            colorScheme.tertiaryContainer.withAlpha(
              widget.isPreview ? 0 : 255,
            );
    final Color measurementLineColor =
        widget.measurementLineColor ?? colorScheme.primary;
    final Color measurementDotStrokeColor =
        widget.measurementDotStrokeColor ?? colorScheme.onSurface;
    final Color targetWeightLineColor =
        widget.targetWeightLineColor ?? colorScheme.tertiary;
    final Color targetWeightLabelTextColor =
        widget.targetWeightLabelTextColor ?? colorScheme.onSurface;
    final Color targetWeightLabelBackgroundColor =
        widget.targetWeightLabelBackgroundColor ??
            colorScheme.surfaceContainerLow;

    final List<FlSpot> measurements =
      vectorsToFlSpot(msTimes, ms);
    final List<FlSpot> measurementsInterpol =
      vectorsToFlSpot(interpolTimes, interpol);

    final int indexFirst = measurements.lastIndexWhere(
      (FlSpot e) => e.x < minX
    );
    final int indexLast = measurements.indexWhere((FlSpot e) => e.x > maxX) + 1;
    final List<FlSpot> shownData = measurements.sublist(
      indexFirst == -1
        ? 0
        : indexFirst,
      (
        indexLast == -1 ||
        indexLast >= measurements.length ||
        indexLast < indexFirst  //TODO: this includes -1 ?
      )
        ? measurements.length
        : indexLast,
    );

    double minY;
    double maxY;
    if (shownData.isEmpty) {
      // take global extrema if shownData is empty.
      minY = measurements.map((FlSpot e) => e.y).toList().reduce(min);
      maxY = measurements.map((FlSpot e) => e.y).toList().reduce(max);
    } else {
      minY = shownData.map((FlSpot e) => e.y).toList().reduce(min);
      maxY = shownData.map((FlSpot e) => e.y).toList().reduce(max);
    }
    // add padding to minY and maxY
    minY -= 0.2 * (maxY - minY);
    maxY += 0.2 * (maxY - minY);
    // ensure that minY and maxY are not to close
    if (maxY - minY < 2) {
      minY = (maxY + minY) / 2 - 1;
      maxY = (maxY + minY) / 2 + 1;
    }

    /// convert time [ms since Epoch] to xtick label
    String time2xticklabel(double time) {
      final DateTime date = DateTime.fromMillisecondsSinceEpoch(
        time.toInt()
      );
      final int interval = (
        max<double>(maxX - minX, 1) / (24 * 3600 * 1000) ~/ 6
      ).toInt();
      if (date.day == 1 && date.month == 1) {
        return DateFormat(
            'yy',
            Localizations.localeOf(context).languageCode
        ).format(date);
      } else if (date.day == 1) {
        // if tick interval of more than 45 days show only every second tick
        // starting from the first date of shown range.
        if (
          (interval <= 45) ||
          (interval > 45 && interval < 75 && date.month % 2 == 1) ||
          (interval >= 75 && interval < 120 && date.month % 3 == 1) ||
          (interval >= 120 && date.month % 6 == 1)
        ) {
          return DateFormat(
              'MMM',
              Localizations.localeOf(context).languageCode
          ).format(date);
        }
        return '';
      } else if (
        date.month != date.add(Duration(days: interval ~/ 1.5)).month ||
        (
            maxX - date.millisecondsSinceEpoch <
                const Duration(days: 1).inMilliseconds
        )
      ) {
        return '';
      } else if (
        date.day % interval == 0 && date.day - interval ~/ 1.5 > 0
      ) {
        return date.day.toString();
      }
      return '';
    }


    AxisTitles bottomTitles () {
      return AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: textSize.height + margin,
          interval: 24 * 3600 * 1000,  // days
          getTitlesWidget: (double time, TitleMeta titleMeta) => Padding(
            padding: EdgeInsets.only(top: margin),
            child: AutoSizeText(
              time2xticklabel(time),
              style: labelTextStyle,
            ),
          ),
        ),
      );
    }

    AxisTitles leftTitles () {
      return AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: textSize.width,
          interval: max<int>((maxY - minY)~/ 4, 1).toDouble(),
          getTitlesWidget: (double weight, TitleMeta titleMeta) =>
            AutoSizeText(
              weight.toStringAsFixed(0),
              style: labelTextStyle,
            ),
        ),
      );
    }

    Widget lineChart (double minX, double maxX, double minY, double maxY) {
      return LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: minY.floorToDouble(),
          maxY: maxY.ceilToDouble(),
          lineTouchData: const LineTouchData(enabled: false),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: bottomTitles(),
            leftTitles: leftTitles(),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)
            ),
            show: true,
          ),
          clipData: const FlClipData.all(),
          extraLinesData: ExtraLinesData(
          extraLinesOnTop: true,
            horizontalLines: <HorizontalLine>[
              if (targetWeight != null && !widget.isPreview)
                HorizontalLine(
                  y: targetWeight / unitScaling,
                  color: targetWeightLineColor,
                  strokeWidth: 2,
                  dashArray: <int>[8, 6],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment:
                      ip.db.measurements.first.weight > targetWeight
                        ? Alignment.bottomRight
                        : Alignment.topRight,
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    style: theme.textTheme.bodySmall!.apply(
                        color: targetWeightLabelTextColor,
                        backgroundColor: targetWeightLabelBackgroundColor,
                    ),
                    labelResolver: (HorizontalLine line) =>
                      ' ${AppLocalizations.of(context)!.targetWeightShort}',
                  ),
                ),
            ],
          ),
          lineBarsData: <LineChartBarData>[
            LineChartBarData(
              spots: measurementsInterpol,
              isCurved: true,
              color: interpolationLineColor,
              //color: Theme.of(context).colorScheme.primaryContainer,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: interpolationBelowAreaColor,
                // cutOffY: targetWeight ?? 0,
                // applyCutOffY: targetWeight != null,
              ),
              aboveBarData: BarAreaData(
                show: targetWeight != null,
                color: interpolationAboveAreaColor,
                cutOffY: targetWeight ?? 0,
                applyCutOffY: true,
              ),
            ),
            LineChartBarData(
              spots: measurements,
              isCurved: false,
              color: measurementLineColor,
              barWidth: 0,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (
                  FlSpot spot,
                  double percent,
                  LineChartBarData barData,
                  int index
                ) => FlDotCirclePainter(
                  radius:
                    max<double>(
                      5 - (maxX - minX) / (90 * 24 * 3600 * 1000),
                      1,
                    ),
                  color: measurementLineColor,
                  strokeColor: measurementDotStrokeColor,
                  strokeWidth: 0.2,
                )
              ),
            ),
          ],
        ),
        duration: TraleTheme.of(context)!.transitionDuration.normal,
        curve: Curves.easeOut,
      );
    }

    void scaleUpdate (ScaleUpdateDetails details) {
      if (!widget.isPreview) {
        setState(() {
          final double scale = (1 - details.horizontalScale) / 50;
          if (scale.isNegative) {
            if (maxX - minX > 1000 * 3600 * 24 * 7 * 2) {
              minX -= (maxX - minX) * scale;
              maxX += (maxX - minX) * scale;
            }
          } else {
            if (maxX - minX < 1000 * 3600 * 24 * 7 * 12) {
              if (minX - (maxX - minX) * scale > msTimes.first) {
                minX -= (maxX - minX) * scale;
              }
              if (
              maxX + (maxX - minX) * scale
                  < DateTime.now().millisecondsSinceEpoch.toDouble()
              ) {
                maxX += (maxX - minX) * scale;
              }
            }
          }
        });
      }
    }

    void dragUpdate (DragUpdateDetails dragUpdDet) {
      if (!widget.isPreview) {
        setState(() {
          final double primDelta =
              (dragUpdDet.primaryDelta ?? 0.0) * (maxX - minX) / 100;

          final double allowedMaxX =
          interpolTimes.last > DateTime.now().millisecondsSinceEpoch
              ? interpolTimes.last
              : DateTime.now().millisecondsSinceEpoch.toDouble();
          final double allowedMinX = interpolTimes.first;
          if (
          maxX - primDelta <= allowedMaxX &&
              minX - primDelta >= allowedMinX
          ) {
            maxX -= primDelta;
            minX -= primDelta;
          }
        });
      }
    }
    void doubleTap () {
      if (!widget.isPreview) {
        notifier.nextZoomLevel();
        setState(() {
          maxX = notifier.zoomLevel.maxX;
          minX = notifier.zoomLevel.minX;
        });
      }
    }

    return Column(
      children: <Widget>[
        Card(
          color: widget.backgroundColor,
          shape: TraleTheme.of(context)!.borderShape,
          margin: EdgeInsets.symmetric(
            horizontal: TraleTheme.of(context)!.padding,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height  * widget.relativeHeight,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(margin, 2*margin, margin, margin),
            child: GestureDetector(
              onDoubleTap: doubleTap,
              //onScaleUpdate: scaleUpdate,
              onHorizontalDragUpdate: dragUpdate,
              child: lineChart(minX, maxX, minY, maxY)
            ),
          ),
        ),
        if (!widget.isPreview)
        SizedBox(height: 0.5 * TraleTheme.of(context)!.padding),
        if (!widget.isPreview)
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Card(
              shape: TraleTheme.of(context)!.borderShape,
              margin: EdgeInsets.only(
                right: 0.5 * TraleTheme.of(context)!.padding,
              ),
              child: IconButton(
                onPressed: notifier.zoomLevel == ZoomLevel.all
                  ? null
                  : () {
                    notifier.zoomOut();
                    setState(() {
                      maxX = notifier.zoomLevel.maxX;
                      minX = notifier.zoomLevel.minX;
                    });
                  },
                icon: PPIcon(
                  PhosphorIconsDuotone.magnifyingGlassMinus,
                  context,
                ),
              ),
            ),
            Card(
              shape: TraleTheme.of(context)!.borderShape,
              margin: EdgeInsets.only(
                right: TraleTheme.of(context)!.padding,
              ),
              child: IconButton(
                onPressed: notifier.zoomLevel == ZoomLevel.two
                  ? null
                  : () {
                    notifier.zoomIn();
                    setState(() {
                      maxX = notifier.zoomLevel.maxX;
                      minX = notifier.zoomLevel.minX;
                    });
                  },
                icon: PPIcon(
                  PhosphorIconsDuotone.magnifyingGlassPlus,
                  context,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
