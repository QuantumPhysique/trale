import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:trale/pages/homescreen_calendar.dart';
import 'package:trale/l10n-gen/app_localizations.dart';

void main() {
  testWidgets('Calendar shows markers for dates with check-ins', (
    WidgetTester tester,
  ) async {
    // Provide initial events directly to avoid relying on native sqlite3 in test environment
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeScreenCalendarPage(initialEvents: <DateTime>[DateTime(2026, 1, 11)]),
      ),
    );

    // Wait for async load
    await tester.pumpAndSettle();

    // Expect to find the day number '11' in the calendar
    expect(find.text('11'), findsWidgets);

    // Select the date and ensure selection updates
    await tester.tap(find.text('11').first);
    await tester.pumpAndSettle();

    // After selecting, events list should be present (even if empty list tile)
    expect(find.byType(ListTile), findsWidgets);

    // Verify the event marker is rendered
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color ==
                Theme.of(tester.element(find.byType(TableCalendar<String>)))
                    .colorScheme
                    .primary,
      ),
      findsOneWidget,
    );
  });
}
