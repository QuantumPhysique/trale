// Standard integration-test driver.
//
// Receives screenshots from the test via the method channel and writes them
// to app/screenshots/ on the host filesystem so they can be uploaded as CI
// artifacts.
//
// Usage (from app/):
//   flutter drive \
//     --driver=test_driver/integration_test.dart \
//     --target=integration_test/smoke_test.dart \
//     --device-id=<device-id>

import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() => integrationDriver(
  onScreenshot:
      (String name, List<int> bytes, [Map<String, Object?>? args]) async {
        final Directory dir = Directory('screenshots');
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }
        File('screenshots/$name.png').writeAsBytesSync(bytes);
        return true;
      },
);
