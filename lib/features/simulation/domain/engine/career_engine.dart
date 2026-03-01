class CareerEngine {
  /// Compute Career growth index based on weekly skill hours and certs per year
  double calculateCareerGrowthIndex({
    required double weeklySkillHours,
    required int certsPerYear,
    required int years,
  }) {
    // Basic logic mapping hours and certs to a growth index. Max around 100.
    final baseSkillPoints = weeklySkillHours * 5;
    final certPoints = certsPerYear * 10;

    final annualGrowth = baseSkillPoints + certPoints;
    return (annualGrowth * years).clamp(0, 100);
  }

  /// Multiply salary over time
  double calculateSalaryMultiplier({
    required double weeklySkillHours,
    required int certsPerYear,
    required int years,
  }) {
    final growthIndex = calculateCareerGrowthIndex(
      weeklySkillHours: weeklySkillHours,
      certsPerYear: certsPerYear,
      years: years,
    );
    // Salary multiplier increases based on growth index. Max ~3.0x multiplier.
    return 1.0 + (growthIndex * 0.02);
  }

  /// Promotion probability (0 to 1) based on skills and certs
  double calculatePromotionProbability({
    required double weeklySkillHours,
    required int certsPerYear,
  }) {
    final probability = (weeklySkillHours * 0.02) + (certsPerYear * 0.1);
    return probability.clamp(0.0, 1.0);
  }
}
