import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/durationExtension.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:trale/l10n-gen/app_localizations.dart';

void main() {
  group('StringExtension on Duration', () {
    testWidgets('durationToString handles -1 days specially', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final duration = const Duration(days: -1);
              final result = duration.durationToString(context);

              // Special emoji for -1 days
              expect(result, '🥳');

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('durationToString formats days correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final duration = const Duration(days: 5);
              final result = duration.durationToString(context);

              // Should contain the number of days
              expect(result, contains('5'));
              expect(result.contains('days') || result.contains('day'), true);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('durationToString formats weeks correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final duration = const Duration(days: 35); // 5 weeks
              final result = duration.durationToString(context);

              // Should contain the number of weeks
              expect(result, contains('5'));

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('durationToString formats months correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final duration = const Duration(days: 90); // ~3 months
              final result = duration.durationToString(context);

              // Should contain the number of months
              expect(result, contains('3'));

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('durationToString formats years correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final duration = const Duration(days: 730); // 2 years
              final result = duration.durationToString(context);

              // Should contain the number of years
              expect(result, contains('2'));

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('durationToString transitions at correct thresholds', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              // 27 days should be shown as days
              final days27 = const Duration(days: 27);
              final result27 = days27.durationToString(context);
              expect(result27, contains('27'));

              // 28 days should start showing weeks
              final days28 = const Duration(days: 28);
              final result28 = days28.durationToString(context);
              expect(result28, contains('4')); // 4 weeks

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('durationToString handles zero duration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final duration = Duration.zero;
              final result = duration.durationToString(context);

              // Zero days
              expect(result, contains('0'));

              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}
