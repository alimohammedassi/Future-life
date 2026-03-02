import '../models/simulation_input.dart';

/// Derives alternate life-path inputs from a baseline [SimulationInput].
class ScenarioEngine {
  /// Optimized path: increased discipline, higher savings, better habits.
  SimulationInput buildOptimizedInput(SimulationInput base) {
    return base.copyWith(
      savingPercentage: (base.savingPercentage + 0.10).clamp(0, 0.50),
      dailyStudyHours: (base.dailyStudyHours + 1.5).clamp(0, 10),
      workoutDaysPerWeek: (base.workoutDaysPerWeek + 2).clamp(0, 7),
      weeklySkillHours: (base.weeklySkillHours + 3).clamp(0, 30),
      certsPerYear: base.certsPerYear + 1,
      socialMediaHours: (base.socialMediaHours - 1.5).clamp(0, 24),
      networkingHours: (base.networkingHours + 2).clamp(0, 24),
    );
  }

  /// Decline path: reduced effort, higher spending, burnout risk.
  SimulationInput buildDeclineInput(SimulationInput base) {
    return base.copyWith(
      savingPercentage: (base.savingPercentage - 0.10).clamp(0, 0.50),
      dailyStudyHours: (base.dailyStudyHours - 1.0).clamp(0, 10),
      workoutDaysPerWeek: (base.workoutDaysPerWeek - 2).clamp(0, 7),
      weeklySkillHours: (base.weeklySkillHours - 2).clamp(0, 30),
      certsPerYear: (base.certsPerYear - 1).clamp(0, 999),
      socialMediaHours: (base.socialMediaHours + 2).clamp(0, 24),
      networkingHours: (base.networkingHours - 1).clamp(0, 24),
    );
  }
}
