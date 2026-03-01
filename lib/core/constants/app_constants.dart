/// App-wide constants for the Life Simulator.
abstract class AppConstants {
  // ── Spacing System ───────────────────────────────────────────
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // ── Border Radii ─────────────────────────────────────────────
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 28.0;
  static const double radiusFull = 100.0;

  // ── Simulation Parameters ─────────────────────────────────────
  static const double annualInterestRate = 0.06; // 6% compound annual rate
  static const int compoundsPerYear = 12; // Monthly compounding
  static const double maxSavingPercentage = 0.50; // 50% max savings
  static const int maxStudyHoursPerDay = 10;
  static const int daysPerYear = 365;
  static const int workoutDaysMax = 7;

  // ── Simulation Horizons (years) ───────────────────────────────
  static const List<int> projectionYears = [1, 5, 10];

  // ── UI Durations ──────────────────────────────────────────────
  static const Duration animationFast = Duration(milliseconds: 300);
  static const Duration animationMedium = Duration(milliseconds: 600);
  static const Duration animationSlow = Duration(milliseconds: 1000);
  static const Duration counterDuration = Duration(milliseconds: 1500);

  // ── App Info ──────────────────────────────────────────────────
  static const String appName = 'Life Simulator';
  static const String appVersion = '4.0';
  static const String engineLabel = 'POWERED BY LIFE ENGINE V4.0';

  // ── Input Defaults ────────────────────────────────────────────
  static const double defaultIncome = 4500;
  static const double defaultSavingPct = 0.25;
  static const double defaultStudyHours = 2.5;
  static const int defaultWorkoutDays = 4;

  // ── Storage Keys ─────────────────────────────────────────────
  static const String scenarioAKey = 'scenario_a';
  static const String scenarioBKey = 'scenario_b';
}
