import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:trale/core/icons.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/animate_in_effect.dart';
import 'package:trale/widget/fade_in_effect.dart';

/// Define empty Chart, which is used in case there are no measurements yet
Widget emptyChart(BuildContext context, List<InlineSpan> inlineSpan) {
  final int animationDurationInMilliseconds =
      TraleTheme.of(context)!.transitionDuration.slow.inMilliseconds;
  final int firstDelayInMilliseconds =
      TraleTheme.of(context)!.transitionDuration.normal.inMilliseconds;

  return AnimateInEffect(
    durationInMilliseconds: animationDurationInMilliseconds,
    delayInMilliseconds: firstDelayInMilliseconds,
    child: SizedBox(
      height: MediaQuery.of(context).size.height / 2,
      width: MediaQuery.of(context).size.width,
      child: Card(
        shape: TraleTheme.of(context)!.borderShape,
        margin: EdgeInsets.fromLTRB(
          TraleTheme.of(context)!.padding,
          0,
          TraleTheme.of(context)!.padding,
          TraleTheme.of(context)!.padding,
        ),
        child: FadeInEffect(
          durationInMilliseconds: animationDurationInMilliseconds,
          delayInMilliseconds: firstDelayInMilliseconds +
          animationDurationInMilliseconds,
          child: Center(
            child: RichText(
              text: TextSpan(
                children: inlineSpan,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ),
  );
}

/// Define the default empty Chart,
/// which is used in case there are no measurements yet.
Widget defaultEmptyChart({required BuildContext context,
                          bool overviewScreen = false}) {
  List<InlineSpan> inlineSpan;
  if (overviewScreen){
    inlineSpan = <InlineSpan>[
      TextSpan(
        text: AppLocalizations.of(context)!.intro1,
      ),
      WidgetSpan(
        child: PPIcon(PhosphorIconsDuotone.plusCircle, context),
        alignment: PlaceholderAlignment.middle,
      ),
      TextSpan(
        text: AppLocalizations.of(context)!.intro2,
      ),
    ];
  } else{
    inlineSpan = <InlineSpan>[
      TextSpan(
        text: AppLocalizations.of(context)!.intro3,
      ),
      const TextSpan(
          text: '\n\n😃'
      ),
    ];
  }
  return emptyChart(context, inlineSpan);
}