import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:trale/core/icons.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/l10n-gen/app_localizations.dart';

/// m3 floating action button
class FAB extends StatefulWidget {
  const FAB({
    required this.show,
    required this.onPressed,
    super.key
  });

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
    const double buttonHeight = 96;  /// The new m3e size for a large FAB
    return AnimatedContainer(
        alignment: Alignment.center,
        height: widget.show ? buttonHeight : 0,
        width: widget.show ? buttonHeight : 0,
        margin: EdgeInsets.all(
          widget.show ? 0 : 0.5 * buttonHeight,
        ),
        duration: TraleTheme.of(context)!.transitionDuration.normal,
        child: FittedBox(
          fit: BoxFit.contain,
          child: FloatingActionButton.large(
            elevation: 0,
            onPressed: widget.onPressed,
            tooltip: AppLocalizations.of(context)!.addWeight,
            child: PPIcon(PhosphorIconsRegular.plus, context),
          ),
        )
    );
  }
}