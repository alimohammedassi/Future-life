/// Calculates multi-dimensional life risk indicators.
class RiskEngine {
  // ── Individual Risk Dimensions ────────────────────────────────

  /// Financial collapse risk (0–1). Low savings = high risk.
  double calculateFinancialCollapseRisk({
    required double savingPercentage,
    required double monthlyIncome,
  }) {
    if (savingPercentage < 0.05) return 0.90;
    if (savingPercentage < 0.10) return 0.65;
    if (savingPercentage < 0.20) return 0.40;
    if (savingPercentage < 0.30) return 0.20;
    if (savingPercentage < 0.40) return 0.10;
    return 0.05;
  }

  /// Career stagnation risk (0–1). Low skill investment = high risk.
  double calculateCareerStagnationRisk({
    required double weeklySkillHours,
    required int certsPerYear,
  }) {
    final skillScore = (weeklySkillHours * 4 + certsPerYear * 15).clamp(0, 100);
    return (1 - skillScore / 100).clamp(0, 1);
  }

  /// Energy depletion risk (0–1).
  double calculateEnergyDepletionRisk({
    required double dailyStudyHours,
    required int workoutDaysPerWeek,
    required double socialMediaHours,
  }) {
    final overload = (dailyStudyHours / 10).clamp(0, 1) * 0.45;
    final inactivity = (1 - workoutDaysPerWeek / 7) * 0.35;
    final distraction = (socialMediaHours / 8).clamp(0, 1) * 0.20;
    return (overload + inactivity + distraction).clamp(0, 1);
  }

  // ── Composite ────────────────────────────────────────────────

  /// Overall risk index (0–100, higher = riskier).
  double calculateOverallRiskIndex({
    required double financialCollapseRisk,
    required double careerStagnationRisk,
    required double burnoutRisk,
    required double energyDepletionRisk,
  }) {
    return ((financialCollapseRisk * 0.35 +
                careerStagnationRisk * 0.25 +
                burnoutRisk * 0.25 +
                energyDepletionRisk * 0.15) *
            100)
        .clamp(0, 100);
  }
}
