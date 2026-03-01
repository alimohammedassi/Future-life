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
import '../widgets/shared_widgets.dart';

/// Screen 3 — "Scenario Comparison"
/// Side-by-side comparison of two saved scenarios with a dual line chart.
class ComparisonScreen extends ConsumerStatefulWidget {
  const ComparisonScreen({super.key});

  @override
  ConsumerState<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends ConsumerState<ComparisonScreen> {
  @override
  Widget build(BuildContext context) {
    final scenarios = ref.watch(scenariosProvider);
    final scenarioA = scenarios.scenarioA;

    if (scenarioA == null) {
      return _NoScenarioView(
        onGoToSimulation: () => context.go(AppRoutes.input),
      );
    }

    if (scenarios.scenarioB == null) {
      return _SetupScenarioBView(
        scenarioA: scenarioA,
        onRunScenarioB: () => _showSetupBottomSheet(context),
      );
    }

    return _ComparisonDashboard(
      scenarioA: scenarioA,
      scenarioB: scenarios.scenarioB!,
      onSwitchToB: () {
        ref.read(scenariosProvider.notifier).clearAll();
        final inputB = ref.read(simulationInputProvider);
        ref.read(scenariosProvider.notifier).runScenarioA(inputB);
        context.go(AppRoutes.results);
      },
    );
  }

  void _showSetupBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _ScenarioBInputSheet(
        onRun: (input) async {
          Navigator.pop(context);
          await ref.read(scenariosProvider.notifier).runScenarioB(
                input,
                name: 'Optimized Path',
              );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ComparisonDashboard extends StatelessWidget {
  final SimulationResult scenarioA;
  final SimulationResult scenarioB;
  final VoidCallback onSwitchToB;

  const _ComparisonDashboard({
    required this.scenarioA,
    required this.scenarioB,
    required this.onSwitchToB,
  });

  @override
  Widget build(BuildContext context) {
    final savingsDiff = (scenarioB.savings10Y - scenarioA.savings10Y) /
        scenarioA.savings10Y.abs();
    final healthDiff = (scenarioB.healthScore10Y - scenarioA.healthScore10Y) /
        scenarioA.healthScore10Y.abs();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            floating: true,
            pinned: false,
            snap: true,
            automaticallyImplyLeading: false,
            title: Text(
              'Scenario Comparison',
              style: AppTextStyles.headlineSmall,
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: AppConstants.spacingM),
                child: Icon(
                  Icons.show_chart_rounded,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingM,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppConstants.spacingM),

                // Scenario cards row
                Row(
                  children: [
                    Expanded(
                      child: _ScenarioSummaryCard(
                        label: 'SCENARIO A',
                        name: scenarioA.name,
                        savings10Y: scenarioA.savings10Y,
                        currency: scenarioA.currency,
                        color: AppColors.primary,
                        isActive: true,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingM),
                    Expanded(
                      child: _ScenarioSummaryCard(
                        label: 'SCENARIO B',
                        name: scenarioB.name,
                        savings10Y: scenarioB.savings10Y,
                        currency: scenarioB.currency,
                        color: AppColors.accentCyan,
                        isActive: false,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 500.ms),

                const SizedBox(height: AppConstants.spacingL),

                // Dual line chart
                _DualLineChartCard(
                  scenarioA: scenarioA,
                  scenarioB: scenarioB,
                ).animate(delay: 200.ms).fadeIn(),

                const SizedBox(height: AppConstants.spacingL),

                Text(
                  'Detailed Impact',
                  style: AppTextStyles.headlineMedium,
                ).animate(delay: 300.ms).fadeIn(),

                const SizedBox(height: AppConstants.spacingM),

                // Savings comparison row
                _ImpactRow(
                  icon: Icons.savings_rounded,
                  iconColor: AppColors.accentGreen,
                  label: 'Monthly Savings',
                  valueA: AppFormatters.abbreviate(scenarioA.monthlySavings,
                      currencyCode: scenarioA.currency),
                  valueB: AppFormatters.abbreviate(scenarioB.monthlySavings,
                      currencyCode: scenarioB.currency),
                  diffPercent: savingsDiff,
                  delayMs: 400,
                ),

                const SizedBox(height: AppConstants.spacingM),

                // Health comparison row
                _ImpactRow(
                  icon: Icons.fitness_center_rounded,
                  iconColor: AppColors.accentAmber,
                  label: 'Health Index',
                  valueA: AppFormatters.score(scenarioA.healthScore10Y),
                  valueB: AppFormatters.score(scenarioB.healthScore10Y),
                  diffPercent: healthDiff,
                  delayMs: 500,
                ),

                const SizedBox(height: AppConstants.spacingM),

                // Knowledge comparison row
                _ImpactRow(
                  icon: Icons.school_rounded,
                  iconColor: AppColors.accentCyan,
                  label: 'Knowledge Growth',
                  valueA: 'Linear',
                  valueB: 'Exponential',
                  diffPercent:
                      (scenarioB.studyHours10Y - scenarioA.studyHours10Y) /
                          (scenarioA.studyHours10Y == 0
                              ? 1
                              : scenarioA.studyHours10Y),
                  delayMs: 600,
                ),

                const SizedBox(height: AppConstants.spacingXL),

                // Switch CTA
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Switch to Optimized Path',
                    icon: Icons.rocket_launch_rounded,
                    gradient: AppColors.cyanGradient,
                    onPressed: onSwitchToB,
                  ),
                ).animate(delay: 700.ms).fadeIn().slideY(begin: 0.2),

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

class _ScenarioSummaryCard extends StatelessWidget {
  final String label;
  final String name;
  final double savings10Y;
  final String currency;
  final Color color;
  final bool isActive;

  const _ScenarioSummaryCard({
    required this.label,
    required this.name,
    required this.savings10Y,
    required this.currency,
    required this.color,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: color.withOpacity(0.3),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color.withOpacity(0.12), AppColors.cardBackground],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.overline.copyWith(color: color)),
              isActive
                  ? const Icon(Icons.history_rounded,
                      color: AppColors.textMuted, size: 16)
                  : const Icon(Icons.add_circle_outline_rounded,
                      color: AppColors.textMuted, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(name, style: AppTextStyles.headlineSmall),
          const SizedBox(height: 4),
          Text(
            AppFormatters.abbreviate(savings10Y, currencyCode: currency),
            style: AppTextStyles.moneyMedium,
          ),
          const SizedBox(height: 2),
          Text('Net Worth @ 10yrs', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DualLineChartCard extends StatelessWidget {
  final SimulationResult scenarioA;
  final SimulationResult scenarioB;

  const _DualLineChartCard({
    required this.scenarioA,
    required this.scenarioB,
  });

  @override
  Widget build(BuildContext context) {
    final spotsA = scenarioA.yearlySnapshots
        .map((s) => FlSpot(s.year.toDouble(), s.savings))
        .toList();
    final spotsB = scenarioB.yearlySnapshots
        .map((s) => FlSpot(s.year.toDouble(), s.savings))
        .toList();

    final maxY = [
          ...scenarioA.yearlySnapshots.map((s) => s.savings),
          ...scenarioB.yearlySnapshots.map((s) => s.savings),
        ].reduce((a, b) => a > b ? a : b) *
        1.1;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '10-Year Projections',
                style: AppTextStyles.headlineSmall,
              ),
              Row(
                children: [
                  _LegendDot(color: AppColors.primary, label: 'Current'),
                  const SizedBox(width: 12),
                  _LegendDot(
                      color: AppColors.accentCyan.withOpacity(0.8),
                      label: 'Optimized',
                      isDashed: true),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingL),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minX: 1,
                maxX: 10,
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
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 4.5,
                      getTitlesWidget: (v, _) => Text(
                        v == 1
                            ? 'Year 1'
                            : v.toInt() == 5
                                ? 'Year 5'
                                : 'Year 10',
                        style: AppTextStyles.labelSmall,
                      ),
                    ),
                  ),
                ),
                lineBarsData: [
                  // Scenario A (solid purple)
                  LineChartBarData(
                    spots: spotsA,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withOpacity(0.2),
                          AppColors.primary.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                  // Scenario B (dashed cyan)
                  LineChartBarData(
                    spots: spotsB,
                    isCurved: true,
                    color: AppColors.accentCyan,
                    barWidth: 2.5,
                    dashArray: [6, 4],
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.accentCyan.withOpacity(0.1),
                          AppColors.accentCyan.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDashed;

  const _LegendDot({
    required this.color,
    required this.label,
    this.isDashed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 2,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ImpactRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String valueA;
  final String valueB;
  final double diffPercent;
  final int delayMs;

  const _ImpactRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.valueA,
    required this.valueB,
    required this.diffPercent,
    this.delayMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.labelMedium),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(valueA,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(Icons.arrow_forward_rounded,
                          color: AppColors.textMuted, size: 14),
                    ),
                    Text(
                      valueB,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.accentCyan,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GainBadge(
            text: AppFormatters.gainPercent(diffPercent),
            isPositive: diffPercent >= 0,
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: delayMs))
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.05, end: 0, duration: 400.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Placeholder / Setup views
// ─────────────────────────────────────────────────────────────────────────────

class _NoScenarioView extends StatelessWidget {
  final VoidCallback onGoToSimulation;

  const _NoScenarioView({required this.onGoToSimulation});

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
              const Icon(
                Icons.compare_arrows_rounded,
                color: AppColors.textMuted,
                size: 64,
              ),
              const SizedBox(height: AppConstants.spacingL),
              Text(
                'Run a simulation first to compare scenarios.',
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingXL),
              PrimaryButton(
                label: 'Go to Simulation',
                icon: Icons.auto_graph_rounded,
                onPressed: onGoToSimulation,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SetupScenarioBView extends StatelessWidget {
  final SimulationResult scenarioA;
  final VoidCallback onRunScenarioB;

  const _SetupScenarioBView({
    required this.scenarioA,
    required this.onRunScenarioB,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'Scenario Comparison',
          style: AppTextStyles.headlineSmall,
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          children: [
            _ScenarioSummaryCard(
              label: 'SCENARIO A',
              name: scenarioA.name,
              savings10Y: scenarioA.savings10Y,
              currency: scenarioA.currency,
              color: AppColors.primary,
              isActive: true,
            ),
            const Spacer(),
            GlassCard(
              borderColor: AppColors.primary.withOpacity(0.3),
              child: Column(
                children: [
                  const Icon(
                    Icons.add_circle_outline_rounded,
                    color: AppColors.primaryLight,
                    size: 40,
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  Text(
                    'Add Scenario B',
                    style: AppTextStyles.headlineMedium,
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    'Set up a second scenario with different\nhabits to compare outcomes.',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Setup Scenario B',
                icon: Icons.add_rounded,
                onPressed: onRunScenarioB,
              ),
            ),
            const SizedBox(height: AppConstants.spacingXL),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Bottom sheet to enter parameters for Scenario B.
class _ScenarioBInputSheet extends StatefulWidget {
  final Future<void> Function(SimulationInput input) onRun;

  const _ScenarioBInputSheet({required this.onRun});

  @override
  State<_ScenarioBInputSheet> createState() => _ScenarioBInputSheetState();
}

class _ScenarioBInputSheetState extends State<_ScenarioBInputSheet> {
  double _income = 6000;
  double _saving = 0.35;
  double _study = 4.0;
  int _workout = 6;
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppConstants.spacingM,
        right: AppConstants.spacingM,
        top: AppConstants.spacingL,
        bottom:
            MediaQuery.of(context).viewInsets.bottom + AppConstants.spacingL,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),
            Text('Setup Scenario B', style: AppTextStyles.headlineLarge),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              'Enter your optimized daily habits.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Income
            Text('Monthly Income: \$${_income.toInt()}',
                style: AppTextStyles.labelLarge),
            Slider(
              value: _income,
              min: 1000,
              max: 20000,
              divisions: 190,
              onChanged: (v) => setState(() => _income = v),
            ),

            // Saving %
            Text('Saving: ${(_saving * 100).toInt()}%',
                style: AppTextStyles.labelLarge),
            Slider(
              value: _saving,
              min: 0,
              max: 0.5,
              divisions: 50,
              onChanged: (v) => setState(() => _saving = v),
            ),

            // Study hours
            Text('Study: ${_study.toStringAsFixed(1)} hrs/day',
                style: AppTextStyles.labelLarge),
            Slider(
              value: _study,
              min: 0,
              max: 10,
              divisions: 20,
              onChanged: (v) => setState(() => _study = v),
            ),

            // Workout days
            Text('Workout: $_workout days/week',
                style: AppTextStyles.labelLarge),
            Slider(
              value: _workout.toDouble(),
              min: 0,
              max: 7,
              divisions: 7,
              onChanged: (v) => setState(() => _workout = v.toInt()),
            ),

            const SizedBox(height: AppConstants.spacingL),

            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Run Scenario B',
                icon: Icons.rocket_launch_rounded,
                isLoading: _isRunning,
                onPressed: () async {
                  setState(() => _isRunning = true);
                  final input = SimulationInput(
                    monthlyIncome: _income,
                    savingPercentage: _saving,
                    dailyStudyHours: _study,
                    workoutDaysPerWeek: _workout,
                    currency: 'USD',
                    careerField: 'Technology',
                    weeklySkillHours: 5.0,
                    certsPerYear: 1,
                    socialMediaHours: 2.0,
                    familyHours: 10.0,
                    networkingHours: 2.0,
                  );
                  await widget.onRun(input);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
