import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:provider/provider.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/first_day.dart';
import 'package:trale/core/interpolation.dart';
import 'package:trale/core/interpolation_preview.dart';
import 'package:trale/core/l10n_extension.dart';
import 'package:trale/core/measurement_database.dart';
import 'package:trale/core/measurement_interpolation.dart';
import 'package:trale/core/print_format.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/trale_notifier.dart';
import 'package:trale/core/unit_precision.dart';
import 'package:trale/core/units.dart';
import 'package:trale/widget/custom_scroll_view_snapping.dart';
import 'package:trale/widget/linechart.dart';
import 'package:trale/widget/user_dialog.dart';

/// Settings personalization page.
class PersonalizationSettingsPage extends StatefulWidget {
  /// Constructor.
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
            context.l10n.strength.inCaps,
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
      QPWidgetGroup(
        title: context.l10n.interpolation,
        children: <Widget>[
          QPGroupedWidget(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            child: CustomLineChart(
              loadedFirst: false,
              ip: useUserData
                  ? MeasurementInterpolation()
                  : PreviewInterpolation(),
              isPreview: true,
              relativeHeight: 0.25,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerLowest,
              chartMargin: EdgeInsets.zero,
            ),
          ),
          if (hasEnoughData)
            QPGroupedSwitchListTile(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              contentPadding: EdgeInsets.symmetric(
                horizontal: TraleTheme.of(context)!.padding,
              ),
              title: Text(
                context.l10n.showUserData.inCaps,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              value: _showUserData,
              onChanged: (bool? value) {
                setState(() {
                  _showUserData = value ?? false;
                });
              },
            ),
          QPGroupedWidget(
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
          context.l10n.interpolationExplanation(
            noneInterpol: InterpolStrength.none.nameLong(context),
          ),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      SizedBox(height: TraleTheme.of(context)!.padding),
      Consumer<TraleNotifier>(
        builder: (BuildContext context, TraleNotifier notifier, _) {
          final ColorScheme colorScheme = Theme.of(context).colorScheme;
          return QPWidgetGroup(
            title: context.l10n.statsSourceTitle,
            children: <Widget>[
              RadioGroup<bool>(
                groupValue: notifier.statsUseInterpolation,
                onChanged: (bool? value) {
                  if (value != null) {
                    notifier.statsUseInterpolation = value;
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    QPGroupedRadioListTile<bool>(
                      color: notifier.statsUseInterpolation
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerLowest,
                      shape: notifier.statsUseInterpolation
                          ? const StadiumBorder()
                          : null,
                      value: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: TraleTheme.of(context)!.padding,
                      ),
                      title: Text(
                        context.l10n.interpolation.inCaps,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    QPGroupedRadioListTile<bool>(
                      color: !notifier.statsUseInterpolation
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerLowest,
                      shape: !notifier.statsUseInterpolation
                          ? const StadiumBorder()
                          : null,
                      value: false,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: TraleTheme.of(context)!.padding,
                      ),
                      title: Text(
                        context.l10n.measurements.inCaps,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      SizedBox(height: 0.5 * TraleTheme.of(context)!.padding),
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: TraleTheme.of(context)!.padding,
        ),
        child: Text(
          context.l10n.statsSourceExplanation,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      SizedBox(height: TraleTheme.of(context)!.padding),
      QPWidgetGroup(
        title: context.l10n.unitTitle,
        children: const <Widget>[
          UnitsListTile(),
          UnitPrecisionListTile(),
          HeightUnitListTile(),
        ],
      ),
      QPWidgetGroup(
        title: context.l10n.dateSettings,
        children: const <Widget>[FirstDayListTile(), DatePrintListTile()],
      ),
      UserDetailsGroup(
        title: context.l10n.user,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        notifier: notifier,
        onRefresh: () => setState(() {}),
      ),
      TargetWeightGroup(
        title: context.l10n.targetWeight,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        notifier: notifier,
        onRefresh: () => setState(() {}),
      ),
    ];

    return Scaffold(
      body: SliverAppBarSnap(
        title: context.l10n.personalization,
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
    return QPGroupedListTile(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      contentPadding: EdgeInsets.symmetric(
        horizontal: TraleTheme.of(context)!.padding,
        vertical: TraleTheme.of(context)!.padding,
      ),
      title: AutoSizeText(
        context.l10n.unit,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      trailing: DropdownMenu<TraleUnit>(
        initialSelection: Provider.of<TraleNotifier>(context).unit,
        label: AutoSizeText(
          context.l10n.unit,
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
    return QPGroupedListTile(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      contentPadding: EdgeInsets.symmetric(
        horizontal: TraleTheme.of(context)!.padding,
        vertical: TraleTheme.of(context)!.padding,
      ),
      title: AutoSizeText(
        context.l10n.precision.inCaps,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      trailing: DropdownMenu<TraleUnitPrecision>(
        initialSelection: Provider.of<TraleNotifier>(context).unitPrecision,
        label: AutoSizeText(
          context.l10n.precision,
          style: Theme.of(context).textTheme.bodyLarge,
          maxLines: 1,
        ),
        dropdownMenuEntries: <DropdownMenuEntry<TraleUnitPrecision>>[
          for (final TraleUnitPrecision precision in TraleUnitPrecision.values)
            DropdownMenuEntry<TraleUnitPrecision>(
              value: precision,
              label: precision.settingsName ?? context.l10n.defaultFormat,
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

/// Generic dropdown settings widget.
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
        return QPGroupedListTile(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          contentPadding: EdgeInsets.symmetric(
            horizontal: TraleTheme.of(context)!.padding,
            vertical: TraleTheme.of(context)!.padding,
          ),
          title: AutoSizeText(
            context.l10n.firstDay,
            style: Theme.of(context).textTheme.bodyLarge,
            maxLines: 1,
          ),
          trailing: DropdownMenu<TraleFirstDay>(
            initialSelection: traleNotifier.firstDay,
            label: AutoSizeText(
              context.l10n.firstDay,
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

/// Settings tile widget.
class DatePrintListTile extends StatelessWidget {
  /// constructor
  const DatePrintListTile({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch the current date print format from the provider
    final TraleNotifier traleNotifier = Provider.of<TraleNotifier>(context);

    return QPGroupedListTile(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      contentPadding: EdgeInsets.symmetric(
        horizontal: TraleTheme.of(context)!.padding,
        vertical: TraleTheme.of(context)!.padding,
      ),
      title: AutoSizeText(
        context.l10n.format,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      trailing: DropdownMenu<TraleDatePrintFormat>(
        initialSelection: Provider.of<TraleNotifier>(context).datePrintFormat,
        label: AutoSizeText(
          context.l10n.format,
          style: Theme.of(context).textTheme.bodyLarge,
          maxLines: 1,
        ),
        dropdownMenuEntries: <DropdownMenuEntry<TraleDatePrintFormat>>[
          for (final TraleDatePrintFormat datePrintFormat
              in TraleDatePrintFormat.values)
            DropdownMenuEntry<TraleDatePrintFormat>(
              value: datePrintFormat,
              label: datePrintFormat.pattern ?? context.l10n.defaultFormat,
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
    return QPGroupedListTile(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      contentPadding: EdgeInsets.symmetric(
        horizontal: TraleTheme.of(context)!.padding,
        vertical: TraleTheme.of(context)!.padding,
      ),
      title: AutoSizeText(
        context.l10n.heightUnit,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      trailing: DropdownMenu<TraleUnitHeight>(
        initialSelection: Provider.of<TraleNotifier>(context).heightUnit,
        label: AutoSizeText(
          context.l10n.heightUnit,
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
