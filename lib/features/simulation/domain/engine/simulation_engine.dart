import 'package:uuid/uuid.dart';
import '../models/simulation_input.dart';
import '../models/simulation_result.dart';
import '../../../../core/constants/app_constants.dart';
import 'finance_engine.dart';
import 'health_engine.dart';
import 'career_engine.dart';
import 'social_engine.dart';
import 'energy_engine.dart';
import 'risk_engine.dart';

class LifeEngine {
  final FinanceEngine finance = FinanceEngine();
  final CareerEngine career = CareerEngine();
  final HealthEngine health = HealthEngine();
  final SocialEngine social = SocialEngine();
  final EnergyEngine energy = EnergyEngine();
  final RiskEngine risk = RiskEngine();

  SimulationResult simulate(SimulationInput input,
      {String? name, int years = 10}) {
    const uuid = Uuid();
    final snapshots = _buildYearlySnapshots(input, years);
    final monthlySnaps = _buildMonthlySnapshots(input);

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

    // Energy scores
    final energyScore1Y = energy.calculateEnergyLevel(
      dailyStudyHours: input.dailyStudyHours,
      workoutDaysPerWeek: input.workoutDaysPerWeek,
      socialMediaHours: input.socialMediaHours,
      years: 1,
    );
    final energyScore5Y = energy.calculateEnergyLevel(
      dailyStudyHours: input.dailyStudyHours,
      workoutDaysPerWeek: input.workoutDaysPerWeek,
      socialMediaHours: input.socialMediaHours,
      years: 5,
    );
    final energyScore10Y = energy.calculateEnergyLevel(
      dailyStudyHours: input.dailyStudyHours,
      workoutDaysPerWeek: input.workoutDaysPerWeek,
      socialMediaHours: input.socialMediaHours,
      years: 10,
    );
    final burnoutRisk = energy.calculateBurnoutRisk(
      dailyStudyHours: input.dailyStudyHours,
      workoutDaysPerWeek: input.workoutDaysPerWeek,
      socialMediaHours: input.socialMediaHours,
      weeklySkillHours: input.weeklySkillHours,
    );

    // Risk scores
    final financialCollapseRisk = risk.calculateFinancialCollapseRisk(
      savingPercentage: input.savingPercentage,
      monthlyIncome: input.monthlyIncome,
    );
    final careerStagnationRisk = risk.calculateCareerStagnationRisk(
      weeklySkillHours: input.weeklySkillHours,
      certsPerYear: input.certsPerYear,
    );
    final energyDepletionRisk = risk.calculateEnergyDepletionRisk(
      dailyStudyHours: input.dailyStudyHours,
      workoutDaysPerWeek: input.workoutDaysPerWeek,
      socialMediaHours: input.socialMediaHours,
    );
    final overallRiskIndex = risk.calculateOverallRiskIndex(
      financialCollapseRisk: financialCollapseRisk,
      careerStagnationRisk: careerStagnationRisk,
      burnoutRisk: burnoutRisk,
      energyDepletionRisk: energyDepletionRisk,
    );

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
      energyScore1Y: energyScore1Y,
      energyScore5Y: energyScore5Y,
      energyScore10Y: energyScore10Y,
      burnoutRisk: burnoutRisk,
      financialCollapseRisk: financialCollapseRisk,
      careerStagnationRisk: careerStagnationRisk,
      energyDepletionRisk: energyDepletionRisk,
      overallRiskIndex: overallRiskIndex,
      yearlySnapshots: snapshots,
      monthlySnapshots: monthlySnaps,
    );
  }

  List<MonthSnapshot> _buildMonthlySnapshots(SimulationInput input) {
    final snaps = <MonthSnapshot>[];
    final salaryMult = career.calculateSalaryMultiplier(
      weeklySkillHours: input.weeklySkillHours,
      certsPerYear: input.certsPerYear,
      years: 1,
    );
    for (int m = 1; m <= 12; m++) {
      snaps.add(MonthSnapshot(
        month: m,
        savings: finance.calculateProjectedSavingsForMonths(
          monthlyPayment: input.monthlySavings * salaryMult,
          annualRate: AppConstants.annualInterestRate,
          months: m,
        ),
        studyHours: input.dailyStudyHours * 30.0 * m,
        healthScore: (health.calculateHealthScore(
                  workoutDays: input.workoutDaysPerWeek,
                  years: 1,
                ) *
                (m / 12))
            .clamp(0, 100),
      ));
    }
    return snaps;
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
