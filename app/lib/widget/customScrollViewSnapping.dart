import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:trale/core/stringExtension.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/l10n-gen/app_localizations.dart';


class SliverAppBarSnap extends StatefulWidget {

  SliverAppBarSnap({
    super.key,
    required this.title,
    required this.sliverlist,
    required this.returnPage,
  });

  final String title;
  final List<Widget> sliverlist;
  final Widget returnPage;

  @override
  _SliverAppBarSnapState createState() => _SliverAppBarSnapState();
}

class _SliverAppBarSnapState extends State<SliverAppBarSnap> {
  final ScrollController _controller = ScrollController();

  double get maxHeight => 150 + MediaQuery.of(context).padding.top;
  double get minHeight => kToolbarHeight + MediaQuery.of(context).padding.top;
  bool isEmpty = true;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollEndNotification>(
      onNotification: (_) {
        _snapAppbar();
        return false;
      },
      child: CustomScrollView(
        // physics: const AlwaysScrollableScrollPhysics(),
        controller: _controller,
        slivers: <Widget>[
          SliverSafeArea(
            top: false,
            sliver: SliverAppBar.large(
              pinned: true,
              stretch: true,
              title: Text(widget.title.allInCaps),
              leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push<dynamic>(
                      MaterialPageRoute<Widget>(
                        builder: (BuildContext context) => widget.returnPage,
                      ),
                    );
                  },
                  icon: const Icon(PhosphorIconsDuotone.arrowLeft),
                ),
              expandedHeight: maxHeight - MediaQuery.of(context).padding.top,
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(TraleTheme.of(context)!.padding),
            sliver: SliverList.list(
              children: widget.sliverlist,
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: SizedBox(height: MediaQuery.of(context).padding.top),
          ),
        ],
      ),
    );
  }


  void _snapAppbar() {
    final double scrollDistance = maxHeight - minHeight;
    if (_controller.offset > 0 && _controller.offset < scrollDistance) {
      final double snapOffset = _controller.offset / scrollDistance > 0.5
          ? scrollDistance
          : 0;

      Future<void>.microtask(
        () => _controller.animateTo(
          snapOffset,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn,
        ),
      );
    }
  }
}

