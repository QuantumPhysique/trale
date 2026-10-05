import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/duration_extension.dart';
import 'package:trale/l10n-gen/app_localizations.dart';

void main() {
  /// Runs [build] with the app's strings for [locale].
  Future<String> inLocale(
    WidgetTester tester,
    String locale,
    String Function(BuildContext context) build,
  ) async {
    late String result;
    await tester.pumpWidget(
      Localizations(
        locale: Locale(locale),
        delegates: AppLocalizations.localizationsDelegates,
        child: Builder(
          builder: (BuildContext context) {
            result = build(context);
            return const SizedBox();
          },
        ),
      ),
    );
    return result;
  }

  /// Formats [days] as a duration in [locale].
  Future<String> format(WidgetTester tester, String locale, int days) =>
      inLocale(
        tester,
        locale,
        (BuildContext context) =>
            Duration(days: days).durationToString(context),
      );

  testWidgets('a single day is not counted in the plural', (
    WidgetTester tester,
  ) async {
    expect(await format(tester, 'en', 1), '1 day');
    expect(await format(tester, 'en', 2), '2 days');
    expect(await format(tester, 'de', 1), '1 Tag');
    expect(await format(tester, 'de', 2), '2 Tage');
  });

  testWidgets('the longer units follow the count', (WidgetTester tester) async {
    expect(await format(tester, 'en', 42), '6 weeks');
    expect(await format(tester, 'en', 120), '4 months');
    expect(await format(tester, 'en', 5 * 365), '5 years');
  });
}
