import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/health_connect_messages.dart';
import 'package:trale/core/health_connect_service.dart';
import 'package:trale/l10n-gen/app_localizations.dart';

// A Health Connect import used to report a bare count, so "Imported 0
// measurements." was shown whether Health Connect was missing, the read
// permission was withheld, the read threw, or there was genuinely nothing to
// import (github.com/QuantumPhysique/trale/issues/508). Every branch below is
// a failure mode that must stay distinguishable from an empty but successful
// import.
void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  group('import message', () {
    test('says nothing was found instead of counting zero', () {
      expect(
        healthConnectImportMessage(
          l10n,
          const HealthConnectImportResult(HealthConnectImportStatus.success),
        ),
        l10n.healthConnectImportNothingFound,
      );
    });

    test('distinguishes every failure from an empty import', () {
      final Map<HealthConnectImportStatus, String> expected =
          <HealthConnectImportStatus, String>{
            HealthConnectImportStatus.busy: l10n.healthConnectBusy,
            HealthConnectImportStatus.unavailable:
                l10n.healthConnectNotAvailable,
            HealthConnectImportStatus.missingPermission:
                l10n.healthConnectImportPermissionRequired,
            HealthConnectImportStatus.failed: l10n.healthConnectImportError,
          };

      for (final HealthConnectImportStatus status in expected.keys) {
        expect(
          healthConnectImportMessage(l10n, HealthConnectImportResult(status)),
          expected[status],
          reason: '$status must not read as an empty import',
        );
      }
    });
  });

  // Health Connect's 30-day cap and READ_HEALTH_DATA_HISTORY shipped together,
  // so "the feature is missing" and "the permission is missing" are opposite
  // outcomes: the first means the full history already came through.
  group('history cap', () {
    late int asked;

    Future<bool> alwaysTrue() async => true;
    Future<bool> alwaysFalse() async => false;

    setUp(() => asked = 0);

    Future<bool> grantOnRequest(bool granted) async {
      asked += 1;
      return granted;
    }

    test(
      'a Health Connect without the feature does not cap the read',
      () async {
        expect(
          await historyReadIsCapped(
            isFeatureAvailable: alwaysFalse,
            isGranted: alwaysFalse,
            requestAccess: () => grantOnRequest(true),
            request: true,
          ),
          isFalse,
          reason: 'no history feature means no 30-day cap to warn about',
        );
        expect(
          asked,
          0,
          reason: 'nothing to ask for when the feature is absent',
        );
      },
    );

    test('a withheld permission caps the read without asking', () async {
      expect(
        await historyReadIsCapped(
          isFeatureAvailable: alwaysTrue,
          isGranted: alwaysFalse,
          requestAccess: () => grantOnRequest(true),
          request: false,
        ),
        isTrue,
      );
      expect(asked, 0, reason: 'a background import must not raise a dialog');
    });

    test('granting on request lifts the cap', () async {
      expect(
        await historyReadIsCapped(
          isFeatureAvailable: alwaysTrue,
          isGranted: alwaysFalse,
          requestAccess: () => grantOnRequest(true),
          request: true,
        ),
        isFalse,
      );
      expect(asked, 1);
    });
  });
}
