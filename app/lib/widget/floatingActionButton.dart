import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/core/theme.dart';

/// m3 floating action button
class FAB extends StatefulWidget {
  const FAB({
    required this.show,
    required this.onPressed,
    Key? key
  }) : super(key: key);

  /// show FAB
  final bool show;
  /// onPressed
  final void Function() onPressed;

  @override
  State<FAB> createState() => _FABState();
}

class _FABState extends State<FAB> {
  @override
  Widget build(BuildContext context) {
    const double topInset = 12;
    const double buttonHeight = 80 - 2 * topInset;
    return Padding(
      padding: EdgeInsets.only(
        //todo add adaptive padding such that FAB is like a third bottom icon
        right: TraleTheme.of(context)!.padding,
        top: 80.0,
      ),
      child: AnimatedContainer(
          alignment: Alignment.center,
          height: widget.show ? buttonHeight : 0,
          width: widget.show ? buttonHeight : 0,
          margin: EdgeInsets.all(
            widget.show ? 0 : 0.5 * buttonHeight,
          ),
          duration: TraleTheme.of(context)!.transitionDuration.normal,
          child: FittedBox(
            fit: BoxFit.contain,
            child: FloatingActionButton(
              elevation: 0,
              onPressed: widget.onPressed,
              tooltip: AppLocalizations.of(context)!.addWeight,
              child: Icon(
                CustomIcons.add,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          )
      ),
    );
  }
}