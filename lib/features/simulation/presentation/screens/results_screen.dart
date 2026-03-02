import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../data/providers/simulation_providers.dart';
import '../../domain/models/simulation_input.dart';
import '../../domain/models/simulation_result.dart';
import '../../domain/engine/simulation_engine.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../widgets/shared_widgets.dart';

/// Screen 2 — "Future Dashboard"
/// Displays the simulation results with charts, counters, and metrics.
class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

// ─────────────────────────────────────────────────────────────────────────────
// Time-range option model
// ─────────────────────────────────────────────────────────────────────────────

class _TimeOption {
  final String label;
  final bool isMonth; // true = months, false = years
  final int count;
  const _TimeOption(this.label, this.isMonth, this.count);
}

const _kTimeOptions = [
  _TimeOption('1M', true, 1),
  _TimeOption('2M', true, 2),
  _TimeOption('3M', true, 3),
  _TimeOption('6M', true, 6),
  _TimeOption('1Y', false, 1),
  _TimeOption('2Y', false, 2),
  _TimeOption('3Y', false, 3),
  _TimeOption('5Y', false, 5),
  _TimeOption('10Y', false, 10),
];

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  _TimeOption _selected = _kTimeOptions[7]; // default 5Y

  @override
  Widget build(BuildContext context) {
    final scenarios = ref.watch(scenariosProvider);
    final result = scenarios.scenarioA;

    if (scenarios.isRunning) {
      return const _LoadingView();
    }

    if (result == null) {
      return _EmptyResultsView(
        onStartSimulation: () => context.go(AppRoutes.input),
      );
    }

    return _ResultsDashboard(
      result: result,
      selected: _selected,
      onOptionChanged: (opt) => setState(() => _selected = opt),
      onCompare: () => context.go(AppRoutes.comparison),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ResultsDashboard extends StatelessWidget {
  final SimulationResult result;
  final _TimeOption selected;
  final ValueChanged<_TimeOption> onOptionChanged;
  final VoidCallback onCompare;

  const _ResultsDashboard({
    required this.result,
    required this.selected,
    required this.onOptionChanged,
    required this.onCompare,
  });

  double get _savings {
    if (selected.isMonth) {
      final snaps = result.monthlySnapshots;
      if (snaps.isEmpty) return result.monthlySavings * selected.count;
      return snaps
          .firstWhere((s) => s.month == selected.count,
              orElse: () => snaps.last)
          .savings;
    }
    return switch (selected.count) {
      1 => result.savings1Y,
      5 => result.savings5Y,
      10 => result.savings10Y,
      _ => _interpolateYearly(result, selected.count),
    };
  }

  double get _studyHours {
    if (selected.isMonth) {
      final snaps = result.monthlySnapshots;
      if (snaps.isEmpty) return result.studyHours1Y / 12 * selected.count;
      return snaps
          .firstWhere((s) => s.month == selected.count,
              orElse: () => snaps.last)
          .studyHours;
    }
    return switch (selected.count) {
      1 => result.studyHours1Y,
      5 => result.studyHours5Y,
      10 => result.studyHours10Y,
      _ => result.studyHours1Y * selected.count,
    };
  }

  double get _healthScore {
    if (selected.isMonth) {
      final snaps = result.monthlySnapshots;
      if (snaps.isEmpty) return result.healthScore1Y * (selected.count / 12);
      return snaps
          .firstWhere((s) => s.month == selected.count,
              orElse: () => snaps.last)
          .healthScore;
    }
    return switch (selected.count) {
      1 => result.healthScore1Y,
      5 => result.healthScore5Y,
      10 => result.healthScore10Y,
      _ => result.healthScore1Y +
          (result.healthScore5Y - result.healthScore1Y) *
              ((selected.count - 1) / 4),
    };
  }

  static double _interpolateYearly(SimulationResult r, int year) {
    final snap = r.yearlySnapshots
        .where((s) => s.year <= year)
        .fold<YearSnapshot?>(
            null, (prev, s) => (prev == null || s.year > prev.year) ? s : prev);
    return snap?.savings ?? r.savings10Y;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: AppColors.background,
            floating: true,
            pinned: false,
            snap: true,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: AppColors.primaryLight,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingS),
                Text(l10n.resultsTitle, style: AppTextStyles.headlineSmall),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: AppConstants.spacingM),
                child: Icon(Icons.share_outlined, color: AppColors.textMuted),
              ),
            ],
          ),

          // ── Content ────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingM,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppConstants.spacingM),

                // Hero header
                _HeroSection(
                  result: result,
                  selected: selected,
                  savings: _savings,
                ).animate().fadeIn(duration: 500.ms),

                const SizedBox(height: AppConstants.spacingL),

                // Financial metric
                MetricCard(
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: AppColors.primaryLight,
                  label: l10n.financial,
                  sublabel: l10n.highLiquidity,
                  value: AppFormatters.abbreviate(_savings,
                      currencyCode: result.currency),
                  progressValue: (_savings / result.savings10Y).clamp(0, 1),
                  progressColor: AppColors.primary,
                  delayMs: 100,
                ),

                const SizedBox(height: AppConstants.spacingM),

                // Knowledge metric
                MetricCard(
                  icon: Icons.school_rounded,
                  iconColor: AppColors.accentCyan,
                  label: l10n.knowledgeLabel,
                  sublabel: l10n.advancedCognitive,
                  value: l10n
                      .iqRank((_studyHours / 10000 * 98).clamp(0, 99).toInt()),
                  progressValue: (_studyHours / (10 * 365 * 10)).clamp(0, 1),
                  progressColor: AppColors.accentCyan,
                  delayMs: 200,
                ),

                const SizedBox(height: AppConstants.spacingM),

                // Health metric
                MetricCard(
                  icon: Icons.fitness_center_rounded,
                  iconColor: AppColors.accentGreen,
                  label: l10n.healthLabel,
                  sublabel: l10n.biomarkersPeak,
                  value: l10n.vitalityScore(_healthScore.toInt()),
                  progressValue: _healthScore / 100,
                  progressColor: AppColors.accentGreen,
                  delayMs: 300,
                ),

                const SizedBox(height: AppConstants.spacingM),

                // Career metric
                MetricCard(
                  icon: Icons.work_history_rounded,
                  iconColor: AppColors.primary,
                  label: l10n.careerGrowthLabel,
                  sublabel: l10n.multiplierTrajectory,
                  value: l10n
                      .growthIndex((result.careerGrowthIndex * 100).toInt()),
                  progressValue: (result.careerGrowthIndex / 5).clamp(0, 1),
                  progressColor: AppColors.primary,
                  delayMs: 350,
                ),

                const SizedBox(height: AppConstants.spacingM),

                // Social metric
                MetricCard(
                  icon: Icons.people_alt_rounded,
                  iconColor: AppColors.accentAmber,
                  label: l10n.socialBalanceLabel,
                  sublabel:
                      l10n.isolationRisk((result.isolationRisk * 100).toInt()),
                  value: l10n.socialScore(result.socialBalanceScore.toInt()),
                  progressValue: (result.socialBalanceScore / 100).clamp(0, 1),
                  progressColor: AppColors.accentAmber,
                  delayMs: 380,
                ),

                const SizedBox(height: AppConstants.spacingL),

                // Life Stability Score (Phase 6)
                _StabilityScoreCard(result: result)
                    .animate(delay: 400.ms)
                    .fadeIn(),

                const SizedBox(height: AppConstants.spacingM),

                // Risk Analysis (Phase 5)
                _RiskAnalysisCard(result: result)
                    .animate(delay: 420.ms)
                    .fadeIn(),

                const SizedBox(height: AppConstants.spacingM),

                // Decision Impact Simulator (Phase 4)
                const _DecisionImpactSection()
                    .animate(delay: 440.ms)
                    .fadeIn(),

                const SizedBox(height: AppConstants.spacingL),

                // Chart section
                _ChartSection(
                  result: result,
                  selected: selected,
                  onOptionChanged: onOptionChanged,
                ).animate(delay: 400.ms).fadeIn(),

                const SizedBox(height: AppConstants.spacingXL),

                // Compare CTA
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: l10n.compareScenario,
                    icon: Icons.compare_arrows_rounded,
                    onPressed: onCompare,
                  ),
                ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2),

                const SizedBox(height: AppConstants.spacingS),

                Text(
                  l10n.predictionDisclaimer,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall,
                ).animate(delay: 600.ms).fadeIn(),

                const SizedBox(height: AppConstants.spacingXXL),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final SimulationResult result;
  final _TimeOption selected;
  final double savings;

  const _HeroSection({
    required this.result,
    required this.selected,
    required this.savings,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final periodLabel = selected.isMonth
        ? '${selected.count}${l10n.monthShort}'
        : l10n.yearsCount(selected.count);
    return GlassCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1E1450), Color(0xFF0F0C24)],
      ),
      borderColor: AppColors.borderGlow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.optimizedPath,
            style: AppTextStyles.overline.copyWith(
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentCyan.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              l10n.strategyScore(result.lifeStrategyScore.toInt()),
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.accentCyan),
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                    text: l10n.futureIn, style: AppTextStyles.displaySmall),
                TextSpan(
                  text: periodLabel,
                  style: AppTextStyles.displaySmall
                      .copyWith(color: AppColors.primaryLight),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: AnimatedCounter(
                  value: savings,
                  formatter: (val) => AppFormatters.currency(val,
                      currencyCode: result.currency),
                  style: AppTextStyles.moneyLarge.copyWith(fontSize: 38),
                ),
              ),
              const SizedBox(width: AppConstants.spacingS),
              GainBadge(
                text: AppFormatters.gainPercent(result.tenYearGainPercent),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.netWorth,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ChartSection extends StatelessWidget {
  final SimulationResult result;
  final _TimeOption selected;
  final ValueChanged<_TimeOption> onOptionChanged;

  const _ChartSection({
    required this.result,
    required this.selected,
    required this.onOptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(l10n.projectedGrowth, style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppConstants.spacingS),

          // Scrollable chip selector — months then years
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _kTimeOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final opt = _kTimeOptions[i];
                final isSelected = opt.label == selected.label;
                return GestureDetector(
                  onTap: () => onOptionChanged(opt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (opt.isMonth
                              ? AppColors.accentCyan
                              : AppColors.primary)
                          : AppColors.surfaceElevated,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusFull),
                      border: isSelected
                          ? null
                          : Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Text(
                      opt.label,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isSelected ? Colors.white : AppColors.textMuted,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppConstants.spacingL),

          // Line chart
          SizedBox(
            height: 200,
            child: _SavingsLineChart(
              result: result,
              selected: selected,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SavingsLineChart extends StatelessWidget {
  final SimulationResult result;
  final _TimeOption selected;

  const _SavingsLineChart({required this.result, required this.selected});

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> spots;
    final double maxX;
    double maxY;
    final bool isMonthView = selected.isMonth;

    if (isMonthView) {
      // Use monthly snapshots up to selected.count
      final snaps = result.monthlySnapshots
          .where((s) => s.month <= selected.count)
          .toList();
      if (snaps.isEmpty) {
        // Fallback: linear from monthlySavings
        spots = [
          const FlSpot(0, 0),
          FlSpot(selected.count.toDouble(),
              result.monthlySavings * selected.count),
        ];
        maxX = selected.count.toDouble();
        maxY = result.monthlySavings * selected.count * 1.5;
        if (maxY == 0) maxY = 100;
      } else {
        spots = [
          const FlSpot(0, 0),
          ...snaps.map((s) => FlSpot(s.month.toDouble(), s.savings)),
        ];
        maxX = selected.count.toDouble();
        maxY =
            snaps.map((s) => s.savings).reduce((a, b) => a > b ? a : b) * 1.15;
        if (maxY == 0) maxY = 100;
      }
    } else {
      if (result.yearlySnapshots.isEmpty) {
        return const SizedBox.shrink();
      }
      final snaps = result.yearlySnapshots
          .where((s) => s.year <= selected.count)
          .toList();
      spots = [
        const FlSpot(0, 0),
        ...snaps.map((s) => FlSpot(s.year.toDouble(), s.savings.toDouble())),
      ];
      maxX = selected.count.toDouble();
      maxY = snaps.isEmpty
          ? 100
          : snaps.map((s) => s.savings).reduce((a, b) => a > b ? a : b) * 1.1;
      if (maxY == 0) maxY = 100;
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX,
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.border,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: isMonthView ? 1 : 1,
              getTitlesWidget: (value, meta) {
                final l10n = AppLocalizations.of(context)!;
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  isMonthView
                      ? '${value.toInt()}${l10n.monthShort}'
                      : '${value.toInt()}${l10n.yearShort}',
                  style: AppTextStyles.labelSmall,
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.4,
            color: isMonthView ? AppColors.accentCyan : AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: 4,
                color:
                    isMonthView ? AppColors.accentCyan : AppColors.primaryLight,
                strokeWidth: 2,
                strokeColor: AppColors.background,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  (isMonthView ? AppColors.accentCyan : AppColors.primary)
                      .withValues(alpha: 0.4),
                  (isMonthView ? AppColors.accentCyan : AppColors.primary)
                      .withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.surface,
            getTooltipItems: (spots) => spots
                .map((s) => LineTooltipItem(
                      AppFormatters.abbreviate(s.y,
                          currencyCode: result.currency),
                      AppTextStyles.labelLarge,
                    ))
                .toList(),
          ),
        ),
      ),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: AppConstants.spacingL),
            Text(l10n.simulatingFuture, style: AppTextStyles.bodyLarge),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EmptyResultsView extends StatelessWidget {
  final VoidCallback onStartSimulation;

  const _EmptyResultsView({required this.onStartSimulation});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: AppColors.primaryLight,
                  size: 40,
                ),
              ),
              const SizedBox(height: AppConstants.spacingL),
              Text(
                l10n.noSimulationYet,
                style: AppTextStyles.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingM),
              Text(
                l10n.noSimulationSub,
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingXL),
              PrimaryButton(
                label: l10n.startSimulation,
                icon: Icons.bolt_rounded,
                onPressed: onStartSimulation,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Phase 6: Life Stability Score
// ─────────────────────────────────────────────────────────────────────────────

class _StabilityScoreCard extends StatelessWidget {
  final SimulationResult result;

  const _StabilityScoreCard({required this.result});

  double get _stabilityScore {
    final riskFactor = (100 - result.overallRiskIndex) * 0.4;
    final stratFactor = result.lifeStrategyScore * 0.4;
    final energyFactor = result.energyScore10Y * 0.2;
    return (riskFactor + stratFactor + energyFactor).clamp(0, 100);
  }

  Color get _scoreColor {
    final s = _stabilityScore;
    if (s >= 70) return AppColors.accentGreen;
    if (s >= 45) return AppColors.accentAmber;
    return AppColors.accentRed;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final score = _stabilityScore;
    final color = _scoreColor;

    return GlassCard(
      child: Row(
        children: [
          // Circular gauge
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 6,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeCap: StrokeCap.round,
                )
                    .animate(onPlay: (c) => c.forward())
                    .custom(
                      duration: 1200.ms,
                      curve: Curves.easeOutCubic,
                      builder: (ctx, value, child) =>
                          CircularProgressIndicator(
                        value: (score / 100) * value,
                        strokeWidth: 6,
                        backgroundColor: color.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                Center(
                  child: Text(
                    '${score.toInt()}',
                    style: AppTextStyles.headlineLarge.copyWith(color: color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spacingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.stabilityScoreLabel,
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.5,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${score.toInt()}/100',
                  style: AppTextStyles.headlineMedium.copyWith(color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  score >= 70
                      ? 'Excellent life balance'
                      : score >= 45
                          ? 'Moderate life balance'
                          : 'Needs improvement',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: AppConstants.spacingS),
                // Mini bar breakdown
                Row(
                  children: [
                    _ScoreBar(
                      label: 'Risk',
                      value: (100 - result.overallRiskIndex) / 100,
                      color: AppColors.accentCyan,
                    ),
                    const SizedBox(width: 4),
                    _ScoreBar(
                      label: 'Life',
                      value: result.lifeStrategyScore / 100,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    _ScoreBar(
                      label: 'Energy',
                      value: result.energyScore10Y / 100,
                      color: AppColors.accentAmber,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final double value; // 0.0 to 1.0
  final Color color;

  const _ScoreBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(fontSize: 9),
          ),
          const SizedBox(height: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value.clamp(0, 1),
              minHeight: 4,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Phase 5: Risk Analysis
// ─────────────────────────────────────────────────────────────────────────────

class _RiskAnalysisCard extends StatelessWidget {
  final SimulationResult result;

  const _RiskAnalysisCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.riskAnalysis, style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppConstants.spacingM),
          // 2x2 grid of risk tiles
          Row(
            children: [
              Expanded(
                child: _RiskTile(
                  label: l10n.burnoutRiskLabel,
                  risk: result.burnoutRisk,
                  icon: Icons.local_fire_department_rounded,
                  l10n: l10n,
                ),
              ),
              const SizedBox(width: AppConstants.spacingS),
              Expanded(
                child: _RiskTile(
                  label: l10n.financialRiskLabel,
                  risk: result.financialCollapseRisk,
                  icon: Icons.account_balance_rounded,
                  l10n: l10n,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingS),
          Row(
            children: [
              Expanded(
                child: _RiskTile(
                  label: l10n.careerRiskLabel,
                  risk: result.careerStagnationRisk,
                  icon: Icons.work_rounded,
                  l10n: l10n,
                ),
              ),
              const SizedBox(width: AppConstants.spacingS),
              Expanded(
                child: _RiskTile(
                  label: l10n.energyRiskLabel,
                  risk: result.energyDepletionRisk,
                  icon: Icons.bolt_rounded,
                  l10n: l10n,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RiskTile extends StatelessWidget {
  final String label;
  final double risk; // 0.0 to 1.0
  final IconData icon;
  final AppLocalizations l10n;

  const _RiskTile({
    required this.label,
    required this.risk,
    required this.icon,
    required this.l10n,
  });

  Color get _color {
    if (risk < 0.35) return AppColors.accentGreen;
    if (risk < 0.65) return AppColors.accentAmber;
    return AppColors.accentRed;
  }

  String get _levelLabel {
    if (risk < 0.35) return l10n.riskLow;
    if (risk < 0.65) return l10n.riskMedium;
    return l10n.riskHigh;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final percent = (risk * 100).toInt();
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.75),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            '$percent%',
            style: AppTextStyles.headlineSmall.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: risk.clamp(0, 1),
              minHeight: 3,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _levelLabel,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Phase 4: Decision Impact Simulator
// ─────────────────────────────────────────────────────────────────────────────

class _DecisionImpactSection extends ConsumerStatefulWidget {
  const _DecisionImpactSection();

  @override
  ConsumerState<_DecisionImpactSection> createState() =>
      _DecisionImpactSectionState();
}

class _DecisionImpactSectionState
    extends ConsumerState<_DecisionImpactSection> {
  bool _expanded = false;

  // Local slider values (start from current input)
  late double _savingPct;
  late double _studyHours;
  late int _workoutDays;
  late double _socialMediaHours;
  late double _skillHours;

  bool _initialized = false;

  void _initFromInput(SimulationInput input) {
    if (_initialized) return;
    _savingPct = input.savingPercentage;
    _studyHours = input.dailyStudyHours;
    _workoutDays = input.workoutDaysPerWeek;
    _socialMediaHours = input.socialMediaHours;
    _skillHours = input.weeklySkillHours;
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final input = ref.watch(simulationInputProvider);
    _initFromInput(input);

    // Live-preview simulation
    final previewInput = input.copyWith(
      savingPercentage: _savingPct,
      dailyStudyHours: _studyHours,
      workoutDaysPerWeek: _workoutDays,
      socialMediaHours: _socialMediaHours,
      weeklySkillHours: _skillHours,
    );
    final currentResult = ref.watch(activeResultProvider);
    final previewResult =
        SimulationEngine.run(previewInput, name: 'Preview');

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / toggle
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentCyan.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: AppColors.accentCyan,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.decisionImpactTitle,
                        style: AppTextStyles.headlineSmall,
                      ),
                      Text(
                        l10n.adjustHabitsHint,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),

          // Collapsible content
          AnimatedSize(
            duration: AppConstants.animationMedium,
            curve: Curves.easeInOut,
            child: _expanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppConstants.spacingL),
                      const Divider(color: AppColors.border, height: 1),
                      const SizedBox(height: AppConstants.spacingM),

                      _SliderRow(
                        label: l10n.savingRate,
                        value: _savingPct,
                        min: 0.0,
                        max: 0.5,
                        divisions: 10,
                        displayValue:
                            '${(_savingPct * 100).toInt()}%',
                        onChanged: (v) =>
                            setState(() => _savingPct = v),
                        color: AppColors.primaryLight,
                      ),

                      _SliderRow(
                        label: l10n.study,
                        value: _studyHours,
                        min: 0,
                        max: 10,
                        divisions: 20,
                        displayValue:
                            '${_studyHours.toStringAsFixed(1)}h',
                        onChanged: (v) =>
                            setState(() => _studyHours = v),
                        color: AppColors.accentCyan,
                      ),

                      _SliderRow(
                        label: l10n.workout,
                        value: _workoutDays.toDouble(),
                        min: 0,
                        max: 7,
                        divisions: 7,
                        displayValue: '$_workoutDays d/wk',
                        onChanged: (v) =>
                            setState(() => _workoutDays = v.round()),
                        color: AppColors.accentGreen,
                      ),

                      _SliderRow(
                        label: l10n.weeklySkillDev,
                        value: _skillHours,
                        min: 0,
                        max: 20,
                        divisions: 20,
                        displayValue:
                            '${_skillHours.toStringAsFixed(1)}h/wk',
                        onChanged: (v) =>
                            setState(() => _skillHours = v),
                        color: AppColors.accentAmber,
                      ),

                      _SliderRow(
                        label: l10n.socialMedia,
                        value: _socialMediaHours,
                        min: 0,
                        max: 8,
                        divisions: 16,
                        displayValue:
                            '${_socialMediaHours.toStringAsFixed(1)}h/d',
                        onChanged: (v) =>
                            setState(() => _socialMediaHours = v),
                        color: AppColors.accentRed,
                      ),

                      const SizedBox(height: AppConstants.spacingL),

                      // Impact comparison
                      if (currentResult != null)
                        _ImpactComparison(
                          current: currentResult,
                          preview: previewResult,
                        ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String displayValue;
  final ValueChanged<double> onChanged;
  final Color color;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.displayValue,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.labelMedium),
              Text(
                displayValue,
                style: AppTextStyles.labelMedium.copyWith(color: color),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.15),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.1),
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 7),
              trackHeight: 3,
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImpactComparison extends StatelessWidget {
  final SimulationResult current;
  final SimulationResult preview;

  const _ImpactComparison({
    required this.current,
    required this.preview,
  });

  @override
  Widget build(BuildContext context) {
    final savingsDelta = preview.savings10Y - current.savings10Y;
    final riskDelta = preview.overallRiskIndex - current.overallRiskIndex;
    final energyDelta = preview.energyScore10Y - current.energyScore10Y;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PROJECTED IMPACT',
            style: AppTextStyles.overline.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),
          Row(
            children: [
              Expanded(
                child: _DeltaMetric(
                  label: '10Y Wealth',
                  delta: savingsDelta,
                  current: current.savings10Y,
                  isMonetary: true,
                  currency: current.currency,
                ),
              ),
              Expanded(
                child: _DeltaMetric(
                  label: 'Risk Index',
                  delta: -riskDelta, // negative is good
                  current: current.overallRiskIndex,
                  isMonetary: false,
                ),
              ),
              Expanded(
                child: _DeltaMetric(
                  label: 'Energy 10Y',
                  delta: energyDelta,
                  current: current.energyScore10Y,
                  isMonetary: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeltaMetric extends StatelessWidget {
  final String label;
  final double delta;
  final double current;
  final bool isMonetary;
  final String currency;

  const _DeltaMetric({
    required this.label,
    required this.delta,
    required this.current,
    this.isMonetary = false,
    this.currency = 'USD',
  });

  Color get _color {
    if (delta > 0) return AppColors.accentGreen;
    if (delta < 0) return AppColors.accentRed;
    return AppColors.textMuted;
  }

  String get _sign => delta > 0 ? '+' : '';

  String get _deltaStr {
    if (isMonetary) {
      return '$_sign${AppFormatters.compactCurrency(delta.abs(), currencyCode: currency)}';
    }
    return '$_sign${delta.toStringAsFixed(1)}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          isMonetary
              ? AppFormatters.compactCurrency(current + delta,
                  currencyCode: currency)
              : (current + delta).toStringAsFixed(0),
          style: AppTextStyles.labelLarge,
        ),
        Text(
          _deltaStr,
          style: AppTextStyles.labelSmall.copyWith(
            color: _color,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(fontSize: 9),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
