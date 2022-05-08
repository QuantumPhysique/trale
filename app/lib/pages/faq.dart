import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:trale/core/gap.dart';
import 'package:trale/core/icons.dart';
import 'package:trale/core/stringExtension.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/widget/customSliverAppBar.dart';


/// launch url
Future<void> _launchURL(String url) async {
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url);
  } else {
    throw 'Could not launch $url';
  }
}

/// class for listing 3rd party licences
class FAQEntry {
  /// constructor
  FAQEntry({
    required this.question,
    required this.answer,
    this.answerWidget=const SizedBox.shrink(),
  });

  /// get list representation of tpl
  Widget toWidget(BuildContext context) => Container(
    padding: EdgeInsets.all(
      TraleTheme.of(context)!.padding,
    ),
    child: Column(
      children: <Widget>[
        Text(
          'Q: $question',
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.justify,
        ),
        SizedBox(height: TraleTheme.of(context)!.padding),
        Text(
          'A: $answer',
          style: Theme.of(context).textTheme.bodyText1,
          textAlign: TextAlign.justify,
        ),
        answerWidget,
      ]
    ),
  );

  /// name of package
  final String question;
  /// name of url
  final String answer;
  /// license
  final Widget answerWidget;
}

/// list of questions and answers
final List<FAQEntry> faqentries = <FAQEntry>[
  FAQEntry(
    question: 'The feature X is missing. When will it be implemented?',
    answer: 'Probably never. This app was created in our free time. '
        'If you miss a feature feel free to open an issue or implement '
        'on your own.'
    ,
  ),
  FAQEntry(
    question: 'The feature X is missing. When will it be implemented?',
    answer: 'Probably never. This app was created in our free time. '
      'If you miss a feature feel free to open an issue or implement '
      'on your own.'
    ,
  ),
];

/// about screen widget class
class FAQ extends StatefulWidget {
  @override
  _FAQ createState() => _FAQ();
}

class _FAQ extends State<FAQ> {
  @override
  Widget build(BuildContext context) {
    Widget faqList() {
      return ListView(
        padding: EdgeInsets.all(TraleTheme.of(context)!.padding),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(TraleTheme.of(context)!.padding),
            child: const Text(
              'This app completely respects your privacy. This means that we '
              'do not earn anything with it and we do not get error logs. If '
              'you are facing problems, please open an issue at GitLab.\n\n'
              'The purpose of this app is to provide a simple log of the '
              ' weight together with a short-term extrapolation. Nothing more,'
              ' but nothing less. Therefore, we do not plan to add fancy '
              'features.\n\n'
              'We are only two devs with little sparse time. If you like the '
              'work consider contributing or donating. \u{1F642}',
              textAlign: TextAlign.justify,
            ),
          ),
          Divider(height: 2 * TraleTheme.of(context)!.padding),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: TraleTheme.of(context)!.padding,
            ),
            child: AutoSizeText(
              AppLocalizations.of(context)!.faq.allInCaps,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline5,
              maxLines: 1,
            ),
          ),
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
