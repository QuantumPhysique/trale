import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:rive/src/rive_core/component.dart';


/// Hero with icon for drawer
class IconHero extends StatefulWidget {
  /// constructor
  const IconHero({Key? key}) : super(key: key);

  @override
  State<IconHero> createState() => _IconHeroState();
}

class _IconHeroState extends State<IconHero> {
  /// path to rive file
  static const String _assetName = 'assets/trale_icon_extended.riv';

  @override
  Widget build(BuildContext context) {
    final ColorScheme ctheme = Theme.of(context).colorScheme;

    final Map<String, Color> colors = <String, Color>{
      'background': ctheme.primaryContainer,
      'wolf': ctheme.onPrimaryContainer,
      'title': ctheme.onSurface,
      'subtitle': ctheme.onSurfaceVariant,
      'slogan': ctheme.primary,
    };

    return RiveAnimation.asset(
      _assetName,
      onInit: (Artboard artboard) {
        artboard.forEachComponent(
          (Component child) {
            if (child is Shape) {
              if (colors.containsKey(child.name)) {
                final Shape shape = child;
                shape.fills.first.paint.color = colors[child.name]!;
              }
            }
          },
        );
      },
    );
  }
}

