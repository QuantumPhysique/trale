import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/icons.dart';
import 'package:trale/core/interpolation.dart';
import 'package:trale/core/language.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/stringExtension.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/units.dart';
import 'package:trale/widget/customSliverAppBar.dart';
import 'package:trale/widget/coloredContainer.dart';


/// ListTile for changing Amoled settings
class AmoledListTile extends StatelessWidget {
  /// constructor
  const AmoledListTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      dense: true,
      title: AutoSizeText(
        AppLocalizations.of(context)!.amoled,
        style: Theme.of(context).textTheme.bodyText1,
        maxLines: 1,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
      ),
      subtitle: AutoSizeText(
        AppLocalizations.of(context)!.amoledSubtitle,
        style: Theme.of(context).textTheme.overline,
      ),
      value: Provider.of<TraleNotifier>(context).isAmoled,
      onChanged: (bool isAmoled) async {
        Provider.of<TraleNotifier>(
            context, listen: false
        ).isAmoled = isAmoled;
      },
    );
  }
}


/// ListTile for changing Language settings
class LanguageListTile extends StatelessWidget {
  /// constructor
  const LanguageListTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
      ),
      title: AutoSizeText(
        AppLocalizations.of(context)!.language,
        style: Theme.of(context).textTheme.bodyText1,
        maxLines: 1,
      ),
      trailing: DropdownButton<String>(
        value: Provider.of<TraleNotifier>(context).language.language,
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
          Provider.of<TraleNotifier>(
              context, listen: false
          ).language = lang!.toLanguage();
        },
      ),
    );
  }
}


/// ListTile for changing units settings
class UnitsListTile extends StatelessWidget {
  /// constructor
  const UnitsListTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
      ),
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
          if (newUnit != null)
            Provider.of<TraleNotifier>(
                context, listen: false
            ).unit = newUnit;
        },
      ),
    );
  }
}


/// ListTile for changing dark mode settings
class DarkModeListTile extends StatelessWidget {
  /// constructor
  const DarkModeListTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
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
          Provider.of<TraleNotifier>(
            context, listen: false,
          ).themeMode = orderedThemeModes[index];
        },
      ),
    );
  }
}


/// ListTile for changing interpolation settings
class InterpolationListTile extends StatelessWidget {
  /// constructor
  const InterpolationListTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
      ),
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
          Provider.of<TraleNotifier>(
              context, listen: false
          ).interpolStrength = strength!;
        },
      ),
    );
  }
}
/// ListTile for changing interpolation settings
class ThemeSelection extends StatelessWidget {
  /// constructor
  const ThemeSelection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Used to adjust themeMode to dark or light
    final TraleNotifier traleNotifier = Provider.of<TraleNotifier>(context);

    return ColoredContainer(
      height: 0.5 * MediaQuery.of(context).size.width,
      child: ListView.builder(
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: TraleCustomTheme.values.length,
          itemBuilder: (BuildContext context, int index) {
            final TraleCustomTheme ctheme = TraleCustomTheme.values[index];
            return GestureDetector(
              onTap: () {
                traleNotifier.theme = TraleCustomTheme.values[index];
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                        TraleTheme.of(context)!.borderShape.borderRadius,
                        border: Border.all(
                            color: TraleTheme.of(context)!.bgFont
                        ),
                        color: TraleTheme.of(context)!.isDark
                            ? traleNotifier.isAmoled
                              ? ctheme.dark.amoled.bg
                              : ctheme.dark.bg
                            : ctheme.light.bg,
                      ),
                      width: 0.2 * MediaQuery.of(context).size.width,
                      margin: EdgeInsets.all(TraleTheme.of(context)!.padding),
                      child: Container(
                        margin: EdgeInsets.all(
                            0.04 * MediaQuery.of(context).size.width
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            AutoSizeText(
                              ctheme.name,
                              style: TraleTheme.of(context)!.isDark
                                  ? ctheme.dark.themeData.textTheme.overline
                                  : ctheme.light.themeData.textTheme.overline,
                              maxLines: 1,
                            ),
                            Divider(
                              height: 5,
                              color:  TraleTheme.of(context)!.isDark
                                  ? ctheme.dark.bgFontLight
                                  : ctheme.light.bgFontLight,
                            ),
                            AutoSizeText(
                              'wwwwwwwwww',
                              style: TraleTheme.of(context)!.isDark
                                  ? ctheme.dark.themeData.textTheme.overline
                                  : ctheme.light.themeData.textTheme.overline,
                              maxLines: 2,
                            ),
                            const Spacer(),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: TraleTheme.of(context)!
                                    .borderShape.borderRadius,
                                color: TraleTheme.of(context)!.isDark
                                    ? ctheme.dark.accent
                                    : ctheme.light.accent,
                              ),
                              height: 0.05 * MediaQuery.of(context).size.width,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Radio<TraleCustomTheme>(
                    value: TraleCustomTheme.values[index],
                    groupValue: traleNotifier.theme,
                    onChanged: (TraleCustomTheme? theme) {
                      if (theme != null)
                        traleNotifier.theme = theme;
                    },
                  ),
                ],
              ),
            );
          }
      ),
    );
  }
}


/// about screen widget class
class Settings extends StatefulWidget {
  @override
  _Settings createState() => _Settings();
}

class _Settings extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = EdgeInsets.symmetric(
      horizontal: TraleTheme.of(context)!.padding,
    );
    Widget settingsList() {
      return ListView(
        children: <Widget>[
          Padding(
            padding: padding,
            child: AutoSizeText(
              AppLocalizations.of(context)!.theme.inCaps,
              style: Theme.of(context).textTheme.headline4,
              maxLines: 1,
            ),
          ),
          const ThemeSelection(),
          const DarkModeListTile(),
          const AmoledListTile(),
          Divider(
              height: 2 * TraleTheme.of(context)!.padding,
          ),
          Padding(
            padding: padding,
            child: AutoSizeText(
              AppLocalizations.of(context)!.language.inCaps,
              style: Theme.of(context).textTheme.headline4,
              maxLines: 1,
            ),
          ),
          const LanguageListTile(),
          const UnitsListTile(),
          const InterpolationListTile(),
        ],
      );
    }

    Widget appBar() {
      return CustomSliverAppBar(
        title: AutoSizeText(
          AppLocalizations.of(context)!.settings.allInCaps,
          style: Theme.of(context).textTheme.headline4,
          maxLines: 1,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(CustomIcons.back),
        ),
      );
    }

    return Container(
      color: Theme.of(context).backgroundColor,
      child: SafeArea(
        child: Scaffold(
          body:  NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool _) {
              return <Widget>[appBar()];
            },
            body: settingsList(),
          ),
        ),
      ),
    );
  }
}
