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
import '../../../../l10n/generated/app_localizations.dart';
import '../widgets/shared_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LifeTimelineScreen — Parallel Futures visualization (Phase 3)
// ─────────────────────────────────────────────────────────────────────────────

class LifeTimelineScreen extends ConsumerStatefulWidget {
  const LifeTimelineScreen({super.key});

  @override
  ConsumerState<LifeTimelineScreen> createState() => _LifeTimelineScreenState();
}

// Metric enum for tab switching
enum _TimelineMetric { netWorth, energy, career, risk }

class _LifeTimelineScreenState extends ConsumerState<LifeTimelineScreen> {
  _TimelineMetric _metric = _TimelineMetric.netWorth;

  // Which paths are visible (all by default)
  bool _showCurrent = true;
  bool _showOptimized = true;
  bool _showDecline = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final futures = ref.watch(parallelFuturesProvider);
    final scenarios = ref.watch(scenariosProvider);
    final input = ref.watch(simulationInputProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────────────────
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
                Text(l10n.timelineTitle, style: AppTextStyles.headlineSmall),
              ],
            ),
            actions: [],
          ),

          // ── Content ──────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingM,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppConstants.spacingM),

                // Generate button
                if (!futures.hasData && !futures.isGenerating)
                  _GenerateCard(
                    hasSimulation: scenarios.scenarioA != null,
                    onGenerate: () {
                      ref
                          .read(parallelFuturesProvider.notifier)
                          .generate(input);
                    },
                  ).animate().fadeIn(duration: 400.ms),

                // Generating indicator
                if (futures.isGenerating)
                  _GeneratingView(label: l10n.generatingFutures)
                      .animate()
                      .fadeIn(),

                // Main timeline content
                if (futures.hasData) ...[
                  // Path visibility toggles
                  _PathToggles(
                    showCurrent: _showCurrent,
                    showOptimized: _showOptimized,
                    showDecline: _showDecline,
                    onCurrentToggle: (v) => setState(() => _showCurrent = v),
                    onOptimizedToggle: (v) =>
                        setState(() => _showOptimized = v),
                    onDeclineToggle: (v) => setState(() => _showDecline = v),
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: AppConstants.spacingM),

                  // Metric selector tabs
                  _MetricTabs(
                    selected: _metric,
                    onChanged: (m) => setState(() => _metric = m),
                  ).animate().fadeIn(duration: 500.ms),

                  const SizedBox(height: AppConstants.spacingM),

                  // Main line chart
                  _ParallelChart(
                    current: futures.currentPath!,
                    optimized: futures.optimizedPath!,
                    decline: futures.declinePath!,
                    metric: _metric,
                    showCurrent: _showCurrent,
                    showOptimized: _showOptimized,
                    showDecline: _showDecline,
                  ).animate(delay: 200.ms).fadeIn(),

                  const SizedBox(height: AppConstants.spacingL),

                  // Summary cards at 10Y
                  _SummaryRow(
                    current: futures.currentPath!,
                    optimized: futures.optimizedPath!,
                    decline: futures.declinePath!,
                    metric: _metric,
                  ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.15),

                  const SizedBox(height: AppConstants.spacingL),

                  // Re-generate button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryLight,
                        side: const BorderSide(
                          color: AppColors.borderGlow,
                          width: 0.75,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusL,
                          ),
                        ),
                      ),
                      onPressed: () {
                        ref
                            .read(parallelFuturesProvider.notifier)
                            .generate(input);
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(l10n.generateFutures),
                    ),
                  ).animate(delay: 400.ms).fadeIn(),
                ],

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

class _GenerateCard extends StatelessWidget {
  final bool hasSimulation;
  final VoidCallback onGenerate;

  const _GenerateCard({
    required this.hasSimulation,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!hasSimulation) {
      return GlassCard(
        child: Column(
          children: [
            const Icon(
              Icons.timeline_rounded,
              color: AppColors.textMuted,
              size: 48,
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              l10n.noFuturesYet,
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              l10n.noFuturesSub,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingL),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: l10n.goToSimulation,
                icon: Icons.auto_graph_rounded,
                onPressed: () => context.go(AppRoutes.input),
              ),
            ),
          ],
        ),
      );
    }

    return GlassCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1E1450), Color(0xFF0F0C24)],
      ),
      borderColor: AppColors.borderGlow,
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: const Icon(
                  Icons.call_split_rounded,
                  color: AppColors.primaryLight,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.timelineTitle,
                      style: AppTextStyles.headlineMedium,
                    ),
                    Text(
                      l10n.noFuturesSub,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingL),

          // Path previews
          Row(
            children: [
              _PathPreviewChip(
                label: 'Current',
                color: AppColors.accentCyan,
              ),
              const SizedBox(width: AppConstants.spacingS),
              _PathPreviewChip(
                label: 'Optimized',
                color: AppColors.accentGreen,
              ),
              const SizedBox(width: AppConstants.spacingS),
              _PathPreviewChip(
                label: 'Decline',
                color: AppColors.accentRed,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingL),

          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: l10n.generateFutures,
              icon: Icons.auto_awesome_rounded,
              onPressed: onGenerate,
            ),
          ),
        ],
      ),
    );
  }
}

class _PathPreviewChip extends StatelessWidget {
  final String label;
  final Color color;

  const _PathPreviewChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.75),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _GeneratingView extends StatelessWidget {
  final String label;

  const _GeneratingView({required this.label});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          const SizedBox(height: AppConstants.spacingM),
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              color: AppColors.primaryLight,
              strokeWidth: 2.5,
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(label, style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppConstants.spacingM),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PathToggles extends StatelessWidget {
  final bool showCurrent;
  final bool showOptimized;
  final bool showDecline;
  final ValueChanged<bool> onCurrentToggle;
  final ValueChanged<bool> onOptimizedToggle;
  final ValueChanged<bool> onDeclineToggle;

  const _PathToggles({
    required this.showCurrent,
    required this.showOptimized,
    required this.showDecline,
    required this.onCurrentToggle,
    required this.onOptimizedToggle,
    required this.onDeclineToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        _ToggleChip(
          label: l10n.currentLabel,
          color: AppColors.accentCyan,
          active: showCurrent,
          onTap: () => onCurrentToggle(!showCurrent),
        ),
        const SizedBox(width: AppConstants.spacingS),
        _ToggleChip(
          label: l10n.optimizedLabel,
          color: AppColors.accentGreen,
          active: showOptimized,
          onTap: () => onOptimizedToggle(!showOptimized),
        ),
        const SizedBox(width: AppConstants.spacingS),
        _ToggleChip(
          label: l10n.declinePathLabel,
          color: AppColors.accentRed,
          active: showDecline,
          onTap: () => onDeclineToggle(!showDecline),
        ),
      ],
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.color,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animationFast,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.18) : Colors.transparent,
          border: Border.all(
            color: active ? color : AppColors.border,
            width: 0.75,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: active ? color : AppColors.textMuted,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: active ? color : AppColors.textMuted,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _MetricTabs extends StatelessWidget {
  final _TimelineMetric selected;
  final ValueChanged<_TimelineMetric> onChanged;

  const _MetricTabs({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = [
      (_TimelineMetric.netWorth, l10n.netWorthAt10.replaceAll(' @ 10yrs', '')),
      (_TimelineMetric.energy, l10n.energyLevelLabel),
      (_TimelineMetric.career, l10n.careerGrowthLabel),
      (_TimelineMetric.risk, l10n.riskLevelLabel),
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final (metric, label) = tabs[i];
          final isSelected = metric == selected;
          return GestureDetector(
            onTap: () => onChanged(metric),
            child: AnimatedContainer(
              duration: AppConstants.animationFast,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color:
                    isSelected ? AppColors.primary : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                border: isSelected
                    ? null
                    : Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected ? Colors.white : AppColors.textMuted,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ParallelChart extends StatelessWidget {
  final SimulationResult current;
  final SimulationResult optimized;
  final SimulationResult decline;
  final _TimelineMetric metric;
  final bool showCurrent;
  final bool showOptimized;
  final bool showDecline;

  const _ParallelChart({
    required this.current,
    required this.optimized,
    required this.decline,
    required this.metric,
    required this.showCurrent,
    required this.showOptimized,
    required this.showDecline,
  });

  List<FlSpot> _spotsFor(SimulationResult r) {
    final spots = [const FlSpot(0, 0)];
    for (final s in r.yearlySnapshots) {
      final y = _valueAt(r, s.year);
      spots.add(FlSpot(s.year.toDouble(), y));
    }
    return spots;
  }

  double _valueAt(SimulationResult r, int year) {
    final snap = r.yearlySnapshots.where((s) => s.year == year).firstOrNull;
    switch (metric) {
      case _TimelineMetric.netWorth:
        return (snap?.savings ?? 0) / 1000; // in K
      case _TimelineMetric.energy:
        if (year <= 1) return r.energyScore1Y;
        if (year <= 5) {
          return r.energyScore1Y +
              (r.energyScore5Y - r.energyScore1Y) * ((year - 1) / 4);
        }
        return r.energyScore5Y +
            (r.energyScore10Y - r.energyScore5Y) * ((year - 5) / 5);
      case _TimelineMetric.career:
        return r.careerGrowthIndex * (year / 10) * 100;
      case _TimelineMetric.risk:
        return r.overallRiskIndex;
    }
  }

  double get _maxY {
    double max = 0;
    for (final r in [current, optimized, decline]) {
      for (final s in r.yearlySnapshots) {
        final v = _valueAt(r, s.year);
        if (v > max) max = v;
      }
    }
    return (max * 1.15).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GlassCard(
      child: SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: 10,
            minY: 0,
            maxY: _maxY == 0 ? 10 : _maxY,
            clipData: const FlClipData.all(),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: _maxY == 0 ? 5 : _maxY / 4,
              getDrawingHorizontalLine: (_) => const FlLine(
                color: Color(0x22FFFFFF),
                strokeWidth: 0.5,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: _maxY == 0 ? 5 : _maxY / 4,
                  getTitlesWidget: (value, _) => Text(
                    metric == _TimelineMetric.netWorth
                        ? '${value.toInt()}k'
                        : value.toInt().toString(),
                    style: AppTextStyles.labelSmall.copyWith(fontSize: 9),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 2,
                  getTitlesWidget: (value, _) {
                    if (value == 0) return const SizedBox.shrink();
                    return Text(
                      '${value.toInt()}${l10n.yearShort}',
                      style: AppTextStyles.labelSmall,
                    );
                  },
                ),
              ),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => AppColors.surface,
                getTooltipItems: (spots) => spots
                    .map((spot) => LineTooltipItem(
                          metric == _TimelineMetric.netWorth
                              ? '\$${spot.y.toStringAsFixed(1)}k'
                              : spot.y.toStringAsFixed(1),
                          AppTextStyles.labelSmall
                              .copyWith(color: spot.bar.color),
                        ))
                    .toList(),
              ),
            ),
            lineBarsData: [
              if (showCurrent)
                _buildLine(
                  _spotsFor(current),
                  AppColors.accentCyan,
                  isDashed: false,
                ),
              if (showOptimized)
                _buildLine(
                  _spotsFor(optimized),
                  AppColors.accentGreen,
                  isDashed: false,
                ),
              if (showDecline)
                _buildLine(
                  _spotsFor(decline),
                  AppColors.accentRed,
                  isDashed: true,
                ),
            ],
          ),
        ),
      ),
    );
  }

  LineChartBarData _buildLine(
    List<FlSpot> spots,
    Color color, {
    required bool isDashed,
  }) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.3,
      color: color,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      dashArray: isDashed ? [4, 3] : null,
      belowBarData: BarAreaData(
        show: !isDashed,
        color: color.withValues(alpha: 0.06),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final SimulationResult current;
  final SimulationResult optimized;
  final SimulationResult decline;
  final _TimelineMetric metric;

  const _SummaryRow({
    required this.current,
    required this.optimized,
    required this.decline,
    required this.metric,
  });

  String _format(SimulationResult r) {
    switch (metric) {
      case _TimelineMetric.netWorth:
        return AppFormatters.compactCurrency(
          r.savings10Y,
          currencyCode: r.currency,
        );
      case _TimelineMetric.energy:
        return '${r.energyScore10Y.toInt()}/100';
      case _TimelineMetric.career:
        return '${(r.careerGrowthIndex * 100).toInt()}%';
      case _TimelineMetric.risk:
        return '${r.overallRiskIndex.toInt()}/100';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: l10n.currentLabel,
            value: _format(current),
            color: AppColors.accentCyan,
            icon: Icons.trending_flat_rounded,
          ),
        ),
        const SizedBox(width: AppConstants.spacingS),
        Expanded(
          child: _SummaryCard(
            label: l10n.optimizedLabel,
            value: _format(optimized),
            color: AppColors.accentGreen,
            icon: Icons.trending_up_rounded,
          ),
        ),
        const SizedBox(width: AppConstants.spacingS),
        Expanded(
          child: _SummaryCard(
            label: l10n.declinePathLabel,
            value: _format(decline),
            color: AppColors.accentRed,
            icon: Icons.trending_down_rounded,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 0.75),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingXS),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(color: color),
          ),
          Text(
            '10Y',
            style: AppTextStyles.labelSmall,
          ),
        ],
      ),
    );
  }
}
