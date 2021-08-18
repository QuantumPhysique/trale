import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:trale/core/theme.dart';


class CustomLineChart extends StatefulWidget {
  const CustomLineChart({Key? key}) : super(key: key);

  @override
  _CustomLineChartState createState() => _CustomLineChartState();
}

class _CustomLineChartState extends State<CustomLineChart> {

  @override
  Widget build(BuildContext context) {

    List<Color> gradientColors = [
      TraleTheme.of(context)!.bg,
      TraleTheme.of(context)!.accent,
    ];

    return Container(
      height: MediaQuery.of(context).size.height / 3,
      width: MediaQuery.of(context).size.width,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: false,
          ),
          titlesData: FlTitlesData(
            show: false,
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, 3),
                FlSpot(2.6, 2),
                FlSpot(4.9, 5),
                FlSpot(6.8, 3.1),
                FlSpot(8, 4),
                FlSpot(9.5, 3),
                FlSpot(11, 4),
              ],
              isCurved: true,
              colors: gradientColors,
              barWidth: 5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: true,
                colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
              ),
            ),
          ],
        )
      ),
    );
  }
}
