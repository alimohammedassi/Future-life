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
import '../../../../l10n/generated/app_localizations.dart';
import '../widgets/shared_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Colour palette — each scenario gets a distinct colour
// ─────────────────────────────────────────────────────────────────────────────

const _scenarioColors = [
  Color(0xFF7C3AED), // A — purple (original)
  Color(0xFF06B6D4), // B — cyan
  Color(0xFF10B981), // C — green
  Color(0xFFF59E0B), // D — amber
  Color(0xFFEF4444), // E — red
];

Color _colorFor(int index) => _scenarioColors[index % _scenarioColors.length];
String _labelFor(int index) =>
    index == 0 ? 'A' : kScenarioLabels[index - 1]; // 0→A, 1→B, 2→C …

// ─────────────────────────────────────────────────────────────────────────────
// ComparisonScreen (entry)
// ─────────────────────────────────────────────────────────────────────────────

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

    if (scenarios.extraScenarios.isEmpty) {
      return _SetupFirstExtraView(
        scenarioA: scenarioA,
        onAddScenario: () => _showAddScenarioSheet(context),
      );
    }

    return _MultiComparisonDashboard(
      onAddScenario:
          scenarios.canAddMore ? () => _showAddScenarioSheet(context) : null,
    );
  }

  void _showAddScenarioSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _AddScenarioSheet(
        nextLabel: _nextLabel(),
        onRun: (input, name) async {
          Navigator.pop(context);
          await ref
              .read(scenariosProvider.notifier)
              .addExtraScenario(input, name: name);
        },
      ),
    );
  }

  String _nextLabel() {
    final count = ref.read(scenariosProvider).extraScenarios.length;
    return kScenarioLabels[count < kScenarioLabels.length ? count : 0];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Multi-Scenario Dashboard
// ─────────────────────────────────────────────────────────────────────────────

class _MultiComparisonDashboard extends ConsumerWidget {
  final VoidCallback? onAddScenario;

  const _MultiComparisonDashboard({this.onAddScenario});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scenariosProvider);
    final all = state.all; // [A, B, C, …]
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: onAddScenario != null
          ? FloatingActionButton.extended(
              onPressed: onAddScenario,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                'Add Scenario',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ).animate().scale(delay: 600.ms, duration: 300.ms)
          : null,
      body: CustomScrollView(
        slivers: [
          // ── AppBar ────────────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: AppColors.background,
            floating: true,
            pinned: false,
            snap: true,
            automaticallyImplyLeading: false,
            title:
                Text(l10n.comparisonTitle, style: AppTextStyles.headlineSmall),
            actions: [
              // Clear all extra — keep only A
              if (state.extraScenarios.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.layers_clear_rounded,
                      color: AppColors.textMuted),
                  tooltip: 'Clear comparisons',
                  onPressed: () =>
                      ref.read(scenariosProvider.notifier).clearComparison(),
                ),
              const SizedBox(width: 4),
            ],
          ),

          SliverPadding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppConstants.spacingM),

                // ── Scenario chip row ────────────────────────────────────
                _ScenarioChipRow(all: all).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: AppConstants.spacingL),

                // ── Multi-line chart ─────────────────────────────────────
                _MultiLineChartCard(all: all)
                    .animate(delay: 150.ms)
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: AppConstants.spacingL),

                // ── Net Worth comparison table ────────────────────────────
                _ComparisonTableCard(all: all, l10n: l10n)
                    .animate(delay: 250.ms)
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: AppConstants.spacingL),

                // ── Per-scenario detail cards ────────────────────────────
                ...List.generate(all.length, (i) {
                  final s = all[i];
                  final color = _colorFor(i);
                  final label = _labelFor(i);
                  return _ScenarioDetailCard(
                    scenario: s,
                    color: color,
                    label: label,
                    baseline: all[0],
                    isBaseline: i == 0,
                    index: i,
                    onRemove: i > 0
                        ? () => ref
                            .read(scenariosProvider.notifier)
                            .removeExtraScenario(i - 1)
                        : null,
                  )
                      .animate(delay: Duration(milliseconds: 350 + i * 80))
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: 0.05, end: 0, duration: 400.ms);
                }),

                // Bottom padding for FAB
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scenario chip row (coloured pills at the top)
// ─────────────────────────────────────────────────────────────────────────────

class _ScenarioChipRow extends StatelessWidget {
  final List<SimulationResult> all;
  const _ScenarioChipRow({required this.all});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(all.length, (i) {
          final color = _colorFor(i);
          final label = _labelFor(i);
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: color.withValues(alpha: 0.4), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Scenario $label',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: color,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    all[i].name,
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Multi-line chart card (savings over 10 years — one line per scenario)
// ─────────────────────────────────────────────────────────────────────────────

class _MultiLineChartCard extends StatelessWidget {
  final List<SimulationResult> all;
  const _MultiLineChartCard({required this.all});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Build spots for every scenario
    final barDataList = List.generate(all.length, (i) {
      final color = _colorFor(i);
      final spots = all[i]
          .yearlySnapshots
          .map((s) => FlSpot(s.year.toDouble(), s.savings))
          .toList();
      final isDashed = i > 0;
      return LineChartBarData(
        spots: spots,
        isCurved: true,
        color: color,
        barWidth: i == 0 ? 3 : 2,
        dashArray: isDashed ? [6, 4] : null,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: i == 0,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.18),
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
      );
    });

    final allSavings =
        all.expand((r) => r.yearlySnapshots.map((s) => s.savings)).toList();
    final maxY = allSavings.reduce((a, b) => a > b ? a : b) * 1.12;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.tenYearProjections, style: AppTextStyles.headlineSmall),
              // Legend dots
              Flexible(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  alignment: WrapAlignment.end,
                  children: List.generate(all.length, (i) {
                    final color = _colorFor(i);
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 18,
                          height: 2.5,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _labelFor(i),
                          style:
                              AppTextStyles.labelSmall.copyWith(color: color),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingL),
          SizedBox(
            height: 220,
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
                        l10n.yearCountLabel(v.toInt()),
                        style: AppTextStyles.labelSmall,
                      ),
                    ),
                  ),
                ),
                lineBarsData: barDataList,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.surfaceElevated,
                    getTooltipItems: (spots) => spots.map((spot) {
                      final color = _colorFor(spot.barIndex);
                      return LineTooltipItem(
                        AppFormatters.abbreviate(spot.y),
                        TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      );
                    }).toList(),
                  ),
                ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Comparison table: key metrics side-by-side for all scenarios
// ─────────────────────────────────────────────────────────────────────────────

class _ComparisonTableCard extends StatelessWidget {
  final List<SimulationResult> all;
  final AppLocalizations l10n;

  const _ComparisonTableCard({required this.all, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final metrics = [
      (
        icon: Icons.savings_rounded,
        color: AppColors.accentGreen,
        label: '10Y Net Worth',
        value: (SimulationResult r) =>
            AppFormatters.abbreviate(r.savings10Y, currencyCode: r.currency),
      ),
      (
        icon: Icons.fitness_center_rounded,
        color: AppColors.accentAmber,
        label: 'Health Score',
        value: (SimulationResult r) => AppFormatters.score(r.healthScore10Y),
      ),
      (
        icon: Icons.trending_up_rounded,
        color: AppColors.accentCyan,
        label: 'Career Growth',
        value: (SimulationResult r) =>
            '${r.careerGrowthIndex.toStringAsFixed(1)}x',
      ),
      (
        icon: Icons.star_rounded,
        color: AppColors.primaryLight,
        label: 'Life Score',
        value: (SimulationResult r) => '${r.lifeStrategyScore.toInt()}/100',
      ),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Key Metrics', style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppConstants.spacingM),
          // Header row
          Row(
            children: [
              const SizedBox(width: 130),
              ...List.generate(all.length, (i) {
                final color = _colorFor(i);
                return Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: color.withValues(alpha: 0.3), width: 1),
                    ),
                    child: Text(
                      _labelFor(i),
                      style: AppTextStyles.labelSmall
                          .copyWith(color: color, fontWeight: FontWeight.w700),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 12),
          // Metric rows
          ...metrics.map((m) {
            final bestIndex = _bestIndexFor(all, m.value);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  // Metric label
                  SizedBox(
                    width: 130,
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: m.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Icon(m.icon, color: m.color, size: 15),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            m.label,
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Value cells
                  ...List.generate(all.length, (i) {
                    final isBest = i == bestIndex;
                    return Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        decoration: isBest
                            ? BoxDecoration(
                                color: AppColors.accentGreen
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: AppColors.accentGreen
                                        .withValues(alpha: 0.4),
                                    width: 1),
                              )
                            : null,
                        child: Text(
                          m.value(all[i]),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isBest
                                ? AppColors.accentGreen
                                : AppColors.textSecondary,
                            fontWeight:
                                isBest ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
          // Best scenario badge
          if (all.length > 1) ...[
            const Divider(color: AppColors.border),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.emoji_events_rounded,
                    color: AppColors.accentAmber, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Best overall: Scenario ${_overallBestLabel(all)}',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.accentAmber),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  int _bestIndexFor(
      List<SimulationResult> all, String Function(SimulationResult) value) {
    // Best = highest numeric value (strip non-numeric chars for comparison)
    double parse(String s) =>
        double.tryParse(s.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    int best = 0;
    for (int i = 1; i < all.length; i++) {
      if (parse(value(all[i])) > parse(value(all[best]))) best = i;
    }
    return best;
  }

  String _overallBestLabel(List<SimulationResult> all) {
    // Score by lifeStrategyScore
    int best = 0;
    for (int i = 1; i < all.length; i++) {
      if (all[i].lifeStrategyScore > all[best].lifeStrategyScore) best = i;
    }
    return _labelFor(best);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Per-scenario detail card
// ─────────────────────────────────────────────────────────────────────────────

class _ScenarioDetailCard extends StatelessWidget {
  final SimulationResult scenario;
  final SimulationResult baseline;
  final Color color;
  final String label;
  final bool isBaseline;
  final int index;
  final VoidCallback? onRemove;

  const _ScenarioDetailCard({
    required this.scenario,
    required this.baseline,
    required this.color,
    required this.label,
    required this.isBaseline,
    required this.index,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final savingsDiff = baseline.savings10Y == 0
        ? 0.0
        : (scenario.savings10Y - baseline.savings10Y) /
            baseline.savings10Y.abs();
    final healthDiff = baseline.healthScore10Y == 0
        ? 0.0
        : (scenario.healthScore10Y - baseline.healthScore10Y) /
            baseline.healthScore10Y.abs();
    final scoreDiff = baseline.lifeStrategyScore == 0
        ? 0.0
        : (scenario.lifeStrategyScore - baseline.lifeStrategyScore) /
            baseline.lifeStrategyScore.abs();

    return GlassCard(
      borderColor: color.withValues(alpha: 0.3),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withValues(alpha: 0.08),
          AppColors.cardBackground,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: color.withValues(alpha: 0.4), width: 1),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(scenario.name, style: AppTextStyles.headlineSmall),
                    if (isBaseline)
                      Text('Original Scenario',
                          style:
                              AppTextStyles.bodySmall.copyWith(color: color)),
                  ],
                ),
              ),
              if (!isBaseline && onRemove != null)
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textMuted, size: 18),
                  onPressed: onRemove,
                  tooltip: 'Remove scenario',
                  splashRadius: 18,
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Key stats row
          Row(
            children: [
              _StatPill(
                label: '10Y Worth',
                value: AppFormatters.abbreviate(scenario.savings10Y,
                    currencyCode: scenario.currency),
                color: AppColors.accentGreen,
                delta: isBaseline ? null : savingsDiff,
              ),
              const SizedBox(width: 8),
              _StatPill(
                label: 'Health',
                value: AppFormatters.score(scenario.healthScore10Y),
                color: AppColors.accentAmber,
                delta: isBaseline ? null : healthDiff,
              ),
              const SizedBox(width: 8),
              _StatPill(
                label: 'Life Score',
                value: '${scenario.lifeStrategyScore.toInt()}/100',
                color: AppColors.primaryLight,
                delta: isBaseline ? null : scoreDiff,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final double? delta; // nullable = no diff shown

  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
    this.delta,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 4),
            Text(value,
                style: AppTextStyles.headlineSmall
                    .copyWith(color: color, fontSize: 14)),
            if (delta != null) ...[
              const SizedBox(height: 3),
              Row(
                children: [
                  Icon(
                    delta! >= 0
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 10,
                    color: delta! >= 0
                        ? AppColors.accentGreen
                        : AppColors.accentRed,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    AppFormatters.gainPercent(delta!),
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 9,
                      color: delta! >= 0
                          ? AppColors.accentGreen
                          : AppColors.accentRed,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Placeholder views
// ─────────────────────────────────────────────────────────────────────────────

class _NoScenarioView extends StatelessWidget {
  final VoidCallback onGoToSimulation;
  const _NoScenarioView({required this.onGoToSimulation});

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
              const Icon(Icons.compare_arrows_rounded,
                  color: AppColors.textMuted, size: 64),
              const SizedBox(height: AppConstants.spacingL),
              Text(l10n.runSimFirst,
                  style: AppTextStyles.bodyLarge, textAlign: TextAlign.center),
              const SizedBox(height: AppConstants.spacingXL),
              PrimaryButton(
                label: l10n.goToSimulation,
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

class _SetupFirstExtraView extends StatelessWidget {
  final SimulationResult scenarioA;
  final VoidCallback onAddScenario;

  const _SetupFirstExtraView({
    required this.scenarioA,
    required this.onAddScenario,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(l10n.comparisonTitle, style: AppTextStyles.headlineSmall),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          children: [
            // Baseline card
            GlassCard(
              borderColor: AppColors.primary.withValues(alpha: 0.3),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.12),
                  AppColors.cardBackground
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.scenarioLabel('A'),
                      style: AppTextStyles.overline
                          .copyWith(color: AppColors.primary)),
                  const SizedBox(height: 8),
                  Text(scenarioA.name, style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    AppFormatters.abbreviate(scenarioA.savings10Y,
                        currencyCode: scenarioA.currency),
                    style: AppTextStyles.moneyMedium,
                  ),
                  Text(l10n.netWorthAt10, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Spacer(),
            GlassCard(
              borderColor: AppColors.accentCyan.withValues(alpha: 0.25),
              child: Column(
                children: [
                  const Icon(Icons.add_circle_outline_rounded,
                      color: AppColors.accentCyan, size: 44),
                  const SizedBox(height: AppConstants.spacingM),
                  Text('Add a Scenario to Compare',
                      style: AppTextStyles.headlineMedium,
                      textAlign: TextAlign.center),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    'Set different habits and compare outcomes against your original scenario.\nYou can add up to 4 extra scenarios.',
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
                label: 'Add Scenario B',
                icon: Icons.add_rounded,
                gradient: AppColors.cyanGradient,
                onPressed: onAddScenario,
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
// Add-Scenario bottom sheet (with name field + sliders)
// ─────────────────────────────────────────────────────────────────────────────

class _AddScenarioSheet extends StatefulWidget {
  final String nextLabel;
  final Future<void> Function(SimulationInput input, String name) onRun;

  const _AddScenarioSheet({required this.nextLabel, required this.onRun});

  @override
  State<_AddScenarioSheet> createState() => _AddScenarioSheetState();
}

class _AddScenarioSheetState extends State<_AddScenarioSheet> {
  final _nameController = TextEditingController();
  double _income = 6000;
  double _saving = 0.35;
  double _study = 4.0;
  int _workout = 6;
  String _currency = 'USD';
  String? _careerField;
  double _weeklySkillHours = 5.0;
  int _certsPerYear = 1;
  double _socialMediaHours = 2.0;
  double _familyHours = 10.0;
  double _networkingHours = 2.0;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = 'Scenario ${widget.nextLabel}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _scenarioColors[
        (kScenarioLabels.indexOf(widget.nextLabel) + 1) %
            _scenarioColors.length];

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
            // Handle
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

            // Title
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      widget.nextLabel,
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w800,
                          fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('New Scenario', style: AppTextStyles.headlineLarge),
                      Text('Set different habits to compare',
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Name field
            TextField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Scenario Name',
                prefixIcon: Icon(Icons.label_rounded, color: color, size: 20),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),

            // Income & Currency
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    l10n.incomeValueLabel(
                        const {
                              'USD': r'$',
                              'EGP': 'E£',
                              'SAR': '﷼',
                              'AED': 'د.إ',
                              'KWD': 'د.ك',
                              'QAR': 'ر.ق'
                            }[_currency] ??
                            _currency,
                        _income.toInt()),
                    style: AppTextStyles.labelLarge),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                          color: AppColors.border.withOpacity(0.6),
                          width: 0.5)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _currency,
                      dropdownColor: AppColors.surfaceElevated,
                      isDense: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary, size: 15),
                      style: AppTextStyles.labelLarge,
                      items: ['USD', 'EGP', 'SAR', 'AED', 'KWD', 'QAR']
                          .map((v) => DropdownMenuItem(
                              value: v,
                              child: Text(v, style: AppTextStyles.labelLarge)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _currency = v);
                      },
                    ),
                  ),
                ),
              ],
            ),
            Slider(
              value: _income,
              min: 1000,
              max: 20000,
              divisions: 190,
              activeColor: color,
              onChanged: (v) => setState(() => _income = v),
            ),

            // Saving %
            Text(l10n.savingValueLabel((_saving * 100).toInt()),
                style: AppTextStyles.labelLarge),
            Slider(
              value: _saving,
              min: 0,
              max: 0.5,
              divisions: 50,
              activeColor: color,
              onChanged: (v) => setState(() => _saving = v),
            ),

            // Study hours
            Text(l10n.studyValueLabel(_study.toStringAsFixed(1)),
                style: AppTextStyles.labelLarge),
            Slider(
              value: _study,
              min: 0,
              max: 10,
              divisions: 20,
              activeColor: color,
              onChanged: (v) => setState(() => _study = v),
            ),

            // Workout
            Text(l10n.workoutValueLabel(_workout),
                style: AppTextStyles.labelLarge),
            Slider(
              value: _workout.toDouble(),
              min: 0,
              max: 7,
              divisions: 7,
              activeColor: color,
              onChanged: (v) => setState(() => _workout = v.toInt()),
            ),

            const SizedBox(height: AppConstants.spacingM),
            Container(height: 1, color: AppColors.border),
            const SizedBox(height: AppConstants.spacingM),

            Text(l10n.career, style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            // Career Field
            DropdownButtonFormField<String>(
              value: _careerField ?? l10n.techField,
              decoration: InputDecoration(
                labelText: 'Career Field',
                labelStyle: const TextStyle(color: AppColors.textMuted),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppColors.border.withOpacity(0.5)),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              dropdownColor: AppColors.surfaceElevated,
              style: AppTextStyles.labelLarge
                  .copyWith(color: AppColors.textPrimary),
              items: [
                l10n.techField,
                l10n.healthField,
                l10n.financeField,
                l10n.artsField,
                l10n.eduField,
                l10n.otherField
              ].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
              onChanged: (v) => setState(() => _careerField = v),
            ),
            const SizedBox(height: 16),
            // Skill Hours
            Text('${l10n.weeklySkillDev} (${_weeklySkillHours.toInt()}h/wk)',
                style: AppTextStyles.labelLarge),
            Slider(
              value: _weeklySkillHours,
              min: 0,
              max: 40,
              divisions: 40,
              activeColor: color,
              onChanged: (v) => setState(() => _weeklySkillHours = v),
            ),
            // Certs
            Text('${l10n.certsPerYearLabel} (${_certsPerYear})',
                style: AppTextStyles.labelLarge),
            Slider(
              value: _certsPerYear.toDouble(),
              min: 0,
              max: 5,
              divisions: 5,
              activeColor: color,
              onChanged: (v) => setState(() => _certsPerYear = v.toInt()),
            ),

            const SizedBox(height: AppConstants.spacingM),
            Container(height: 1, color: AppColors.border),
            const SizedBox(height: AppConstants.spacingM),

            Text(l10n.social, style: AppTextStyles.headlineSmall),
            const SizedBox(height: 16),
            // Social Media
            Text(
                '${l10n.socialMedia} (${_socialMediaHours.toStringAsFixed(1)}h/day)',
                style: AppTextStyles.labelLarge),
            Slider(
              value: _socialMediaHours,
              min: 0,
              max: 10,
              divisions: 20,
              activeColor: color,
              onChanged: (v) => setState(() => _socialMediaHours = v),
            ),
            // Family
            Text('${l10n.familyFriends} (${_familyHours.toInt()}h/wk)',
                style: AppTextStyles.labelLarge),
            Slider(
              value: _familyHours,
              min: 0,
              max: 40,
              divisions: 40,
              activeColor: color,
              onChanged: (v) => setState(() => _familyHours = v),
            ),
            // Networking
            Text('${l10n.networking} (${_networkingHours.toInt()}h/wk)',
                style: AppTextStyles.labelLarge),
            Slider(
              value: _networkingHours,
              min: 0,
              max: 20,
              divisions: 20,
              activeColor: color,
              onChanged: (v) => setState(() => _networkingHours = v),
            ),

            const SizedBox(height: AppConstants.spacingL),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Run Scenario ${widget.nextLabel}',
                icon: Icons.rocket_launch_rounded,
                isLoading: _isRunning,
                onPressed: () async {
                  setState(() => _isRunning = true);
                  final input = SimulationInput(
                    monthlyIncome: _income,
                    savingPercentage: _saving,
                    dailyStudyHours: _study,
                    workoutDaysPerWeek: _workout,
                    currency: _currency,
                    careerField: _careerField ?? l10n.techField,
                    weeklySkillHours: _weeklySkillHours,
                    certsPerYear: _certsPerYear,
                    socialMediaHours: _socialMediaHours,
                    familyHours: _familyHours,
                    networkingHours: _networkingHours,
                  );
                  await widget.onRun(
                    input,
                    _nameController.text.trim().isEmpty
                        ? 'Scenario ${widget.nextLabel}'
                        : _nameController.text.trim(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
