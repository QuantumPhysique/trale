import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trale/core/gap.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/core/stringExtension.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/l10n-gen/app_localizations.dart';
import 'package:trale/widget/customSliverAppBar.dart';
import 'package:url_launcher/url_launcher_string.dart';


/// launch url
Future<void> _launchURL(String url) async {
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url);
  } else {
    throw 'Could not launch $url';
  }
}


/// ListTile for changing Amoled settings
class OnBoardingListTile extends StatelessWidget {
  /// constructor
  const OnBoardingListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: AutoSizeText(
        AppLocalizations.of(context)!.faq_a2_widget,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: 1,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
      ),
      trailing: IconButton(
        icon: PPIcon(PhosphorIconsDuotone.signOut, context),
        onPressed: () {
          Provider.of<TraleNotifier>(
              context, listen: false
          ).showOnBoarding = true;
          // leave settings
          Navigator.of(context).pop();
        },
      ),
    );
  }
}


/// class for listing 3rd party licences
class FAQEntry {
  /// constructor
  FAQEntry({
    required this.question,
    required this.answer,
    this.answerWidget,
  });

  /// get list representation of tpl
  Widget toWidget(BuildContext context) => Column(
    children: <Widget>[
      Container(
        padding: EdgeInsets.fromLTRB(
          TraleTheme.of(context)!.padding,
          TraleTheme.of(context)!.padding,
          TraleTheme.of(context)!.padding,
          0,
        ),
        width: MediaQuery.of(context).size.width,
        child: Text(
          'Q: $question',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.justify,
        ),
      ),
      Container(
        padding: EdgeInsets.all(
          TraleTheme.of(context)!.padding,
        ),
        width: MediaQuery.of(context).size.width,
        child: Text(
          'A: $answer',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.justify,
        ),
      ),
      if (answerWidget != null)
        answerWidget!
    ]
  );

  /// name of package
  final String question;
  /// name of url
  final String answer;
  /// license
  final Widget? answerWidget;
}

/// about screen widget class
class FAQ extends StatefulWidget {
  const FAQ({super.key});

  @override
  _FAQ createState() => _FAQ();
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
      FAQEntry(
        question: AppLocalizations.of(context)!.faq_q2,
        answer: AppLocalizations.of(context)!.faq_a2,
        answerWidget: const OnBoardingListTile(),
      ),
      FAQEntry(
        question: AppLocalizations.of(context)!.faq_q3,
        answer: AppLocalizations.of(context)!.faq_a3,
      ),
    ];

    Widget faqList() {
      return ListView(
        padding: EdgeInsets.all(TraleTheme.of(context)!.padding),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(TraleTheme.of(context)!.padding),
            child: Text(
              AppLocalizations.of(context)!.faqtext,
              textAlign: TextAlign.justify,
            ),
          ),
          ListTile(
            dense: true,
            title: AutoSizeText(
              AppLocalizations.of(context)!.openIssue.allInCaps,
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 1,
            ),
            trailing: PPIcon( PhosphorIconsDuotone.githubLogo, context),
            onTap: () => _launchURL(
                'https://github.com/quantumphysique/trale/'
            ),
          ),
          Divider(height: 2 * TraleTheme.of(context)!.padding),
          ...<Widget>[
            for (final FAQEntry faq in faqEntries)
              faq.toWidget(context),
          ].addDivider(
            padding: 2 * TraleTheme.of(context)!.padding,
          ),
        ],
      );
    }

    Widget appBar() {
      return CustomSliverAppBar(
        title: AutoSizeText(
          AppLocalizations.of(context)!.faq.allInCaps,
          style: Theme.of(context).textTheme.headlineMedium,
          maxLines: 1,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(PhosphorIconsRegular.arrowLeft),
        ),
      );
    }

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Scaffold(
            body:  NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool _) {
                return <Widget>[appBar()];
              },
              body: faqList(),
            ),
        ),
      ),
    );
  }
}
