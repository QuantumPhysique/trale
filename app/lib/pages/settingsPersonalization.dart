import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/firstDay.dart';
import 'package:trale/core/interpolation.dart';
import 'package:trale/core/interpolationPreview.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/measurementInterpolation.dart';
import 'package:trale/core/printFormat.dart';
import 'package:trale/core/stringExtension.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/unit_precision.dart';
import 'package:trale/core/units.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/customScrollViewSnapping.dart';
import 'package:trale/widget/linechart.dart';
import 'package:trale/widget/tile_group.dart';
import 'package:trale/widget/userDialog.dart';

class PersonalizationSettingsPage extends StatefulWidget {
  const PersonalizationSettingsPage({super.key});

  @override
  State<PersonalizationSettingsPage> createState() =>
      _PersonalizationSettingsPageState();
}

class _PersonalizationSettingsPageState
    extends State<PersonalizationSettingsPage> {
  /// Whether to show the user's own data instead of fake preview data.
  bool _showUserData = false;

  @override
  Widget build(BuildContext context) {
    final TraleNotifier notifier = Provider.of<TraleNotifier>(
      context,
      listen: false,
    );

    final Widget sliderTile = Container(
      padding: EdgeInsets.fromLTRB(
        TraleTheme.of(context)!.padding,
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
            value: Provider.of<TraleNotifier>(
              context,
            ).interpolStrength.idx.toDouble(),
            divisions: InterpolStrength.values.length - 1,
            min: 0.0,
            max: InterpolStrength.values.length.toDouble() - 1,
            label: Provider.of<TraleNotifier>(
              context,
            ).interpolStrength.nameLong(context),
            onChanged: (double newStrength) async {
              Provider.of<TraleNotifier>(
                context,
                listen: false,
              ).interpolStrength = InterpolStrength.values[newStrength.toInt()];
            },
          ),
        ],
      ),
    );

    final bool hasEnoughData = MeasurementDatabase().measurements.length > 3;
    final bool useUserData = _showUserData && hasEnoughData;

    final List<Widget> sliverlist = <Widget>[
      WidgetGroup(
        title: AppLocalizations.of(context)!.interpolation,
        children: <Widget>[
          GroupedWidget(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            child: CustomLineChart(
              loadedFirst: false,
              ip: useUserData
                  ? MeasurementInterpolation()
                  : PreviewInterpolation(),
              isPreview: !useUserData,
              relativeHeight: 0.25,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerLowest,
              chartMargin: EdgeInsets.zero,
            ),
          ),
          if (hasEnoughData)
            GroupedSwitchListTile(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              contentPadding: EdgeInsets.symmetric(
                horizontal: TraleTheme.of(context)!.padding,
              ),
              title: Text(
                AppLocalizations.of(context)!.showUserData.inCaps,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              value: _showUserData,
              onChanged: (bool? value) {
                setState(() {
                  _showUserData = value ?? false;
                });
              },
            ),
          GroupedWidget(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            child: sliderTile,
          ),
        ],
      ),
      SizedBox(height: 0.5 * TraleTheme.of(context)!.padding),
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: TraleTheme.of(context)!.padding,
        ),
        child: Text(
          AppLocalizations.of(context)!.interpolationExplanation(
            noneInterpol: InterpolStrength.none.nameLong(context),
          ),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      SizedBox(height: TraleTheme.of(context)!.padding),
      WidgetGroup(
        title: AppLocalizations.of(context)!.unitTitle,
        children: const <Widget>[
          UnitsListTile(),
          UnitPrecisionListTile(),
          HeightUnitListTile(),
        ],
      ),
      WidgetGroup(
        title: AppLocalizations.of(context)!.dateSettings,
        children: const <Widget>[FirstDayListTile(), DatePrintListTile()],
      ),
      UserDetailsGroup(
        title: AppLocalizations.of(context)!.user,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        notifier: notifier,
        onRefresh: () => setState(() {}),
      ),
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
        horizontal: TraleTheme.of(context)!.padding,
        vertical: TraleTheme.of(context)!.padding,
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
            DropdownMenuEntry<TraleUnit>(value: unit, label: unit.name),
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

/// ListTile for changing units settings
class UnitPrecisionListTile extends StatelessWidget {
  /// constructor
  const UnitPrecisionListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return GroupedListTile(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      contentPadding: EdgeInsets.symmetric(
        horizontal: TraleTheme.of(context)!.padding,
        vertical: TraleTheme.of(context)!.padding,
      ),
      title: AutoSizeText(
        AppLocalizations.of(context)!.precision.inCaps,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      trailing: DropdownMenu<TraleUnitPrecision>(
        initialSelection: Provider.of<TraleNotifier>(context).unitPrecision,
        label: AutoSizeText(
          AppLocalizations.of(context)!.precision,
          style: Theme.of(context).textTheme.bodyLarge,
          maxLines: 1,
        ),
        dropdownMenuEntries: <DropdownMenuEntry<TraleUnitPrecision>>[
          for (final TraleUnitPrecision precision in TraleUnitPrecision.values)
            DropdownMenuEntry<TraleUnitPrecision>(
              value: precision,
              label:
                  precision.settingsName ??
                  AppLocalizations.of(context)!.defaultFormat,
            ),
        ],
        onSelected: (TraleUnitPrecision? newPrecision) async {
          if (newPrecision != null) {
            Provider.of<TraleNotifier>(context, listen: false).unitPrecision =
                newPrecision;
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
            horizontal: TraleTheme.of(context)!.padding,
            vertical: TraleTheme.of(context)!.padding,
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
                  label: TraleFirstDayExtension.getLocalizedName(
                    firstDay,
                    locale,
                  ),
                ),
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
        horizontal: TraleTheme.of(context)!.padding,
        vertical: TraleTheme.of(context)!.padding,
      ),
      title: AutoSizeText(
        AppLocalizations.of(context)!.format,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      trailing: DropdownMenu<TraleDatePrintFormat>(
        initialSelection: Provider.of<TraleNotifier>(context).datePrintFormat,
        label: AutoSizeText(
          AppLocalizations.of(context)!.format,
          style: Theme.of(context).textTheme.bodyLarge,
          maxLines: 1,
        ),
        dropdownMenuEntries: <DropdownMenuEntry<TraleDatePrintFormat>>[
          for (final TraleDatePrintFormat datePrintFormat
              in TraleDatePrintFormat.values)
            DropdownMenuEntry<TraleDatePrintFormat>(
              value: datePrintFormat,
              label:
                  datePrintFormat.pattern ??
                  AppLocalizations.of(context)!.defaultFormat,
            ),
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

/// ListTile for changing height unit settings
class HeightUnitListTile extends StatelessWidget {
  /// constructor
  const HeightUnitListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return GroupedListTile(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      contentPadding: EdgeInsets.symmetric(
        horizontal: TraleTheme.of(context)!.padding,
        vertical: TraleTheme.of(context)!.padding,
      ),
      title: AutoSizeText(
        AppLocalizations.of(context)!.heightUnit,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      trailing: DropdownMenu<TraleUnitHeight>(
        initialSelection: Provider.of<TraleNotifier>(context).heightUnit,
        label: AutoSizeText(
          AppLocalizations.of(context)!.heightUnit,
          style: Theme.of(context).textTheme.bodyLarge,
          maxLines: 1,
        ),
        dropdownMenuEntries: <DropdownMenuEntry<TraleUnitHeight>>[
          for (final TraleUnitHeight heightUnit in TraleUnitHeight.values)
            DropdownMenuEntry<TraleUnitHeight>(
              value: heightUnit,
              label: heightUnit.label,
            ),
        ],
        onSelected: (TraleUnitHeight? newHeightUnit) async {
          if (newHeightUnit != null) {
            Provider.of<TraleNotifier>(context, listen: false).heightUnit =
                newHeightUnit;
          }
        },
      ),
    );
  }
}
