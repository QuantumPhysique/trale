import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:trale/core/gap.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/core/stringExtension.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/traleNotifier.dart';
import 'package:trale/widget/customSliverAppBar.dart';


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
  const OnBoardingListTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: AutoSizeText(
        AppLocalizations.of(context)!.factoryReset,
        style: Theme.of(context).textTheme.bodyText1,
        maxLines: 1,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 2 * TraleTheme.of(context)!.padding,
      ),
      subtitle: AutoSizeText(
        AppLocalizations.of(context)!.factoryResetSubtitle,
        style: Theme.of(context).textTheme.overline,
      ),
      trailing: IconButton(
        icon: const Icon(CustomIcons.events),
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
      Padding(
        padding: EdgeInsets.fromLTRB(
          TraleTheme.of(context)!.padding,
          TraleTheme.of(context)!.padding,
          TraleTheme.of(context)!.padding,
          0,
        ),
        child: Text(
          'Q: $question',
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.justify,
        ),
      ),
      Padding(
        padding: EdgeInsets.all(
          TraleTheme.of(context)!.padding,
        ),
        child: Text(
          'A: $answer',
          style: Theme.of(context).textTheme.bodyText1,
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
  @override
  _FAQ createState() => _FAQ();
}

class _FAQ extends State<FAQ> {
  @override
  Widget build(BuildContext context) {
    /// list of questions and answers
    final List<FAQEntry> faqentries = <FAQEntry>[
      FAQEntry(
        question: AppLocalizations.of(context)!.faq_q1,
        answer: AppLocalizations.of(context)!.faq_a1,
      ),
      FAQEntry(
        question: 'The feature X is missing. When will it be implemented?',
        answer: 'Probably never. This app was created in our free time. '
            'If you miss a feature feel free to open an issue or implement '
            'on your own.'
        ,
        answerWidget: const OnBoardingListTile(),
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
          Divider(height: 2 * TraleTheme.of(context)!.padding),
          ...<Widget>[
            for (FAQEntry faq in faqentries)
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
          style: Theme.of(context).textTheme.headline4,
          maxLines: 1,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(CustomIcons.back),
        ),
      );
    }

    return Container(
      color: Theme.of(context).backgroundColor,
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
