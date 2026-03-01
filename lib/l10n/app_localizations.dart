import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Lifecast'**
  String get appTitle;

  /// No description provided for @heroTitlePrefix.
  ///
  /// In en, this message translates to:
  /// **'Simulate Your\n'**
  String get heroTitlePrefix;

  /// No description provided for @heroTitleSuffix.
  ///
  /// In en, this message translates to:
  /// **'Future Life'**
  String get heroTitleSuffix;

  /// No description provided for @heroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See exactly where your habits lead.\nYour choices, visualized 10 years forward.'**
  String get heroSubtitle;

  /// No description provided for @engineLabel.
  ///
  /// In en, this message translates to:
  /// **'AI-POWERED LIFE ENGINE'**
  String get engineLabel;

  /// No description provided for @simFeatureMoney.
  ///
  /// In en, this message translates to:
  /// **'Money Growth'**
  String get simFeatureMoney;

  /// No description provided for @simFeatureMoneySub.
  ///
  /// In en, this message translates to:
  /// **'Projected wealth'**
  String get simFeatureMoneySub;

  /// No description provided for @simFeatureCognitive.
  ///
  /// In en, this message translates to:
  /// **'Cognitive Peak'**
  String get simFeatureCognitive;

  /// No description provided for @simFeatureCognitiveSub.
  ///
  /// In en, this message translates to:
  /// **'Skill mastery'**
  String get simFeatureCognitiveSub;

  /// No description provided for @simFeatureVitality.
  ///
  /// In en, this message translates to:
  /// **'Vitality Index'**
  String get simFeatureVitality;

  /// No description provided for @simFeatureVitalitySub.
  ///
  /// In en, this message translates to:
  /// **'Health longevity'**
  String get simFeatureVitalitySub;

  /// No description provided for @simFeatureCareer.
  ///
  /// In en, this message translates to:
  /// **'Career Trajectory'**
  String get simFeatureCareer;

  /// No description provided for @simFeatureCareerSub.
  ///
  /// In en, this message translates to:
  /// **'Salary growth'**
  String get simFeatureCareerSub;

  /// No description provided for @simFeatureSocial.
  ///
  /// In en, this message translates to:
  /// **'Social Capital'**
  String get simFeatureSocial;

  /// No description provided for @simFeatureSocialSub.
  ///
  /// In en, this message translates to:
  /// **'Your network strength'**
  String get simFeatureSocialSub;

  /// No description provided for @startSimulation.
  ///
  /// In en, this message translates to:
  /// **'Start Simulation'**
  String get startSimulation;

  /// No description provided for @projection.
  ///
  /// In en, this message translates to:
  /// **'Projection'**
  String get projection;

  /// No description provided for @lifeModules.
  ///
  /// In en, this message translates to:
  /// **'Life Modules'**
  String get lifeModules;

  /// No description provided for @scenarios.
  ///
  /// In en, this message translates to:
  /// **'Scenarios'**
  String get scenarios;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
