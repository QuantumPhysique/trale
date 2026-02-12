import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/font.dart';

void main() {
  group('MonospaceExtension', () {
    testWidgets('monospace applies RobotoMono font family', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final textTheme = Theme.of(context).textTheme;
              final monoTheme = textTheme.monospace;

              // Check that the font family is applied
              expect(monoTheme.bodyLarge?.fontFamily, 'RobotoMono');
              expect(monoTheme.bodyMedium?.fontFamily, 'RobotoMono');
              expect(monoTheme.bodySmall?.fontFamily, 'RobotoMono');
              expect(monoTheme.displayLarge?.fontFamily, 'RobotoMono');

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('monospace preserves text style properties', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final textTheme = Theme.of(context).textTheme;
              final originalSize = textTheme.bodyLarge?.fontSize;
              final monoTheme = textTheme.monospace;

              // Font size should be preserved
              expect(monoTheme.bodyLarge?.fontSize, originalSize);

              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  group('EmphasizedExtension', () {
    testWidgets('emphasized applies font variations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final textTheme = Theme.of(context).textTheme;
              final emphasizedTheme = textTheme.emphasized;

              // Check that font variations are applied
              expect(emphasizedTheme.bodyLarge?.fontVariations, isNotNull);
              expect(emphasizedTheme.bodyLarge?.fontVariations, isNotEmpty);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('emphasized applies to all text styles', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final textTheme = Theme.of(context).textTheme;
              final emphasizedTheme = textTheme.emphasized;

              // All text styles should have font variations
              expect(emphasizedTheme.displayLarge?.fontVariations, isNotNull);
              expect(emphasizedTheme.displayMedium?.fontVariations, isNotNull);
              expect(emphasizedTheme.displaySmall?.fontVariations, isNotNull);
              expect(emphasizedTheme.headlineLarge?.fontVariations, isNotNull);
              expect(emphasizedTheme.headlineMedium?.fontVariations, isNotNull);
              expect(emphasizedTheme.headlineSmall?.fontVariations, isNotNull);
              expect(emphasizedTheme.titleLarge?.fontVariations, isNotNull);
              expect(emphasizedTheme.titleMedium?.fontVariations, isNotNull);
              expect(emphasizedTheme.titleSmall?.fontVariations, isNotNull);
              expect(emphasizedTheme.bodyLarge?.fontVariations, isNotNull);
              expect(emphasizedTheme.bodyMedium?.fontVariations, isNotNull);
              expect(emphasizedTheme.bodySmall?.fontVariations, isNotNull);
              expect(emphasizedTheme.labelLarge?.fontVariations, isNotNull);
              expect(emphasizedTheme.labelMedium?.fontVariations, isNotNull);
              expect(emphasizedTheme.labelSmall?.fontVariations, isNotNull);

              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('emphasized preserves original text properties', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final textTheme = Theme.of(context).textTheme;
              final originalSize = textTheme.bodyLarge?.fontSize;
              final originalColor = textTheme.bodyLarge?.color;
              final emphasizedTheme = textTheme.emphasized;

              // Original properties should be preserved
              expect(emphasizedTheme.bodyLarge?.fontSize, originalSize);
              expect(emphasizedTheme.bodyLarge?.color, originalColor);

              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}
