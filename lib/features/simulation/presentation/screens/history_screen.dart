import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../data/providers/simulation_providers.dart';
import '../../domain/models/simulation_result.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../widgets/shared_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HistoryScreen — Simulation History (Phase 7)
// ─────────────────────────────────────────────────────────────────────────────

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            floating: true,
            pinned: false,
            snap: true,
            automaticallyImplyLeading: true,
            leading: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                color: AppColors.primaryLight,
                size: 20,
              ),
            ),
            title: Text(l10n.historyTitle, style: AppTextStyles.headlineSmall),
            actions: [
              historyAsync.whenOrNull(
                    data: (items) => items.isEmpty
                        ? null
                        : TextButton(
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: AppColors.surface,
                                  title: Text(
                                    l10n.clearHistory,
                                    style: AppTextStyles.headlineSmall,
                                  ),
                                  content: Text(
                                    'This will permanently delete all saved simulations.',
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(true),
                                      child: Text(
                                        l10n.clearHistory,
                                        style: const TextStyle(
                                          color: AppColors.accentRed,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true && context.mounted) {
                                ref
                                    .read(historyProvider.notifier)
                                    .clear();
                              }
                            },
                            child: Text(
                              l10n.clearHistory,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.accentRed,
                              ),
                            ),
                          ),
                  ) ??
                  const SizedBox.shrink(),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingM,
            ),
            sliver: historyAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.spacingXXL),
                    child: CircularProgressIndicator(
                      color: AppColors.primaryLight,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingXL),
                    child: Text(
                      'Failed to load history',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ),
              ),
              data: (items) => items.isEmpty
                  ? SliverToBoxAdapter(
                      child: _EmptyHistoryView(),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == 0) {
                            return const SizedBox(
                              height: AppConstants.spacingM,
                            );
                          }
                          final item = items[index - 1];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppConstants.spacingM,
                            ),
                            child: _HistoryCard(result: item)
                                .animate(delay: (index * 60).ms)
                                .fadeIn()
                                .slideY(begin: 0.1),
                          );
                        },
                        childCount: items.length + 1,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EmptyHistoryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.spacingXXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_rounded,
              color: AppColors.textMuted,
              size: 48,
            ),
          ),
          const SizedBox(height: AppConstants.spacingL),
          Text(
            l10n.noHistoryYet,
            style: AppTextStyles.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            l10n.noHistorySub,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final SimulationResult result;

  const _HistoryCard({required this.result});

  String _riskLabel(double risk, AppLocalizations l10n) {
    if (risk < 35) return l10n.riskLow;
    if (risk < 65) return l10n.riskMedium;
    return l10n.riskHigh;
  }

  Color _riskColor(double risk) {
    if (risk < 35) return AppColors.accentGreen;
    if (risk < 65) return AppColors.accentAmber;
    return AppColors.accentRed;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final date = result.createdAt;
    final dateStr =
        '${date.day}/${date.month}/${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: const Icon(
                  Icons.timeline_rounded,
                  color: AppColors.primaryLight,
                  size: 16,
                ),
              ),
              const SizedBox(width: AppConstants.spacingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.name,
                      style: AppTextStyles.headlineSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      dateStr,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              // Life Stability score badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGlow,
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                ),
                child: Text(
                  '${result.lifeStrategyScore.toInt()}/100',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacingM),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: AppConstants.spacingM),

          // Key metrics row
          Row(
            children: [
              Expanded(
                child: _MiniMetric(
                  icon: Icons.account_balance_wallet_rounded,
                  color: AppColors.primaryLight,
                  label: '10Y Net Worth',
                  value: AppFormatters.compactCurrency(
                    result.savings10Y,
                    currencyCode: result.currency,
                  ),
                ),
              ),
              Expanded(
                child: _MiniMetric(
                  icon: Icons.fitness_center_rounded,
                  color: AppColors.accentGreen,
                  label: 'Health 10Y',
                  value: AppFormatters.score(result.healthScore10Y),
                ),
              ),
              Expanded(
                child: _MiniMetric(
                  icon: Icons.bolt_rounded,
                  color: AppColors.accentAmber,
                  label: 'Energy 10Y',
                  value: AppFormatters.score(result.energyScore10Y),
                ),
              ),
              Expanded(
                child: _MiniMetric(
                  icon: Icons.shield_outlined,
                  color: _riskColor(result.overallRiskIndex),
                  label: 'Risk',
                  value: _riskLabel(result.overallRiskIndex, l10n),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _MiniMetric({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(height: 3),
        Text(
          value,
          style: AppTextStyles.labelMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
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
