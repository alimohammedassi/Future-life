import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/navigation/app_router.dart';
import '../widgets/shared_widgets.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _orb1Ctrl;
  late final AnimationController _orb2Ctrl;
  late final AnimationController _gridCtrl;
  late final AnimationController _iconPulseCtrl;

  @override
  void initState() {
    super.initState();
    _orb1Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _orb2Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat(reverse: true);

    _gridCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _iconPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _orb1Ctrl.dispose();
    _orb2Ctrl.dispose();
    _gridCtrl.dispose();
    _iconPulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Animated Background ──────────────────────────────────
          Positioned.fill(
            child: _AnimatedBackground(
              orb1Ctrl: _orb1Ctrl,
              orb2Ctrl: _orb2Ctrl,
              gridCtrl: _gridCtrl,
              size: size,
            ),
          ),

          // ── Main Content ─────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingL),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Top bar: version badge and language switcher
                        _TopBar()
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 200.ms),

                        const Spacer(flex: 1),

                        // ── Hero Section ─────────────────────────────
                        _HeroSection(pulseCtrl: _iconPulseCtrl),

                        const Spacer(flex: 1),

                        // ── Stats Strip ───────────────────────────────
                        _StatsStrip()
                            .animate(delay: 700.ms)
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: 0.1, end: 0, duration: 500.ms),

                        const SizedBox(height: AppConstants.spacingL),

                        // ── Feature Grid ──────────────────────────────
                        _FeatureGrid(),

                        const Spacer(flex: 1),

                        // ── CTA Section ───────────────────────────────
                        _CtaSection(),

                        const SizedBox(height: AppConstants.spacingL),
                      ],
                    ),
                  ),
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
// Animated Background
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedBackground extends StatelessWidget {
  final AnimationController orb1Ctrl;
  final AnimationController orb2Ctrl;
  final AnimationController gridCtrl;
  final Size size;

  const _AnimatedBackground({
    required this.orb1Ctrl,
    required this.orb2Ctrl,
    required this.gridCtrl,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A0718), Color(0xFF060412), Color(0xFF0C0820)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // Orb 1 — top left, primary color
        AnimatedBuilder(
          animation: orb1Ctrl,
          builder: (_, __) => Positioned(
            top: -80 + orb1Ctrl.value * 40,
            left: -60 + orb1Ctrl.value * 30,
            child: Container(
              width: size.width * 0.75,
              height: size.width * 0.75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Orb 2 — bottom right, accent
        AnimatedBuilder(
          animation: orb2Ctrl,
          builder: (_, __) => Positioned(
            bottom: -100 + orb2Ctrl.value * 50,
            right: -80 + orb2Ctrl.value * 20,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentCyan.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Subtle dot grid
        Positioned.fill(
          child: CustomPaint(
            painter: _DotGridPainter(
              color: AppColors.border.withOpacity(0.25),
            ),
          ),
        ),

        // Diagonal scan line (very subtle)
        AnimatedBuilder(
          animation: gridCtrl,
          builder: (_, __) => Positioned(
            top: (gridCtrl.value * size.height * 1.5) - size.height * 0.25,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.primaryLight.withOpacity(0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DotGridPainter extends CustomPainter {
  final Color color;
  const _DotGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const spacing = 28.0;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Top Bar
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // App name wordmark
        Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.show_chart_rounded,
                color: Colors.white,
                size: 13,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.appTitle.toUpperCase(),
              style: AppTextStyles.overline.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 3,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        // Language switcher + Version badge row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                final newLanguage =
                    currentLocale.languageCode == 'en' ? 'ar' : 'en';
                ref.read(localeProvider.notifier).setLocale(newLanguage);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: AppColors.border,
                    width: 0.75,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.language_rounded,
                      size: 12,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      currentLocale.languageCode == 'en' ? 'EN' : 'عربي',
                      style: AppTextStyles.overline.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 0.75,
                ),
              ),
              child: Text(
                'v2.0',
                style: AppTextStyles.overline.copyWith(
                  color: AppColors.primaryLight,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Section
// ─────────────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final AnimationController pulseCtrl;
  const _HeroSection({required this.pulseCtrl});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // App icon with glow ring
        _GlowingIcon(pulseCtrl: pulseCtrl)
            .animate()
            .scale(
              begin: const Offset(0.4, 0.4),
              duration: 900.ms,
              delay: 100.ms,
              curve: Curves.elasticOut,
            )
            .fadeIn(duration: 500.ms, delay: 100.ms),

        const SizedBox(height: AppConstants.spacingXL),

        // Overline label
        Text(
          l10n.engineLabel,
          style: AppTextStyles.overline.copyWith(
            color: AppColors.accentCyan.withOpacity(0.7),
            letterSpacing: 3,
            fontSize: 10,
          ),
        ).animate(delay: 400.ms).fadeIn(duration: 500.ms),

        const SizedBox(height: AppConstants.spacingS),

        // Headline
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: l10n.heroTitlePrefix,
                style: AppTextStyles.displayMedium.copyWith(height: 1.15),
              ),
              WidgetSpan(
                child: ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.primaryGradient.createShader(bounds),
                  child: Text(
                    l10n.heroTitleSuffix,
                    style: AppTextStyles.displayMedium.copyWith(
                      color: Colors.white,
                      height: 1.15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ).animate(delay: 300.ms).fadeIn(duration: 700.ms).slideY(
            begin: 0.15, end: 0, duration: 700.ms, curve: Curves.easeOut),

        const SizedBox(height: AppConstants.spacingM),

        // Subtitle
        Text(
          l10n.heroSubtitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textMuted,
            height: 1.6,
          ),
        ).animate(delay: 500.ms).fadeIn(duration: 600.ms),
      ],
    );
  }
}

class _GlowingIcon extends StatelessWidget {
  final AnimationController pulseCtrl;
  const _GlowingIcon({required this.pulseCtrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseCtrl,
      builder: (_, __) {
        final glow = 0.3 + pulseCtrl.value * 0.2;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring 3
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary
                    .withOpacity(0.04 + pulseCtrl.value * 0.02),
              ),
            ),
            // Outer glow ring 2
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary
                    .withOpacity(0.07 + pulseCtrl.value * 0.03),
              ),
            ),
            // Outer glow ring 1
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.0),
                border: Border.all(
                  color: AppColors.primaryLight
                      .withOpacity(0.12 + pulseCtrl.value * 0.08),
                  width: 1,
                ),
              ),
            ),
            // Icon container
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(glow),
                    blurRadius: 30 + pulseCtrl.value * 10,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: AppColors.primaryLight.withOpacity(0.2),
                    blurRadius: 60,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Inner shine
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      width: 30,
                      height: 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.25),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Center(
                    child: Icon(
                      Icons.show_chart_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Strip
// ─────────────────────────────────────────────────────────────────────────────

class _StatsStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        color: AppColors.primary.withOpacity(0.06),
        border: Border.all(
          color: AppColors.primaryLight.withOpacity(0.1),
          width: 0.75,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(value: '10Y', label: l10n.projection),
          _VerticalDivider(),
          _StatItem(value: '5', label: l10n.lifeModules),
          _VerticalDivider(),
          _StatItem(value: '∞', label: l10n.scenarios),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.primaryLight,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5,
      height: 28,
      color: AppColors.border.withOpacity(0.5),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Feature Grid — 2×2 compact tiles + 1 wide
// ─────────────────────────────────────────────────────────────────────────────

class _FeatureGrid extends StatelessWidget {
  List<_FeatureData> _getFeatures(AppLocalizations l10n) {
    return [
      _FeatureData(
        icon: Icons.account_balance_wallet_rounded,
        title: l10n.simFeatureMoney,
        subtitle: l10n.simFeatureMoneySub,
        color: const Color(0xFF7C6FEC),
        delay: 800,
      ),
      _FeatureData(
        icon: Icons.lightbulb_rounded,
        title: l10n.simFeatureCognitive,
        subtitle: l10n.simFeatureCognitiveSub,
        color: const Color(0xFF5BBFCF),
        delay: 900,
      ),
      _FeatureData(
        icon: Icons.favorite_rounded,
        title: l10n.simFeatureVitality,
        subtitle: l10n.simFeatureVitalitySub,
        color: const Color(0xFF4CAF81),
        delay: 1000,
      ),
      _FeatureData(
        icon: Icons.work_history_rounded,
        title: l10n.simFeatureCareer,
        subtitle: l10n.simFeatureCareerSub,
        color: const Color(0xFFF5A623),
        delay: 1100,
      ),
      _FeatureData(
        icon: Icons.people_alt_rounded,
        title: l10n.simFeatureSocial,
        subtitle: l10n.simFeatureSocialSub,
        color: const Color(0xFFE8607A),
        delay: 1200,
        wide: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final features = _getFeatures(l10n);
    final tiles = features.where((f) => !f.wide).toList();
    final wide = features.where((f) => f.wide).toList();

    return Column(
      children: [
        // 2x2 grid
        Row(
          children: [
            Expanded(child: _FeatureTile(data: tiles[0])),
            const SizedBox(width: AppConstants.spacingS),
            Expanded(child: _FeatureTile(data: tiles[1])),
          ],
        ),
        const SizedBox(height: AppConstants.spacingS),
        Row(
          children: [
            Expanded(child: _FeatureTile(data: tiles[2])),
            const SizedBox(width: AppConstants.spacingS),
            Expanded(child: _FeatureTile(data: tiles[3])),
          ],
        ),
        const SizedBox(height: AppConstants.spacingS),
        // Wide tile
        _FeatureTile(data: wide[0], wide: true),
      ],
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final int delay;
  final bool wide;

  const _FeatureData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.delay,
    this.wide = false,
  });
}

class _FeatureTile extends StatelessWidget {
  final _FeatureData data;
  final bool wide;

  const _FeatureTile({required this.data, this.wide = false});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: wide
          ? Row(
              children: [
                _TileIcon(icon: data.icon, color: data.color),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.title, style: AppTextStyles.headlineSmall),
                      const SizedBox(height: 2),
                      Text(
                        data.subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                // Mini bar chart for visual interest
                _MiniBarChart(color: data.color),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _TileIcon(icon: data.icon, color: data.color),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: data.color.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(data.title,
                    style: AppTextStyles.headlineSmall.copyWith(fontSize: 13)),
                const SizedBox(height: 3),
                Text(
                  data.subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 10),
                // Thin accent line
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      colors: [data.color.withOpacity(0.7), Colors.transparent],
                    ),
                  ),
                ),
              ],
            ),
    )
        .animate(delay: Duration(milliseconds: data.delay))
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.08, end: 0, duration: 500.ms, curve: Curves.easeOut);
  }
}

class _TileIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _TileIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2), width: 0.75),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

class _MiniBarChart extends StatelessWidget {
  final Color color;
  const _MiniBarChart({required this.color});

  @override
  Widget build(BuildContext context) {
    final heights = [0.4, 0.65, 0.5, 0.8, 0.7, 1.0];
    return SizedBox(
      width: 44,
      height: 28,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: heights
            .map((h) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: Container(
                      height: 28 * h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            color.withOpacity(0.8),
                            color.withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CTA Section
// ─────────────────────────────────────────────────────────────────────────────

class _CtaSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Main button
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            label: l10n.startSimulation,
            icon: Icons.bolt_rounded,
            onPressed: () => context.go(AppRoutes.input),
          ),
        )
            .animate(delay: 1350.ms)
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.2, end: 0, duration: 500.ms),

        const SizedBox(height: AppConstants.spacingM),

        // Trust line
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 11,
              color: AppColors.textMuted.withOpacity(0.5),
            ),
            const SizedBox(width: 5),
            Text(
              l10n.engineLabel,
              style: AppTextStyles.overline.copyWith(
                color: AppColors.textMuted.withOpacity(0.5),
                fontSize: 10,
              ),
            ),
          ],
        ).animate(delay: 1500.ms).fadeIn(duration: 400.ms),
      ],
    );
  }
}
