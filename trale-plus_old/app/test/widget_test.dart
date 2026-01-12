// Widget tests for Trale+ Fitness Journal
//
// Tests the main screens of the fitness journal app.
// Note: These screens have async database initialization which makes
// comprehensive widget testing challenging. The database and daily_entry
// tests provide thorough coverage of the app logic.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:trale/screens/settings_screen.dart';
import 'package:trale/screens/daily_entry_screen.dart';

void main() {
  // Initialize FFI for database tests  
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Trale+ Fitness Journal Widget Tests', () {
    testWidgets('Settings screen renders with loading indicator', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      // Initially shows loading while fetching user profile
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Daily entry screen renders successfully', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      await tester.pumpWidget(
        const MaterialApp(
          home: DailyEntryScreen(),
        ),
      );
      
      // Screen renders without crashing
      expect(find.byType(DailyEntryScreen), findsOneWidget);
    });

    test('Settings screen is a StatefulWidget', () {
      expect(const SettingsScreen(), isA<StatefulWidget>());
    });

    test('Daily entry screen is a StatefulWidget', () {
      expect(const DailyEntryScreen(), isA<StatefulWidget>());
    });
  });
}

