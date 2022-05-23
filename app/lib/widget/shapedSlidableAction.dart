import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

/// based on following MR
/// https://github.com/letsar/flutter_slidable/blob/cc91a13ec73fd464be38df7eec9f05e3ce071369/lib/src/actions.dart0

const RoundedRectangleBorder _kshape = RoundedRectangleBorder();

/// Represents an action of an [ActionPane].
class ShapedSlidableAction extends StatelessWidget {
  /// Creates a [ShapedSlidableAction].
  const ShapedSlidableAction({
    Key? key,
    this.flex=1,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    required this.icon,
    required this.tooltip,
    this.autoClose=true,
    this.side=BorderSide.none,
    this.shape=_kshape,
  })  : assert(flex > 0),
        super(key: key);

  /// The flex factor to use for this child.
  final int flex;
  /// The background color of this action.
  final Color backgroundColor;
  /// The foreground color of this action.
  final Color foregroundColor;
  /// Whether the enclosing [Slidable] will be closed after [onPressed]
  /// occurred.
  final bool autoClose;
  /// Called when the action is tapped or otherwise activated.
  final SlidableActionCallback? onPressed;
  /// Typically the action's icon or label.
  final IconData icon;
  /// Defaults to [BorderSide.none].
  final BorderSide? side;
  /// Defaults to [RoundedRectangleBorder].
  final OutlinedBorder? shape;
  /// tooltip
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: SizedBox.expand(
        child: Container(
          alignment: Alignment.center,
          color: Theme.of(context).backgroundColor,
          child: Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              color: backgroundColor,
            ),
            child: IconButton(
              alignment: Alignment.center,
              icon: Icon(
                icon,
              ),
              onPressed: () => _handleTap(context),
              tooltip: tooltip,
              color: foregroundColor,
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    onPressed?.call(context);
    if (autoClose) {
      Slidable.of(context)?.close();
    }
  }
}


class CustomMotion extends StatefulWidget {
  final Function? onOpen;
  final Function? onClose;
  final Widget motionWidget;

  /// constructor
  const CustomMotion({
    Key? key, this.onOpen, this.onClose, required this.motionWidget,
  }) : super(key: key);


  @override
  _CustomMotionState createState() => _CustomMotionState();
}

class _CustomMotionState extends State<CustomMotion> {
  static SlidableController? controller;
  static void Function()? myListener;
  bool isClosed = true;

  void animationListener() {
    if ((controller?.ratio == 0) && widget.onClose != null && !isClosed) {
      isClosed = true;
      widget.onClose!();
    }

    if (
      controller != null &&
      (controller!.ratio == controller!.startActionPaneExtentRatio) &&
      widget.onOpen != null &&
      isClosed
    ) {
      isClosed = false;
      widget.onOpen!();
    }
  }

  @override
  void dispose() {
    if (myListener != null) {
      controller?.animation.removeListener(myListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller = Slidable.of(context);
    myListener = animationListener;

    controller?.animation.addListener(myListener!);

    return widget.motionWidget;
  }

}