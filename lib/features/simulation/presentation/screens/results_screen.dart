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
import '../../domain/models/simulation_result.dart';
import '../widgets/shared_widgets.dart';

/// Screen 2 — "Future Dashboard"
/// Displays the simulation results with charts, counters, and metrics.
class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  /// Which projection year the chart/header shows: 1, 5, or 10.
  int _selectedYear = 5;

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
      selectedYear: _selectedYear,
      onYearChanged: (y) => setState(() => _selectedYear = y),
      onCompare: () => context.go(AppRoutes.comparison),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ResultsDashboard extends StatelessWidget {
  final SimulationResult result;
  final int selectedYear;
  final ValueChanged<int> onYearChanged;
  final VoidCallback onCompare;

  const _ResultsDashboard({
    required this.result,
    required this.selectedYear,
    required this.onYearChanged,
    required this.onCompare,
  });

  double get _savings {
    return switch (selectedYear) {
      1 => result.savings1Y,
      5 => result.savings5Y,
      _ => result.savings10Y,
    };
  }

  double get _studyHours {
    return switch (selectedYear) {
      1 => result.studyHours1Y,
      5 => result.studyHours5Y,
      _ => result.studyHours10Y,
    };
  }

  double get _healthScore {
    return switch (selectedYear) {
      1 => result.healthScore1Y,
      5 => result.healthScore5Y,
      _ => result.healthScore10Y,
    };
  }

  @override
  Widget build(BuildContext context) {
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
                Text('Future Dashboard', style: AppTextStyles.headlineSmall),
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
                  selectedYear: selectedYear,
                  savings: _savings,
                ).animate().fadeIn(duration: 500.ms),

                const SizedBox(height: AppConstants.spacingL),

                // Financial metric
                MetricCard(
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: AppColors.primaryLight,
                  label: 'Financial',
                  sublabel: 'High liquidity strategy',
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
                  label: 'Knowledge',
                  sublabel: 'Advanced cognitive dev.',
                  value:
                      '${(_studyHours / 10000 * 98).clamp(0, 99).toInt()}% IQ Rank',
                  progressValue: (_studyHours / (10 * 365 * 10)).clamp(0, 1),
                  progressColor: AppColors.accentCyan,
                  delayMs: 200,
                ),

                const SizedBox(height: AppConstants.spacingM),

                // Health metric
                MetricCard(
                  icon: Icons.fitness_center_rounded,
                  iconColor: AppColors.accentGreen,
                  label: 'Health',
                  sublabel: 'Biomarkers in peak range',
                  value: '${_healthScore.toInt()}% Vitality',
                  progressValue: _healthScore / 100,
                  progressColor: AppColors.accentGreen,
                  delayMs: 300,
                ),

                const SizedBox(height: AppConstants.spacingM),

                // Career metric
                MetricCard(
                  icon: Icons.work_history_rounded,
                  iconColor: AppColors.primary,
                  label: 'Career Growth',
                  sublabel: 'Multiplier trajectory',
                  value: '${(result.careerGrowthIndex * 100).toInt()}% Index',
                  progressValue: (result.careerGrowthIndex / 5).clamp(0, 1),
                  progressColor: AppColors.primary,
                  delayMs: 350,
                ),

                const SizedBox(height: AppConstants.spacingM),

                // Social metric
                MetricCard(
                  icon: Icons.people_alt_rounded,
                  iconColor: AppColors.accentAmber,
                  label: 'Social Balance',
                  sublabel:
                      'Isolation Risk: ${(result.isolationRisk * 100).toInt()}%',
                  value: '${result.socialBalanceScore.toInt()}/100',
                  progressValue: (result.socialBalanceScore / 100).clamp(0, 1),
                  progressColor: AppColors.accentAmber,
                  delayMs: 380,
                ),

                const SizedBox(height: AppConstants.spacingL),

                // Chart section
                _ChartSection(
                  result: result,
                  selectedYear: selectedYear,
                  onYearChanged: onYearChanged,
                ).animate(delay: 400.ms).fadeIn(),

                const SizedBox(height: AppConstants.spacingXL),

                // Compare CTA
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Compare Another Scenario',
                    icon: Icons.compare_arrows_rounded,
                    onPressed: onCompare,
                  ),
                ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2),

                const SizedBox(height: AppConstants.spacingS),

                Text(
                  'Predictions are based on current market trends and\nsimulation parameters.',
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
  final int selectedYear;
  final double savings;

  const _HeroSection({
    required this.result,
    required this.selectedYear,
    required this.savings,
  });

  @override
  Widget build(BuildContext context) {
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
            'SCENARIO: OPTIMIZED PATH',
            style: AppTextStyles.overline.copyWith(
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentCyan.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Life Strategy Score: ${result.lifeStrategyScore.toInt()}/100',
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.accentCyan),
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                    text: 'Your Future in ', style: AppTextStyles.displaySmall),
                TextSpan(
                  text: '$selectedYear Year${selectedYear > 1 ? 's' : ''}',
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
              AnimatedCounter(
                value: savings,
                formatter: (val) =>
                    AppFormatters.currency(val, currencyCode: result.currency),
                style: AppTextStyles.moneyLarge.copyWith(fontSize: 38),
              ),
              const SizedBox(width: AppConstants.spacingS),
              GainBadge(
                text: AppFormatters.gainPercent(result.tenYearGainPercent),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Estimated Total Net Worth',
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
  final int selectedYear;
  final ValueChanged<int> onYearChanged;

  const _ChartSection({
    required this.result,
    required this.selectedYear,
    required this.onYearChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + year selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Projected Growth', style: AppTextStyles.headlineSmall),
              Row(
                children: [1, 5, 10].map((y) {
                  final isSelected = y == selectedYear;
                  return GestureDetector(
                    onTap: () => onYearChanged(y),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surfaceElevated,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusFull),
                      ),
                      child: Text(
                        '${y}Y',
                        style: AppTextStyles.labelSmall.copyWith(
                          color:
                              isSelected ? Colors.white : AppColors.textMuted,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingL),

          // Line chart
          SizedBox(
            height: 200,
            child: _SavingsLineChart(
              snapshots: result.yearlySnapshots
                  .where((s) => s.year <= selectedYear)
                  .toList(),
              currency: result.currency,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SavingsLineChart extends StatelessWidget {
  final List snapshots;
  final String currency;

  const _SavingsLineChart({required this.snapshots, required this.currency});

  @override
  Widget build(BuildContext context) {
    if (snapshots.isEmpty) return const SizedBox.shrink();

    final maxY = (snapshots.map((s) => s.savings).reduce(
                  (a, b) => a > b ? a : b,
                ) *
            1.1)
        .toDouble();

    final spots = snapshots
        .map((s) => FlSpot(s.year.toDouble(), s.savings.toDouble()))
        .toList();

    return LineChart(
      LineChartData(
        minX: 1,
        maxX: snapshots.last.year.toDouble(),
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
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Text(
                  'Year ${value.toInt()}',
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
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: 4,
                color: AppColors.primaryLight,
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
                  AppColors.primary.withOpacity(0.4),
                  AppColors.primary.withOpacity(0.0),
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
                      AppFormatters.abbreviate(s.y, currencyCode: currency),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: AppConstants.spacingL),
            Text('Simulating your future...', style: AppTextStyles.bodyLarge),
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
                  color: AppColors.primary.withOpacity(0.1),
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
                'No Simulation Yet',
                style: AppTextStyles.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingM),
              Text(
                'Run your first simulation to see your projected future here.',
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingXL),
              PrimaryButton(
                label: 'Start Simulation',
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
