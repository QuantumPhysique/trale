import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/l10n_extension.dart';
import 'package:trale/core/trale_notifier.dart';

/// Banner inviting the user to star the repository on GitHub.
///
/// Disappears for good once it has been tapped.
class GithubStarBanner extends StatelessWidget {
  /// Constructor.
  const GithubStarBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final double padding = QPTheme.of(context)!.padding;

    return Consumer<TraleNotifier>(
      builder: (BuildContext ctx, TraleNotifier notifier, Widget? _) =>
          notifier.showGithubStarBanner
          ? Padding(
              padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
              child: QPSettingsBanner(
                leadingIcon: PhosphorIconsBold.star,
                title: l10n.starOnGithub.allInCaps,
                subtitle: l10n.starOnGithubSubtitle,
                url: 'https://github.com/quantumphysique/trale',
                onTap: () => notifier.showGithubStarBanner = false,
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
