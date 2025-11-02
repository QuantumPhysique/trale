import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:provider/provider.dart';

import 'package:trale/core/contrast.dart';
import 'package:trale/core/interpolation.dart';
import 'package:trale/core/interpolationPreview.dart';
import 'package:trale/core/stringExtension.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/customScrollViewSnapping.dart';
import 'package:trale/widget/linechart.dart';
import 'package:trale/widget/tile_group.dart';

/// ListTile for changing interpolation settings
class ContrastLevelSetting extends StatelessWidget {
  /// constructor
  const ContrastLevelSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return GroupedWidget(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          2 * TraleTheme.of(context)!.padding,
          0.5 * TraleTheme.of(context)!.padding,
          TraleTheme.of(context)!.padding,
          0.5 * TraleTheme.of(context)!.padding,
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            AutoSizeText(
              AppLocalizations.of(context)!.highContrast.inCaps,
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 1,
            ),
            Slider(
              value: Provider.of<TraleNotifier>(context)
                  .contrastLevel.idx.toDouble(),
              divisions: ContrastLevel.values.length - 1,
              min: 0.0,
              max: ContrastLevel.values.length.toDouble() - 1,
              label: Provider.of<TraleNotifier>(context).contrastLevel.nameLong,
              onChanged: (double newContrastLevel) async {
                Provider.of<TraleNotifier>(
                    context, listen: false
                ).contrastLevel = ContrastLevel.values[newContrastLevel.toInt()];
              },
            ),
          ],
        ),
      ),
    );
  }
}




/// ListTile for changing Amoled settings
class AmoledListTile extends StatelessWidget {
  /// constructor
  const AmoledListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      dense: true,
      title: AutoSizeText(
        AppLocalizations.of(context)!.amoled,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
      ),
      subtitle: AutoSizeText(
        AppLocalizations.of(context)!.amoledSubtitle,
        style: Theme.of(context).textTheme.labelSmall,
      ),
      value: Provider.of<TraleNotifier>(context).isAmoled,
      onChanged: (bool isAmoled) async {
        Provider.of<TraleNotifier>(context, listen: false).isAmoled = isAmoled;
      },
    );
  }
}


class SchemeVariantListTile extends StatelessWidget {
  /// constructor
  const SchemeVariantListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return GroupedListTile(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      contentPadding: EdgeInsets.fromLTRB(
        TraleTheme.of(context)!.padding,
        0.5 * TraleTheme.of(context)!.padding,
        TraleTheme.of(context)!.padding,
        0.5 * TraleTheme.of(context)!.padding,
      ),
      title: AutoSizeText(
        AppLocalizations.of(context)!.schemeVariant,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      trailing: DropdownMenu<TraleSchemeVariant>(
        initialSelection: Provider.of<TraleNotifier>(context).schemeVariant,
        label: AutoSizeText(
          AppLocalizations.of(context)!.schemeVariant,
          style: Theme.of(context).textTheme.bodyLarge,
          maxLines: 1,
        ),
        dropdownMenuEntries: <DropdownMenuEntry<TraleSchemeVariant>>[
          for (final TraleSchemeVariant variant in TraleSchemeVariant.values)
            DropdownMenuEntry<TraleSchemeVariant>(
              value: variant,
              label: variant.name,
            )
        ],
        onSelected: (TraleSchemeVariant? newVariant) async {
          if (newVariant != null) {
            Provider
                .of<TraleNotifier>(context, listen: false)
                .schemeVariant = newVariant;
          }
        },
      ),
    );
  }
}



/// ListTile for changing dark mode settings
class DarkModeListTile extends StatelessWidget {
  /// constructor
  const DarkModeListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return GroupedListTile(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      contentPadding: EdgeInsets.fromLTRB(
        TraleTheme.of(context)!.padding,
        0.5 * TraleTheme.of(context)!.padding,
        TraleTheme.of(context)!.padding,
        0.5 * TraleTheme.of(context)!.padding,
      ),
      title: AutoSizeText(
        AppLocalizations.of(context)!.darkmode,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      trailing: SegmentedButton<ThemeMode>(
        selected: <ThemeMode>{Provider.of<TraleNotifier>(context).themeMode},
        showSelectedIcon: false,
        segments: <ButtonSegment<ThemeMode>>[
          for (final ThemeMode mode in orderedThemeModes)
            ButtonSegment<ThemeMode>(
              value: mode,
              tooltip: mode.nameLong(context),
              icon: PPIcon(
                Provider.of<TraleNotifier>(context).themeMode == mode
                  ? mode.activeIcon
                  : mode.icon,
                context,
              ),
            )
        ],
        onSelectionChanged: (Set<ThemeMode> newMode) async {
          Provider.of<TraleNotifier>(context, listen: false).themeMode =
              newMode.first;
        },
      ),
    );
  }
}


/// ListTile for changing interpolation settings
class ThemeSelection extends StatefulWidget {
  /// constructor
  const ThemeSelection({super.key});

  @override
  State<ThemeSelection> createState() => _ThemeSelectionState();
}

class _ThemeSelectionState extends State<ThemeSelection> {
  late final CarouselController _carouselController;
  bool loadedFirst = true;

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loadedFirst) {
      loadedFirst = false;
      final List<TraleCustomTheme> cthemes = TraleCustomTheme.values.toList();
      if (!Provider.of<TraleNotifier>(context).systemColorsAvailable) {
        cthemes.remove(TraleCustomTheme.system);
      }
      final int idx = cthemes.indexWhere(
            (TraleCustomTheme theme) =>
        theme == Provider.of<TraleNotifier>(context).theme,
      );

      // last two cannot be selected, so cap idx
      _carouselController = CarouselController(
        initialItem: idx < cthemes.length - 3 ? idx : cthemes.length - 3,
      );
    }

    /// Used to adjust themeMode to dark or light
    final TraleNotifier traleNotifier = Provider.of<TraleNotifier>(context);
    final bool isDark = traleNotifier.themeMode == ThemeMode.dark ||
        (traleNotifier.themeMode == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    Widget themePreview(BuildContext context, TraleCustomTheme ctheme) {
      return Expanded(
        child: Container(
          decoration: BoxDecoration(
            borderRadius:
            TraleTheme.of(context)!.borderShape.borderRadius,
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            color: (
                isDark
                    ? traleNotifier.isAmoled
                    ? ctheme.dark(context).amoled
                    : ctheme.dark(context)
                    : ctheme.light(context)
            ).themeData.colorScheme.surface,
          ),
          //width: 0.3 * MediaQuery.of(context).size.width,
          margin: EdgeInsets.all(0.5 * TraleTheme.of(context)!.padding),
          child: Container(
            margin: EdgeInsets.all(
                0.04 * MediaQuery.of(context).size.width),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                AutoSizeText(
                  ctheme.name,
                  style: (
                      isDark ? ctheme.dark(context): ctheme.light(context)
                  ).themeData.textTheme.labelSmall,
                  maxLines: 1,
                ),
                Divider(
                  height: 5,
                  color: (
                      isDark ? ctheme.dark(context) : ctheme.light(context)
                  ).themeData.colorScheme.onSurface,
                ),
                AutoSizeText(
                  'wwwwwwwwww',
                  style: (
                      isDark ? ctheme.dark(context): ctheme.light(context)
                  ).themeData.textTheme.labelSmall,
                  maxLines: 2,
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: TraleTheme.of(context)!
                        .borderShape
                        .borderRadius,
                    color: (
                        isDark ? ctheme.dark(context): ctheme.light(context)
                    ).themeData.colorScheme.primary,
                  ),
                  height: 0.05 * MediaQuery.of(context).size.width,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final List<TraleCustomTheme> cthemes = TraleCustomTheme.values.toList();
    if (!traleNotifier.systemColorsAvailable) {
      cthemes.remove(TraleCustomTheme.system);
    }

    return CarouselView.weighted(
      controller: _carouselController,
      scrollDirection: Axis.horizontal,
      flexWeights: const <int>[1, 3, 3, 3, 1],
      padding: EdgeInsets.zero,
      itemSnapping: true,
      backgroundColor: Colors.transparent,
      onTap: (int index) {
        final TraleCustomTheme ctheme = cthemes[index];
        traleNotifier.theme = ctheme;
      },
      children: List<Widget>.generate(
        cthemes.length,
            (int index) {
          final TraleCustomTheme ctheme = cthemes[index];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              themePreview(context, ctheme),
              SizedBox(
                height: 40,
                child: FittedBox(
                  child: Radio<TraleCustomTheme>(
                    value: cthemes[index],
                    groupValue: traleNotifier.theme,
                    onChanged: (TraleCustomTheme? theme) {},
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> sliverlist = <Widget>[
      SizedBox(
        height: 0.5 * MediaQuery.of(context).size.width,
        width: MediaQuery.of(context).size.width,
        child: const ThemeSelection(),
      ),
      WidgetGroup(
        children: const <Widget>[
          DarkModeListTile(),
          SchemeVariantListTile(),
          AmoledListTile(),
          ContrastLevelSetting(),
        ],
      ),
    ];

    return Scaffold(
      body: SliverAppBarSnap(
        title: AppLocalizations.of(context)!.interpolation,
        sliverlist: sliverlist,
      ),
    );
  }
}
