import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/theme.dart';
import 'package:flutter/gestures.dart';
import 'dart:math';


class CustomLineChart extends StatefulWidget {
  const CustomLineChart({Key? key}) : super(key: key);

  @override
  _CustomLineChartState createState() => _CustomLineChartState();
}

class _CustomLineChartState extends State<CustomLineChart> {
  final List<Measurement> data = <Measurement>[
    Measurement(weight: 85.0, date: DateTime.parse('2021-04-23 20:18:04Z')),
    Measurement(weight: 83.0, date: DateTime.parse('2021-06-26 20:18:04Z')),
    Measurement(weight: 83.3, date: DateTime.parse('2021-07-02 20:18:04Z')),
    Measurement(weight: 82.5, date: DateTime.parse('2021-07-06 16:18:04Z')),
    Measurement(weight: 82.2, date: DateTime.parse('2021-07-12 20:18:04Z')),
    Measurement(weight: 81.1, date: DateTime.parse('2021-07-20 20:18:04Z')),
    Measurement(weight: 81.8, date: DateTime.parse('2021-07-22 09:18:04Z')),
    Measurement(weight: 81.3, date: DateTime.parse('2021-07-24 06:18:04Z')),
    Measurement(weight: 79.9, date: DateTime.parse('2021-07-26 08:18:04Z')),
    Measurement(weight: 80.1, date: DateTime.parse('2021-07-29 07:18:04Z')),
    Measurement(weight: 80.3, date: DateTime.parse('2021-08-01 07:18:04Z')),
    Measurement(weight: 79.6, date: DateTime.parse('2021-08-05 07:18:04Z')),
    Measurement(weight: 79.1, date: DateTime.parse('2021-08-06 07:18:04Z')),
    Measurement(weight: 78.7, date: DateTime.parse('2021-08-16 07:18:04Z')),
  ];

  late double minX;
  late double maxX;
  @override
  void initState() {
    super.initState();
    minX = DateTime.now().subtract(const Duration(days: 21)
                                   ).millisecondsSinceEpoch.toDouble();
    maxX = DateTime.now().millisecondsSinceEpoch.toDouble();
  }

  @override
  Widget build(BuildContext context) {

    final List<Color> gradientColors = <Color>[
      //colorElevated(TraleTheme.of(context)!.accent, 100.0),
      TraleTheme.of(context)!.accent.withOpacity(0.5),
      TraleTheme.of(context)!.accent,
    ];


    FlSpot measurementToFlSpot (Measurement measurement) {
      return FlSpot(measurement.date.millisecondsSinceEpoch.toDouble(),
                    measurement.weight.toDouble());
    }

    final List<FlSpot> measurements = data.map(measurementToFlSpot).toList();

    final List<FlSpot> shownData = measurements.where(
            (FlSpot e) => e.x <= maxX && e.x >= minX).toList();
/*    final List<FlSpot> shownData = measurements.sublist(
      measurements.lastIndexWhere((FlSpot e) => e.x < minX),
      measurements.indexWhere((FlSpot e) => e.x > maxX),
    );*/

    double minY;
    double maxY;
    if (shownData.isEmpty) {
      // if no datapoint is inside of interval take closed ones.
      minY = measurements.lastWhere((FlSpot e) => e.x <= minX).y;
      maxY = measurements.firstWhere((FlSpot e) => e.x >= maxX).y;
      /*minY = measurements.map((FlSpot e) => e.y).toList().reduce(min);
      maxY = measurements.map((FlSpot e) => e.y).toList().reduce(max);*/
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
        reservedSize: 22,
        interval: ((maxX - minX)~/ 6).toDouble(),
        margin: 10,
        getTextStyles:(double value) => Theme.of(context).textTheme.bodyText1!,
        getTitles: (double value) {
          return DateTime.fromMillisecondsSinceEpoch(
              value.toInt()).day.toString();
        },
      );
    }

    SideTitles rightTitles () {
      return SideTitles(
        showTitles: true,
        reservedSize: 35,
        interval: 1,
        margin: 10,
        getTextStyles:(double value) => Theme.of(context).textTheme.bodyText1!,
        getTitles: (double value) {
          return '$value kg';
        },
      );
    }

    //todo use ScatterChart for data and use LineChart for the model.
    Widget lineChart (double minX, double maxX, double minY, double maxY) {
      return LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: minY.floorToDouble(),
          maxY: maxY.ceilToDouble(),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            verticalInterval: 1000 * 3600 * 24 * 30,
            horizontalInterval: 1,
            drawVerticalLine: true,
            drawHorizontalLine: false,
            getDrawingHorizontalLine: (double value) {
              return FlLine(
                color: TraleTheme.of(context)!.bgShade2,
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (double value) {
              return FlLine(
                color: TraleTheme.of(context)!.bgShade2,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            bottomTitles: bottomTitles(),
            leftTitles: SideTitles(showTitles: false),
            rightTitles: rightTitles(),
            show: true,
          ),
          clipData: FlClipData.all(),
          lineBarsData: <LineChartBarData>[
            LineChartBarData(
              spots: measurements,
              isCurved: false,
              colors: gradientColors,
              gradientFrom: const Offset(0.5, 1),
              gradientTo: const Offset(0.5, 0),
              barWidth: 5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
              ),
              belowBarData: BarAreaData(
                show: true,
                gradientFrom: const Offset(0.5, 1),
                gradientTo: const Offset(0.5, 0),
                colors: gradientColors.map(
                        (Color color) => color.withOpacity(0.3)).toList(),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height / 3,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onDoubleTap: () {
          setState(() {
            if (minX == data.first.date.millisecondsSinceEpoch.toDouble()
                && maxX == data.last.date.millisecondsSinceEpoch.toDouble()) {
              minX = DateTime.now().subtract(const Duration(days: 21)
              ).millisecondsSinceEpoch.toDouble();
              maxX = DateTime.now().millisecondsSinceEpoch.toDouble();
            } else {
              minX = data.first.date.millisecondsSinceEpoch.toDouble();
              maxX = data.last.date.millisecondsSinceEpoch.toDouble();
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
                (dragUpdDet.primaryDelta ?? 0.0) * (maxX - minX) / 100  ;
            if (maxX - primDelta
                <= DateTime.now().millisecondsSinceEpoch.toDouble()
                && maxX - primDelta
                >= data.first.date.millisecondsSinceEpoch.toDouble()) {
              maxX -= primDelta;
              minX -= primDelta;
            }
            print([(maxX - minX) / 1000 / 3600 / 24,
                   primDelta / 1000 / 3600 / 24]);
          });
        },
        child: lineChart(minX, maxX, minY, maxY)
      )
    );
  }
}
