import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/interpolation.dart';
import 'package:trale/core/interpolationPreview.dart';

import 'package:trale/core/stringExtension.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/customScrollViewSnapping.dart';
import 'package:trale/widget/linechart.dart';
import 'package:trale/widget/tile_group.dart';

class InterpolationSettingsPage extends StatelessWidget {
  const InterpolationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TraleNotifier notifier = Provider.of<TraleNotifier>(context);

    // Build list of sliver children: translate pill + radio list + bottom spacer
    final List<Widget> sliverlist = <Widget>[
      const InterpolationSetting(),
    ];

    return Scaffold(
      body: SliverAppBarSnap(
        title: AppLocalizations.of(context)!.interpolation,
        sliverlist: sliverlist,
      ),
    );
  }
}


/// ListTile for changing interpolation settings
class InterpolationSetting extends StatelessWidget {
  /// constructor
  const InterpolationSetting({super.key});

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

    return WidgetGroup(
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
    );
  }
}