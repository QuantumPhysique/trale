import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/font.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/core/stringExtension.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/pages/onBoarding.dart';
import 'package:trale/widget/customScrollViewSnapping.dart';
import 'package:trale/widget/settingsBanner.dart';
import 'package:trale/widget/tile_group.dart';

/// ListTile for changing Amoled settings
class OnBoardingListTile extends StatelessWidget {
  /// constructor
  const OnBoardingListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: GroupedListTile(
        color: Theme.of(context).colorScheme.primaryContainer,
        title: Text(
          AppLocalizations.of(context)!.faq_a2_widget,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        leading: PPIcon(PhosphorIconsRegular.signOut, context),
      ),
      onTap: () {
        Provider.of<TraleNotifier>(context, listen: false).showOnBoarding =
            true;
        // leave settings; pop twice to get back to home
        Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
        Navigator.of(context).push(
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => const OnBoardingPage(),
          ),
        );
      },
    );
  }
}

/// class for listing 3rd party licences
class FAQEntry {
  /// constructor
  FAQEntry({required this.question, required this.answer, this.answerWidget});

  /// get list representation of tpl
  Widget toWidget(BuildContext context) => WidgetGroup(
    children: <Widget>[
      GroupedListTile(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        leading: PPIcon(PhosphorIconsDuotone.question, context),
        title: Text(
          question,
          style: Theme.of(context).textTheme.emphasized.bodyMedium!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      GroupedListTile(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        leading: PPIcon(PhosphorIconsDuotone.chatCircleDots, context),
        title: Text(
          answer,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.justify,
        ),
      ),
      ?answerWidget,
    ],
  );

  /// name of package
  final String question;

  /// name of url
  final String answer;

  /// license
  final Widget? answerWidget;
}

/// FAQ page widget.
class FAQ extends StatefulWidget {
  /// Constructor.
  const FAQ({super.key});

  @override
  State<FAQ> createState() => _FAQ();
}

class _FAQ extends State<FAQ> {
  @override
  Widget build(BuildContext context) {
    /// list of questions and answers
    final List<FAQEntry> faqEntries = <FAQEntry>[
      FAQEntry(
        question: AppLocalizations.of(context)!.faq_q1,
        answer: AppLocalizations.of(context)!.faq_a1,
      ),
      // FAQEntry(
      //   question: AppLocalizations.of(context)!.faq_q2,
      //   answer: AppLocalizations.of(context)!.faq_a2,
      //   answerWidget: const OnBoardingListTile(),
      // ),
      FAQEntry(
        question: AppLocalizations.of(context)!.faq_q4,
        answer: AppLocalizations.of(context)!.faq_a4,
      ),
      FAQEntry(
        question: AppLocalizations.of(context)!.faq_q3,
        answer: AppLocalizations.of(context)!.faq_a3,
      ),
    ];

    List<Widget> faqList() {
      return <Widget>[
        SettingsBanner(
          leadingIcon: PhosphorIconsBold.githubLogo,
          title: AppLocalizations.of(context)!.openIssue.allInCaps,
          subtitle: AppLocalizations.of(context)!.openIssueSubtitle,
          url: 'https://github.com/quantumphysique/trale/',
        ),
        SizedBox(height: 2 * TraleTheme.of(context)!.padding),
        SizedBox(height: TraleTheme.of(context)!.padding),
        ...<Widget>[
          for (final FAQEntry faq in faqEntries) faq.toWidget(context),
        ],
      ];
    }

    return Scaffold(
      body: SliverAppBarSnap(
        title: AppLocalizations.of(context)!.faq.allInCaps,
        sliverlist: faqList(),
      ),
    );
  }
}
