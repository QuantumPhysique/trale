import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bg.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_et.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_lt.dart';
import 'app_localizations_nb.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sk.dart';
import 'app_localizations_sl.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n-gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bg'),
    Locale('cs'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('et'),
    Locale('fi'),
    Locale('fr'),
    Locale('hr'),
    Locale('it'),
    Locale('ko'),
    Locale('lt'),
    Locale('nb'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('sk'),
    Locale('sl'),
    Locale('ta'),
    Locale('tr'),
    Locale('uk'),
    Locale('vi'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// achievements
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// Label for experimental features section
  ///
  /// In en, this message translates to:
  /// **'experimental features'**
  String get experimentalFeatures;

  /// Lose weight switch label (label name loose is a typo!).
  ///
  /// In en, this message translates to:
  /// **'Lose weight'**
  String get looseWeight;

  /// Gain weight switch label.
  ///
  /// In en, this message translates to:
  /// **'Gain weight'**
  String get gainWeight;

  /// Helper text shown in empty state calendar view
  ///
  /// In en, this message translates to:
  /// **'Tap a date above to add an entry.'**
  String get tapDateAboveToAddEntry;

  /// Switching between losing or gaining weight.
  ///
  /// In en, this message translates to:
  /// **'Switching between losing or gaining weight.'**
  String get looseWeightSubtitle;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @weeks.
  ///
  /// In en, this message translates to:
  /// **'weeks'**
  String get weeks;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'week'**
  String get week;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get months;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get month;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get year;

  /// Frequency of backup interval
  ///
  /// In en, this message translates to:
  /// **'never'**
  String get never;

  /// Frequency of backup interval
  ///
  /// In en, this message translates to:
  /// **'weekly'**
  String get weekly;

  /// Frequency of backup interval
  ///
  /// In en, this message translates to:
  /// **'biweekly'**
  String get biweekly;

  /// Frequency of backup interval
  ///
  /// In en, this message translates to:
  /// **'monthly'**
  String get monthly;

  /// Frequency of backup interval
  ///
  /// In en, this message translates to:
  /// **'quarterly'**
  String get quarterly;

  /// Please remember to back up your data regularly.
  ///
  /// In en, this message translates to:
  /// **'Please back up regularly'**
  String get backupReminder;

  /// Back up now
  ///
  /// In en, this message translates to:
  /// **'back up'**
  String get backupReminderButton;

  /// Back successfully exported
  ///
  /// In en, this message translates to:
  /// **'Backup successfully exported'**
  String get backupSuccess;

  /// Frequency of backup interval
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get backupInterval;

  /// Time of last backup
  ///
  /// In en, this message translates to:
  /// **'last backup'**
  String get lastBackup;

  /// Time of last backup
  ///
  /// In en, this message translates to:
  /// **'next backup'**
  String get nextBackup;

  /// Header for statistics section
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get stats;

  /// Name of app: trale
  ///
  /// In en, this message translates to:
  /// **'trale'**
  String get trale;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get unit;

  /// Date
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// weight
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// Name of user menu
  ///
  /// In en, this message translates to:
  /// **'User profile'**
  String get user;

  /// Settings to customize user experience
  ///
  /// In en, this message translates to:
  /// **'User settings'**
  String get userSettings;

  /// Settings which cannot be undone.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get dangerzone;

  /// Name of settings menu
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Frequently ask questions
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// Name of about menu section
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// System default language.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get defaultLang;

  /// Language menu item.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Theme menu item.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Dark mode menu item.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkmode;

  /// Light mode menu item.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightmode;

  /// System mode menu item.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemmode;

  /// Export all measurements
  ///
  /// In en, this message translates to:
  /// **'Export all measurements'**
  String get export;

  /// This exposes all measurements to all apps.
  ///
  /// In en, this message translates to:
  /// **'This exposes all measurements to all apps.'**
  String get exportSubtitle;

  /// This will export all measurements to the external storage. Writing permissions are needed.
  ///
  /// In en, this message translates to:
  /// **'This will export all measurements to the external storage. Writing permissions are needed.'**
  String get exportDialog;

  /// Open (file).
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// Abort (action).
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get abort;

  /// Import backup.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get import;

  /// Import measurements from txt backup file.
  ///
  /// In en, this message translates to:
  /// **'Import measurements from .txt backup file.'**
  String get importSubtitle;

  /// AMOLED
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get amoled;

  /// Change background color to true black for dark mode.
  ///
  /// In en, this message translates to:
  /// **'Change background color to true black for dark mode.'**
  String get amoledSubtitle;

  /// Factory reset app.
  ///
  /// In en, this message translates to:
  /// **'Reset app'**
  String get reset;

  /// Factory reset app.
  ///
  /// In en, this message translates to:
  /// **'Factory reset'**
  String get factoryReset;

  /// Reset all settings and delete all measurements.
  ///
  /// In en, this message translates to:
  /// **'Reset all settings and delete all measurements.'**
  String get factoryResetSubtitle;

  /// Reset application to default? This will delete all settings, and added measurements. This can not be undone.
  ///
  /// In en, this message translates to:
  /// **'Reset application to default? This will delete all settings, and added measurements. This can not be undone.'**
  String get factoryResetDialog;

  /// delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Import aborted.
  ///
  /// In en, this message translates to:
  /// **'Import cancelled.'**
  String get importingAbort;

  /// Include all measurements to the current database. This can not be undone!
  ///
  /// In en, this message translates to:
  /// **'Include all measurements to the current database. This can not be undone!'**
  String get importDialog;

  /// home screen
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// yes
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// ok
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// edit
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// backup
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// time
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// assets
  ///
  /// In en, this message translates to:
  /// **'assets'**
  String get assets;

  /// packages
  ///
  /// In en, this message translates to:
  /// **'packages'**
  String get packages;

  /// loading
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// measurements
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get measurements;

  /// version
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// third-party licences
  ///
  /// In en, this message translates to:
  /// **'Third-party licenses'**
  String get tpl;

  /// licence
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get licence;

  /// source code
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get sourcecode;

  /// open issue
  ///
  /// In en, this message translates to:
  /// **'Open issue'**
  String get openIssue;

  /// String to show third-party license.
  ///
  /// In en, this message translates to:
  /// **'© {years} by {author} under {licence} licence'**
  String undertpl(String years, String author, String licence);

  /// Enter your weight
  ///
  /// In en, this message translates to:
  /// **'Enter your weight'**
  String get addWeight;

  /// Enter your height
  ///
  /// In en, this message translates to:
  /// **'Enter your height'**
  String get addHeight;

  /// interpolation
  ///
  /// In en, this message translates to:
  /// **'interpolation'**
  String get interpolation;

  /// interpolation strength
  ///
  /// In en, this message translates to:
  /// **'strength'**
  String get strength;

  /// no interpolation
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// soft interpolation
  ///
  /// In en, this message translates to:
  /// **'Soft'**
  String get soft;

  /// medium interpolation
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// strong interpolation
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get strong;

  /// welcome
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Text of 1st onBoarding screen.
  ///
  /// In en, this message translates to:
  /// **'This simplistic Material-You-design app helps you to reach your dream weight! Whether you want to gain weight, lose weight or simply maintain your weight: Reliable weight predictions and versatile statistics help you to stay on track. \n\n Join our community today to trace yourself. \n🐺🤸‍♀️🏋‍♀️🧘‍♂️🏆🥇'**
  String get onBoarding1;

  /// Text of 2nd onBoarding screen.
  ///
  /// In en, this message translates to:
  /// **'Choose one out of six themes to personalize your app. Which one does express your feelings the best?'**
  String get onBoarding2;

  /// Text of 3rd onBoarding screen.
  ///
  /// In en, this message translates to:
  /// **'Thank you for giving our app a try. 🙂\n\n If you like the app, we would be very happy about your feedback, a contribution on Github or a coffee. In return, we spare you annoying and privacy-critical ads.'**
  String get onBoarding3;

  /// Title of 2nd onBoarding screen.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get onBoarding2Title;

  /// Title of 3rd onBoarding screen.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get onBoarding3Title;

  /// Skip onboarding screen.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Press to start the app.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startApp;

  /// Your target weight.
  ///
  /// In en, this message translates to:
  /// **'Target weight'**
  String get targetWeight;

  /// Explanation to clarify the importance of a target weight.
  ///
  /// In en, this message translates to:
  /// **'Setting a target weight is very important and a step in the right direction. Having a goal in mind motivates you to do more to achieve it.'**
  String get targetWeightMotivation;

  /// Short label to show for indicating target weight in line chart.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get targetWeightShort;

  /// How shall we call you?
  ///
  /// In en, this message translates to:
  /// **'How shall we call you?'**
  String get addUserName;

  /// Press to add a target weight.
  ///
  /// In en, this message translates to:
  /// **'Add target weight'**
  String get addTargetWeight;

  /// Start of 'press + to get started'
  ///
  /// In en, this message translates to:
  /// **'Press'**
  String get intro1;

  /// End of 'press + to get started'
  ///
  /// In en, this message translates to:
  /// **'to get started'**
  String get intro2;

  /// Text shown on statsOverview in case of no measurements
  ///
  /// In en, this message translates to:
  /// **'Today is a good day to start with your first measurement!'**
  String get intro3;

  /// Here you find answers to some of the most frequent questions. If you have any other questions, feel free to open an issue on the github repository.
  ///
  /// In en, this message translates to:
  /// **'Here you find answers to some of the most frequent questions. If you have any other questions, feel free to open an issue on the github repository.'**
  String get faqtext;

  /// The feature/function X is missing. When will it be implemented?
  ///
  /// In en, this message translates to:
  /// **'The feature/function X is missing. When will it be implemented?'**
  String get faq_q1;

  /// The app is maintained in our free time and we try to keep the app sleek and simple. We believe that adding to many features making the app less usable. If you believe that we are missing a key feature, feel free to open an issue or a merge request.
  ///
  /// In en, this message translates to:
  /// **'The app is maintained in our free time and we try to keep the app sleek and simple. We believe that adding too many features making the app less usable. If you believe that we are missing a key feature, feel free to open an issue or a merge request.'**
  String get faq_a1;

  /// Can I see once again the intro/onboarding screen?
  ///
  /// In en, this message translates to:
  /// **'Can I see once again the intro/onboarding screen?'**
  String get faq_q2;

  /// Yes for sure! Simple press the icon below.
  ///
  /// In en, this message translates to:
  /// **'Yes for sure! Just press the icon below.'**
  String get faq_a2;

  /// Return to onboarding screen
  ///
  /// In en, this message translates to:
  /// **'Return to onboarding screen'**
  String get faq_a2_widget;

  /// What is the app icon showing?
  ///
  /// In en, this message translates to:
  /// **'What is the app icon showing?'**
  String get faq_q3;

  /// It shows a wolf sitting an the letter 'r' and its tail is partially hidden by the letter 't'.
  ///
  /// In en, this message translates to:
  /// **'A howling wolf sitting, its tail partially hidden by the letter \'t\', and the letter \'r\'.'**
  String get faq_a3;

  /// Can I enter a target weight below 50kg / 110 lb / 7.9 st?
  ///
  /// In en, this message translates to:
  /// **'Can I enter a target weight below 50kg / 110 lb / 7.9 st?'**
  String get faq_q4;

  /// Yes, by providing your height.
  /// Anorexia is a serious disease that is increasingly becoming a problem for society as a whole, partly due to the many negative examples on social media. To support prevention efforts, we do not allow target weights below 50 kg / 110 lb / 7.9 st. Entering your height allows us to calculate a minimum target weight corresponding to a BMI of 18.5.
  ///
  /// In en, this message translates to:
  /// **'Yes, by providing your height.\n\nAnorexia is a serious disease that is increasingly becoming a problem for society as a whole, partly due to the many negative examples on social media. To support prevention efforts, we do not allow target weights below 50 kg / 110 lb / 7.9 st. Entering your height allows us to calculate a minimum target weight corresponding to a BMI of 18.5.'**
  String get faq_a4;

  /// Anorexia is a serious disease that is increasingly becoming a problem for society as a whole, partly due to the many negative examples on social media. To support prevention efforts, we do not allow target weights below  50 kg / 110 lb / 7.9 st and BMIs below 18.5.
  ///
  /// In en, this message translates to:
  /// **'Anorexia is a serious disease that is increasingly becoming a problem for society as a whole, partly due to the many negative examples on social media. To support prevention efforts, we do not allow target weights below 50 kg / 110 lb / 7.9 st and BMIs below 18.5.'**
  String get target_weight_warning;

  /// Shorthand for maximum.
  ///
  /// In en, this message translates to:
  /// **'max'**
  String get max;

  /// Shorthand for minimum.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get min;

  /// A short word describing a difference in numbers, i.e. the change of the weight
  ///
  /// In en, this message translates to:
  /// **'change'**
  String get change;

  /// The quantity describing the overall change of body weight
  ///
  /// In en, this message translates to:
  /// **'total change'**
  String get totalChange;

  /// (Color) scheme variant label.
  ///
  /// In en, this message translates to:
  /// **'scheme variant'**
  String get schemeVariant;

  /// The mathematical quantity (arithmetic mean)
  ///
  /// In en, this message translates to:
  /// **'mean'**
  String get mean;

  /// The frequency of measurements, i.e., how often the user measures their weight within a day on average
  ///
  /// In en, this message translates to:
  /// **'measurement frequency'**
  String get measurementFrequency;

  /// Message shown when the user reached their target weight.
  ///
  /// In en, this message translates to:
  /// **'you reached your target weight!'**
  String get targetWeightReached;

  /// Message shown when the user has not reached its target weight. Here, the sentence starts with 'x days/weeks/ left...'
  ///
  /// In en, this message translates to:
  /// **'left to reach target weight'**
  String get targetWeightReachedIn;

  /// The longest streak of measurements
  ///
  /// In en, this message translates to:
  /// **'longest streak'**
  String get maxStreak;

  /// The current streak of measurements
  ///
  /// In en, this message translates to:
  /// **'current streak'**
  String get currentStreak;

  /// A brief sentence describing the duration from the first measurement to the present
  ///
  /// In en, this message translates to:
  /// **'time since first measurement'**
  String get timeSinceFirstMeasurement;

  /// First displayed day of the week
  ///
  /// In en, this message translates to:
  /// **'First day'**
  String get firstDay;

  /// High contrast mode label (accessibility setting).
  ///
  /// In en, this message translates to:
  /// **'High contrast'**
  String get highContrast;

  /// No description provided for @bmi.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get bmi;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'bg',
    'cs',
    'de',
    'en',
    'es',
    'et',
    'fi',
    'fr',
    'hr',
    'it',
    'ko',
    'lt',
    'nb',
    'nl',
    'pl',
    'pt',
    'ru',
    'sk',
    'sl',
    'ta',
    'tr',
    'uk',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bg':
      return AppLocalizationsBg();
    case 'cs':
      return AppLocalizationsCs();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'et':
      return AppLocalizationsEt();
    case 'fi':
      return AppLocalizationsFi();
    case 'fr':
      return AppLocalizationsFr();
    case 'hr':
      return AppLocalizationsHr();
    case 'it':
      return AppLocalizationsIt();
    case 'ko':
      return AppLocalizationsKo();
    case 'lt':
      return AppLocalizationsLt();
    case 'nb':
      return AppLocalizationsNb();
    case 'nl':
      return AppLocalizationsNl();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'sk':
      return AppLocalizationsSk();
    case 'sl':
      return AppLocalizationsSl();
    case 'ta':
      return AppLocalizationsTa();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
