import 'dart:convert';

/// Immutable model capturing the user's life habit inputs.
class SimulationInput {
  // ── Existing ──────────────────────────────────────────────────
  final double monthlyIncome;
  final double savingPercentage; // 0.0 to 0.50
  final double dailyStudyHours; // 0.0 to 10.0
  final int workoutDaysPerWeek; // 0 to 7

  // ── New Modules ───────────────────────────────────────────────
  final String currency; // EGP, SAR, AED, KWD, QAR, USD
  final String careerField;
  final double weeklySkillHours;
  final int certsPerYear;
  final double socialMediaHours;
  final double familyHours;
  final double networkingHours;

  const SimulationInput({
    required this.monthlyIncome,
    required this.savingPercentage,
    required this.dailyStudyHours,
    required this.workoutDaysPerWeek,
    required this.currency,
    required this.careerField,
    required this.weeklySkillHours,
    required this.certsPerYear,
    required this.socialMediaHours,
    required this.familyHours,
    required this.networkingHours,
  });

  /// Default starting values used in the input form.
  factory SimulationInput.defaults() => const SimulationInput(
        monthlyIncome: 4500,
        savingPercentage: 0.25,
        dailyStudyHours: 2.5,
        workoutDaysPerWeek: 4,
        currency: 'USD',
        careerField: 'Technology',
        weeklySkillHours: 5.0,
        certsPerYear: 1,
        socialMediaHours: 2.0,
        familyHours: 10.0,
        networkingHours: 2.0,
      );

  /// Monthly amount saved in currency units.
  double get monthlySavings => monthlyIncome * savingPercentage;

  /// Creates a copy with specified fields overridden.
  SimulationInput copyWith({
    double? monthlyIncome,
    double? savingPercentage,
    double? dailyStudyHours,
    int? workoutDaysPerWeek,
    String? currency,
    String? careerField,
    double? weeklySkillHours,
    int? certsPerYear,
    double? socialMediaHours,
    double? familyHours,
    double? networkingHours,
  }) {
    return SimulationInput(
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      savingPercentage: savingPercentage ?? this.savingPercentage,
      dailyStudyHours: dailyStudyHours ?? this.dailyStudyHours,
      workoutDaysPerWeek: workoutDaysPerWeek ?? this.workoutDaysPerWeek,
      currency: currency ?? this.currency,
      careerField: careerField ?? this.careerField,
      weeklySkillHours: weeklySkillHours ?? this.weeklySkillHours,
      certsPerYear: certsPerYear ?? this.certsPerYear,
      socialMediaHours: socialMediaHours ?? this.socialMediaHours,
      familyHours: familyHours ?? this.familyHours,
      networkingHours: networkingHours ?? this.networkingHours,
    );
  }

  // ── Serialization ─────────────────────────────────────────────
  Map<String, dynamic> toMap() => {
        'monthlyIncome': monthlyIncome,
        'savingPercentage': savingPercentage,
        'dailyStudyHours': dailyStudyHours,
        'workoutDaysPerWeek': workoutDaysPerWeek,
        'currency': currency,
        'careerField': careerField,
        'weeklySkillHours': weeklySkillHours,
        'certsPerYear': certsPerYear,
        'socialMediaHours': socialMediaHours,
        'familyHours': familyHours,
        'networkingHours': networkingHours,
      };

  factory SimulationInput.fromMap(Map<String, dynamic> map) => SimulationInput(
        monthlyIncome: (map['monthlyIncome'] as num).toDouble(),
        savingPercentage: (map['savingPercentage'] as num).toDouble(),
        dailyStudyHours: (map['dailyStudyHours'] as num).toDouble(),
        workoutDaysPerWeek: map['workoutDaysPerWeek'] as int,
        currency: map['currency'] as String? ?? 'USD',
        careerField: map['careerField'] as String? ?? 'Technology',
        weeklySkillHours: (map['weeklySkillHours'] as num?)?.toDouble() ?? 5.0,
        certsPerYear: map['certsPerYear'] as int? ?? 1,
        socialMediaHours: (map['socialMediaHours'] as num?)?.toDouble() ?? 2.0,
        familyHours: (map['familyHours'] as num?)?.toDouble() ?? 10.0,
        networkingHours: (map['networkingHours'] as num?)?.toDouble() ?? 2.0,
      );

  String toJson() => jsonEncode(toMap());

  factory SimulationInput.fromJson(String source) =>
      SimulationInput.fromMap(jsonDecode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimulationInput &&
          other.monthlyIncome == monthlyIncome &&
          other.savingPercentage == savingPercentage &&
          other.dailyStudyHours == dailyStudyHours &&
          other.workoutDaysPerWeek == workoutDaysPerWeek &&
          other.currency == currency &&
          other.careerField == careerField &&
          other.weeklySkillHours == weeklySkillHours &&
          other.certsPerYear == certsPerYear &&
          other.socialMediaHours == socialMediaHours &&
          other.familyHours == familyHours &&
          other.networkingHours == networkingHours;

  @override
  int get hashCode => Object.hash(
        monthlyIncome,
        savingPercentage,
        dailyStudyHours,
        workoutDaysPerWeek,
        currency,
        careerField,
        weeklySkillHours,
        certsPerYear,
        socialMediaHours,
        familyHours,
        networkingHours,
      );

  @override
  String toString() =>
      'SimulationInput(income: \$$monthlyIncome, saving: ${(savingPercentage * 100).toInt()}%, '
      'study: ${dailyStudyHours}h, workout: $workoutDaysPerWeek days)';
}
