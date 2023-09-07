import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:rive/src/rive_core/component.dart';


/// Hero with splash animation
class SplashHero extends StatefulWidget {
  /// constructor
  const SplashHero({Key? key, required this.onStop}) : super(key: key);

  /// function called once finished
  final void Function() onStop;

  @override
  State<SplashHero> createState() => _SplashHeroState();
}

class _SplashHeroState extends State<SplashHero> {
  /// path to rive file
  static const String assetName = 'assets/trale.riv';
  static const String artboard = 'splash';
  static const String animation = 'splash';

  /// Controller for playback
  late RiveAnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = OneShotAnimation(
      animation,
      autoplay: true,
      onStop: () => widget.onStop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme ctheme = Theme.of(context).colorScheme;

    final Map<String, Color> colors = <String, Color>{
      'background': ctheme.onSurfaceVariant,
      'wolf': ctheme.primaryContainer,
      'background_outline': ctheme.onBackground,
      'wolf_outline': ctheme.onBackground,
      'title': ctheme.onBackground,
      'subtitle': ctheme.onSurfaceVariant,
      'bars': ctheme.onSurfaceVariant,
      'slogan': ctheme.primary,
      'poweredby': ctheme.onSurfaceVariant,
    };

    return RiveAnimation.asset(
      assetName,
      artboard: artboard,
      controllers: <RiveAnimationController>[controller],
      animations: const <String>[animation],
      onInit: (Artboard artboard) {
        artboard.forEachComponent(
          (Component child) {
            if (child is Shape) {
              if (colors.containsKey(child.name)) {
                final Shape shape = child;
                //shape.fills.first.paint.color = colors[child.name]!;
                if (shape.fills.isNotEmpty) {
                  (shape.fills.first.children[0] as SolidColor).colorValue =
                      colors[child.name]!.value;
                }
                if (shape.strokes.isNotEmpty) {
                  (shape.strokes.first.children[0] as SolidColor).colorValue =
                      colors[child.name]!.value;
                  shape.strokes.first.thickness = 25;
                }
              }
            }
          },
        );
      },
    );
  }
}

