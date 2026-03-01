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
/// import 'generated/app_localizations.dart';
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

  /// No description provided for @inputTitle.
  ///
  /// In en, this message translates to:
  /// **'LIFE PARAMETERS'**
  String get inputTitle;

  /// No description provided for @inputSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Setup Your Future'**
  String get inputSubtitle;

  /// No description provided for @trajectory.
  ///
  /// In en, this message translates to:
  /// **'TRAJECTORY'**
  String get trajectory;

  /// No description provided for @definePath.
  ///
  /// In en, this message translates to:
  /// **'Define Your Path'**
  String get definePath;

  /// No description provided for @liveProjection.
  ///
  /// In en, this message translates to:
  /// **'LIVE • 10-YEAR PROJECTION'**
  String get liveProjection;

  /// No description provided for @finances.
  ///
  /// In en, this message translates to:
  /// **'FINANCES'**
  String get finances;

  /// No description provided for @monthlyIncome.
  ///
  /// In en, this message translates to:
  /// **'Monthly Income'**
  String get monthlyIncome;

  /// No description provided for @incomeHint.
  ///
  /// In en, this message translates to:
  /// **'Post-tax monthly earnings'**
  String get incomeHint;

  /// No description provided for @incomeErrorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your monthly income'**
  String get incomeErrorEmpty;

  /// No description provided for @incomeErrorInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid income amount'**
  String get incomeErrorInvalid;

  /// No description provided for @savingRate.
  ///
  /// In en, this message translates to:
  /// **'Saving Rate'**
  String get savingRate;

  /// No description provided for @savingLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get savingLow;

  /// No description provided for @savingModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get savingModerate;

  /// No description provided for @savingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get savingGood;

  /// No description provided for @savingExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get savingExcellent;

  /// No description provided for @healthGrowth.
  ///
  /// In en, this message translates to:
  /// **'HEALTH & GROWTH'**
  String get healthGrowth;

  /// No description provided for @study.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get study;

  /// No description provided for @workout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workout;

  /// No description provided for @workoutDaysPerWeek.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{day} other{days}} / week'**
  String workoutDaysPerWeek(int count);

  /// No description provided for @career.
  ///
  /// In en, this message translates to:
  /// **'CAREER'**
  String get career;

  /// No description provided for @careerSkills.
  ///
  /// In en, this message translates to:
  /// **'Career & Skills'**
  String get careerSkills;

  /// No description provided for @weeklySkillDev.
  ///
  /// In en, this message translates to:
  /// **'Weekly Skill Dev.'**
  String get weeklySkillDev;

  /// No description provided for @certsPerYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Certs per Year'**
  String get certsPerYearLabel;

  /// No description provided for @social.
  ///
  /// In en, this message translates to:
  /// **'SOCIAL'**
  String get social;

  /// No description provided for @socialNetworking.
  ///
  /// In en, this message translates to:
  /// **'Social & Networking'**
  String get socialNetworking;

  /// No description provided for @socialMedia.
  ///
  /// In en, this message translates to:
  /// **'Social Media'**
  String get socialMedia;

  /// No description provided for @familyFriends.
  ///
  /// In en, this message translates to:
  /// **'Family & Friends'**
  String get familyFriends;

  /// No description provided for @networking.
  ///
  /// In en, this message translates to:
  /// **'Networking'**
  String get networking;

  /// No description provided for @dayUnit.
  ///
  /// In en, this message translates to:
  /// **'/day'**
  String get dayUnit;

  /// No description provided for @weekUnit.
  ///
  /// In en, this message translates to:
  /// **'/wk'**
  String get weekUnit;

  /// No description provided for @simulateMyFuture.
  ///
  /// In en, this message translates to:
  /// **'Simulate My Future'**
  String get simulateMyFuture;

  /// No description provided for @techField.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get techField;

  /// No description provided for @healthField.
  ///
  /// In en, this message translates to:
  /// **'Healthcare'**
  String get healthField;

  /// No description provided for @financeField.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get financeField;

  /// No description provided for @artsField.
  ///
  /// In en, this message translates to:
  /// **'Arts'**
  String get artsField;

  /// No description provided for @eduField.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get eduField;

  /// No description provided for @otherField.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherField;

  /// No description provided for @resultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Future Dashboard'**
  String get resultsTitle;

  /// No description provided for @financial.
  ///
  /// In en, this message translates to:
  /// **'Financial'**
  String get financial;

  /// No description provided for @highLiquidity.
  ///
  /// In en, this message translates to:
  /// **'High liquidity strategy'**
  String get highLiquidity;

  /// No description provided for @knowledgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Knowledge'**
  String get knowledgeLabel;

  /// No description provided for @advancedCognitive.
  ///
  /// In en, this message translates to:
  /// **'Advanced cognitive dev.'**
  String get advancedCognitive;

  /// No description provided for @iqRank.
  ///
  /// In en, this message translates to:
  /// **'{percent}% IQ Rank'**
  String iqRank(int percent);

  /// No description provided for @healthLabel.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get healthLabel;

  /// No description provided for @biomarkersPeak.
  ///
  /// In en, this message translates to:
  /// **'Biomarkers in peak range'**
  String get biomarkersPeak;

  /// No description provided for @vitalityScore.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Vitality'**
  String vitalityScore(int percent);

  /// No description provided for @careerGrowthLabel.
  ///
  /// In en, this message translates to:
  /// **'Career Growth'**
  String get careerGrowthLabel;

  /// No description provided for @multiplierTrajectory.
  ///
  /// In en, this message translates to:
  /// **'Multiplier trajectory'**
  String get multiplierTrajectory;

  /// No description provided for @growthIndex.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Index'**
  String growthIndex(int percent);

  /// No description provided for @socialBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Social Balance'**
  String get socialBalanceLabel;

  /// No description provided for @isolationRisk.
  ///
  /// In en, this message translates to:
  /// **'Isolation Risk: {percent}%'**
  String isolationRisk(int percent);

  /// No description provided for @socialScore.
  ///
  /// In en, this message translates to:
  /// **'{score}/100'**
  String socialScore(int score);

  /// No description provided for @compareScenario.
  ///
  /// In en, this message translates to:
  /// **'Compare Another Scenario'**
  String get compareScenario;

  /// No description provided for @predictionDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Predictions are based on current market trends and\nsimulation parameters.'**
  String get predictionDisclaimer;

  /// No description provided for @optimizedPath.
  ///
  /// In en, this message translates to:
  /// **'SCENARIO: OPTIMIZED PATH'**
  String get optimizedPath;

  /// No description provided for @strategyScore.
  ///
  /// In en, this message translates to:
  /// **'Life Strategy Score: {score}/100'**
  String strategyScore(int score);

  /// No description provided for @futureIn.
  ///
  /// In en, this message translates to:
  /// **'Your Future in '**
  String get futureIn;

  /// No description provided for @oneMonth.
  ///
  /// In en, this message translates to:
  /// **'1 Month'**
  String get oneMonth;

  /// No description provided for @yearsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{Year} other{Years}}'**
  String yearsCount(int count);

  /// No description provided for @netWorth.
  ///
  /// In en, this message translates to:
  /// **'Estimated Total Net Worth'**
  String get netWorth;

  /// No description provided for @projectedGrowth.
  ///
  /// In en, this message translates to:
  /// **'Projected Growth'**
  String get projectedGrowth;

  /// No description provided for @monthShort.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get monthShort;

  /// No description provided for @yearShort.
  ///
  /// In en, this message translates to:
  /// **'Y'**
  String get yearShort;

  /// No description provided for @simulatingFuture.
  ///
  /// In en, this message translates to:
  /// **'Simulating your future...'**
  String get simulatingFuture;

  /// No description provided for @noSimulationYet.
  ///
  /// In en, this message translates to:
  /// **'No Simulation Yet'**
  String get noSimulationYet;

  /// No description provided for @noSimulationSub.
  ///
  /// In en, this message translates to:
  /// **'Run your first simulation to see your projected future here.'**
  String get noSimulationSub;

  /// No description provided for @comparisonTitle.
  ///
  /// In en, this message translates to:
  /// **'Scenario Comparison'**
  String get comparisonTitle;

  /// No description provided for @scenarioLabel.
  ///
  /// In en, this message translates to:
  /// **'SCENARIO {id}'**
  String scenarioLabel(String id);

  /// No description provided for @detailedImpact.
  ///
  /// In en, this message translates to:
  /// **'Detailed Impact'**
  String get detailedImpact;

  /// No description provided for @monthlySavingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly Savings'**
  String get monthlySavingsLabel;

  /// No description provided for @healthIndexLabel.
  ///
  /// In en, this message translates to:
  /// **'Health Index'**
  String get healthIndexLabel;

  /// No description provided for @knowledgeGrowthLabel.
  ///
  /// In en, this message translates to:
  /// **'Knowledge Growth'**
  String get knowledgeGrowthLabel;

  /// No description provided for @linear.
  ///
  /// In en, this message translates to:
  /// **'Linear'**
  String get linear;

  /// No description provided for @exponential.
  ///
  /// In en, this message translates to:
  /// **'Exponential'**
  String get exponential;

  /// No description provided for @switchToOptimized.
  ///
  /// In en, this message translates to:
  /// **'Switch to Optimized Path'**
  String get switchToOptimized;

  /// No description provided for @netWorthAt10.
  ///
  /// In en, this message translates to:
  /// **'Net Worth @ 10yrs'**
  String get netWorthAt10;

  /// No description provided for @tenYearProjections.
  ///
  /// In en, this message translates to:
  /// **'10-Year Projections'**
  String get tenYearProjections;

  /// No description provided for @currentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get currentLabel;

  /// No description provided for @optimizedLabel.
  ///
  /// In en, this message translates to:
  /// **'Optimized'**
  String get optimizedLabel;

  /// No description provided for @yearCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Year {count}'**
  String yearCountLabel(int count);

  /// No description provided for @runSimFirst.
  ///
  /// In en, this message translates to:
  /// **'Run a simulation first to compare scenarios.'**
  String get runSimFirst;

  /// No description provided for @goToSimulation.
  ///
  /// In en, this message translates to:
  /// **'Go to Simulation'**
  String get goToSimulation;

  /// No description provided for @addScenarioB.
  ///
  /// In en, this message translates to:
  /// **'Add Scenario B'**
  String get addScenarioB;

  /// No description provided for @setupScenarioBSub.
  ///
  /// In en, this message translates to:
  /// **'Set up a second scenario with different\nhabits to compare outcomes.'**
  String get setupScenarioBSub;

  /// No description provided for @setupScenarioBTitle.
  ///
  /// In en, this message translates to:
  /// **'Setup Scenario B'**
  String get setupScenarioBTitle;

  /// No description provided for @enterOptimizedHabits.
  ///
  /// In en, this message translates to:
  /// **'Enter your optimized daily habits.'**
  String get enterOptimizedHabits;

  /// No description provided for @incomeValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly Income: {currency}{value}'**
  String incomeValueLabel(String currency, int value);

  /// No description provided for @savingValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Saving: {percent}%'**
  String savingValueLabel(int percent);

  /// No description provided for @studyValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Study: {hours} hrs/day'**
  String studyValueLabel(String hours);

  /// No description provided for @workoutValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Workout: {days} days/week'**
  String workoutValueLabel(int days);

  /// No description provided for @runScenarioB.
  ///
  /// In en, this message translates to:
  /// **'Run Scenario B'**
  String get runScenarioB;

  /// No description provided for @navSimulation.
  ///
  /// In en, this message translates to:
  /// **'Simulation'**
  String get navSimulation;

  /// No description provided for @navInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get navInsights;

  /// No description provided for @navCompare.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get navCompare;

  /// No description provided for @simulatingBtn.
  ///
  /// In en, this message translates to:
  /// **'Simulating…'**
  String get simulatingBtn;
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
