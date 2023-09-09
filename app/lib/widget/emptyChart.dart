import 'package:flutter/material.dart';
import 'package:trale/core/theme.dart';


SizedBox emptyChart(BuildContext context, List<InlineSpan> inlineSpan) {
  return SizedBox(
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
  );
}