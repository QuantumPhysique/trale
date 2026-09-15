import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:trale/core/trale_notifier.dart';

import '../helpers/widget_test_helper.dart';

void main() {
  late TraleNotifier notifier;

  setUp(() async {
    notifier = await setUpWidgetTestDependencies();
  });

  tearDown(resetWidgetTestDependencies);

  Future<BuildContext> pumpLocale(WidgetTester tester, String language) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(
      Localizations(
        locale: Locale(language),
        delegates: const <LocalizationsDelegate<dynamic>>[
          DefaultWidgetsLocalizations.delegate,
        ],
        child: Builder(
          builder: (BuildContext context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return capturedContext;
  }

  group('system default date format', () {
    final DateTime date = DateTime(2026, 9, 14);

    testWidgets('pads a locale pattern with single-letter fields', (
      WidgetTester tester,
    ) async {
      final BuildContext context = await pumpLocale(tester, 'de');

      expect(notifier.dateFormat(context).format(date), '14.09.2026');
      expect(notifier.dayFormat(context).format(date), '14.09.');
    });

    testWidgets('leaves an already padded locale pattern alone', (
      WidgetTester tester,
    ) async {
      final BuildContext context = await pumpLocale(tester, 'fr');

      expect(notifier.dateFormat(context).format(date), '14/09/2026');
      expect(notifier.dayFormat(context).format(date), '14/09');
    });

    testWidgets('keeps the day before the month in Italian', (
      WidgetTester tester,
    ) async {
      final BuildContext context = await pumpLocale(tester, 'it');

      expect(notifier.dateFormat(context).format(date), '14/09/2026');
      expect(notifier.dayFormat(context).format(date), '14/09');
    });
  });
}
