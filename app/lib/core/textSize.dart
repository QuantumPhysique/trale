import 'package:flutter/material.dart';

/// function to measure size of text widget
Size sizeOfText({
  required String text,
  required BuildContext context,
  TextStyle? style,
}) {
  style = style ?? Theme.of(context).textTheme.bodyLarge;
  return (TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textScaleFactor: MediaQuery.of(context).textScaleFactor,
    textDirection: Directionality.of(context),
  )..layout()).size;
}
