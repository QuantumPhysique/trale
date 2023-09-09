import 'package:flutter/material.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/widget/animate_in_effect.dart';
import 'package:trale/widget/fade_in_effect.dart';


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
  /* return SizedBox(
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
  );*/
}