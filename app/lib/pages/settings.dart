import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/icons.dart';
import 'package:trale/core/interpolation.dart';
import 'package:trale/core/language.dart';
import 'package:trale/core/stringExtension.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/units.dart';
import 'package:trale/widget/coloredContainer.dart';
import 'package:trale/widget/customSliverAppBar.dart';


/// ListTile for changing Amoled settings
class ResetListTile extends StatelessWidget {
  /// constructor
  const ResetListTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: AutoSizeText(
        AppLocalizations.of(context)!.factoryReset,
        style: Theme.of(context).textTheme.bodyText1,
        maxLines: 1,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
      ),
      subtitle: AutoSizeText(
        AppLocalizations.of(context)!.factoryResetSubtitle,
        style: Theme.of(context).textTheme.overline,
      ),
      trailing: IconButton(
        icon: const Icon(CustomIcons.delete),
        onPressed: () async {
          final bool accepted = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.factoryReset,
                style: Theme.of(context).textTheme.headline6,
              ),
              content: Text(
                AppLocalizations.of(context)!.factoryResetDialog,
                style: Theme.of(context).textTheme.bodyText1,
              ),
              actions: <Widget>[
                TextButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(
                      Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                  child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: TraleTheme.of(context)!.padding / 2,
                        horizontal: TraleTheme.of(context)!.padding,
                      ),
                      child: Text(AppLocalizations.of(context)!.abort)
                  ),
                ),
                TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: TraleTheme.of(context)!.padding / 2,
                          horizontal: TraleTheme.of(context)!.padding,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Icon(CustomIcons.done),
                            SizedBox(width: TraleTheme.of(context)!.padding),
                            Text(AppLocalizations.of(context)!.yes),
                          ],
                        )
                    )
                ),
              ],
            ),
          ) ?? false;
          if (accepted) {
            Provider.of<TraleNotifier>(
              context, listen: false
            ).factoryReset();
            // leave settings
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}


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
      contentPadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
        vertical: 0.5 * TraleTheme.of(context)!.padding,
      ),
      title: AutoSizeText(
        AppLocalizations.of(context)!.language,
        style: Theme.of(context).textTheme.bodyText1,
        maxLines: 1,
      ),
      trailing: DropdownMenu<String>(
        label: AutoSizeText(
          AppLocalizations.of(context)!.language,
          style: Theme.of(context).textTheme.bodyText1,
          maxLines: 1,
        ),
        initialSelection: Provider.of<TraleNotifier>(context).language.language,
        dropdownMenuEntries: <DropdownMenuEntry<String>>[
          for (final Language lang in Language.supportedLanguages)
            DropdownMenuEntry<String>(
              value: lang.language,
              label: lang.languageLong(context),
            )
        ],
        onSelected: (String? lang) async {
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
      contentPadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
        vertical: 0.5 * TraleTheme.of(context)!.padding,
      ),
      title: AutoSizeText(
        AppLocalizations.of(context)!.unit,
        style: Theme.of(context).textTheme.bodyText1,
        maxLines: 1,
      ),
      trailing: DropdownMenu<TraleUnit>(
        initialSelection: Provider.of<TraleNotifier>(context).unit,
        label: AutoSizeText(
          AppLocalizations.of(context)!.unit,
          style: Theme.of(context).textTheme.bodyText1,
          maxLines: 1,
        ),
        dropdownMenuEntries: <DropdownMenuEntry<TraleUnit>>[
          for (final TraleUnit unit in TraleUnit.values)
            DropdownMenuEntry<TraleUnit>(
              value: unit,
              label: unit.name,
            )
        ],
        onSelected: (TraleUnit? newUnit) async {
          if (newUnit != null) {
            Provider.of<TraleNotifier>(
                context, listen: false
            ).unit = newUnit;
          }
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
      contentPadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
        vertical: 0.5 * TraleTheme.of(context)!.padding,
      ),
      title: AutoSizeText(
        AppLocalizations.of(context)!.darkmode,
        style: Theme.of(context).textTheme.bodyText1,
        maxLines: 1,
      ),
      trailing: SegmentedButton<ThemeMode>(
        selected: <ThemeMode>{
          Provider.of<TraleNotifier>(context).themeMode
        },
        showSelectedIcon: false,
        segments: <ButtonSegment<ThemeMode>>[
          for (final ThemeMode mode in orderedThemeModes)
            ButtonSegment<ThemeMode>(
              value: mode,
              tooltip: mode.nameLong(context),
              icon: Icon(mode.icon),
            )
        ],
        onSelectionChanged: (Set<ThemeMode> newMode) async {
          Provider.of<TraleNotifier>(
              context, listen: false
          ).themeMode = newMode.first;
        },
        // isSelected: List<bool>.generate(
        //   orderedThemeModes.length,
        //       (int index) => index == orderedThemeModes.indexOf(
        //       Provider.of<TraleNotifier>(context).themeMode
        //   ),
        // ),
        // onPressed: (int index) {
        //   Provider.of<TraleNotifier>(
        //     context, listen: false,
        //   ).themeMode = orderedThemeModes[index];
        // },
        // children: <Widget>[
        //   const Icon(CustomIcons.lightmode),
        //   Padding(
        //     padding: EdgeInsets.symmetric(
        //       horizontal: TraleTheme.of(context)!.padding,
        //     ),
        //     child: const Icon(CustomIcons.automode),
        //   ),
        //   const Icon(CustomIcons.darkmode),
        // ],
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
      contentPadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
        vertical: 0.5 * TraleTheme.of(context)!.padding,
      ),
      title: AutoSizeText(
        AppLocalizations.of(context)!.interpolation,
        style: Theme.of(context).textTheme.bodyText1,
        maxLines: 1,
      ),
      trailing: SegmentedButton<InterpolStrength>(
        selected: <InterpolStrength>{
          Provider.of<TraleNotifier>(context).interpolStrength
        },
        showSelectedIcon: false,
        segments: <ButtonSegment<InterpolStrength>>[
          for (final InterpolStrength strength in InterpolStrength.values)
            ButtonSegment<InterpolStrength>(
              value: strength,
              tooltip: strength.nameLong(context),
              icon: Icon(strength.icon),
            )
        ],
        onSelectionChanged: (Set<InterpolStrength> newStrength) async {
          Provider.of<TraleNotifier>(
              context, listen: false
          ).interpolStrength = newStrength.first;
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

    return ListView.builder(
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: TraleCustomTheme.values.length,
        itemBuilder: (BuildContext context, int index) {
          final TraleCustomTheme ctheme = TraleCustomTheme.values[index];
          if (
            !traleNotifier.systemColorsAvailable &&
            ctheme == TraleCustomTheme.system
          ) {
            return const SizedBox.shrink();
          }
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
                          color: Theme.of(context).colorScheme.onBackground,
                      ),
                      color: (
                        TraleTheme.of(context)!.isDark
                          ? traleNotifier.isAmoled
                            ? ctheme.dark(context).amoled
                            : ctheme.dark(context)
                          : ctheme.light(context)
                      ).themeData.colorScheme.background,
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
                                ? ctheme.dark(context).themeData.textTheme.overline
                                : ctheme.light(context).themeData.textTheme.overline,
                            maxLines: 1,
                          ),
                          Divider(
                            height: 5,
                            color: (
                                TraleTheme.of(context)!.isDark
                                    ? ctheme.dark(context)
                                    : ctheme.light(context)
                            ).themeData.colorScheme.onBackground,
                          ),
                          AutoSizeText(
                            'wwwwwwwwww',
                            style: TraleTheme.of(context)!.isDark
                                ? ctheme.dark(context).themeData.textTheme.overline
                                : ctheme.light(context).themeData.textTheme.overline,
                            maxLines: 2,
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: TraleTheme.of(context)!
                                  .borderShape.borderRadius,
                              color: (
                                  TraleTheme.of(context)!.isDark
                                      ? ctheme.dark(context)
                                      : ctheme.light(context)
                              ).themeData.colorScheme.primary,
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
                    if (theme != null) {
                      traleNotifier.theme = theme;
                    }
                  },
                ),
              ],
            ),
          );
        }
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
          ColoredContainer(
            height: 0.7 * MediaQuery.of(context).size.width,
            width: MediaQuery.of(context).size.width,
            child: const ThemeSelection(),
          ),
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
          Divider(
            height: 2 * TraleTheme.of(context)!.padding,
          ),
          Padding(
            padding: padding,
            child: AutoSizeText(
              AppLocalizations.of(context)!.reset.inCaps,
              style: Theme.of(context).textTheme.headline4,
              maxLines: 1,
            ),
          ),
          const ResetListTile(),
          SizedBox(height: TraleTheme.of(context)!.padding),
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
