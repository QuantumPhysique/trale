// This is based on the following SO post:
//
// Source - https://stackoverflow.com/a/67910495
// Posted by MBK, modified by community. See post 'Timeline' for change history
// Retrieved 2026-02-24, License - CC BY-SA 4.0
import 'package:flutter/material.dart';
import 'package:trale/core/theme.dart';

/// A simple widget to display a list of strings as a bulleted list.
class BulletList extends StatelessWidget {
  /// The list of strings to display as a bulleted list.
  final List<String> strings;

  /// Creates a [BulletList] widget.
  BulletList(this.strings);

  @override
  Widget build(BuildContext context) {
    TraleTheme theme = TraleTheme.of(context)!;

    final Text bulletpoint = Text(
      '\u2022',
      style: Theme.of(context).textTheme.bodyMedium!,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: strings.map((String str) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            bulletpoint,
            SizedBox(width: 0.5 * theme.padding),
            Expanded(
              child: Container(
                child: Text(
                  str,
                  softWrap: true,
                  style: Theme.of(context).textTheme.bodyMedium!,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
