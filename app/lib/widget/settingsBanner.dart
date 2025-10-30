import 'package:flutter/material.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/core/theme.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsBanner extends StatelessWidget {
  const SettingsBanner({
    required this.leadingIcon,
    this.trailingIcon,
    required this.title,
    required this.subtitle,
    this.backgroundColor,
    this.trailingColor,
    this.fontColor,
    this.url,
    super.key,
  });

  final IconData leadingIcon;
  final String title;
  final String subtitle;
  final IconData? trailingIcon;
  final Color? backgroundColor;
  final Color? trailingColor;
  final Color? fontColor;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final double padding = TraleTheme.of(context)!.padding;
    final ThemeData theme = Theme.of(context);
    final Color resolvedBackgroundColor = backgroundColor ?? Theme.of(context).colorScheme.primaryContainer;
    final Color resolvedFontColor = fontColor ?? Theme.of(context).colorScheme.onPrimaryContainer;
    final Color resolvedTrailingColor = trailingColor ?? Theme.of(context).colorScheme.surfaceContainerLowest;
    final bool hasTrailingIcon = trailingIcon != null;

    return GestureDetector(
      onTap: () => url == null ? () {} : _launchURL(url!),
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(
              vertical: padding,
              horizontal: 2 * padding,
            ),
            decoration: BoxDecoration(
              color: resolvedBackgroundColor,
              borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  leadingIcon,
                  color: resolvedFontColor,
                ),
                SizedBox(width: padding),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: hasTrailingIcon ? 3 * padding : 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(color: resolvedFontColor),
                        ),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(color: resolvedFontColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (hasTrailingIcon)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.all(padding / 2),
                  child: FractionallySizedBox(
                    heightFactor: 1,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: resolvedTrailingColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: PPIcon(
                            trailingIcon!,
                            context,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}



/// launch url
Future<void> _launchURL(String url) async {
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url);
  } else {
    throw 'Could not launch $url';
  }
}
