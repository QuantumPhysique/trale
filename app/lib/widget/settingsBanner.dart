import 'package:flutter/material.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/core/theme.dart';

class SettingsBanner extends StatelessWidget {
  const SettingsBanner({
    required this.leadingIcon,
    required this.trailingIcon,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.trailingColor,
    required this.fontColor,
    super.key,
  });

  final IconData leadingIcon;
  final IconData trailingIcon;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color trailingColor;
  final Color fontColor;

  @override
  Widget build(BuildContext context) {
    final double padding = TraleTheme.of(context)!.padding;
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(
            vertical: padding,
            horizontal: 2 * padding,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                leadingIcon,
                color: fontColor,
              ),
              SizedBox(width: padding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: fontColor),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: fontColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
                      color: trailingColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: PPIcon(
                        trailingIcon,
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
    );
  }
}
