import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:quantumphysique/src/types/font.dart';
import 'package:quantumphysique/src/types/string_extension.dart';
import 'package:quantumphysique/src/widgets/qp_layout.dart';

/// A large snapping [SliverAppBar] wrapping a list of sliver children.
///
/// Used by all QP settings pages to provide a consistent collapsible-header
/// layout.
class QPSliverAppBarSnap extends StatefulWidget {
  /// Creates a [QPSliverAppBarSnap].
  const QPSliverAppBarSnap({
    super.key,
    required this.title,
    required this.sliverlist,
  });

  /// Page title displayed in the app bar.
  final String title;

  /// Sliver widgets rendered below the app bar.
  final List<Widget> sliverlist;

  @override
  State<QPSliverAppBarSnap> createState() => _QPSliverAppBarSnapState();
}

class _QPSliverAppBarSnapState extends State<QPSliverAppBarSnap> {
  final ScrollController _controller = ScrollController();

  double get maxHeight => 150 + MediaQuery.of(context).padding.top;
  double get minHeight => kToolbarHeight + MediaQuery.of(context).padding.top;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollEndNotification>(
      onNotification: (_) {
        _snap();
        return false;
      },
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: CustomScrollView(
          controller: _controller,
          slivers: <Widget>[
            SliverSafeArea(
              top: false,
              sliver: SliverAppBar.large(
                pinned: true,
                stretch: true,
                title: Text(
                  widget.title.allInCaps,
                  style: Theme.of(context).textTheme.emphasized.headlineMedium
                      ?.apply(color: Theme.of(context).colorScheme.onSurface),
                ),
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                leading: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: PhosphorIcon(
                    PhosphorIconsDuotone.arrowLeft,
                    duotoneSecondaryColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerLowest,
                    duotoneSecondaryOpacity: 1.0,
                  ),
                ),
                expandedHeight: maxHeight - MediaQuery.of(context).padding.top,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(QPLayout.padding),
              sliver: SliverList.list(children: widget.sliverlist),
            ),
            const SliverFillRemaining(
              hasScrollBody: false,
              child: SizedBox.shrink(),
            ),
            SliverToBoxAdapter(child: SizedBox(height: maxHeight - minHeight)),
          ],
        ),
      ),
    );
  }

  void _snap() {
    final double scrollDistance = maxHeight - minHeight;
    if (_controller.offset > 0 && _controller.offset < scrollDistance) {
      final double snapOffset = _controller.offset / scrollDistance > 0.5
          ? scrollDistance
          : 0;
      Future<void>.microtask(
        () => _controller.animateTo(
          snapOffset,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        ),
      );
    }
  }
}
