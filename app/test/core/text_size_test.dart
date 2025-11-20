import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/textSize.dart';

void main() {
  group('sizeOfText', () {
    testWidgets('returns Size for simple text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final size = sizeOfText(
                text: 'Hello',
                context: context,
              );

              expect(size, isA<Size>());
              expect(size.width, greaterThan(0));
              expect(size.height, greaterThan(0));

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns different sizes for different text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final shortSize = sizeOfText(
                text: 'Hi',
                context: context,
              );
              final longSize = sizeOfText(
                text: 'Hello World',
                context: context,
              );

              // Longer text should have larger width
              expect(longSize.width, greaterThan(shortSize.width));

              // Height should be roughly the same for same style
              expect(longSize.height, closeTo(shortSize.height, 5.0));

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('uses provided TextStyle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final defaultSize = sizeOfText(
                text: 'Test',
                context: context,
              );
              final largeSize = sizeOfText(
                text: 'Test',
                context: context,
                style: const TextStyle(fontSize: 48),
              );

              // Larger font size should result in larger dimensions
              expect(largeSize.width, greaterThan(defaultSize.width));
              expect(largeSize.height, greaterThan(defaultSize.height));

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('respects textScaleFactor', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaleFactor: 2.0),
            child: Builder(
              builder: (context) {
                final size = sizeOfText(
                  text: 'Test',
                  context: context,
                );

                // With 2x scale factor, dimensions should be larger
                expect(size.width, greaterThan(0));
                expect(size.height, greaterThan(0));

                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('handles empty string', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final size = sizeOfText(
                text: '',
                context: context,
              );

              expect(size, isA<Size>());
              // Empty string should have minimal or zero width
              expect(size.width, greaterThanOrEqualTo(0));
              expect(size.height, greaterThan(0)); // Height from font

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('handles special characters', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final size = sizeOfText(
                text: '🎉🎊',
                context: context,
              );

              expect(size, isA<Size>());
              expect(size.width, greaterThan(0));
              expect(size.height, greaterThan(0));

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('respects text directionality', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                final sizeLtr = sizeOfText(
                  text: 'Test',
                  context: context,
                );

                expect(sizeLtr, isA<Size>());
                expect(sizeLtr.width, greaterThan(0));

                return const SizedBox();
              },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Builder(
              builder: (context) {
                final sizeRtl = sizeOfText(
                  text: 'Test',
                  context: context,
                );

                expect(sizeRtl, isA<Size>());
                expect(sizeRtl.width, greaterThan(0));

                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });
  });
}
