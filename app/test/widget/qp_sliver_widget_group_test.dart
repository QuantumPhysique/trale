import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quantumphysique/quantumphysique.dart';

// Covers the quantumphysique widget rather than app code, but lives here
// because the package cannot run widget tests standalone: its own dependency
// resolution picks phosphor_flutter 2.1.0, which no longer compiles against
// the current Flutter.
void main() {
  Widget host(Set<int> built, int count) => MaterialApp(
    home: Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: QPLayout.padding),
            sliver: QPSliverWidgetGroup(
              title: '2026 - April',
              itemCount: count,
              itemBuilder: (BuildContext context, int i) {
                built.add(i);
                return QPGroupedListTile(title: Text('tile $i'));
              },
            ),
          ),
        ],
      ),
    ),
  );

  testWidgets('renders title and builds lazily', (WidgetTester tester) async {
    final Set<int> built = <int>{};
    await tester.pumpWidget(host(built, 500));

    expect(tester.takeException(), isNull);
    expect(find.text('2026 - April'), findsOneWidget);
    expect(find.text('tile 0'), findsOneWidget);
    // The whole point: 500 tiles must not all be built.
    expect(built.length, lessThan(100));
    debugPrint('built ${built.length} of 500 tiles');
  });

  testWidgets('rounds first and last tile only', (WidgetTester tester) async {
    final Set<int> built = <int>{};
    await tester.pumpWidget(host(built, 3));
    await tester.pumpAndSettle();

    final List<ClipRRect> clips = tester
        .widgetList<ClipRRect>(find.byType(ClipRRect))
        .toList();
    expect(clips.length, 3);
    const Radius outer = Radius.circular(QPLayout.borderRadius);
    const Radius inner = Radius.circular(QPLayout.innerBorderRadius);
    expect(
      clips.first.borderRadius,
      const BorderRadius.vertical(top: outer, bottom: inner),
    );
    expect(
      clips[1].borderRadius,
      const BorderRadius.vertical(top: inner, bottom: inner),
    );
    expect(
      clips.last.borderRadius,
      const BorderRadius.vertical(top: inner, bottom: outer),
    );
  });

  testWidgets('single tile is rounded on all corners', (
    WidgetTester tester,
  ) async {
    final Set<int> built = <int>{};
    await tester.pumpWidget(host(built, 1));
    await tester.pumpAndSettle();

    const Radius outer = Radius.circular(QPLayout.borderRadius);
    expect(
      tester.widget<ClipRRect>(find.byType(ClipRRect)).borderRadius,
      const BorderRadius.vertical(top: outer, bottom: outer),
    );
  });
}
