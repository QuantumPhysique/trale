import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:trale/core/icons.dart';
import 'package:trale/core/interpolation.dart';
import 'package:trale/core/language.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/units.dart';
import 'package:trale/main.dart';
import 'package:trale/widget/addWeightDialog.dart';
import 'package:trale/widget/linechart.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> key = GlobalKey();
  final Duration animationDuration = const Duration(milliseconds: 500);
  final PanelController panelController = PanelController();
  final SlidableController slidableController = SlidableController();
  late double collapsed;
  bool popupShown = false;
  final double minHeight = 45.0;

  @override
  void initState() {
    super.initState();
    collapsed = 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final Box<Measurement> box_ = Hive.box<Measurement>(measurementBoxName);
    final List<SortedMeasurement> measurements =
      MeasurementDatabase().sortedMeasurements;
    final bool showFAB = collapsed > 0.9 && !popupShown;

    final AppBar appBar = AppBar(
      centerTitle: true,
      title: AutoSizeText(
        AppLocalizations.of(context)!.trale.toUpperCase(),
        style: Theme.of(context).textTheme.headline4,
        maxLines: 1,
      ),
      leading: IconButton(
        icon: const Icon(CustomIcons.settings),
        onPressed: () => key.currentState!.openDrawer(),
      ),
    );

    final SlidingUpPanel slidingUpPanel = SlidingUpPanel(
      controller: panelController,
      minHeight: minHeight + 10,
      onPanelClosed: () {
        slidableController.activeState?.close();
      },
      maxHeight: MediaQuery.of(context).size.height / 2
        - appBar.preferredSize.height,
      onPanelSlide: (double x) {
        setState(() {
          collapsed = 1.0 - x;
        });
      },
      renderPanelSheet: false,
      panelBuilder: (ScrollController sc) => Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          AnimatedContainer(
              margin: const EdgeInsets.only(top: 10),
              duration: TraleTheme.of(context)!.transitionDuration.normal,
              child: Container(
                width: 20,
                child: Divider(
                  color: Theme.of(context).iconTheme.color,
                  thickness: 1.5,
                  height: collapsed > 0.1
                      ? 50.0
                      : 2 * TraleTheme.of(context)!.padding,
                ),
              ),
          ),
          AnimatedContainer(
            duration: TraleTheme.of(context)!.transitionDuration.normal,
            padding: EdgeInsets.only(
              top: collapsed > 0.1
                ? 50.0
                : 2 * TraleTheme.of(context)!.padding,
            ),
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: sc.hasClients && sc.offset == 0
                ? TraleTheme.of(context)!.isDark
                  ? TraleTheme.of(context)!.bgShade2
                  : TraleTheme.of(context)!.bg
                : TraleTheme.of(context)!.isDark
                  ? TraleTheme.of(context)!.bgShade1
                  : TraleTheme.of(context)!.bgShade3,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(2 * TraleTheme.of(context)!.borderRadius),
                topRight: Radius.circular(2 * TraleTheme.of(context)!.borderRadius),
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  blurRadius: 8.0,
                  color: Color.fromRGBO(0, 0, 0, 0.25),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(2 * TraleTheme.of(context)!.borderRadius),
                topRight: Radius.circular(2 * TraleTheme.of(context)!.borderRadius),
              ),
              child: ListView.builder(
                controller: sc,
                clipBehavior: Clip.antiAlias,
                itemCount: measurements.length,
                itemBuilder: (BuildContext context, int index) {
                  final SortedMeasurement currentMeasurement
                    = measurements[index];
                  Widget deleteAction() {
                    return IconSlideAction(
                      caption: AppLocalizations.of(context)!.delete,
                      color: TraleTheme.of(context)?.accent,
                      icon: CustomIcons.delete,
                      onTap: () {
                        box_.delete(currentMeasurement.key);
                        final SnackBar snackBar = SnackBar(
                          content: const Text('Measurement was deleted'),
                          behavior: SnackBarBehavior.floating,
                          width: MediaQuery.of(context).size.width / 3 * 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                TraleTheme.of(context)!.borderRadius
                              )
                            )
                          ),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              box_.add(currentMeasurement.measurement);
                            },
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    );
                  }
                  Widget editAction() {
                    return IconSlideAction(
                      caption: AppLocalizations.of(context)!.edit,
                      color: TraleTheme.of(context)!.bgShade3,
                      icon: CustomIcons.edit,
                      onTap: () async {
                        final bool changed = await showAddWeightDialog(
                          context: context,
                          weight: currentMeasurement.measurement.weight,
                          date: currentMeasurement.measurement.date,
                          box: Hive.box<Measurement>(measurementBoxName),
                        );
                        if (changed)
                          box_.delete(currentMeasurement.key);
                      },
                    );
                  }
                  return Slidable(
                    controller: slidableController,
                    actionPane: const SlidableDrawerActionPane(),
                    actionExtentRatio: 0.25,
                    closeOnScroll: true,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          color: TraleTheme.of(context)!.isDark
                            ? TraleTheme.of(context)!.bgShade2
                            : TraleTheme.of(context)!.bg,
                          width: MediaQuery.of(context).size.width,
                          height: 40.0,
                          child: Text(
                            currentMeasurement.measurement.measureToString(
                              context, ws: 12,
                            ),
                            style: Theme.of(context).textTheme
                              .bodyText1?.apply(fontFamily: 'Courier'),
                          ),
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      deleteAction(),
                      editAction(),
                    ],
                    secondaryActions: <Widget>[
                      editAction(),
                      deleteAction()
                    ],
                  );
                }
              ),
            ),
          ),
        ].reversed.toList(),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Measurement>(measurementBoxName).listenable(),
        builder: (BuildContext context, Box<Measurement> box, _) =>
          Column(
            children: <Widget>[
              Container(
                height: collapsed * (
                    MediaQuery.of(context).size.height / 3 - minHeight
                  ) + (1-collapsed) * MediaQuery.of(context).size.height / 12,
              ),
              CustomLineChart(box: box),
            ],
          ),
      ),
    );

    Widget floatingActionButton () {
      const double buttonHeight = 60;
      return Container(
        padding: EdgeInsets.only(
          bottom: (1 - collapsed) * (
              MediaQuery.of(context).size.height / 2
                  - appBar.preferredSize.height
                  - minHeight),
          right: TraleTheme.of(context)!.padding,
        ),
        child: AnimatedContainer(
            alignment: Alignment.center,
            height: showFAB ? buttonHeight : 0,
            width: showFAB ? buttonHeight : 0,
            margin: EdgeInsets.all(
              showFAB ? 0 : 0.5 * buttonHeight,
            ),
            duration: TraleTheme.of(context)!.transitionDuration.fast,
            child: FittedBox(
              fit: BoxFit.contain,
              child: FloatingActionButton(
                onPressed: () async {
                  setState(() {
                    popupShown = true;
                  });
                  await showAddWeightDialog(
                    context: context,
                    weight: measurements.isNotEmpty
                        ? measurements.first.measurement.weight.toDouble()
                        : 70,
                    date: DateTime.now(),
                    box: Hive.box<Measurement>(measurementBoxName),
                  );
                  setState(() {
                    popupShown = false;
                  });
                },
                tooltip: AppLocalizations.of(context)!.addWeight,
                child: const Icon(CustomIcons.add),
              ),
            )
        ),
      );
    }


    return Scaffold(
      key: key,
      appBar: appBar,
      onDrawerChanged: (bool isOpen) {
        if (isOpen && panelController.isAttached)
          panelController.close();
      },
      body: SafeArea(
        child: slidingUpPanel,
      ),
      floatingActionButton: floatingActionButton(),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            DrawerHeader(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/launcher/foreground_crop.png',
                    width: MediaQuery.of(context).size.width * 0.2,
                  ),
                  SizedBox(width: TraleTheme.of(context)!.padding),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        AppLocalizations.of(context)!.trale,
                        style: Theme.of(context).textTheme.headline4,
                        maxLines: 1,
                      ),
                      AutoSizeText(
                        AppLocalizations.of(context)!.tralesub,
                        style: Theme.of(context).textTheme.headline6,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ],
              ),
              decoration: BoxDecoration(
                color: TraleTheme.of(context)!.isDark
                  ? TraleTheme.of(context)!.bgShade1
                  : TraleTheme.of(context)!.bgShade3,
              ),
            ),
            AutoSizeText(
              AppLocalizations.of(context)!.settings.toUpperCase(),
              style: Theme.of(context).textTheme.headline6,
              maxLines: 1,
            ),
            ListTile(
              dense: true,
              title: AutoSizeText(
                AppLocalizations.of(context)!.language,
                style: Theme.of(context).textTheme.bodyText1,
                maxLines: 1,
              ),
              trailing: DropdownButton<String>(
                value: Provider.of<TraleNotifier>(context) .language.language,
                items: <DropdownMenuItem<String>>[
                  for (Language lang in Language.supportedLanguages)
                    DropdownMenuItem<String>(
                      value: lang.language,
                      child: Text(
                        lang.languageLong(context),
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    )
                ],
                onChanged: (String? lang) async {
                  setState(() {
                    Provider.of<TraleNotifier>(
                      context, listen: false
                    ).language = lang!.toLanguage();
                  });
                },
              ),
            ),
            ListTile(
              dense: true,
              title: AutoSizeText(
                AppLocalizations.of(context)!.unit,
                style: Theme.of(context).textTheme.bodyText1,
                maxLines: 1,
              ),
              trailing: DropdownButton<TraleUnit>(
                value: Provider.of<TraleNotifier>(context).unit,
                items: <DropdownMenuItem<TraleUnit>>[
                  for (TraleUnit unit in TraleUnit.values)
                    DropdownMenuItem<TraleUnit>(
                      value: unit,
                      child: Text(
                        unit.name,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    )
                ],
                onChanged: (TraleUnit? newUnit) async {
                  setState(() {
                    if (newUnit != null)
                      Provider.of<TraleNotifier>(
                          context, listen: false
                      ).unit = newUnit;
                  });
                },
              ),
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: TraleTheme.of(context)!.padding,
              ),
              title: AutoSizeText(
                AppLocalizations.of(context)!.darkmode,
                style: Theme.of(context).textTheme.bodyText1,
                maxLines: 1,
              ),
              trailing: ToggleButtons(
                renderBorder: false,
                fillColor: Colors.transparent,
                children: <Widget>[
                  const Icon(CustomIcons.lightmode),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: TraleTheme.of(context)!.padding,
                    ),
                    child: const Icon(CustomIcons.automode),
                  ),
                  const Icon(CustomIcons.darkmode),
                ],
                isSelected: List<bool>.generate(
                  orderedThemeModes.length,
                  (int index) => index == orderedThemeModes.indexOf(
                    Provider.of<TraleNotifier>(context).themeMode
                  ),
                ),
                onPressed: (int index) {
                  setState(() {
                    Provider.of<TraleNotifier>(
                        context, listen: false,
                    ).themeMode = orderedThemeModes[index];
                  });
                },
              ),
            ),
            ListTile(
              dense: true,
              title: AutoSizeText(
                AppLocalizations.of(context)!.interpolation,
                style: Theme.of(context).textTheme.bodyText1,
                maxLines: 1,
              ),
              trailing: DropdownButton<InterpolStrength>(
                value: Provider.of<TraleNotifier>(context).interpolStrength,
                items: <DropdownMenuItem<InterpolStrength>>[
                  for (InterpolStrength strength in InterpolStrength.values)
                    DropdownMenuItem<InterpolStrength>(
                      value: strength,
                      child: Text(
                        strength.nameLong(context),
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    )
                ],
                onChanged: (InterpolStrength? strength) async {
                  setState(() {
                    Provider.of<TraleNotifier>(
                        context, listen: false
                    ).interpolStrength = strength!;
                  });
                },
              ),
            ),
            const Spacer(),
            const Divider(),
            ListTile(
                dense: true,
                leading: Icon(
                  CustomIcons.settings,
                  color: Theme.of(context).iconTheme.color,
                ),
                title: AutoSizeText(
                  AppLocalizations.of(context)!.moreSettings,
                  style: Theme.of(context).textTheme.bodyText1,
                  maxLines: 1,
                ),
            ),
            ListTile(
              dense: true,
              leading: Icon(
                CustomIcons.faq,
                color: Theme.of(context).iconTheme.color,
              ),
              title: AutoSizeText(
                AppLocalizations.of(context)!.faq,
                style: Theme.of(context).textTheme.bodyText1,
                maxLines: 1,
              ),
            ),
            ListTile(
              dense: true,
              leading: Icon(
                CustomIcons.info,
                color: Theme.of(context).iconTheme.color,
              ),
              title: AutoSizeText(
                AppLocalizations.of(context)!.about,
                style: Theme.of(context).textTheme.bodyText1,
                maxLines: 1,
              ),
            ),
          ],
        ),
      )
    );
  }
}
