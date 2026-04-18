import 'package:flutter/material.dart';
import 'package:quantumphysique/src/types/font.dart';
import 'package:quantumphysique/src/types/icons.dart';
import 'package:quantumphysique/src/widgets/qp_layout.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Banner widget for settings pages.
class SettingsBanner extends StatelessWidget {
  /// Constructor.
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

  /// Leading icon.
  final IconData leadingIcon;

  /// Title text.
  final String title;

  /// Subtitle text.
  final String subtitle;

  /// Trailing icon.
  final IconData? trailingIcon;

  /// Background color.
  final Color? backgroundColor;

  /// Trailing icon color.
  final Color? trailingColor;

  /// Font color.
  final Color? fontColor;

  /// URL to open on tap.
  final String? url;

  @override
  Widget build(BuildContext context) {
    const double padding = QPLayout.padding;
    final ThemeData theme = Theme.of(context);
    final Color resolvedBackgroundColor =
        backgroundColor ?? theme.colorScheme.tertiaryContainer;
    final Color resolvedFontColor =
        fontColor ?? theme.colorScheme.onTertiaryContainer;
    final Color resolvedTrailingColor =
        trailingColor ?? theme.colorScheme.surfaceContainerLowest;
    final bool hasTrailingIcon = trailingIcon != null;

    return Material(
      color: resolvedBackgroundColor,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => url == null ? null : _launchURL(url!),
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: padding,
                horizontal: 2 * padding,
              ),
              child: Row(
                children: <Widget>[
                  Icon(leadingIcon, color: resolvedFontColor),
                  const SizedBox(width: padding),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: hasTrailingIcon ? 3 * padding : 0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            title,
                            style: theme.textTheme.emphasized.titleLarge
                                ?.copyWith(color: resolvedFontColor),
                          ),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: resolvedFontColor,
                            ),
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
                    padding: const EdgeInsets.all(padding / 2),
                    child: FractionallySizedBox(
                      heightFactor: 1,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: resolvedTrailingColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(child: PPIcon(trailingIcon!, context)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Launches [url] in the external browser.
Future<void> _launchURL(String url) async {
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url);
  } else {
    throw 'Could not launch $url';
  }
}
