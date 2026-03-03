import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/localization/auth_provider.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/network/api_client.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../simulation/presentation/widgets/shared_widgets.dart';
import '../../../simulation/data/providers/simulation_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (!authState.isAuthenticated || authState.currentUser == null) {
      return const _NotLoggedInView();
    }

    final user = authState.currentUser!;
    final locale = ref.watch(localeProvider);
    final isAr = locale.languageCode == 'ar';
    final l10n = AppLocalizations.of(context)!;
    final statsAsync = ref.watch(simulationStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background blobs
          Positioned(
            top: -100,
            right: -60,
            child: _GlowBlob(
                color: AppColors.primary.withValues(alpha: 0.10), size: 300),
          ),
          Positioned(
            bottom: 120,
            left: -80,
            child: _GlowBlob(
                color: AppColors.accentCyan.withValues(alpha: 0.06), size: 260),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Header ───────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Row(
                      children: [
                        Text(l10n.navProfile,
                            style: AppTextStyles.headlineMedium),
                        const Spacer(),
                        _IconAction(
                          icon: Icons.edit_outlined,
                          tooltip: 'Edit Profile',
                          onTap: () => _showEditProfileSheet(
                              context, ref, user.name, user.email),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),

                // ── Hero Card (Avatar + Name + Email + quick action) ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _HeroCard(
                        user: user,
                        onEdit: () => _showEditProfileSheet(
                            context, ref, user.name, user.email)),
                  )
                      .animate()
                      .fadeIn(delay: 80.ms, duration: 500.ms)
                      .slideY(begin: 0.08, end: 0),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // ── Stats Row ─────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: statsAsync
                        .when(
                          loading: () => _StatsRow(
                              strategies: '…',
                              insights: '…',
                              scenarios: '…',
                              l10n: l10n),
                          error: (_, __) => _StatsRow(
                              strategies: '0',
                              insights: '0',
                              scenarios: '0',
                              l10n: l10n),
                          data: (stats) => _StatsRow(
                            strategies: stats.totalSimulations.toString(),
                            insights: stats.averageLifeStrategyScore > 0
                                ? stats.averageLifeStrategyScore
                                    .toStringAsFixed(0)
                                : '—',
                            scenarios: stats.averageSavingPercentage > 0
                                ? '${(stats.averageSavingPercentage * 100).toStringAsFixed(0)}%'
                                : '—',
                            l10n: l10n,
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 180.ms, duration: 450.ms),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // ── Preferences Section ───────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel(l10n.profileSettings),
                        const SizedBox(height: 10),
                        GlassCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              _SettingTile(
                                icon: Icons.person_outline_rounded,
                                label: l10n.profileEditProfile,
                                subtitle: user.name,
                                onTap: () => _showEditProfileSheet(
                                    context, ref, user.name, user.email),
                                showDivider: true,
                              ),
                              _SettingTile(
                                icon: Icons.language_rounded,
                                label: l10n.language,
                                subtitle: isAr ? 'العربية' : 'English',
                                trailing: _LangToggle(isAr: isAr, ref: ref),
                                showDivider: true,
                              ),
                              _SettingTile(
                                icon: Icons.notifications_outlined,
                                label: l10n.profileNotifications,
                                subtitle: 'Manage alerts & reminders',
                                onTap: () {},
                                showDivider: true,
                              ),
                              _SettingTile(
                                icon: Icons.analytics_rounded,
                                label: 'How We Calculate',
                                subtitle: 'Learn about our methodology',
                                iconColor: AppColors.accentCyan,
                                onTap: () =>
                                    context.push(AppRoutes.howWeCalculate),
                                showDivider: false,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _SectionLabel(l10n.profileAccount),
                        const SizedBox(height: 10),
                        GlassCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              _SettingTile(
                                icon: Icons.lock_outline_rounded,
                                label: l10n.profileChangePassword,
                                subtitle: 'Update your password',
                                onTap: () {},
                                showDivider: true,
                              ),
                              _SettingTile(
                                icon: Icons.logout_rounded,
                                label: l10n.profileLogout,
                                subtitle: 'Sign out of your account',
                                iconColor: AppColors.accentRed,
                                textColor: AppColors.accentRed,
                                onTap: () => _confirmLogout(context, ref),
                                showDivider: false,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        Center(
                          child: Text(
                            'Strategic Life Planner v1.0.0',
                            style: AppTextStyles.overline.copyWith(
                              color:
                                  AppColors.textMuted.withValues(alpha: 0.45),
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ).animate().fadeIn(delay: 280.ms, duration: 450.ms),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Logout confirmation ───────────────────────────────────────────────────
  void _confirmLogout(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign Out?', style: AppTextStyles.headlineMedium),
        content: Text(
          'Are you sure you want to sign out of your account?',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
              ApiClient.dispose();
            },
            child: Text('Sign Out',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.accentRed)),
          ),
        ],
      ),
    );
  }

  void _showEditProfileSheet(
      BuildContext context, WidgetRef ref, String name, String email) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(
        initialName: name,
        initialEmail: email,
        onSave: (n, e) async =>
            ref.read(authProvider.notifier).updateProfile(name: n, email: e),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _HeroCard — replaces plain avatar+text with a contained card
// ─────────────────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final dynamic user; // your User model
  final VoidCallback onEdit;
  const _HeroCard({required this.user, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.18),
            AppColors.accentCyan.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.18), width: 0.75),
      ),
      child: Row(
        children: [
          _Avatar(initials: user.initials),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name,
                    style: AppTextStyles.headlineMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Edit Profile',
                      style: AppTextStyles.overline.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
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
// _StatsRow — extracted for clarity
// ─────────────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final String strategies, insights, scenarios;
  final AppLocalizations l10n;
  const _StatsRow(
      {required this.strategies,
      required this.insights,
      required this.scenarios,
      required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatBubble(
            label: l10n.profileStrategies,
            value: strategies,
            icon: Icons.auto_graph_rounded,
            color: AppColors.primary),
        const SizedBox(width: 12),
        _StatBubble(
            label: l10n.profileInsights,
            value: insights,
            icon: Icons.lightbulb_outline_rounded,
            color: AppColors.accentCyan),
        const SizedBox(width: 12),
        _StatBubble(
            label: l10n.profileScenarios,
            value: scenarios,
            icon: Icons.compare_arrows_rounded,
            color: AppColors.accentGreen),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SectionLabel
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.overline.copyWith(
        color: AppColors.textMuted,
        letterSpacing: 1.4,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EditProfileSheet
// ─────────────────────────────────────────────────────────────────────────────

class _EditProfileSheet extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final Future<void> Function(String name, String email) onSave;

  const _EditProfileSheet(
      {required this.initialName,
      required this.initialEmail,
      required this.onSave});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  bool _isSaving = false;
  String? _error;

  bool get _hasChanges =>
      _nameCtrl.text.trim() != widget.initialName ||
      _emailCtrl.text.trim() != widget.initialEmail;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _emailCtrl = TextEditingController(text: widget.initialEmail);
    _nameCtrl.addListener(() => setState(() {}));
    _emailCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Name cannot be empty');
      return;
    }
    if (email.isNotEmpty && !email.contains('@')) {
      setState(() => _error = 'Enter a valid email');
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      await widget.onSave(name, email);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _isSaving = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle + close row
            Row(
              children: [
                const Spacer(),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4)),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close_rounded,
                      size: 20, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Edit Profile', style: AppTextStyles.headlineMedium),
            Text(
              'Update your name or email address',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),

            _InputField(
                controller: _nameCtrl,
                label: 'Full Name',
                icon: Icons.person_outline_rounded,
                keyboardType: TextInputType.name),
            const SizedBox(height: 14),
            _InputField(
                controller: _emailCtrl,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress),

            // Inline error
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: _error != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              size: 14, color: AppColors.accentRed),
                          const SizedBox(width: 6),
                          Expanded(
                              child: Text(_error!,
                                  style: AppTextStyles.bodySmall
                                      .copyWith(color: AppColors.accentRed))),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 28),

            // Save button — disabled when no changes
            AnimatedOpacity(
              opacity: _hasChanges ? 1.0 : 0.45,
              duration: const Duration(milliseconds: 200),
              child: SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: _hasChanges
                        ? AppColors.primaryGradient
                        : LinearGradient(
                            colors: [AppColors.border, AppColors.border]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: _hasChanges
                        ? [
                            BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6))
                          ]
                        : [],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: (_isSaving || !_hasChanges) ? null : _handleSave,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : Text('Save Changes',
                                  style: AppTextStyles.labelMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _InputField
// ─────────────────────────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;

  const _InputField(
      {required this.controller,
      required this.label,
      required this.icon,
      this.keyboardType = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.border, width: 0.75)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.border, width: 0.75)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _NotLoggedInView
// ─────────────────────────────────────────────────────────────────────────────

class _NotLoggedInView extends StatelessWidget {
  const _NotLoggedInView();

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
                            offset: const Offset(0, 10))
                      ]),
                  child: const Icon(Icons.person_outline_rounded,
                      color: Colors.white, size: 44),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(0.8, 0.8)),
                const SizedBox(height: 28),
                Text(l10n.profileNotLoggedInTitle,
                        style: AppTextStyles.headlineMedium,
                        textAlign: TextAlign.center)
                    .animate()
                    .fadeIn(delay: 200.ms),
                const SizedBox(height: 12),
                Text(l10n.profileNotLoggedInSub,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textMuted),
                        textAlign: TextAlign.center)
                    .animate()
                    .fadeIn(delay: 350.ms),
                const SizedBox(height: 36),
                PrimaryButton(
                        label: l10n.profileLoginBtn,
                        icon: Icons.login_rounded,
                        onPressed: () => context.go(AppRoutes.auth))
                    .animate()
                    .fadeIn(delay: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _Avatar
// ─────────────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String initials;
  const _Avatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(colors: [
                AppColors.primary,
                AppColors.accentCyan,
                AppColors.primary
              ])),
        ),
        Container(
            width: 74,
            height: 74,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: AppColors.background)),
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
              shape: BoxShape.circle, gradient: AppColors.primaryGradient),
          child: Center(
              child: Text(initials,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1))),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StatBubble
// ─────────────────────────────────────────────────────────────────────────────

class _StatBubble extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const _StatBubble(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.14),
                color.withValues(alpha: 0.04)
              ]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.18), width: 0.75),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value,
                style: AppTextStyles.headlineMedium
                    .copyWith(color: color, fontSize: 20)),
            const SizedBox(height: 4),
            Text(label,
                style: AppTextStyles.overline
                    .copyWith(color: AppColors.textMuted, fontSize: 10),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SettingTile — now with subtitle support
// ─────────────────────────────────────────────────────────────────────────────

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;
  final Color? textColor;
  final bool showDivider;

  const _SettingTile({
    required this.icon,
    required this.label,
    this.subtitle,
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
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: (iconColor ?? AppColors.primary)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon,
                        color: iconColor ?? AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: textColor ?? AppColors.textPrimary,
                                fontWeight: FontWeight.w500)),
                        if (subtitle != null)
                          Text(subtitle!,
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  trailing ??
                      (onTap != null
                          ? const Icon(Icons.chevron_right_rounded,
                              color: AppColors.textMuted, size: 20)
                          : const SizedBox.shrink()),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
              height: 1,
              indent: 20,
              endIndent: 20,
              color: AppColors.border.withValues(alpha: 0.4)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LangToggle
// ─────────────────────────────────────────────────────────────────────────────

class _LangToggle extends StatelessWidget {
  final bool isAr;
  final WidgetRef ref;
  const _LangToggle({required this.isAr, required this.ref});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(localeProvider.notifier).setLocale(isAr ? 'en' : 'ar');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20)),
        child: Text(isAr ? 'EN' : 'عربي',
            style: const TextStyle(
                fontFamily: 'Inter',
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _IconAction
// ─────────────────────────────────────────────────────────────────────────────

class _IconAction extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback? onTap;
  const _IconAction({required this.icon, this.tooltip, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 0.75)),
          child: Icon(icon, color: AppColors.textMuted, size: 20),
        ),
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
        decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
          BoxShadow(color: color, blurRadius: 80, spreadRadius: 20)
        ]));
  }
}
