import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/firstDay.dart';
import 'package:trale/core/interpolation.dart';
import 'package:trale/core/interpolationPreview.dart';
import 'package:trale/core/printFormat.dart';

import 'package:trale/core/stringExtension.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/units.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/customScrollViewSnapping.dart';
import 'package:trale/widget/linechart.dart';
import 'package:trale/widget/tile_group.dart';

class PersonalizationSettingsPage extends StatelessWidget {
  const PersonalizationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {

  final Widget sliderTile = Container(
        padding: EdgeInsets.fromLTRB(
          2 * TraleTheme.of(context)!.padding,
          0.5 * TraleTheme.of(context)!.padding,
          TraleTheme.of(context)!.padding,
          0.5 * TraleTheme.of(context)!.padding,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.strength.inCaps,
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 1,
            ),
            Slider(
              value: Provider.of<TraleNotifier>(context)
                  .interpolStrength.idx.toDouble(),
              divisions: InterpolStrength.values.length - 1,
              min: 0.0,
              max: InterpolStrength.values.length.toDouble() - 1,
              label: Provider.of<TraleNotifier>(context).interpolStrength.name,
              onChanged: (double newStrength) async {
                Provider.of<TraleNotifier>(
                    context, listen: false
                ).interpolStrength = InterpolStrength.values[newStrength.toInt()];
              },
            ),
          ],
        ),
      );

    final List<Widget> sliverlist = <Widget>[
      WidgetGroup(
        title: AppLocalizations.of(context)!.interpolation,
        children:  <Widget>[
            GroupedWidget(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              child: CustomLineChart(
                loadedFirst: false,
                ip: PreviewInterpolation(),
                isPreview: true,
                relativeHeight: 0.25,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
              ),
            ),
            GroupedWidget(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              child: sliderTile,
            ),
          ],
      ),
      SizedBox(height: 2 * TraleTheme.of(context)!.padding),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: TraleTheme.of(context)!.padding),
        child: Text('Add some meaningful text explaining the interpolation settings here.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      WidgetGroup(
        title: "Unit",
        children: [
          const UnitsListTile(),
        ],
      ),
      WidgetGroup(
        title: "Date Settings",
        children: [
          const FirstDayListTile(),
          const DatePrintListTile(),
        ],
      )
    ];

    return Scaffold(
      body: SliverAppBarSnap(
        title: AppLocalizations.of(context)!.personalization,
        sliverlist: sliverlist,
      ),
    );
  }
}



/// ListTile for changing units settings
class UnitsListTile extends StatelessWidget {
  /// constructor
  const UnitsListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return GroupedListTile(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
        vertical: 0.5 * TraleTheme.of(context)!.padding,
      ),
      title: AutoSizeText(
        AppLocalizations.of(context)!.unit,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      trailing: DropdownMenu<TraleUnit>(
        initialSelection: Provider.of<TraleNotifier>(context).unit,
        label: AutoSizeText(
          AppLocalizations.of(context)!.unit,
          style: Theme.of(context).textTheme.bodyLarge,
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
            Provider.of<TraleNotifier>(context, listen: false).unit = newUnit;
          }
        },
      ),
    );
  }
}


class FirstDayListTile extends StatelessWidget {
  /// constructor
  const FirstDayListTile({super.key});

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    final TraleNotifier traleNotifier = Provider.of<TraleNotifier>(context);
    return FutureBuilder<void>(
      future: TraleFirstDayExtension.loadLocalizedNames(locale),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        return GroupedListTile(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 2 * TraleTheme.of(context)!.padding,
            vertical: 0.5 * TraleTheme.of(context)!.padding,
          ),
          title: AutoSizeText(
            AppLocalizations.of(context)!.firstDay,
            style: Theme.of(context).textTheme.bodyLarge,
            maxLines: 1,
          ),
          trailing: DropdownMenu<TraleFirstDay>(
            initialSelection: traleNotifier.firstDay,
            label: AutoSizeText(
              AppLocalizations.of(context)!.firstDay,
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 1,
            ),
            dropdownMenuEntries: <DropdownMenuEntry<TraleFirstDay>>[
              for (final TraleFirstDay firstDay in TraleFirstDay.values)
                DropdownMenuEntry<TraleFirstDay>(
                  value: firstDay,
                  label:
                      TraleFirstDayExtension.getLocalizedName(firstDay, locale),
                )
            ],
            onSelected: (TraleFirstDay? newFirstDay) async {
              if (newFirstDay != null) {
                traleNotifier.firstDay = newFirstDay;
              }
            },
          ),
        );
      },
    );
  }
}


class DatePrintListTile extends StatelessWidget {
  /// constructor
  const DatePrintListTile({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch the current date print format from the provider
    final TraleNotifier traleNotifier = Provider.of<TraleNotifier>(context);

    return GroupedListTile(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
        vertical: 0.5 * TraleTheme.of(context)!.padding,
      ),
      title: AutoSizeText(
        'Format',
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      trailing: DropdownMenu<TraleDatePrintFormat>(
        initialSelection: Provider.of<TraleNotifier>(context).datePrintFormat,
        label: AutoSizeText(
          'Format',
          style: Theme.of(context).textTheme.bodyLarge,
          maxLines: 1,
        ),
        dropdownMenuEntries: <DropdownMenuEntry<TraleDatePrintFormat>>[
          for (final TraleDatePrintFormat datePrintFormat
              in TraleDatePrintFormat.values)
            DropdownMenuEntry<TraleDatePrintFormat>(
              value: datePrintFormat,
              label: datePrintFormat.pattern ?? 'Default',
            )
        ],
        onSelected: (TraleDatePrintFormat? newDatePrintFormat) async {
          if (newDatePrintFormat != null) {
            traleNotifier.datePrintFormat = newDatePrintFormat;
          }
        },
      ),
    );
  }
}