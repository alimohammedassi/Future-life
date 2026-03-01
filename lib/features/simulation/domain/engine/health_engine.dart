import '../../../../core/constants/app_constants.dart';

class HealthEngine {
  /// Health score (0–100), growing slightly with consistency over time.
  ///
  /// Base score = (workoutDays / 7) × 100
  /// Growth bonus: +2 per year of consistency (capped so total ≤ 100)
  double calculateHealthScore({
    required int workoutDays,
    required int years,
  }) {
    final consistency = workoutDays / AppConstants.workoutDaysMax;
    final baseScore = consistency * 100;

    // Small compounding bonus for sustained consistency
    final growthBonus = consistency * (years - 1) * 2.0;

    return (baseScore + growthBonus).clamp(0, 100);
  }
}
