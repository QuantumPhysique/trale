import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:flutter_m3shapes_extended/flutter_m3shapes_extended.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/duration_extension.dart';
import 'package:trale/core/gap.dart';
import 'package:trale/core/l10n_extension.dart';
import 'package:trale/core/measurement_stats.dart';
import 'package:trale/core/text_size.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/trale_notifier.dart';
import 'package:trale/core/units.dart';
import 'package:trale/widget/icon_hero.dart';

part 'stats/rate_cards.dart';
part 'stats/weight_cards.dart';
part 'stats/streak_cards.dart';
part 'stats/info_cards.dart';
part 'stats/utils.dart';

/// Animated statistics widgets container.
class AnimatedStatsWidgets extends StatefulWidget {
  /// Constructor.
  const AnimatedStatsWidgets({super.key});

  @override
  State<AnimatedStatsWidgets> createState() => _AnimatedStatsWidgetsState();
}

class _AnimatedStatsWidgetsState extends State<AnimatedStatsWidgets> {
  Timer? _weightLostDelayTimer;
  bool _showWeightLostCard = false;

  void _ensureWeightLostCardVisibility(bool shouldShow) {
    if (!shouldShow) {
      _weightLostDelayTimer?.cancel();
      _weightLostDelayTimer = null;
      if (!_showWeightLostCard) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(() => _showWeightLostCard = false);
      });
      return;
    }
    if (_showWeightLostCard || _weightLostDelayTimer != null) {
      return;
    }
    _weightLostDelayTimer = Timer(
      Duration(
        milliseconds:
            (TraleTheme.of(context)!.transitionDuration.normal.inMilliseconds /
                    2)
                .toInt(),
      ),
      () {
        if (!mounted) {
          return;
        }
        setState(() {
          _showWeightLostCard = true;
          _weightLostDelayTimer = null;
        });
      },
    );
  }

  @override
  void dispose() {
    _weightLostDelayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MeasurementStats stats = MeasurementStats();
    final TraleNotifier notifier = Provider.of<TraleNotifier>(context);

    final double? userTargetWeight = notifier.effectiveTargetWeight;
    final Duration? timeOfTargetWeight = stats.timeOfTargetWeight(
      userTargetWeight,
      notifier.looseWeight,
    );
    final int nMeasured = stats.nMeasurements;
    _ensureWeightLostCardVisibility(nMeasured >= 2);
    Card userTargetWeightCard(double utw) => Card(
      shape: const StadiumBorder(),
      color: Theme.of(context).colorScheme.secondaryContainer,
      margin: EdgeInsets.symmetric(vertical: TraleTheme.of(context)!.padding),
      child: Padding(
        padding: EdgeInsets.all(TraleTheme.of(context)!.padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            AutoSizeText(
              '${notifier.unit.weightToString(utw, notifier.unitPrecision)} in',
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.onSecondaryContainer(context),
            ),
            AutoSizeText(
              timeOfTargetWeight == null
                  ? '--'
                  : timeOfTargetWeight.durationToString(context),
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.onSecondaryContainer(context),
            ),
          ],
        ),
      ),
    );

    Card userWeightLostCard() {
      final double deltaWeight = stats.monthlyChange;

      return Card(
        shape: const StadiumBorder(),
        margin: EdgeInsets.symmetric(vertical: TraleTheme.of(context)!.padding),
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Padding(
          padding: EdgeInsets.all(TraleTheme.of(context)!.padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              AutoSizeText(
                '${context.l10n.change} / '
                '${context.l10n.month}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall!.onSecondaryContainer(context),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AutoSizeText(
                    notifier.unit.weightToString(
                      deltaWeight,
                      notifier.unitPrecision,
                    ),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.onSecondaryContainer(context),
                  ),
                  const SizedBox(width: 5),
                  SizedBox(
                    height: sizeOfText(
                      text: '0',
                      context: context,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.onSecondaryContainer(context),
                    ).height,
                    child: Transform.rotate(
                      // a change of 1kg / 30d corresponds to 45°
                      angle: -1 * atan(deltaWeight),
                      child: Icon(
                        PhosphorIconsRegular.arrowRight,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return FractionallySizedBox(
      widthFactor: (userTargetWeight == null || nMeasured < 2) ? 0.5 : 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:
            <Widget>[
              if (userTargetWeight != null)
                Expanded(
                  child: QPAnimateInEffect(
                    durationInMilliseconds: TraleTheme.of(
                      context,
                    )!.transitionDuration.slow.inMilliseconds,
                    child: userTargetWeightCard(userTargetWeight),
                  ),
                ),
              if (nMeasured >= 2 && _showWeightLostCard)
                Expanded(
                  child: QPAnimateInEffect(
                    durationInMilliseconds: TraleTheme.of(
                      context,
                    )!.transitionDuration.slow.inMilliseconds,
                    child: userWeightLostCard(),
                  ),
                ),
            ].addGap(
              padding: TraleTheme.of(context)!.padding,
              direction: Axis.horizontal,
            ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BentoCard-based widget builders
// ---------------------------------------------------------------------------
