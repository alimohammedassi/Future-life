// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'لايف كاست';

  @override
  String get heroTitlePrefix => 'حاكي\n';

  @override
  String get heroTitleSuffix => 'مستقبلك';

  @override
  String get heroSubtitle =>
      'شاهد إلى أين ستقودك عاداتك اليومية.\nخياراتك، متوقعة لعشر سنوات قادمة.';

  @override
  String get engineLabel => 'محرك حياة مدعوم بالذكاء الاصطناعي';

  @override
  String get simFeatureMoney => 'نمو المال';

  @override
  String get simFeatureMoneySub => 'ثروتك المتوقعة';

  @override
  String get simFeatureCognitive => 'قمة الإدراك';

  @override
  String get simFeatureCognitiveSub => 'إتقان المهارات';

  @override
  String get simFeatureVitality => 'مؤشر الحيوية';

  @override
  String get simFeatureVitalitySub => 'الصحة وطول العمر';

  @override
  String get simFeatureCareer => 'المسار المهني';

  @override
  String get simFeatureCareerSub => 'نمو الراتب';

  @override
  String get simFeatureSocial => 'الرصيد الاجتماعي';

  @override
  String get simFeatureSocialSub => 'قوة علاقاتك';

  @override
  String get startSimulation => 'أبدأ المحاكاة';

  @override
  String get projection => 'توقعات';

  @override
  String get lifeModules => 'جوانب حياة';

  @override
  String get scenarios => 'سيناريوهات';

  @override
  String get language => 'اللغة';

  @override
  String get inputTitle => 'إعدادات الحياة';

  @override
  String get inputSubtitle => 'خطط لمستقبلك';

  @override
  String get trajectory => 'مسار وتوجه';

  @override
  String get definePath => 'حدد طريقك';

  @override
  String get liveProjection => 'مباشرة • توقعات 10 سنوات';

  @override
  String get finances => 'المالية';

  @override
  String get monthlyIncome => 'الدخل الشهري';

  @override
  String get incomeHint => 'الدخل الشهري بعد الضرائب';

  @override
  String get incomeErrorEmpty => 'يرجى إدخال دخلك الشهري';

  @override
  String get incomeErrorInvalid => 'يرجى إدخال مبلغ صحيح';

  @override
  String get savingRate => 'معدل الادخار';

  @override
  String get savingLow => 'منخفض';

  @override
  String get savingModerate => 'متوسط';

  @override
  String get savingGood => 'جيد';

  @override
  String get savingExcellent => 'ممتاز';

  @override
  String get healthGrowth => 'الصحة والنمو';

  @override
  String get study => 'الدراسة';

  @override
  String get workout => 'الرياضة';

  @override
  String workoutDaysPerWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أيام',
      two: 'يومين',
      one: 'يوم',
    );
    return '$count $_temp0 / أسبوع';
  }

  @override
  String get career => 'المهنة';

  @override
  String get careerSkills => 'المهنة والمهارات';

  @override
  String get weeklySkillDev => 'تطوير مهارات أسبوعي';

  @override
  String get certsPerYearLabel => 'شهادات سنوياً';

  @override
  String get social => 'اجتماعي';

  @override
  String get socialNetworking => 'الجانب الاجتماعي';

  @override
  String get socialMedia => 'تواصل اجتماعي';

  @override
  String get familyFriends => 'العائلة والأصدقاء';

  @override
  String get networking => 'العلاقات المهنية';

  @override
  String get dayUnit => '/يوم';

  @override
  String get weekUnit => '/أس';

  @override
  String get simulateMyFuture => 'أظهر لي مستقبلي';

  @override
  String get techField => 'تكنولوجيا';

  @override
  String get healthField => 'رعاية صحية';

  @override
  String get financeField => 'مالية';

  @override
  String get artsField => 'فنون';

  @override
  String get eduField => 'تعليم';

  @override
  String get otherField => 'أخرى';

  @override
  String get resultsTitle => 'لوحة النتائج';

  @override
  String get financial => 'المالي';

  @override
  String get highLiquidity => 'استراتيجية سيولة عالية';

  @override
  String get knowledgeLabel => 'المعرفة';

  @override
  String get advancedCognitive => 'تطوير إدراكي متقدم';

  @override
  String iqRank(int percent) {
    return '$percent% رتبة ذكاء';
  }

  @override
  String get healthLabel => 'الصحة';

  @override
  String get biomarkersPeak => 'مؤشرات حيوية ممتازة';

  @override
  String vitalityScore(int percent) {
    return '$percent% حيوية';
  }

  @override
  String get careerGrowthLabel => 'النمو المهني';

  @override
  String get multiplierTrajectory => 'مسار نمو مضاعف';

  @override
  String growthIndex(int percent) {
    return '$percent% مؤشر';
  }

  @override
  String get socialBalanceLabel => 'التوازن الاجتماعي';

  @override
  String isolationRisk(int percent) {
    return 'خطر الانعزال: $percent%';
  }

  @override
  String socialScore(int score) {
    return '$score/100';
  }

  @override
  String get compareScenario => 'قارن مع سيناريو آخر';

  @override
  String get predictionDisclaimer =>
      'التوقعات مبنية على اتجاهات السوق الحالية ومعايير المحاكاة.';

  @override
  String get optimizedPath => 'السيناريو: المسار الأمثل';

  @override
  String strategyScore(int score) {
    return 'درجة استراتيجية الحياة: $score/100';
  }

  @override
  String get futureIn => 'مستقبلك في غضون ';

  @override
  String get oneMonth => 'شهر واحد';

  @override
  String yearsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سنوات',
      two: 'سنتين',
      one: 'سنة',
    );
    return '$count $_temp0';
  }

  @override
  String get netWorth => 'صافي القيمة التقديرية';

  @override
  String get projectedGrowth => 'النمو المتوقع';

  @override
  String get monthShort => 'ش';

  @override
  String get yearShort => 'س';

  @override
  String get simulatingFuture => 'محاكاة مستقبلك قيد التنفيذ...';

  @override
  String get noSimulationYet => 'لا توجد محاكاة بعد';

  @override
  String get noSimulationSub =>
      'قم بإجراء محاكاتك الأولى لترى توقعات مستقبلك هنا.';

  @override
  String get comparisonTitle => 'مقارنة السيناريوهات';

  @override
  String scenarioLabel(String id) {
    return 'سيناريو $id';
  }

  @override
  String get detailedImpact => 'التأثير التفصيلي';

  @override
  String get monthlySavingsLabel => 'الادخار الشهري';

  @override
  String get healthIndexLabel => 'مؤشر الصحة';

  @override
  String get knowledgeGrowthLabel => 'نمو المعرفة';

  @override
  String get linear => 'خطي';

  @override
  String get exponential => 'أسي';

  @override
  String get switchToOptimized => 'التحول للمسار الأمثل';

  @override
  String get netWorthAt10 => 'صافي القيمة بعد 10 سنوات';

  @override
  String get tenYearProjections => 'توقعات 10 سنوات';

  @override
  String get currentLabel => 'الحالي';

  @override
  String get optimizedLabel => 'المحسن';

  @override
  String yearCountLabel(int count) {
    return 'سنة $count';
  }

  @override
  String get runSimFirst => 'قم بإجراء محاكاة أولاً للمقارنة بين السيناريوهات.';

  @override
  String get goToSimulation => 'انتقل للمحاكاة';

  @override
  String get addScenarioB => 'أضف سيناريو ب';

  @override
  String get setupScenarioBSub =>
      'قم بإعداد سيناريو ثانٍ بعادات مختلفة لمقارنة النتائج.';

  @override
  String get setupScenarioBTitle => 'إعداد السيناريو ب';

  @override
  String get enterOptimizedHabits => 'أدخل عاداتك اليومية المحسنة.';

  @override
  String incomeValueLabel(String currency, int value) {
    return 'الدخل الشهري: $currency$value';
  }

  @override
  String savingValueLabel(int percent) {
    return 'الادخار: $percent%';
  }

  @override
  String studyValueLabel(String hours) {
    return 'الدراسة: $hours ساعة/يوم';
  }

  @override
  String workoutValueLabel(int days) {
    return 'الرياضة: $days أيام/أسبوع';
  }

  @override
  String get runScenarioB => 'تشغيل السيناريو ب';

  @override
  String get navSimulation => 'المحاكاة';

  @override
  String get navInsights => 'الرؤى';

  @override
  String get navCompare => 'المقارنة';

  @override
  String get simulatingBtn => 'جاري المحاكاة...';

  @override
  String get loginTitle => 'مرحباً بعودتك';

  @override
  String get loginSubtitle => 'أكمل رحلتك نحو النجاح وتحقيق أهدفك.';

  @override
  String get signupTitle => 'إنشاء حساب جديد';

  @override
  String get signupSubtitle => 'ابدأ في رسم ملامح مستقبلك اليوم.';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get emailHint => 'example@domain.com';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get passwordHint => '••••••••';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get signupButton => 'إنشاء الحساب';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟ سجل دخولك';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟ سجل الآن';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get authErrorInvalidEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get authErrorShortPassword =>
      'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get authErrorShortName => 'يجب أن يتكون الاسم من حرفين على الأقل';

  @override
  String get authErrorPasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get authErrorEmpty => 'هذا الحقل مطلوب';

  @override
  String get fullNameLabel => 'الاسم الكامل';

  @override
  String get fullNameHint => 'اسمك الكامل';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get alreadyHaveAccountPrefix => 'لديك حساب بالفعل؟ ';

  @override
  String get dontHaveAccountPrefix => 'ليس لديك حساب؟ ';

  @override
  String get signInLink => 'تسجيل الدخول';

  @override
  String get signUpLink => 'إنشاء حساب';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get profileTitle => 'ملفي الشخصي';

  @override
  String get profileStrategies => 'الاستراتيجيات';

  @override
  String get profileInsights => 'الرؤى';

  @override
  String get profileScenarios => 'السيناريوهات';

  @override
  String get profileSettings => 'الإعدادات';

  @override
  String get profileAccount => 'الحساب';

  @override
  String get profileEditProfile => 'تعديل الملف';

  @override
  String get profileNotifications => 'الإشعارات';

  @override
  String get profileChangePassword => 'تغيير كلمة المرور';

  @override
  String get profileLogout => 'تسجيل الخروج';

  @override
  String get profileNotLoggedInTitle => 'أنت لم تسجل دخولك بعد';

  @override
  String get profileNotLoggedInSub =>
      'سجل دخولك لعرض ملفك الشخصي وتتبع استراتيجياتك.';

  @override
  String get profileLoginBtn => 'تسجيل الدخول للمتابعة';

  // ── New Feature Strings ──────────────────────────────────────
  @override
  String get navFuture => 'المستقبل';
  @override
  String get timelineTitle => 'مسارات متوازية';
  @override
  String get declinePathLabel => 'التراجع';
  @override
  String get generateFutures => 'توليد المسارات';
  @override
  String get generatingFutures => 'جاري توليد المسارات...';
  @override
  String get noFuturesYet => 'لم تُولَّد مسارات بعد';
  @override
  String get noFuturesSub =>
      'قم بإجراء محاكاة أولاً ثم اضغط توليد لعرض مسارات حياتك المتوازية.';
  @override
  String get switchPathLabel => 'عرض المسار';
  @override
  String get allPathsLabel => 'جميع المسارات';
  @override
  String get riskAnalysis => 'تحليل المخاطر';
  @override
  String get burnoutRiskLabel => 'الإرهاق';
  @override
  String get financialRiskLabel => 'مالي';
  @override
  String get careerRiskLabel => 'مهني';
  @override
  String get energyRiskLabel => 'الطاقة';
  @override
  String get riskLow => 'منخفض';
  @override
  String get riskMedium => 'متوسط';
  @override
  String get riskHigh => 'مرتفع';
  @override
  String get stabilityScoreLabel => 'استقرار الحياة';
  @override
  String get decisionImpactTitle => 'تأثير القرارات';
  @override
  String get adjustHabitsHint => 'عدّل العادات لرؤية التوقعات مباشرة';
  @override
  String get applyImpact => 'تطبيق التغييرات';
  @override
  String get historyTitle => 'السجل';
  @override
  String get noHistoryYet => 'لا يوجد سجل بعد';
  @override
  String get noHistorySub => 'ستظهر محاكاتك السابقة هنا.';
  @override
  String get clearHistory => 'مسح السجل';
  @override
  String get energyLevelLabel => 'مستوى الطاقة';
  @override
  String get riskLevelLabel => 'مؤشر المخاطر';
}
