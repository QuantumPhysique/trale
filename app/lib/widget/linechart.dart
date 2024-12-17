import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:ml_linalg/linalg.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/measurementInterpolation.dart';
import 'package:trale/core/textSize.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/units.dart';
import 'package:trale/core/zoomLevel.dart';


class CustomLineChart extends StatefulWidget {
  const CustomLineChart({
    required this.loadedFirst,
    required this.ip,
    this.interactive = true,
    super.key,
  });

  final bool loadedFirst;
  final bool interactive;
  final MeasurementInterpolationBaseclass ip;

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
    minX = notifier.zoomLevel.minX;
    maxX = notifier.zoomLevel.maxX;
  }

  @override
  Widget build(BuildContext context) {
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
      Theme.of(context).textTheme.bodySmall!.apply(
        fontFamily: 'CourierPrime',
        color: Theme.of(context).colorScheme.onSurface,
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
              if (targetWeight != null)
                HorizontalLine(
                  y: targetWeight / unitScaling,
                  color: Theme.of(context).colorScheme.tertiary,
                  strokeWidth: 2,
                  dashArray: <int>[8, 6],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment:
                      ip.db.measurements.first.weight > targetWeight
                        ? Alignment.bottomRight
                        : Alignment.topRight,
                    padding: const EdgeInsets.only(bottom: 3),
                    style: Theme.of(context).textTheme.bodySmall!.apply(
                        color: Theme.of(context).colorScheme.onSurface,
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
                      ),
                    labelResolver: (HorizontalLine line) =>
                      AppLocalizations.of(context)!.targetWeightShort,
                  ),
                ),
            ],
          ),
          lineBarsData: <LineChartBarData>[
            LineChartBarData(
              spots: measurementsInterpol,
              isCurved: true,
              color: Colors.transparent,
              //color: Theme.of(context).colorScheme.primaryContainer,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).colorScheme.primaryContainer,
                // cutOffY: targetWeight ?? 0,
                // applyCutOffY: targetWeight != null,
              ),
              aboveBarData: BarAreaData(
                show: targetWeight != null,
                color: Theme.of(context).colorScheme.tertiaryContainer,
                cutOffY: targetWeight ?? 0,
                applyCutOffY: true,
              ),
            ),
            LineChartBarData(
              spots: measurements,
              isCurved: false,
              color: Theme.of(context).colorScheme.primary,
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
                  color: barData.color ?? Colors.black,
                  strokeColor: Theme.of(context).colorScheme.onSurface,
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

    return Container(
      height: MediaQuery.of(context).size.height / 3,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(margin, 2*margin, margin, margin),
      child: GestureDetector(
        onDoubleTap: () {
          if (widget.interactive) {
            notifier.nextZoomLevel();
            setState(() {
              maxX = notifier.zoomLevel.maxX;
              minX = notifier.zoomLevel.minX;
            });
          }
        },
        onScaleUpdate: (ScaleUpdateDetails details) {
          if (widget.interactive) {
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
        },
        onHorizontalDragUpdate: (DragUpdateDetails dragUpdDet) {
          if (widget.interactive) {
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
        },
        child: lineChart(minX, maxX, minY, maxY)
      )
    );
  }
}
