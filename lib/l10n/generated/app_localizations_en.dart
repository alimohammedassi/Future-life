// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Lifecast';

  @override
  String get heroTitlePrefix => 'Simulate Your\n';

  @override
  String get heroTitleSuffix => 'Future Life';

  @override
  String get heroSubtitle =>
      'See exactly where your habits lead.\nYour choices, visualized 10 years forward.';

  @override
  String get engineLabel => 'AI-POWERED LIFE ENGINE';

  @override
  String get simFeatureMoney => 'Money Growth';

  @override
  String get simFeatureMoneySub => 'Projected wealth';

  @override
  String get simFeatureCognitive => 'Cognitive Peak';

  @override
  String get simFeatureCognitiveSub => 'Skill mastery';

  @override
  String get simFeatureVitality => 'Vitality Index';

  @override
  String get simFeatureVitalitySub => 'Health longevity';

  @override
  String get simFeatureCareer => 'Career Trajectory';

  @override
  String get simFeatureCareerSub => 'Salary growth';

  @override
  String get simFeatureSocial => 'Social Capital';

  @override
  String get simFeatureSocialSub => 'Your network strength';

  @override
  String get startSimulation => 'Start Simulation';

  @override
  String get projection => 'Projection';

  @override
  String get lifeModules => 'Life Modules';

  @override
  String get scenarios => 'Scenarios';

  @override
  String get language => 'Language';

  @override
  String get inputTitle => 'LIFE PARAMETERS';

  @override
  String get inputSubtitle => 'Setup Your Future';

  @override
  String get trajectory => 'TRAJECTORY';

  @override
  String get definePath => 'Define Your Path';

  @override
  String get liveProjection => 'LIVE • 10-YEAR PROJECTION';

  @override
  String get finances => 'FINANCES';

  @override
  String get monthlyIncome => 'Monthly Income';

  @override
  String get incomeHint => 'Post-tax monthly earnings';

  @override
  String get incomeErrorEmpty => 'Please enter your monthly income';

  @override
  String get incomeErrorInvalid => 'Please enter a valid income amount';

  @override
  String get savingRate => 'Saving Rate';

  @override
  String get savingLow => 'Low';

  @override
  String get savingModerate => 'Moderate';

  @override
  String get savingGood => 'Good';

  @override
  String get savingExcellent => 'Excellent';

  @override
  String get healthGrowth => 'HEALTH & GROWTH';

  @override
  String get study => 'Study';

  @override
  String get workout => 'Workout';

  @override
  String workoutDaysPerWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return '$count $_temp0 / week';
  }

  @override
  String get career => 'CAREER';

  @override
  String get careerSkills => 'Career & Skills';

  @override
  String get weeklySkillDev => 'Weekly Skill Dev.';

  @override
  String get certsPerYearLabel => 'Certs per Year';

  @override
  String get social => 'SOCIAL';

  @override
  String get socialNetworking => 'Social & Networking';

  @override
  String get socialMedia => 'Social Media';

  @override
  String get familyFriends => 'Family & Friends';

  @override
  String get networking => 'Networking';

  @override
  String get dayUnit => '/day';

  @override
  String get weekUnit => '/wk';

  @override
  String get simulateMyFuture => 'Simulate My Future';

  @override
  String get techField => 'Technology';

  @override
  String get healthField => 'Healthcare';

  @override
  String get financeField => 'Finance';

  @override
  String get artsField => 'Arts';

  @override
  String get eduField => 'Education';

  @override
  String get otherField => 'Other';

  @override
  String get resultsTitle => 'Future Dashboard';

  @override
  String get financial => 'Financial';

  @override
  String get highLiquidity => 'High liquidity strategy';

  @override
  String get knowledgeLabel => 'Knowledge';

  @override
  String get advancedCognitive => 'Advanced cognitive dev.';

  @override
  String iqRank(int percent) {
    return '$percent% IQ Rank';
  }

  @override
  String get healthLabel => 'Health';

  @override
  String get biomarkersPeak => 'Biomarkers in peak range';

  @override
  String vitalityScore(int percent) {
    return '$percent% Vitality';
  }

  @override
  String get careerGrowthLabel => 'Career Growth';

  @override
  String get multiplierTrajectory => 'Multiplier trajectory';

  @override
  String growthIndex(int percent) {
    return '$percent% Index';
  }

  @override
  String get socialBalanceLabel => 'Social Balance';

  @override
  String isolationRisk(int percent) {
    return 'Isolation Risk: $percent%';
  }

  @override
  String socialScore(int score) {
    return '$score/100';
  }

  @override
  String get compareScenario => 'Compare Another Scenario';

  @override
  String get predictionDisclaimer =>
      'Predictions are based on current market trends and\nsimulation parameters.';

  @override
  String get optimizedPath => 'SCENARIO: OPTIMIZED PATH';

  @override
  String strategyScore(int score) {
    return 'Life Strategy Score: $score/100';
  }

  @override
  String get futureIn => 'Your Future in ';

  @override
  String get oneMonth => '1 Month';

  @override
  String yearsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Years',
      one: 'Year',
    );
    return '$count $_temp0';
  }

  @override
  String get netWorth => 'Estimated Total Net Worth';

  @override
  String get projectedGrowth => 'Projected Growth';

  @override
  String get monthShort => 'M';

  @override
  String get yearShort => 'Y';

  @override
  String get simulatingFuture => 'Simulating your future...';

  @override
  String get noSimulationYet => 'No Simulation Yet';

  @override
  String get noSimulationSub =>
      'Run your first simulation to see your projected future here.';

  @override
  String get comparisonTitle => 'Scenario Comparison';

  @override
  String scenarioLabel(String id) {
    return 'SCENARIO $id';
  }

  @override
  String get detailedImpact => 'Detailed Impact';

  @override
  String get monthlySavingsLabel => 'Monthly Savings';

  @override
  String get healthIndexLabel => 'Health Index';

  @override
  String get knowledgeGrowthLabel => 'Knowledge Growth';

  @override
  String get linear => 'Linear';

  @override
  String get exponential => 'Exponential';

  @override
  String get switchToOptimized => 'Switch to Optimized Path';

  @override
  String get netWorthAt10 => 'Net Worth @ 10yrs';

  @override
  String get tenYearProjections => '10-Year Projections';

  @override
  String get currentLabel => 'Current';

  @override
  String get optimizedLabel => 'Optimized';

  @override
  String yearCountLabel(int count) {
    return 'Year $count';
  }

  @override
  String get runSimFirst => 'Run a simulation first to compare scenarios.';

  @override
  String get goToSimulation => 'Go to Simulation';

  @override
  String get addScenarioB => 'Add Scenario B';

  @override
  String get setupScenarioBSub =>
      'Set up a second scenario with different\nhabits to compare outcomes.';

  @override
  String get setupScenarioBTitle => 'Setup Scenario B';

  @override
  String get enterOptimizedHabits => 'Enter your optimized daily habits.';

  @override
  String incomeValueLabel(String currency, int value) {
    return 'Monthly Income: $currency$value';
  }

  @override
  String savingValueLabel(int percent) {
    return 'Saving: $percent%';
  }

  @override
  String studyValueLabel(String hours) {
    return 'Study: $hours hrs/day';
  }

  @override
  String workoutValueLabel(int days) {
    return 'Workout: $days days/week';
  }

  @override
  String get runScenarioB => 'Run Scenario B';

  @override
  String get navSimulation => 'Simulation';

  @override
  String get navInsights => 'Insights';

  @override
  String get navCompare => 'Compare';

  @override
  String get navProfile => 'Profile';

  @override
  String get simulatingBtn => 'Simulating…';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get loginSubtitle => 'Continue your journey to success.';

  @override
  String get signupTitle => 'Create Account';

  @override
  String get signupSubtitle => 'Start projecting your future today.';

  @override
  String get emailLabel => 'Email Address';

  @override
  String get emailHint => 'name@example.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => '••••••••';

  @override
  String get loginButton => 'Login';

  @override
  String get signupButton => 'Create Account';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign In';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Sign Up';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get authErrorInvalidEmail => 'Please enter a valid email';

  @override
  String get authErrorShortPassword => 'Password must be at least 6 characters';

  @override
  String get authErrorShortName => 'Name must be at least 2 characters';

  @override
  String get authErrorPasswordMismatch => 'Passwords do not match';

  @override
  String get authErrorEmpty => 'Field cannot be empty';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get fullNameHint => 'Your full name';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get alreadyHaveAccountPrefix => 'Already have an account? ';

  @override
  String get dontHaveAccountPrefix => "Don't have an account? ";

  @override
  String get signInLink => 'Sign In';

  @override
  String get signUpLink => 'Sign Up';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profileStrategies => 'Strategies';

  @override
  String get profileInsights => 'Insights';

  @override
  String get profileScenarios => 'Scenarios';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileAccount => 'Account';

  @override
  String get profileEditProfile => 'Edit Profile';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileChangePassword => 'Change Password';

  @override
  String get profileLogout => 'Log Out';

  @override
  String get profileNotLoggedInTitle => "You're not logged in";

  @override
  String get profileNotLoggedInSub =>
      'Sign in to view your profile and track your life strategies.';

  @override
  String get profileLoginBtn => 'Sign In to Continue';
}
