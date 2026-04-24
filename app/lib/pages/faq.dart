import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/l10n_extension.dart';

/// FAQ page widget.
class FAQ extends StatelessWidget {
  /// Constructor.
  const FAQ({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return QPFAQPage(
      title: l10n.faq.allInCaps,
      entries: <QPFAQEntry>[
        QPFAQEntry(question: l10n.faq_q1, answer: l10n.faq_a1),
        QPFAQEntry(question: l10n.faq_q4, answer: l10n.faq_a4),
        QPFAQEntry(question: l10n.faq_q3, answer: l10n.faq_a3),
      ],
      headerWidget: QPSettingsBanner(
        leadingIcon: PhosphorIconsBold.githubLogo,
        title: l10n.openIssue.allInCaps,
        subtitle: l10n.openIssueSubtitle,
        url: 'https://github.com/quantumphysique/trale/',
      ),
    );
  }
}
