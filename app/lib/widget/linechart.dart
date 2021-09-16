import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/measurement.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/units.dart';
import 'package:trale/core/traleNotifier.dart';


/// return gaussian with std of 3 days in x [ms]
double gaussian(
    double x, {double sigma=72 * 3600 * 1000, double mu=0}
) => 1 / (sigma * sqrt(2 * pi)) * exp(-1 / 2 * pow(x - mu, 2) / pow(sigma, 2));

// interpolate measurements
// measurement.date.millisecondsSinceEpoch.toDouble(),
// notifier.unit.scaling * measurement.weight,
List<Measurement> measurementInerpol(List<Measurement> measurements) {
  measurements.sort((Measurement a, Measurement b) {
    return a.compareTo(b);
  });
  final List<RawMeasurement> values = <RawMeasurement>[
    for (Measurement m in measurements)
      RawMeasurement.fromMeasurement(measurement: m)
  ];

  List<Measurement> interpol = <Measurement>[];

  final int date_from = values.first.date - 7 * 24*3600*1000;
  final int date_to = values.last.date + 7 * 24*3600*1000;

  for (int date=date_from; date < date_to; date += 24*3600*1000) {
    double weight_sum = 0;
    double mean_sum = 0;
    for (final RawMeasurement m in values) {
      final double weight = gaussian(date.toDouble(), mu: m.date.toDouble());
      weight_sum += weight;
      mean_sum += m.weight * weight;
    }
    interpol.add(
      Measurement(
        weight: mean_sum / weight_sum,
        date: DateTime.fromMillisecondsSinceEpoch(date),
      )
    );
  }
  return interpol;
}


class CustomLineChart extends StatefulWidget {
  CustomLineChart({Key? key, required this.box}) : super(key: key);

  /// Hive box of measurments
  final Box<Measurement> box;

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
    maxX = DateTime.now().millisecondsSinceEpoch.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    TraleNotifier notifier = Provider.of<TraleNotifier>(context, listen: false);

    final List<Measurement> data = widget.box.values.toList();
    data.sort((Measurement a, Measurement b) {
      return a.compareTo(b);
    });

    final List<Color> gradientColors = <Color>[
      //colorElevated(TraleTheme.of(context)!.accent, 100.0),
      TraleTheme.of(context)!.accent.withOpacity(0.5),
      TraleTheme.of(context)!.accent,
    ];


    FlSpot measurementToFlSpot (Measurement measurement) {
      return FlSpot(
        measurement.date.millisecondsSinceEpoch.toDouble(),
        notifier.unit.scaling * measurement.weight,
      );
    }

    final List<FlSpot> measurements = data.map(measurementToFlSpot).toList();
    final List<FlSpot> measurements_interpol = measurementInerpol(
      data,
    ).map(measurementToFlSpot).toList();

/*    final List<FlSpot> shownData = measurements.where(
            (FlSpot e) => e.x <= maxX && e.x >= minX).toList();*/

    final int indexFirst = measurements.lastIndexWhere(
            (FlSpot e) => e.x < minX);
    final int indexLast = measurements.indexWhere((FlSpot e) => e.x > maxX) + 1;
    final List<FlSpot> shownData = measurements.sublist(
      indexFirst == -1 ? 0 : indexFirst,
      (indexLast == -1 || indexLast >= measurements.length
          || indexLast < indexFirst)
            ? measurements.length : indexLast,
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
        reservedSize: 22,
        interval: max<int>((maxX - minX)~/ 6, 1).toDouble(),
        margin: 10,
        getTextStyles: (BuildContext context, double value)
          => Theme.of(context).textTheme.bodyText1!,
        getTitles: (double value) {
          return DateTime.fromMillisecondsSinceEpoch(
              value.toInt()).day.toString();
        },
      );
    }
    print(((maxY - minY)~/ 4).toDouble());
    SideTitles rightTitles () {
      return SideTitles(
        showTitles: true,
        reservedSize: 35,
        interval: max<int>((maxY - minY)~/ 4, 1).toDouble(),
        margin: 10,
        getTextStyles: (BuildContext context, double value)
          => Theme.of(context).textTheme.bodyText1!,
        getTitles: (double value) {
          return '${value.toStringAsFixed(0)} ${notifier.unit.name}';
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
            topTitles: SideTitles(showTitles: false),
            rightTitles: rightTitles(),
            show: true,
          ),
          clipData: FlClipData.all(),
          lineBarsData: <LineChartBarData>[
            LineChartBarData(
              spots: measurements_interpol,
              isCurved: true,
              colors: gradientColors,
              gradientFrom: const Offset(0.5, 1),
              gradientTo: const Offset(0.5, 0),
              barWidth: 5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: true,
                gradientFrom: const Offset(0.5, 1),
                gradientTo: const Offset(0.5, 0),
                colors: gradientColors.map(
                        (Color color) => color.withOpacity(0.3)).toList(),
              ),
            ),
            LineChartBarData(
              spots: measurements,
              isCurved: false,
              colors: gradientColors,
              gradientFrom: const Offset(0.5, 1),
              gradientTo: const Offset(0.5, 0),
              barWidth: 0,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
              ),
            ),
          ],
        ),
        swapAnimationDuration: const Duration(milliseconds: 150),
        swapAnimationCurve: Curves.easeIn,
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
                (dragUpdDet.primaryDelta ?? 0.0) * (maxX - minX) / 100;
            if (maxX - primDelta <=
                  DateTime.now().millisecondsSinceEpoch.toDouble()
                && maxX - primDelta >=
                  data.first.date.millisecondsSinceEpoch.toDouble()
                  + (maxX - minX) / 2) {
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
