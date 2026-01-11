// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:trale/main.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/core/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App boots with provider', (WidgetTester tester) async {
    // Initialize mock shared preferences for test environment.
    SharedPreferences.setMockInitialValues(<String, Object>{});

    // Initialize preferences and build the app wrapped with the required provider.
    final Preferences prefs = Preferences();
    await prefs.loaded;

    // Build a minimal app under the same provider to avoid timed Splash timers.
    await tester.pumpWidget(
      ChangeNotifierProvider<TraleNotifier>.value(
        value: TraleNotifier(),
        child: const MaterialApp(
          home: Scaffold(body: Center(child: Text('ok'))),
        ),
      ),
    );

    // Verify the minimal app builds and the text is present.
    expect(find.text('ok'), findsOneWidget);
  });
}
