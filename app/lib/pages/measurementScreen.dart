import 'package:flutter/material.dart';

import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/widget/emptyChart.dart';
import 'package:trale/widget/weightList.dart';

class MeasurementScreen extends StatefulWidget {
  const MeasurementScreen({super.key, required this.tabController});

  final TabController tabController;
  @override
  _MeasurementScreen createState() => _MeasurementScreen();
}

class _MeasurementScreen extends State<MeasurementScreen> {
  final ScrollController scrollController = ScrollController();
  final GlobalKey<ScaffoldState> key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Under construction',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
