import 'package:flutter/material.dart';
import 'package:quantumphysique/src/widgets/qp_layout.dart';

/// A simple bulleted list widget.
class QPBulletList extends StatelessWidget {
  /// Creates a [QPBulletList] widget.
  const QPBulletList(this.strings, {super.key});

  /// The list of strings to display as a bulleted list.
  final List<String> strings;

  @override
  Widget build(BuildContext context) {
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
            SizedBox(width: 0.5 * QPLayout.padding),
            Expanded(
              child: Text(
                str,
                softWrap: true,
                style: Theme.of(context).textTheme.bodyMedium!,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
