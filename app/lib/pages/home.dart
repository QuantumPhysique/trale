import 'dart:math';

import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';


import 'package:trale/core/measurement.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/main.dart';
import 'package:trale/widget/linechart.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    Widget appBar(BuildContext context, Box<Measurement> box) =>
    SliverOverlapAbsorber(
      sliver: SliverSafeArea(
        top: false,
        sliver: SliverAppBar(
          expandedHeight: 300.0,
          centerTitle: true,
          title: AutoSizeText(
            AppLocalizations.of(context)!.trale.toUpperCase(),
            style: Theme.of(context).textTheme.headline4,
            maxLines: 1,
          ),
          floating: true,
          snap: true,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const <StretchMode>[
              StretchMode.blurBackground,
            ],
            background: Container(
              padding: EdgeInsets.fromLTRB(
                TraleTheme.of(context)!.padding,
                TraleTheme.of(context)!.padding + kToolbarHeight,
                TraleTheme.of(context)!.padding,
                TraleTheme.of(context)!.padding,
              ),
              child: CustomLineChart(box: box),
            ),
          ),
          elevation: Theme.of(context).bottomAppBarTheme.elevation,
        ),
      ),
      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
    );


    return Container(
      color: Theme.of(context).backgroundColor,
      child: SafeArea(
        child: Scaffold(
          body: ValueListenableBuilder(
            valueListenable: Hive.box<Measurement>(measurementBoxName).listenable(),
            builder: (BuildContext context, Box<Measurement> box, _) =>
              NestedScrollView(
                headerSliverBuilder: (BuildContext context, bool _)  {
                  return <Widget>[appBar(context, box)];
                },
                body:
                  ListView.builder(
                    itemCount: box.values.length,
                    itemBuilder: (BuildContext context, int index) {
                      Measurement? currentMeasurement = box.getAt(index);
                      if (currentMeasurement == null)
                        return SizedBox.shrink();
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: TraleTheme.of(context)!.padding * 2,
                        ),
                        dense: true,
                        title: Text(
                          currentMeasurement.weight.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        leading: Text(
                          DateFormat('dd/MM/yy').format(currentMeasurement.date),
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      );
                    }
                  )
              ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Box<Measurement> box = Hive.box(measurementBoxName);
              final Random rng = Random();
              box.add(
                  Measurement(
                    weight: 75 + rng.nextInt(50) / 10,
                    date: DateTime.now().subtract(
                        Duration(days: rng.nextInt(31))
                    ),
                ),
              );
            },
            tooltip: 'Increment',
            child: Icon(Icons.add),
          ),
          drawer: Drawer(
            child: Column(
              children: <Widget>[
                DrawerHeader(
                  child: Center(
                    child: AutoSizeText(
                      AppLocalizations.of(context)!.trale,
                      style: Theme.of(context).textTheme.headline4,
                      maxLines: 1,
                    ),
                  ),
                decoration: BoxDecoration(
                  color: TraleTheme.of(context)!.isDark
                    ? TraleTheme.of(context)!.bgShade1
                    : TraleTheme.of(context)!.bgShade3,
                ),
              ),
              const Divider(),
              ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.settings,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  title: AutoSizeText(
                    AppLocalizations.of(context)!.settings,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
