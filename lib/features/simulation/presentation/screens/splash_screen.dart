import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/navigation/app_router.dart';
import '../widgets/shared_widgets.dart';

/// Landing screen — the first impression of the app.
/// Matches the reference design: centered logo, feature list, CTA button.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              // Ensure the content fills at least the full screen height
              // so Spacers work on large screens; scrolls on small screens.
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingL),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      // ── App Icon ─────────────────────────────────────
                      _AppIcon()
                          .animate()
                          .scale(
                            begin: const Offset(0.5, 0.5),
                            duration: 700.ms,
                            curve: Curves.elasticOut,
                          )
                          .fadeIn(duration: 500.ms),

                      const SizedBox(height: AppConstants.spacingXL),

                      // ── Hero Headline ────────────────────────────────
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Simulate Your\n',
                              style: AppTextStyles.displayMedium,
                            ),
                            TextSpan(
                              text: 'Future',
                              style: AppTextStyles.displayMedium.copyWith(
                                color: AppColors.primaryLight,
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate(delay: 200.ms)
                          .fadeIn(duration: 600.ms)
                          .slideY(begin: 0.2, end: 0, duration: 600.ms),

                      const SizedBox(height: AppConstants.spacingM),

                      Text(
                        'See where your daily habits will take you.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyLarge,
                      ).animate(delay: 400.ms).fadeIn(duration: 600.ms),

                      const Spacer(flex: 2),

                      // ── Feature List ─────────────────────────────────
                      Column(
                        children: [
                          _FeatureRow(
                            icon: Icons.account_balance_wallet_rounded,
                            title: 'Money Growth',
                            subtitle: 'Projected wealth & assets',
                            delay: 600,
                          ),
                          const SizedBox(height: AppConstants.spacingM),
                          _FeatureRow(
                            icon: Icons.lightbulb_rounded,
                            title: 'Cognitive Peak',
                            subtitle: 'Learning & skill mastery',
                            delay: 750,
                          ),
                          const SizedBox(height: AppConstants.spacingM),
                          _FeatureRow(
                            icon: Icons.favorite_rounded,
                            title: 'Vitality Index',
                            subtitle: 'Health & fitness longevity',
                            delay: 900,
                          ),
                        ],
                      ),

                      const Spacer(flex: 2),

                      // ── CTA Button ────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          label: 'Start Simulation',
                          icon: Icons.bolt_rounded,
                          onPressed: () => context.go(AppRoutes.input),
                        ),
                      )
                          .animate(delay: 1100.ms)
                          .fadeIn(duration: 500.ms)
                          .slideY(begin: 0.3, end: 0, duration: 500.ms),

                      const SizedBox(height: AppConstants.spacingM),

                      Text(
                        AppConstants.engineLabel,
                        style: AppTextStyles.overline,
                      ).animate(delay: 1300.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: AppConstants.spacingL),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _AppIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.show_chart_rounded,
        color: Colors.white,
        size: 48,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int delay;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryLight, size: 22),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.headlineSmall),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Icon(
            _trailingIcon(icon),
            color: AppColors.textMuted,
            size: 18,
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 500.ms)
        .slideX(begin: 0.1, end: 0, duration: 500.ms);
  }

  IconData _trailingIcon(IconData icon) {
    if (icon == Icons.account_balance_wallet_rounded) {
      return Icons.trending_up_rounded;
    } else if (icon == Icons.lightbulb_rounded) {
      return Icons.menu_book_rounded;
    }
    return Icons.fitness_center_rounded;
  }
}
