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
    final ColorScheme _ctheme = Theme.of(context).colorScheme;
    final bool _isDark = Theme.of(context).brightness == Brightness.dark;

    final Map<String, Color> colors = <String, Color>{
      'tr': _isDark
        ? _ctheme.surfaceVariant
        : _ctheme.primary,
      'background': _isDark
        ? _ctheme.primaryContainer
        : _ctheme.primaryContainer,
      'wolf': _isDark
        ? _ctheme.onPrimaryContainer
        : _ctheme.onSurface,
      'title': _ctheme.onSurfaceVariant,
      'subtitle': _ctheme.onSurfaceVariant,
      'slogan': _isDark
        ? _ctheme.primaryContainer
        : _ctheme.primary,
    };

    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      height: MediaQuery.of(context).size.width * 0.3,
      alignment: Alignment.center,
      child: RiveAnimation.asset(
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
      ),
    );
  }
}

