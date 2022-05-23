import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/textSize.dart';
import 'package:trale/core/theme.dart';


class CustomLineChart extends StatefulWidget {
  const CustomLineChart({required this.loadedFirst, Key? key}) : super(key: key);

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
    final MeasurementDatabase db = MeasurementDatabase();
    minX = db.sortedMeasurements.first.measurement.date.subtract(
      const Duration(days: 21)
    ).millisecondsSinceEpoch.toDouble();
    maxX = db.sortedMeasurements.first.measurement.date.add(
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

    final TextStyle labelTextStyle =
      Theme.of(context).textTheme.caption!.apply(
        fontFamily: 'Courier',
        color: Theme.of(context).colorScheme.onSurface,
      );
    final Size textSize = sizeOfText(
      text: '1234',
      context: context,
      style: labelTextStyle,
    );
    final double margin = TraleTheme.of(context)!.padding;

    final List<Color> gradientColors = <Color>[
      Color.alphaBlend(
        Theme.of(context).colorScheme.primary.withOpacity(0.2),
        Theme.of(context).colorScheme.background,
      ),
      Color.alphaBlend(
        Theme.of(context).colorScheme.primary.withOpacity(0.4),
        Theme.of(context).colorScheme.background,
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

    /// convert time [ms since Epoch] to xtick label
    String time2xticklabel(double time) {
      final DateTime date = DateTime.fromMillisecondsSinceEpoch(
          time.toInt()
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
          lineTouchData: LineTouchData(enabled: false),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: false,
          ),
          titlesData: FlTitlesData(
            bottomTitles: bottomTitles(),
            leftTitles: leftTitles(),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            show: true,
          ),
          clipData: FlClipData.all(),
          lineBarsData: <LineChartBarData>[
            LineChartBarData(
              spots: measurementsInterpol,
              isCurved: true,
              color: Colors.transparent,
              barWidth: 5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).colorScheme.primaryContainer,
                //gradient: LinearGradient(
                //  colors: gradientColors,
                //  stops: const <double>[0.2, 1.0],
                //  begin: Alignment.bottomCenter,
                //  end: Alignment.topCenter,
                //),
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
                  color: barData.color,
                  strokeColor: Theme.of(context).colorScheme.onBackground,
                  strokeWidth: 0.2,
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
      padding: EdgeInsets.fromLTRB(margin, 2*margin, margin, margin),
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
