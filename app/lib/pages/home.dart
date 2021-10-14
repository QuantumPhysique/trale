import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/core/language.dart';
import 'package:trale/core/measurement.dart';
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
  bool isExtended = false;
  final GlobalKey<ScaffoldState> key = GlobalKey();
  final Duration animationDuration = const Duration(milliseconds: 500);
  @override
  Widget build(BuildContext context) {

    final TraleNotifier notifier =
      Provider.of<TraleNotifier>(context, listen: false);
    final SlidableController slidableController = SlidableController();

    return Scaffold(
      key: key,
      appBar: AppBar(
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
      ),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: Hive.box<Measurement>(measurementBoxName).listenable(),
          builder: (BuildContext context, Box<Measurement> box, _) =>
                Column(
                  children: <Widget>[
                    AnimatedContainer(
                      height: isExtended
                          ? 0.0
                          : MediaQuery.of(context).size.height / 6,
                      duration: animationDuration,
                    ),
                    CustomLineChart(box: box),
                    AnimatedContainer(
                      height: isExtended
                          ? 0.0
                          : MediaQuery.of(context).size.height / 6,
                      duration: animationDuration,
                    ),
                    IconButton(
                      onPressed: () => setState(() => isExtended = !isExtended),
                      icon: Icon(isExtended
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up)),
                    Expanded(
                      child: AnimatedContainer(
                        duration: animationDuration,
                        child: ListView.builder(
                          itemCount: box.values.length,
                          itemBuilder: (BuildContext context, int index) {
                            Measurement? currentMeasurement = box.getAt(index);
                            if (currentMeasurement == null)
                              return const SizedBox.shrink();

                            Widget deleteAction() {
                              return IconSlideAction(
                                caption: AppLocalizations.of(context)!.delete,
                                color: TraleTheme.of(context)!.accent,
                                icon: CustomIcons.delete,
                                onTap: () {
                                  box.deleteAt(index);
                                  final SnackBar snackBar = SnackBar(
                                    content: Text('Measurement was deleted'),
                                    behavior: SnackBarBehavior.floating,
                                    width: MediaQuery.of(context).size.width / 3 * 2,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                TraleTheme.of(context)!.borderRadius)
                                        )
                                    ),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      onPressed: () {
                                        box.add(currentMeasurement);
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
                                    weight: currentMeasurement.weight,
                                    date: currentMeasurement.date,
                                    box: Hive.box<Measurement>(measurementBoxName),
                                  );
                                  if (changed)
                                    box.deleteAt(index);
                                },
                              );
                            }

                            return Slidable(
                              controller: slidableController,
                              actionPane: const SlidableDrawerActionPane(),
                              actionExtentRatio: 0.25,
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: MediaQuery.of(context).size.width/2,
                                    height: 45.0,
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.only(
                                        right: TraleTheme.of(context)!.padding
                                    ),
                                    child: Text(
                                      DateFormat('dd/MM/yy').format(
                                          currentMeasurement.date),
                                      style:
                                        Theme.of(context).textTheme.bodyText1,
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width/2,
                                    height: 45.0,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '${(
                                          currentMeasurement.inUnit(context)
                                      ).toStringAsFixed(1)} ${notifier.unit.name}',
                                      style: Theme.of(context).textTheme.bodyText1,
                                    ),
                                  ),
                                ]
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
                  ],
                ),
        ),
      ),
      floatingActionButton: isExtended
        ? Container()
        : FloatingActionButton.extended(
          onPressed: () async {
            // get weight from most recent measurement
            final List<Measurement> data
              = Hive.box<Measurement>(measurementBoxName).values.toList();
            data.sort((Measurement a, Measurement b) {
              return a.compareTo(b);
            });
            showAddWeightDialog(
              context: context,
              weight: data.isNotEmpty
                ? data.last.weight.toDouble()
                : 70,
              date: DateTime.now(),
              box: Hive.box<Measurement>(measurementBoxName),
            );
          },
          tooltip: AppLocalizations.of(context)!.addWeight,
          icon: const Icon(CustomIcons.add),
          label: Text(AppLocalizations.of(context)!.addWeight),
        ),
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
                value: Provider.of<TraleNotifier>(context)
                  .language.language,
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
                value: Provider.of<TraleNotifier>(context)
                    .unit,
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
