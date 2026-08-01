// Driver for the screenshot tour.
//
// Mirrors test_driver/integration_test.dart but writes to the repo-root
// screenshots/ directory instead of app/screenshots/, and treats slashes in a
// screenshot name as directories so the tour can group its output by theme and
// brightness (e.g. `berry/dark/02_stats` → screenshots/berry/dark/02_stats.png).
//
// Usage (from app/):
//   flutter drive \
//     --driver=test_driver/screenshot_driver.dart \
//     --target=integration_test/screenshots_test.dart \
//     --device-id=<device-id>

import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() => integrationDriver(
  onScreenshot:
      (String name, List<int> bytes, [Map<String, Object?>? args]) async {
        final File file = File('../screenshots/$name.png');
        file.parent.createSync(recursive: true);
        file.writeAsBytesSync(bytes);
        return true;
      },
);
