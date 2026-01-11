import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:trale/core/font.dart';
import 'package:trale/core/measurement.dart';
import 'package:trale/core/measurementDatabase.dart';
import 'package:trale/core/textSize.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/addWeightDialog.dart';

@immutable
class WeightListTile extends StatefulWidget {
  const WeightListTile({
    super.key,
    required this.measurement,
    required this.updateActiveState,
    required this.activeKey,
    this.offset = const Offset(-100, 0),
    this.durationInMilliseconds = 1000,
  });

  final SortedMeasurement measurement;
  final Offset offset;
  final int durationInMilliseconds;
  final Function updateActiveState;
  final int? activeKey;

  @override
  State<WeightListTile> createState() => _WeightListTileState();
}

class _WeightListTileState extends State<WeightListTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<Offset> offsetAnimation;

  // bool reverse = false;
  final MeasurementDatabase database = MeasurementDatabase();

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationInMilliseconds),
    );

    offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: widget.offset,
    ).animate(animationController);
  }

  @override
  void dispose() {
    animationController.dispose(); // you need this
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool reverse = widget.activeKey == widget.measurement.key;

    if (reverse == false) {
      animationController.reverse();
    } else {
      animationController.forward();
    }

    final double height = 1.5 * sizeOfText(text: '10', context: context).height;

    final Widget child = Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        AnimatedContainer(
          duration: Duration(milliseconds: widget.durationInMilliseconds),
          alignment: Alignment.center,
          //color: Theme.of(context).colorScheme.background,
          width: MediaQuery.of(context).size.width,
          height: height,
          child: AutoSizeText(
            widget.measurement.measurement.measureToString(context, ws: 11),
            style: Theme.of(context).textTheme.monospace.bodyLarge!,
          ),
        ),
      ],
    );

    Widget actionButton(
      IconData icon,
      Color iconColor,
      Color containerColor,
      Function onTap,
    ) => InkWell(
      onTap: () {
        onTap();
      },
      child: AnimatedContainer(
        height: reverse ? height : 0,
        width: MediaQuery.of(context).size.width / 6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            reverse ? TraleTheme.of(context)!.borderRadius : 0,
          ),
          color: containerColor,
        ),
        duration: Duration(milliseconds: widget.durationInMilliseconds),
        child: Icon(icon, color: iconColor),
      ),
    );

    Future<void> edit() async {
      final bool changed = await showAddWeightDialog(
        context: context,
        weight: widget.measurement.measurement.weight,
        date: widget.measurement.measurement.date,
        editMode: true,
      );
      if (changed) {
        database.deleteMeasurement(widget.measurement);
        setState(() {});
      }
      setState(() {
        reverse = false;
      });
      animationController.reverse();

      Future<void>.delayed(
        Duration(milliseconds: widget.durationInMilliseconds),
        () => widget.updateActiveState(null),
      );
    }

    void delete() {
      final SortedMeasurement deletedSortedMeasurement = widget.measurement;
      database.deleteMeasurement(widget.measurement);
      final SnackBar snackBar = SnackBar(
        content: Text(AppLocalizations.of(context)!.measurementDeleted),
        behavior: SnackBarBehavior.floating,
        width: MediaQuery.of(context).size.width / 3 * 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(TraleTheme.of(context)!.borderRadius),
          ),
        ),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.undo,
          onPressed: () {
            setState(() {
              reverse = false;
            });
            animationController.reverse();

            Future<void>.delayed(
              Duration(milliseconds: widget.durationInMilliseconds),
              () {
                database.insertMeasurement(
                  deletedSortedMeasurement.measurement,
                );
                // setState(() {});
                widget.updateActiveState(null);
              },
            );
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      animationController.reverse();
      Future<void>.delayed(
        Duration(milliseconds: widget.durationInMilliseconds),
        () => widget.updateActiveState(null),
      );
    }

    return InkWell(
      onLongPress: () {
        widget.updateActiveState(widget.measurement.key);
      },
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              SizedBox(width: MediaQuery.of(context).size.width / 2),
              AnimatedContainer(
                duration: Duration(milliseconds: widget.durationInMilliseconds),
                height: reverse ? 2 * height : 0,
                width: MediaQuery.of(context).size.width / 2,
                padding: EdgeInsets.only(
                  top: TraleTheme.of(context)!.padding,
                  right: TraleTheme.of(context)!.padding,
                  bottom: TraleTheme.of(context)!.padding,
                ),
                alignment: Alignment.center,
                child: AnimatedOpacity(
                  duration: Duration(
                    milliseconds: widget.durationInMilliseconds,
                  ),
                  opacity: reverse ? 1 : 0,
                  child: ClipRRect(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        actionButton(
                          PhosphorIconsFill.trash,
                          TraleTheme.of(
                            context,
                          )!.themeData.colorScheme.onTertiaryContainer,
                          TraleTheme.of(
                            context,
                          )!.themeData.colorScheme.tertiaryContainer,
                          delete,
                        ),
                        SizedBox(width: TraleTheme.of(context)!.padding),
                        actionButton(
                          PhosphorIconsFill.pencilSimple,
                          TraleTheme.of(
                            context,
                          )!.themeData.colorScheme.onSecondaryContainer,
                          TraleTheme.of(
                            context,
                          )!.themeData.colorScheme.secondaryContainer,
                          edit,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          AnimatedBuilder(
            animation: animationController,
            builder: (BuildContext context, Widget? child) =>
                Transform.translate(
                  offset: offsetAnimation.value,
                  transformHitTests: true,
                  child: child,
                ),
            child: child,
          ),
        ],
      ),
    );
  }
}
