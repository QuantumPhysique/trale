/// Changelog data re-exported from quantumphysique and extended with
/// the app-specific [changelog] constant (see changelog.g.dart).
library;

// Import QP changelog types into this library scope (so changelog.g.dart part
// can use them), and also re-export them for callers of this library.
import 'package:quantumphysique/quantumphysique.dart'
    show Changelog, ChangelogEntry, ChangelogSection;
export 'package:quantumphysique/quantumphysique.dart'
    show Changelog, ChangelogEntry, ChangelogSection;

// The generated constant — a part file so it can use the types above.
part 'changelog.g.dart';
