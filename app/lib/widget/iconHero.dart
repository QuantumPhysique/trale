import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class TraleIconColorMapper implements ColorMapper {
  const TraleIconColorMapper({
    required this.bgColor,
    required this.wolfColor,
    required this.titleColor,
    required this.sloganColor,
  });

  static const Color _defaultBgColor = Color(0xFFFFF1EF);
  static const Color _defaultWolfColor = Color(0xFF00658B);
  static const Color _defaultTitleColor = Color(0xFF001D2C);
  static const Color _defaultSloganColor = Color(0xFFFFDBCE);

  final Color bgColor;
  final Color wolfColor;
  final Color titleColor;
  final Color sloganColor;

  @override
  Color substitute(
    String? id, String elementName, String attributeName, Color color
  ) {
    if (color == _defaultBgColor) {
      return bgColor;
    } else if (color == _defaultWolfColor) {
      return wolfColor;
    } else if (color == _defaultTitleColor) {
      return titleColor;
    } else if (color == _defaultSloganColor) {
      return sloganColor;
    }

    return color;
  }
}


/// Hero with icon for drawer
class IconHero extends StatefulWidget {
  /// constructor
  const IconHero({super.key});

  @override
  State<IconHero> createState() => _IconHeroState();
}

class _IconHeroState extends State<IconHero> {
  /// path to rive file
  static const String assetName = 'assets/trale_icon_extended.svg';

  @override
  Widget build(BuildContext context) {
    final ColorScheme ctheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        return SvgPicture(
          SvgAssetLoader(
            assetName,
            colorMapper: TraleIconColorMapper(
              bgColor: ctheme.surfaceContainerLowest,
              wolfColor: ctheme.primary,
              titleColor: ctheme.onSurface,
              sloganColor: ctheme.secondaryContainer,
            ),
          ),
          width: width,
          fit: BoxFit.contain,
        );
      }
    );
  }
}


/// Hero with icon for drawer
class IconHeroStatScreen extends StatefulWidget {
  /// constructor
  const IconHeroStatScreen({super.key});

  @override
  State<IconHeroStatScreen> createState() => _IconHeroStatScreenState();
}

class _IconHeroStatScreenState extends State<IconHeroStatScreen> {
  /// path to rive file
  static const String assetName = 'assets/trale_icon.svg';

  @override
  Widget build(BuildContext context) {
    final ColorScheme ctheme = Theme.of(context).colorScheme;
    return SvgPicture(
        SvgAssetLoader(
          assetName,
          colorMapper: TraleIconColorMapper(
            bgColor: ctheme.onSurface,
            wolfColor: ctheme.primary,
            titleColor: ctheme.onSurface,
            sloganColor: ctheme.primary,
          ),
        )
    );
  }
}
