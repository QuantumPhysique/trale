import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/theme.dart';


class CustomLineChart extends StatefulWidget {
  const CustomLineChart({Key? key}) : super(key: key);

  @override
  _CustomLineChartState createState() => _CustomLineChartState();
}

class _CustomLineChartState extends State<CustomLineChart> {

  @override
  Widget build(BuildContext context) {

    final List<Color> gradientColors = <Color>[
      TraleTheme.of(context)!.bg,
      TraleTheme.of(context)!.accent,
    ];

    final List<Measurement> data = <Measurement>[
      Measurement(weight: 83.0, date: DateTime.parse('2021-06-26 20:18:04Z')),
      Measurement(weight: 83.3, date: DateTime.parse('2021-07-02 20:18:04Z')),
      Measurement(weight: 82.5, date: DateTime.parse('2021-07-06 16:18:04Z')),
      Measurement(weight: 82.2, date: DateTime.parse('2021-07-12 20:18:04Z')),
      Measurement(weight: 81.1, date: DateTime.parse('2021-07-20 20:18:04Z')),
      Measurement(weight: 81.8, date: DateTime.parse('2021-07-22 09:18:04Z')),
      Measurement(weight: 81.3, date: DateTime.parse('2021-07-24 06:18:04Z')),
      Measurement(weight: 79.9, date: DateTime.parse('2021-07-26 08:18:04Z')),
      Measurement(weight: 80.1, date: DateTime.parse('2021-07-29 07:18:04Z'))
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

    Widget linechart = LineChart(
        LineChartData(
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
          /*         minX: 0.0,
          maxX: 31.0,*/
          minY: 78.0,
          maxY: 84.0,
          lineBarsData: <LineChartBarData>[
            LineChartBarData(
              spots: convertMeasurements(data),
              isCurved: true,
              colors: <Color>[TraleTheme.of(context)!.accent],
              barWidth: 5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: true,
                colors: gradientColors.map(
                        (Color color) => color.withOpacity(0.3)).toList(),
              ),
            ),
          ],
        ),
      );

    return Container(
      height: MediaQuery.of(context).size.height / 3,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: linechart
    );
  }
}
