
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/pages/settings.dart';
import 'package:trale/pages/statScreen.dart';
import 'package:trale/widget/appDrawer.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/units.dart'; // Added import
import 'package:trale/main.dart'; 
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trale/core/preferences.dart'; // Import Preferences

// Mock TraleNotifier to avoid complex setup
class MockTraleNotifier extends ChangeNotifier implements TraleNotifier {
  @override
  bool get isAmoled => false;
  @override
  set isAmoled(bool value) {}
  
  @override
  ThemeMode get themeMode => ThemeMode.light;
  @override
  set themeMode(ThemeMode value) {}

  @override
  TraleCustomTheme get theme => TraleCustomTheme.forest;
  
  // Need to provide a valid unit
  @override
  get unit => TraleUnit.kg; // Assuming UnitSystem or similar

  @override
  bool get systemColorsAvailable => false;
  
  @override 
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    SharedPreferences.setMockInitialValues({});
    await Preferences().loaded;
  });

  // Helper to build TraleApp for testing
  Widget buildTestApp(Widget home, TraleNotifier notifier) {
    final theme = TraleTheme(
      seedColor: Colors.blue,
      brightness: Brightness.light,
      schemeVariant: DynamicSchemeVariant.tonalSpot,
    );
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TraleNotifier>.value(value: notifier),
      ],
      child: TraleApp(
        traleNotifier: notifier,
        light: theme,
        dark: theme,
        amoled: theme,
        routes: {
          '/': (context) => home,
        },
      ),
    );
  }

  group('Feature Verification Tests', () {
    
    testWidgets('Achievements Page (StatsScreen) should show "Under construction"', (WidgetTester tester) async {
       // Only StatsScreen needs to be tested, it was simplified to just text
       final TabController controller = TabController(length: 3, vsync: const TestVSync());
       
       await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
             body: StatsScreen(tabController: controller), 
          ),
        ),
      );
      
      expect(find.text('Under construction'), findsOneWidget);
    });

    testWidgets('Settings should NOT show "Lose weight"', (WidgetTester tester) async {
      final mockNotifier = TraleNotifier(); // Using real one might be easier if it has defaults
      
      await tester.pumpWidget(
        buildTestApp(const Settings(), mockNotifier),
      );
      
      // Wait for build
      await tester.pumpAndSettle();

      // "Lose weight" comes from AppLocalizations.looseWeight.
      // In English arb: "Lose weight" or "Gain weight".     
      expect(find.text('Lose weight'), findsNothing);
      expect(find.text('Gain weight'), findsNothing);
    });

    testWidgets('App Drawer should have "Your private journal" and NO target weight', (WidgetTester tester) async {
       final mockNotifier = TraleNotifier();

       await tester.pumpWidget(
        buildTestApp(
           Scaffold(
              body: Builder(
                builder: (context) {
                  return appDrawer(context, (i) {}, 0);
                }
              ),
            ),
            mockNotifier,
        ),
      );
      
      await tester.pumpAndSettle();

      expect(find.text('Your private journal'), findsOneWidget);
      expect(find.text('Add target weight'), findsNothing); 
    });

  });
}

