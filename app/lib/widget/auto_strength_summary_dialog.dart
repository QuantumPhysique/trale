import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trale/core/auto_strength.dart';
import 'package:trale/core/constants.dart';
import 'package:trale/core/l10n_extension.dart';
import 'package:trale/core/measurement_interpolation.dart';

/// Shows how the automatic strength fits the user's diary, for them to share.
Future<void> showAutoStrengthSummaryDialog({
  required BuildContext context,
}) async {
  final Future<AutoStrengthSummary> summary = MeasurementInterpolation()
      .autoStrengthSummary();
  await showDialog<void>(
    context: context,
    builder: (BuildContext context) => QPDialog(
      title: context.l10n.autoStrengthSummary,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(context.l10n.autoStrengthSummaryExplanation),
          const SizedBox(height: QPLayout.smallPadding),
          const SelectableText(autoStrengthDiscussionUrl),
          const SizedBox(height: QPLayout.padding),
          FutureBuilder<AutoStrengthSummary>(
            future: summary,
            builder:
                (
                  BuildContext context,
                  AsyncSnapshot<AutoStrengthSummary> snapshot,
                ) {
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return SelectableText(
                    snapshot.data!.toText(),
                    style: Theme.of(context).textTheme.monospace.bodySmall,
                  );
                },
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
          onPressed: () async {
            final AutoStrengthSummary result = await summary;
            await SharePlus.instance.share(
              ShareParams(
                text: '${result.toText()}\n\n$autoStrengthDiscussionUrl',
              ),
            );
          },
          icon: PhosphorIconsRegular.shareNetwork,
          label: context.l10n.share,
          isPrimary: true,
        ),
      ],
    ),
  );
}
