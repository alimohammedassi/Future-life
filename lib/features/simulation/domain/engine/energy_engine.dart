/// Calculates energy level and burnout risk from daily habits.
class EnergyEngine {
  /// Energy level (0–100) per year.
  ///
  /// High workout = energy boost.
  /// Excess study > 6 h/day + high social media = energy drain.
  double calculateEnergyLevel({
    required double dailyStudyHours,
    required int workoutDaysPerWeek,
    required double socialMediaHours,
    required int years,
  }) {
    final workoutBonus = (workoutDaysPerWeek / 7) * 30;
    final studyPenalty = dailyStudyHours > 6 ? (dailyStudyHours - 6) * 4.5 : 0;
    final socialPenalty =
        socialMediaHours > 3 ? (socialMediaHours - 3) * 3.5 : 0;

    double base = 55 + workoutBonus - studyPenalty - socialPenalty;

    // Sustained overwork compounds fatigue after year 3
    if (years > 3) {
      final burnoutDrag = (dailyStudyHours / 12.0) * ((years - 3) * 1.8);
      base -= burnoutDrag;
    }

    return base.clamp(0, 100);
  }

  /// Burnout risk (0–1). Higher = more likely to burn out.
  double calculateBurnoutRisk({
    required double dailyStudyHours,
    required int workoutDaysPerWeek,
    required double socialMediaHours,
    required double weeklySkillHours,
  }) {
    final overwork =
        ((dailyStudyHours + weeklySkillHours / 7) / 16).clamp(0, 1);
    final inactivity = (1 - workoutDaysPerWeek / 7);
    final isolation = (socialMediaHours / 10).clamp(0, 1);

    return (overwork * 0.5 + inactivity * 0.3 + isolation * 0.2).clamp(0, 1);
  }
}
