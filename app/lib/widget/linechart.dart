import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/textSize.dart';
import 'package:trale/core/theme.dart';


class CustomLineChart extends StatefulWidget {
  CustomLineChart({required this.loadedFirst, Key? key}) : super(key: key);

  final bool loadedFirst;
  @override
  _CustomLineChartState createState() => _CustomLineChartState();
}

class _CustomLineChartState extends State<CustomLineChart> {
  late double minX;
  late double maxX;
  @override
  void initState() {
    super.initState();
    minX = DateTime.now().subtract(
      const Duration(days: 21)
    ).millisecondsSinceEpoch.toDouble();
    maxX = DateTime.now().add(
      const Duration(days: 7)
    ).millisecondsSinceEpoch.toDouble();

  }

  @override
  Widget build(BuildContext context) {
    final MeasurementDatabase db = MeasurementDatabase();
    final List<Measurement> data = widget.loadedFirst
      ? db.averageMeasurements(db.measurements)
      : db.measurements;
    final List<Measurement> dataInterpol = widget.loadedFirst
      ? db.averageMeasurements(db.gaussianExtrapolatedMeasurements)
      : db.gaussianExtrapolatedMeasurements;
    final Size textSize = sizeOfText(
      text: '1234',
      context: context,
      style: Theme.of(context).textTheme.bodyText1!.apply(
        fontFamily: 'Courier',
      ),
    );
    const double margin = 10;

    final List<Color> gradientColors = <Color>[
      Color.alphaBlend(
        TraleTheme.of(context)!.accent.withOpacity(0.2),
        TraleTheme.of(context)!.bg,
      ),
      Color.alphaBlend(
        TraleTheme.of(context)!.accent.withOpacity(0.4),
        TraleTheme.of(context)!.bg,
      ),
    ];


    FlSpot measurementToFlSpot (Measurement measurement) {
      return FlSpot(
        measurement.date.millisecondsSinceEpoch.toDouble(),
        measurement.inUnit(context),
      );
    }

    final List<FlSpot> measurements = data.map(measurementToFlSpot).toList();
    final List<FlSpot> measurementsInterpol =
      dataInterpol.map(measurementToFlSpot).toList();

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
    SideTitles bottomTitles () {
      return SideTitles(
        showTitles: true,
        reservedSize: textSize.height,
        interval: 24 * 3600 * 1000,
        margin: margin,
        getTextStyles: (BuildContext context, double value)
          => Theme.of(context).textTheme.bodyText1!.apply(
            fontFamily: 'Courier',
          ),
        getTitles: (double value) {
          final DateTime date = DateTime.fromMillisecondsSinceEpoch(
              value.toInt()
          );
          final int interval = (
              max<double>(maxX - minX, 1) / (24 * 3600 * 1000) ~/ 6
          ).toInt();
          if (
            date.month != date.add(Duration(days: interval ~/ 1.5)).month ||
            (
              maxX - date.millisecondsSinceEpoch <
              const Duration(days: 1).inMilliseconds
            )
          ) {
            return '';
          } else if (date.day == 1) {
            return DateFormat(
              'MMM',
              Localizations.localeOf(context).languageCode
            ).format(date);
          } else if (
            date.day % interval == 0 &&
            date.day - interval ~/ 1.5 > 0
          ) {
            return date.day.toString();
          }
          return '';
        },
      );
    }

    SideTitles leftTitles () {
      return SideTitles(
        showTitles: true,
        reservedSize: textSize.width,
        interval: max<int>((maxY - minY)~/ 4, 1).toDouble(),
        margin: margin,
        getTextStyles: (BuildContext context, double value)
          => Theme.of(context).textTheme.bodyText1!.apply(
            fontFamily: 'Courier',
          ),
        getTitles: (double value) {
          return value.toStringAsFixed(0);
        },
      );
    }

    Widget lineChart (double minX, double maxX, double minY, double maxY) {
      return LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: minY.floorToDouble(),
          maxY: maxY.ceilToDouble(),
          lineTouchData: LineTouchData(enabled: false),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: false,
          ),
          titlesData: FlTitlesData(
            bottomTitles: bottomTitles(),
            leftTitles: leftTitles(),
            topTitles: SideTitles(showTitles: false),
            rightTitles: SideTitles(showTitles: false),
            show: true,
          ),
          clipData: FlClipData.all(),
          lineBarsData: <LineChartBarData>[
            LineChartBarData(
              spots: measurementsInterpol,
              isCurved: true,
              colors: <Color>[Colors.transparent],
              barWidth: 5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: true,
                gradientFrom: const Offset(0, 1),
                gradientTo: const Offset(0, 0.5),
                colors: gradientColors,
              ),
            ),
            LineChartBarData(
              spots: measurements,
              isCurved: false,
              colors: <Color>[TraleTheme.of(context)!.accent],
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
                  color: barData.colors.first,
                  strokeColor: TraleTheme.of(context)!.bgFont,
                )
              ),
            ),
          ],
        ),
        swapAnimationDuration: TraleTheme.of(context)!
          .transitionDuration.normal,
        swapAnimationCurve: Curves.easeOut,
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height / 3,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(
        right: margin,
        top: margin,
      ),
      child: GestureDetector(
        onDoubleTap: () {
          setState(() {
            if (
              minX == dataInterpol.first.date.millisecondsSinceEpoch.toDouble() &&
              maxX == (
                dataInterpol.last.date.compareTo(DateTime.now()) > 0
                  ? dataInterpol.last.date
                  : DateTime.now()
              ).millisecondsSinceEpoch.toDouble()
            ) {
              minX = DateTime.now().subtract(
                const Duration(days: 21)
              ).millisecondsSinceEpoch.toDouble();
              maxX = DateTime.now().add(
                const Duration(days: 7)
              ).millisecondsSinceEpoch.toDouble();
            } else {
              minX = dataInterpol.first.dateInMs.toDouble();
              maxX = (
                dataInterpol.last.date.compareTo(DateTime.now()) > 0
                  ? dataInterpol.last.date
                  : DateTime.now()
              ).millisecondsSinceEpoch.toDouble();
            }
          });
        },
        onScaleUpdate: (ScaleUpdateDetails details) {
          setState(() {
            final double scale = (1 - details.horizontalScale) / 50;
            if (scale.isNegative) {
              if (maxX - minX > 1000 * 3600 * 24 * 7 * 2) {
                minX -= (maxX - minX) * scale;
                maxX += (maxX - minX) * scale;
              }
            } else {
              if (maxX - minX < 1000 * 3600 * 24 * 7 *  12) {
                if (minX - (maxX - minX) * scale
                    > data.first.date.millisecondsSinceEpoch.toDouble()) {
                  minX -= (maxX - minX) * scale;
                }
                if (maxX + (maxX - minX) * scale
                    < DateTime.now().millisecondsSinceEpoch.toDouble()) {
                  maxX += (maxX - minX) * scale;
                }
              }
            }
          });
        },
        onHorizontalDragUpdate: (DragUpdateDetails dragUpdDet) {
          setState(() {
            final double primDelta =
                (dragUpdDet.primaryDelta ?? 0.0) * (maxX - minX) / 100;

            final double allowedMaxX = (
                dataInterpol.last.date.compareTo(DateTime.now()) > 0
                    ? dataInterpol.last.date
                    : DateTime.now()
            ).millisecondsSinceEpoch.toDouble();
            final double allowedMinX = dataInterpol.first.dateInMs.toDouble();
            if (
              maxX - primDelta <= allowedMaxX &&
              minX - primDelta >= allowedMinX
            ) {
              maxX -= primDelta;
              minX -= primDelta;
            }
          });
        },
        child: lineChart(minX, maxX, minY, maxY)
      )
    );
  }
}
