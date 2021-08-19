import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/theme.dart';
import 'package:flutter/gestures.dart';


class CustomLineChart extends StatefulWidget {
  const CustomLineChart({Key? key}) : super(key: key);

  @override
  _CustomLineChartState createState() => _CustomLineChartState();
}

class _CustomLineChartState extends State<CustomLineChart> {
  final List<Measurement> data = <Measurement>[
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
      colorElevated(TraleTheme.of(context)!.accent, 50.0),
      TraleTheme.of(context)!.accent,
    ];


    FlSpot measurementToFlSpot (Measurement measurement) {
      return FlSpot(measurement.date.millisecondsSinceEpoch.toDouble(),
                    measurement.weight.toDouble());
    }

    List<FlSpot> convertMeasurements(List<Measurement> measurements) {
      return measurements.map(measurementToFlSpot).toList();
    }

    SideTitles bottomTitles () {
      return SideTitles(
        showTitles: true,
        reservedSize: 22,
        interval: 1000 * 60 * 60 * 24 * 2,  // 2 days
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
        interval: 1,  // 2 days
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
          minY: minY,
          maxY: maxY,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: false,
            verticalInterval: 1000 * 60 * 60 * 24,
            horizontalInterval: 1,
            drawVerticalLine: true,
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
              spots: convertMeasurements(data),
              isCurved: false,
              colors: gradientColors,
              barWidth: 5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
              ),
              belowBarData: BarAreaData(
                show: true,
                /* uncomment to make vertical gradient
                gradientFrom: Offset(0.5, 1),
                gradientTo: Offset(0.5, 0), */
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
      child: Listener(
        onPointerSignal: (signal) {
          if (signal is PointerScrollEvent) {
            setState(() {
              if (signal.scrollDelta.dy.isNegative) {
                minX += 1000 * 3600 * 24;
                maxX -= 1000 * 3600 * 24;
              } else {
                minX -= 1000 * 3600 * 24;
                maxX += 1000 * 3600 * 24;
              }
            });
          }
        },
        child: GestureDetector(
          onDoubleTap: () {
            setState(() {
              minX = data.first.date.millisecondsSinceEpoch.toDouble();
              maxX = data.last.date.millisecondsSinceEpoch.toDouble();
            });
          },
          onHorizontalDragUpdate: (dragUpdDet) {
            setState(() {
              print(dragUpdDet.primaryDelta);
              double primDelta = dragUpdDet.primaryDelta ?? 0.0;
              if (primDelta != 0) {
                if (primDelta.isNegative) {
                  if (maxX < data.last.date.millisecondsSinceEpoch.toDouble()) {
                    minX += 1000 * 3600 * 24;
                    maxX += 1000 * 3600 * 24;
                  }
                } else {
                  if (minX > data.first.date.millisecondsSinceEpoch.toDouble()) {
                    minX -= 1000 * 3600 * 24;
                    maxX -= 1000 * 3600 * 24;
                  }
                }
              }
            });
          },
          child: lineChart(minX, maxX, 77, 84)
        ),
      )
    );
  }
}
