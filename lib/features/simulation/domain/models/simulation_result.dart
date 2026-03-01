import 'dart:convert';

/// Immutable result model for a single year's projection snapshot.
class YearSnapshot {
  final int year;
  final double savings;
  final double studyHours;
  final double healthScore;

  const YearSnapshot({
    required this.year,
    required this.savings,
    required this.studyHours,
    required this.healthScore,
  });

  Map<String, dynamic> toMap() => {
        'year': year,
        'savings': savings,
        'studyHours': studyHours,
        'healthScore': healthScore,
      };

  factory YearSnapshot.fromMap(Map<String, dynamic> map) => YearSnapshot(
        year: map['year'] as int,
        savings: (map['savings'] as num).toDouble(),
        studyHours: (map['studyHours'] as num).toDouble(),
        healthScore: (map['healthScore'] as num).toDouble(),
      );
}

/// Complete simulation result containing all year projections with metadata.
class SimulationResult {
  final String id;
  final String name;
  final DateTime createdAt;

  // ── Financial ─────────────────────────────────────────────────
  final double savings1Y;
  final double savings5Y;
  final double savings10Y;
  final double monthlySavings;
  final double netWorth10Y;

  // ── Knowledge / Study ─────────────────────────────────────────
  final double studyHours1Y;
  final double studyHours5Y;
  final double studyHours10Y;

  // ── Health ────────────────────────────────────────────────────
  final double healthScore1Y;
  final double healthScore5Y;
  final double healthScore10Y;

  // ── Career ────────────────────────────────────────────────────
  final double careerGrowthIndex;
  final double salaryMultiplier;
  final double promotionProbability;

  // ── Social ────────────────────────────────────────────────────
  final double socialBalanceScore;
  final double isolationRisk;

  // ── Strategy ──────────────────────────────────────────────────
  final String currency;
  final double lifeStrategyScore;

  // ── Chart Data ────────────────────────────────────────────────
  final List<YearSnapshot> yearlySnapshots;

  const SimulationResult({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.savings1Y,
    required this.savings5Y,
    required this.savings10Y,
    required this.monthlySavings,
    required this.netWorth10Y,
    required this.studyHours1Y,
    required this.studyHours5Y,
    required this.studyHours10Y,
    required this.healthScore1Y,
    required this.healthScore5Y,
    required this.healthScore10Y,
    required this.careerGrowthIndex,
    required this.salaryMultiplier,
    required this.promotionProbability,
    required this.socialBalanceScore,
    required this.isolationRisk,
    required this.currency,
    required this.lifeStrategyScore,
    required this.yearlySnapshots,
  });

  /// Percentage gain from 0→10 years for display as a badge.
  double get tenYearGainPercent {
    if (savings1Y == 0) return 0;
    return (savings10Y - savings1Y) / savings1Y;
  }

  // ── Serialization ─────────────────────────────────────────────
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'savings1Y': savings1Y,
        'savings5Y': savings5Y,
        'savings10Y': savings10Y,
        'monthlySavings': monthlySavings,
        'netWorth10Y': netWorth10Y,
        'studyHours1Y': studyHours1Y,
        'studyHours5Y': studyHours5Y,
        'studyHours10Y': studyHours10Y,
        'healthScore1Y': healthScore1Y,
        'healthScore5Y': healthScore5Y,
        'healthScore10Y': healthScore10Y,
        'careerGrowthIndex': careerGrowthIndex,
        'salaryMultiplier': salaryMultiplier,
        'promotionProbability': promotionProbability,
        'socialBalanceScore': socialBalanceScore,
        'isolationRisk': isolationRisk,
        'currency': currency,
        'lifeStrategyScore': lifeStrategyScore,
        'yearlySnapshots': yearlySnapshots.map((s) => s.toMap()).toList(),
      };

  factory SimulationResult.fromMap(Map<String, dynamic> map) =>
      SimulationResult(
        id: map['id'] as String,
        name: map['name'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
        savings1Y: (map['savings1Y'] as num).toDouble(),
        savings5Y: (map['savings5Y'] as num).toDouble(),
        savings10Y: (map['savings10Y'] as num).toDouble(),
        monthlySavings: (map['monthlySavings'] as num).toDouble(),
        netWorth10Y: (map['netWorth10Y'] as num).toDouble(),
        studyHours1Y: (map['studyHours1Y'] as num).toDouble(),
        studyHours5Y: (map['studyHours5Y'] as num).toDouble(),
        studyHours10Y: (map['studyHours10Y'] as num).toDouble(),
        healthScore1Y: (map['healthScore1Y'] as num).toDouble(),
        healthScore5Y: (map['healthScore5Y'] as num).toDouble(),
        healthScore10Y: (map['healthScore10Y'] as num).toDouble(),
        careerGrowthIndex:
            (map['careerGrowthIndex'] as num?)?.toDouble() ?? 0.0,
        salaryMultiplier: (map['salaryMultiplier'] as num?)?.toDouble() ?? 1.0,
        promotionProbability:
            (map['promotionProbability'] as num?)?.toDouble() ?? 0.0,
        socialBalanceScore:
            (map['socialBalanceScore'] as num?)?.toDouble() ?? 50.0,
        isolationRisk: (map['isolationRisk'] as num?)?.toDouble() ?? 0.0,
        currency: map['currency'] as String? ?? 'USD',
        lifeStrategyScore:
            (map['lifeStrategyScore'] as num?)?.toDouble() ?? 0.0,
        yearlySnapshots: (map['yearlySnapshots'] as List)
            .map((e) => YearSnapshot.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  String toJson() => jsonEncode(toMap());
  factory SimulationResult.fromJson(String source) =>
      SimulationResult.fromMap(jsonDecode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'SimulationResult(name: $name, 10Y: \$$savings10Y, Currency: $currency, Score: $lifeStrategyScore)';
}
