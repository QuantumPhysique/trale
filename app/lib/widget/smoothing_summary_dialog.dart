import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trale/core/constants.dart';
import 'package:trale/core/l10n_extension.dart';
import 'package:trale/core/smoothing_summary.dart';

/// Shows what the smoothing learned from the user's diary, for them to share.
Future<void> showSmoothingSummaryDialog({
  required BuildContext context,
  required SmoothingSummary summary,
}) async {
  await showDialog<void>(
    context: context,
    builder: (BuildContext context) => QPDialog(
      title: context.l10n.smoothingSummary,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(context.l10n.smoothingSummaryExplanation),
          const SizedBox(height: QPLayout.smallPadding),
          const SelectableText(smoothingDiscussionUrl),
          const SizedBox(height: QPLayout.padding),
          SelectableText(
            summary.toText(),
            style: Theme.of(context).textTheme.monospace.bodySmall,
          ),
        ],
      ),
      actions: <Widget>[
        QPDialogAction(
          onPressed: () => Navigator.pop(context),
          icon: PhosphorIconsRegular.x,
          label: context.l10n.close,
        ),
        QPDialogAction(
          onPressed: () => SharePlus.instance.share(
            ShareParams(text: '${summary.toText()}\n\n$smoothingDiscussionUrl'),
          ),
          icon: PhosphorIconsRegular.shareNetwork,
          label: context.l10n.share,
          isPrimary: true,
        ),
      ],
    ),
  );
}
