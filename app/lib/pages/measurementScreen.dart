import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/stringExtension.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/widget/emptyChart.dart';
import 'package:trale/widget/text_size_in_effect.dart';
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
    final MeasurementDatabase database = MeasurementDatabase();

    final int animationDurationInMilliseconds =
        TraleTheme.of(context)!.transitionDuration.slow.inMilliseconds;
    final int firstDelayInMilliseconds =
        TraleTheme.of(context)!.transitionDuration.normal.inMilliseconds;
    final int secondDelayInMilliseconds =  firstDelayInMilliseconds;

    // Define empty Chart in case there are no measurements
    final Widget dummyChart = emptyChart(
      context,
      <InlineSpan>[
        TextSpan(
          text: AppLocalizations.of(context)!.intro3,
        ),
        const TextSpan(
            text: '\n\n😃'
        ),
      ],
    );

    Widget measurementScreen(BuildContext context,
        AsyncSnapshot<List<Measurement>> snapshot) {

      return CustomScrollView(
        controller: scrollController,
        cacheExtent: MediaQuery.of(context).size.height,
        slivers: <Widget>[
          SliverPersistentHeader(
            pinned: true,
            delegate: HeaderDelegate(
                AppLocalizations.of(context)!.stats.inCaps,
                animationDurationInMilliseconds,
                firstDelayInMilliseconds),
          ),
          WeightList(
            durationInMilliseconds: animationDurationInMilliseconds,
            delayInMilliseconds: secondDelayInMilliseconds,
            scrollController: scrollController,
            tabController: widget.tabController,
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: TraleTheme.of(context)!.padding,
            ),
          ),
        ],
      );
    }

    Widget measurementScreenWrapper(BuildContext context,
        AsyncSnapshot<List<Measurement>> snapshot) {
      final MeasurementDatabase database = MeasurementDatabase();
      final List<SortedMeasurement> measurements = database.sortedMeasurements;
      return measurements.isNotEmpty
          ? measurementScreen(context, snapshot)
          : dummyChart;
    }

    return StreamBuilder<List<Measurement>>(
        stream: database.streamController.stream,
        builder: (
            BuildContext context, AsyncSnapshot<List<Measurement>> snapshot,
            ) => SafeArea(
            key: key,
            child: measurementScreenWrapper(context, snapshot)
        )
    );

  }
}


class HeaderDelegate extends SliverPersistentHeaderDelegate {
  const HeaderDelegate(
      this.title,
      this.animationDurationInMilliseconds,
      this.firstDelayInMilliseconds);
  final String title;
  final int animationDurationInMilliseconds;
  final int firstDelayInMilliseconds;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {

    final EdgeInsets padding = EdgeInsets.symmetric(
      horizontal: TraleTheme.of(context)!.padding,
    );
    return Align(
      child: Container(
        padding: padding,
        color: Theme.of(context).colorScheme.background,
        width: MediaQuery.of(context).size.width,
        child: TextSizeInEffect(
          text: title,
          textStyle: Theme.of(context).textTheme.headlineMedium!,
          durationInMilliseconds: animationDurationInMilliseconds,
          delayInMilliseconds: firstDelayInMilliseconds,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 36;

  @override
  double get minExtent => 36;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}