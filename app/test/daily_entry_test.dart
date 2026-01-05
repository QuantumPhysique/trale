import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:trale/screens/daily_entry_screen.dart';

void main() {
  setUpAll(() {
    // Initialize FFI for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('DailyEntryScreen can be instantiated', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DailyEntryScreen(),
      ),
    );

    // Just check that the widget is created (loading indicator should be shown)
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}