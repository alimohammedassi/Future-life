import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/localization/auth_provider.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../simulation/presentation/widgets/shared_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Guard: redirect to auth if not logged in.
    if (!authState.isAuthenticated || authState.currentUser == null) {
      return _NotLoggedInView();
    }

    final user = authState.currentUser!;
    final locale = ref.watch(localeProvider);
    final isAr = locale.languageCode == 'ar';
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Background decorations ────────────────────────────
          Positioned(
            top: -120,
            right: -60,
            child: _GlowBlob(
              color: AppColors.primary.withValues(alpha: 0.12),
              size: 320,
            ),
          ),
          Positioned(
            bottom: 100,
            left: -80,
            child: _GlowBlob(
              color: AppColors.accentCyan.withValues(alpha: 0.07),
              size: 280,
            ),
          ),

          // ── Content ───────────────────────────────────────────
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // ── AppBar ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Row(
                      children: [
                        Text(
                          l10n.navProfile,
                          style: AppTextStyles.headlineMedium,
                        ),
                        const Spacer(),
                        _IconAction(
                          icon: Icons.settings_outlined,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // ── Avatar + Name + Email ────────────────────────
                SliverToBoxAdapter(
                  child: Center(
                    child: Column(
                      children: [
                        _Avatar(initials: user.initials),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          style: AppTextStyles.headlineLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 600.ms)
                      .slideY(begin: 0.1, end: 0),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),

                // ── Stats Row ───────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        _StatBubble(
                          label: l10n.profileStrategies,
                          value: '3',
                          icon: Icons.auto_graph_rounded,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        _StatBubble(
                          label: l10n.profileInsights,
                          value: '12',
                          icon: Icons.lightbulb_outline_rounded,
                          color: AppColors.accentCyan,
                        ),
                        const SizedBox(width: 12),
                        _StatBubble(
                          label: l10n.profileScenarios,
                          value: '5',
                          icon: Icons.compare_arrows_rounded,
                          color: AppColors.accentGreen,
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // ── Settings Section ────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.profileSettings,
                          style: AppTextStyles.overline.copyWith(
                            color: AppColors.textMuted,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GlassCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              _SettingTile(
                                icon: Icons.person_outline_rounded,
                                label: l10n.profileEditProfile,
                                onTap: () {},
                                showDivider: true,
                              ),
                              _SettingTile(
                                icon: Icons.language_rounded,
                                label: l10n.language,
                                trailing: _LangToggle(isAr: isAr, ref: ref),
                                showDivider: true,
                              ),
                              _SettingTile(
                                icon: Icons.notifications_outlined,
                                label: l10n.profileNotifications,
                                onTap: () {},
                                showDivider: false,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          l10n.profileAccount,
                          style: AppTextStyles.overline.copyWith(
                            color: AppColors.textMuted,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GlassCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              _SettingTile(
                                icon: Icons.lock_outline_rounded,
                                label: l10n.profileChangePassword,
                                onTap: () {},
                                showDivider: true,
                              ),
                              _SettingTile(
                                icon: Icons.logout_rounded,
                                label: l10n.profileLogout,
                                iconColor: AppColors.accentRed,
                                textColor: AppColors.accentRed,
                                onTap: () async {
                                  await ref
                                      .read(authProvider.notifier)
                                      .logout();
                                },
                                showDivider: false,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // App version footnote
                        Center(
                          child: Text(
                            'Strategic Life Planner v1.0.0',
                            style: AppTextStyles.overline.copyWith(
                              color: AppColors.textMuted.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _NotLoggedInView — shown when user is not authenticated
// ─────────────────────────────────────────────────────────────────────────────

class _NotLoggedInView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(0.8, 0.8)),
                const SizedBox(height: 28),
                Text(
                  l10n.profileNotLoggedInTitle,
                  style: AppTextStyles.headlineMedium,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 12),
                Text(
                  l10n.profileNotLoggedInSub,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 350.ms),
                const SizedBox(height: 36),
                PrimaryButton(
                  label: l10n.profileLoginBtn,
                  icon: Icons.login_rounded,
                  onPressed: () => context.go(AppRoutes.auth),
                ).animate().fadeIn(delay: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _Avatar — gradient circle with initials
// ─────────────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String initials;
  const _Avatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [
                AppColors.primary,
                AppColors.accentCyan,
                AppColors.primary,
              ],
            ),
          ),
        ),
        // White spacer
        Container(
          width: 104,
          height: 104,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.background,
          ),
        ),
        // Inner gradient circle
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StatBubble
// ─────────────────────────────────────────────────────────────────────────────

class _StatBubble extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBubble({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.15),
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 0.75),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.headlineMedium.copyWith(
                color: color,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.overline.copyWith(
                color: AppColors.textMuted,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SettingTile
// ─────────────────────────────────────────────────────────────────────────────

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;
  final Color? textColor;
  final bool showDivider;

  const _SettingTile({
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
    this.iconColor,
    this.textColor,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color:
                        (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: textColor ?? AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                trailing ??
                    (onTap != null
                        ? const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textMuted,
                            size: 20,
                          )
                        : const SizedBox.shrink()),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: AppColors.border.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LangToggle — inline language switcher
// ─────────────────────────────────────────────────────────────────────────────

class _LangToggle extends StatelessWidget {
  final bool isAr;
  final WidgetRef ref;

  const _LangToggle({required this.isAr, required this.ref});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(isAr ? 'en' : 'ar');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          isAr ? 'EN' : 'عربي',
          style: const TextStyle(
            fontFamily: 'Inter',
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _IconAction
// ─────────────────────────────────────────────────────────────────────────────

class _IconAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _IconAction({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.75),
        ),
        child: Icon(icon, color: AppColors.textMuted, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _GlowBlob
// ─────────────────────────────────────────────────────────────────────────────

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color, blurRadius: 80, spreadRadius: 20),
        ],
      ),
    );
  }
}
