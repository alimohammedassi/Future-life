import 'package:uuid/uuid.dart';
import '../models/simulation_input.dart';
import '../models/simulation_result.dart';
import '../../../../core/constants/app_constants.dart';
import 'finance_engine.dart';
import 'health_engine.dart';
import 'career_engine.dart';
import 'social_engine.dart';

class LifeEngine {
  final FinanceEngine finance = FinanceEngine();
  final CareerEngine career = CareerEngine();
  final HealthEngine health = HealthEngine();
  final SocialEngine social = SocialEngine();

  SimulationResult simulate(SimulationInput input,
      {String? name, int years = 10}) {
    const uuid = Uuid();
    final snapshots = _buildYearlySnapshots(input, years);

    final s1 = _snapshotAt(snapshots, 1);
    final s5 = _snapshotAt(snapshots, 5);
    final s10 = _snapshotAt(snapshots, 10);

    final careerGrowth = career.calculateCareerGrowthIndex(
      weeklySkillHours: input.weeklySkillHours,
      certsPerYear: input.certsPerYear,
      years: years,
    );

    final salaryMult = career.calculateSalaryMultiplier(
      weeklySkillHours: input.weeklySkillHours,
      certsPerYear: input.certsPerYear,
      years: years,
    );

    final promoProb = career.calculatePromotionProbability(
      weeklySkillHours: input.weeklySkillHours,
      certsPerYear: input.certsPerYear,
    );

    final socialBalance = social.calculateBalanceScore(
      socialMediaHours: input.socialMediaHours,
      familyHours: input.familyHours,
      networkingHours: input.networkingHours,
    );

    final isolRisk = social.calculateIsolationRisk(
      socialMediaHours: input.socialMediaHours,
      familyHours: input.familyHours,
      networkingHours: input.networkingHours,
    );

    // Life Strategy Score (Custom aggregation)
    final financialHealth = (s10.savings /
            (input.monthlyIncome * 12 * years).clamp(1, double.infinity)) *
        100;
    final avgScore = (s10.healthScore +
            socialBalance +
            careerGrowth +
            financialHealth.clamp(0, 100)) /
        4;
    final lifeStrategyScore = avgScore.clamp(0.0, 100.0);

    return SimulationResult(
      id: uuid.v4(),
      name: name ?? 'Scenario',
      createdAt: DateTime.now(),
      savings1Y: s1.savings,
      savings5Y: s5.savings,
      savings10Y: s10.savings,
      monthlySavings: input.monthlySavings *
          salaryMult, // Using multiplier for final metric
      netWorth10Y: s10.savings,
      studyHours1Y: s1.studyHours,
      studyHours5Y: s5.studyHours,
      studyHours10Y: s10.studyHours,
      healthScore1Y: s1.healthScore,
      healthScore5Y: s5.healthScore,
      healthScore10Y: s10.healthScore,
      careerGrowthIndex: careerGrowth,
      salaryMultiplier: salaryMult,
      promotionProbability: promoProb,
      socialBalanceScore: socialBalance,
      isolationRisk: isolRisk,
      currency: input.currency,
      lifeStrategyScore: lifeStrategyScore,
      yearlySnapshots: snapshots,
    );
  }

  List<YearSnapshot> _buildYearlySnapshots(
      SimulationInput input, int maxYears) {
    final snapshots = <YearSnapshot>[];
    for (int year = 1; year <= maxYears; year++) {
      final salaryMult = career.calculateSalaryMultiplier(
        weeklySkillHours: input.weeklySkillHours,
        certsPerYear: input.certsPerYear,
        years: year,
      );

      snapshots.add(YearSnapshot(
        year: year,
        savings: finance.calculateProjectedSavings(
          monthlyPayment: input.monthlySavings * salaryMult,
          annualRate: AppConstants.annualInterestRate,
          years: year,
        ),
        studyHours: _totalStudyHours(
          dailyHours: input.dailyStudyHours,
          years: year,
        ),
        healthScore: health.calculateHealthScore(
          workoutDays: input.workoutDaysPerWeek,
          years: year,
        ),
      ));
    }
    return snapshots;
  }

  YearSnapshot _snapshotAt(List<YearSnapshot> snapshots, int year) {
    return snapshots.firstWhere(
      (s) => s.year == year,
      orElse: () => snapshots.last,
    );
  }

  double _totalStudyHours({required double dailyHours, required int years}) {
    return dailyHours * AppConstants.daysPerYear * years;
  }
}

/// Backward compatibility wrapper
class SimulationEngine {
  const SimulationEngine._();

  static SimulationResult run(SimulationInput input, {String? name}) {
    final engine = LifeEngine();
    return engine.simulate(input, name: name, years: 10);
  }
}
