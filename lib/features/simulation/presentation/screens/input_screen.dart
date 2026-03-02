import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../../l10n/generated/app_localizations.dart';
import '../widgets/shared_widgets.dart';

/// Screen 1 — "Setup Your Life Parameters"
/// Collects income, saving %, study hours, and workout days.
class InputScreen extends ConsumerStatefulWidget {
  const InputScreen({super.key});

  @override
  ConsumerState<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends ConsumerState<InputScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _incomeController = TextEditingController();
  bool _isSubmitting = false;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    final input = ref.read(simulationInputProvider);
    _incomeController.text = input.monthlyIncome.toStringAsFixed(0);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _simulateFuture() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    final input = ref.read(simulationInputProvider);
    await ref.read(scenariosProvider.notifier).runScenarioA(
          input,
          name: 'My Simulation',
        );
    if (mounted) {
      setState(() => _isSubmitting = false);
      context.go(AppRoutes.results);
    }
  }

  @override
  Widget build(BuildContext context) {
    final input = ref.watch(simulationInputProvider);
    final preview10Y = ref.watch(livePreviewProvider);

    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── App Bar ──────────────────────────────────────────
            SliverAppBar(
              backgroundColor: AppColors.background,
              floating: true,
              pinned: false,
              snap: true,
              automaticallyImplyLeading: false,
              expandedHeight: 70,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                ),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  left: AppConstants.spacingM,
                  right: AppConstants.spacingM,
                ),
                child: Row(
                  children: [
                    _NavButton(
                      onTap: () => context.go(AppRoutes.splash),
                      child: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: AppColors.primaryLight,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingM),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.inputTitle,
                          style: AppTextStyles.overline.copyWith(
                            color: AppColors.primaryLight,
                            letterSpacing: 3,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          l10n.inputSubtitle,
                          style: AppTextStyles.headlineSmall,
                        ),
                      ],
                    ),
                    const Spacer(),
                    _NavButton(
                      onTap: () {
                        ref.read(simulationInputProvider.notifier).reset();
                        _incomeController.text = SimulationInput.defaults()
                            .monthlyIncome
                            .toStringAsFixed(0);
                      },
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: AppColors.textMuted,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Content ──────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingM,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: AppConstants.spacingM),

                  // Compact Hero with progress indicators
                  _HeroHeader(pulseController: _pulseController)
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .scale(begin: const Offset(0.97, 0.97)),

                  const SizedBox(height: AppConstants.spacingM),

                  // Live Preview pinned near top for instant feedback
                  _LivePreviewBanner(
                    savings10Y: preview10Y,
                    currency: input.currency,
                    pulseController: _pulseController,
                  ).animate(delay: 80.ms).fadeIn().slideY(begin: 0.05),

                  const SizedBox(height: AppConstants.spacingL),

                  // Section header: Finances
                  _SectionHeader(
                    icon: Icons.account_balance_wallet_outlined,
                    label: l10n.finances,
                    color: AppColors.primaryLight,
                  ).animate(delay: 120.ms).fadeIn(),

                  const SizedBox(height: AppConstants.spacingS),

                  // Monthly Income
                  _IncomeCard(
                    controller: _incomeController,
                    currency: input.currency,
                    onCurrencyChanged: (val) => ref
                        .read(simulationInputProvider.notifier)
                        .updateCurrency(val),
                    onChanged: (val) {
                      final parsed = double.tryParse(val) ?? 0;
                      ref
                          .read(simulationInputProvider.notifier)
                          .updateIncome(parsed);
                    },
                  ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.08),

                  const SizedBox(height: AppConstants.spacingS),

                  // Saving Percentage Slider
                  _SavingPercentageCard(
                    value: input.savingPercentage,
                    onChanged: (v) => ref
                        .read(simulationInputProvider.notifier)
                        .updateSavingPercentage(v),
                  ).animate(delay: 180.ms).fadeIn().slideY(begin: 0.08),

                  const SizedBox(height: AppConstants.spacingL),

                  // Section header: Health & Growth
                  _SectionHeader(
                    icon: Icons.bolt_rounded,
                    label: l10n.healthGrowth,
                    color: AppColors.accentCyan,
                  ).animate(delay: 220.ms).fadeIn(),

                  const SizedBox(height: AppConstants.spacingS),

                  // Study + Workout in a row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _StudyHoursCard(
                          value: input.dailyStudyHours,
                          onChanged: (v) => ref
                              .read(simulationInputProvider.notifier)
                              .updateStudyHours(v),
                        ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.08),
                      ),
                      const SizedBox(width: AppConstants.spacingS),
                      Expanded(
                        child: _WorkoutDaysCard(
                          value: input.workoutDaysPerWeek,
                          onChanged: (v) => ref
                              .read(simulationInputProvider.notifier)
                              .updateWorkoutDays(v),
                        ).animate(delay: 280.ms).fadeIn().slideY(begin: 0.08),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.spacingL),

                  // Section header: Career
                  _SectionHeader(
                    icon: Icons.work_outline_rounded,
                    label: l10n.career,
                    color: AppColors.accentCyan,
                  ).animate(delay: 320.ms).fadeIn(),

                  const SizedBox(height: AppConstants.spacingS),

                  // Career Module
                  _CareerCard(
                    careerField: input.careerField,
                    weeklySkillHours: input.weeklySkillHours,
                    certsPerYear: input.certsPerYear,
                    onFieldChanged: (v) => ref
                        .read(simulationInputProvider.notifier)
                        .updateCareerField(v),
                    onSkillChanged: (v) => ref
                        .read(simulationInputProvider.notifier)
                        .updateWeeklySkillHours(v),
                    onCertsChanged: (v) => ref
                        .read(simulationInputProvider.notifier)
                        .updateCertsPerYear(v),
                  ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.08),

                  const SizedBox(height: AppConstants.spacingL),

                  // Section header: Social
                  _SectionHeader(
                    icon: Icons.people_outline_rounded,
                    label: l10n.social,
                    color: AppColors.accentAmber,
                  ).animate(delay: 390.ms).fadeIn(),

                  const SizedBox(height: AppConstants.spacingS),

                  // Social Module
                  _SocialCard(
                    socialMediaHours: input.socialMediaHours,
                    familyHours: input.familyHours,
                    networkingHours: input.networkingHours,
                    onSocialMediaChanged: (v) => ref
                        .read(simulationInputProvider.notifier)
                        .updateSocialMediaHours(v),
                    onFamilyChanged: (v) => ref
                        .read(simulationInputProvider.notifier)
                        .updateFamilyHours(v),
                    onNetworkingChanged: (v) => ref
                        .read(simulationInputProvider.notifier)
                        .updateNetworkingHours(v),
                  ).animate(delay: 420.ms).fadeIn().slideY(begin: 0.08),

                  // Space for sticky button
                  const SizedBox(height: 110),
                ]),
              ),
            ),
          ],
        ),
      ),

      // ── Sticky Bottom Button ────────────────────────────────────
      bottomNavigationBar: _BottomActionBar(
        isSubmitting: _isSubmitting,
        onPressed: _simulateFuture,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _NavButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _NavButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 13),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.overline.copyWith(
            color: color.withOpacity(0.8),
            letterSpacing: 2.5,
            fontSize: 10,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 0.5,
            color: AppColors.border.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final AnimationController pulseController;

  const _HeroHeader({required this.pulseController});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1836), Color(0xFF0D0B1E)],
        ),
        border: Border.all(
          color: AppColors.borderGlow,
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        child: Stack(
          children: [
            // Animated orbs
            AnimatedBuilder(
              animation: pulseController,
              builder: (_, __) => Stack(
                children: [
                  Positioned(
                    left: -10 + pulseController.value * 5,
                    top: -10,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary.withValues(
                                alpha: 0.25 + pulseController.value * 0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20 - pulseController.value * 5,
                    bottom: -15,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.accentCyan.withValues(
                                alpha: 0.15 + pulseController.value * 0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Grid pattern overlay
            Positioned.fill(
              child: CustomPaint(painter: _GridPainter()),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.trajectory,
                        style: AppTextStyles.overline.copyWith(
                          color: AppColors.primaryLight,
                          letterSpacing: 4,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.definePath,
                        style: AppTextStyles.headlineLarge,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _MiniPill(
                              label: '10Y', color: AppColors.primaryLight),
                          const SizedBox(width: 6),
                          _MiniPill(
                              label: '5 ${l10n.lifeModules.toUpperCase()}',
                              color: AppColors.accentCyan),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.15),
                      border: Border.all(
                        color: AppColors.primaryLight.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.show_chart_rounded,
                      color: AppColors.primaryLight,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: AppTextStyles.overline.copyWith(
          color: color,
          fontSize: 9,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withOpacity(0.15)
      ..strokeWidth = 0.5;

    const spacing = 20.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────

class _LivePreviewBanner extends StatelessWidget {
  final double savings10Y;
  final String currency;
  final AnimationController pulseController;

  const _LivePreviewBanner({
    required this.savings10Y,
    required this.currency,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1450), Color(0xFF0F0B2A)],
        ),
        border: Border.all(color: AppColors.borderGlow, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: pulseController,
                      builder: (_, __) => Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentGreen,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentGreen.withValues(
                                  alpha: 0.4 + pulseController.value * 0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.liveProjection,
                      style: AppTextStyles.overline.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 2,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                AnimatedCounter(
                  value: savings10Y,
                  formatter: (val) =>
                      AppFormatters.currency(val, currencyCode: currency),
                  style: AppTextStyles.moneyLarge,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GainBadge(text: '+12%', isPositive: true),
              const SizedBox(height: 8),
              Container(
                height: 32,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.primary.withOpacity(0.1),
                ),
                child: CustomPaint(painter: _SparklinePainter()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final points = [0.2, 0.35, 0.25, 0.55, 0.45, 0.7, 0.6, 0.85, 1.0];
    final paint = Paint()
      ..color = AppColors.primaryLight
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final x = size.width * (i / (points.length - 1));
      final y = size.height * (1 - points[i]);
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    // fill below line
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryLight.withOpacity(0.2),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────

class _IncomeCard extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String currency;
  final ValueChanged<String> onCurrencyChanged;

  const _IncomeCard({
    required this.controller,
    required this.onChanged,
    required this.currency,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.monthlyIncome, style: AppTextStyles.headlineSmall),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: currency,
                    dropdownColor: AppColors.surfaceElevated,
                    isDense: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary, size: 16),
                    style: AppTextStyles.labelLarge,
                    items: ['USD', 'EGP', 'SAR', 'AED', 'KWD', 'QAR']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: AppTextStyles.labelLarge),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) onCurrencyChanged(value);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.primaryLight,
              letterSpacing: 1,
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                borderSide: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.6), width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                borderSide: const BorderSide(
                  color: AppColors.primaryLight,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                borderSide: const BorderSide(color: AppColors.accentRed),
              ),
              filled: true,
              fillColor: AppColors.surfaceElevated,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _currencySymbol(currency),
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
              hintText: '0',
              hintStyle: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.textMuted.withValues(alpha: 0.4),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.incomeErrorEmpty;
              }
              final parsed = double.tryParse(value);
              if (parsed == null || parsed <= 0) {
                return l10n.incomeErrorInvalid;
              }
              return null;
            },
            onChanged: onChanged,
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            l10n.incomeHint,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  String _currencySymbol(String code) {
    const symbols = {
      'USD': '\$',
      'EGP': 'E£',
      'SAR': '﷼',
      'AED': 'د.إ',
      'KWD': 'د.ك',
      'QAR': 'ر.ق',
    };
    return symbols[code] ?? code;
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SavingPercentageCard extends StatelessWidget {
  final double value; // 0.0 to 0.50
  final ValueChanged<double> onChanged;

  const _SavingPercentageCard({
    required this.value,
    required this.onChanged,
  });

  String _ratingLabel(AppLocalizations l10n) {
    if (value < 0.1) return l10n.savingLow;
    if (value < 0.15) return l10n.savingModerate;
    if (value < 0.25) return l10n.savingGood;
    return l10n.savingExcellent;
  }

  Color get _ratingColor {
    if (value < 0.1) return AppColors.accentRed;
    if (value < 0.15) return AppColors.accentAmber;
    if (value < 0.25) return AppColors.primaryLight;
    return AppColors.accentGreen;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.savingRate, style: AppTextStyles.headlineSmall),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _ratingColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                  border: Border.all(
                      color: _ratingColor.withValues(alpha: 0.3), width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(value * 100).toInt()}%',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: _ratingColor,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '· ${_ratingLabel(l10n)}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: _ratingColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),
          // Segmented track
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / AppConstants.maxSavingPercentage,
              backgroundColor: AppColors.border.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation(_ratingColor),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              thumbColor: AppColors.primaryLight,
              overlayColor: AppColors.primaryGlow,
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: AppConstants.maxSavingPercentage,
              divisions: 50,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0%', style: AppTextStyles.labelSmall),
              Text('${(AppConstants.maxSavingPercentage * 100).toInt()}%',
                  style: AppTextStyles.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StudyHoursCard extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _StudyHoursCard({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GlassCard(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_rounded,
                  color: AppColors.accentCyan, size: 16),
              const SizedBox(width: 6),
              Text(l10n.study, style: AppTextStyles.labelMedium),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),
          Center(
            child: _CircularStepper(
              value: value,
              unit: l10n.dayUnit,
              accentColor: AppColors.accentCyan,
              onDecrease: value > 0
                  ? () => onChanged((value - 0.5).clamp(0, 10))
                  : null,
              onIncrease: value < AppConstants.maxStudyHoursPerDay
                  ? () => onChanged((value + 0.5).clamp(0, 10))
                  : null,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
        ],
      ),
    );
  }
}

class _WorkoutDaysCard extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _WorkoutDaysCard({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GlassCard(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fitness_center_rounded,
                  color: AppColors.accentGreen, size: 16),
              const SizedBox(width: 6),
              Text(l10n.workout, style: AppTextStyles.labelMedium),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),
          // Compact day dots
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(7, (i) {
              final day = i + 1;
              final isSelected = day <= value;
              final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
              return GestureDetector(
                onTap: () => onChanged(day == value ? 0 : day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accentGreen.withValues(alpha: 0.2)
                        : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accentGreen
                          : AppColors.border.withValues(alpha: 0.5),
                      width: isSelected ? 1 : 0.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      dayLabels[i],
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isSelected
                            ? AppColors.accentGreen
                            : AppColors.textMuted,
                        fontSize: 9,
                        fontWeight: isSelected ? FontWeight.w700 : null,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.workoutDaysPerWeek(value),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.accentGreen.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact circular stepper with +/- controls
class _CircularStepper extends StatelessWidget {
  final double value;
  final String unit;
  final Color accentColor;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  const _CircularStepper({
    required this.value,
    required this.unit,
    required this.accentColor,
    this.onDecrease,
    this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StepButton(
          icon: Icons.remove_rounded,
          onTap: onDecrease,
          color: accentColor,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value.toStringAsFixed(1),
                  style:
                      AppTextStyles.displaySmall.copyWith(color: accentColor),
                ),
              ),
              Text(unit, style: AppTextStyles.labelSmall),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _StepButton(
          icon: Icons.add_rounded,
          onTap: onIncrease,
          color: accentColor,
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  const _StepButton({required this.icon, this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isEnabled
              ? color.withValues(alpha: 0.12)
              : AppColors.border.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isEnabled ? color.withValues(alpha: 0.4) : AppColors.border,
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          color: isEnabled ? color : AppColors.textMuted,
          size: 18,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CareerCard extends StatelessWidget {
  final String careerField;
  final double weeklySkillHours;
  final int certsPerYear;
  final ValueChanged<String> onFieldChanged;
  final ValueChanged<double> onSkillChanged;
  final ValueChanged<int> onCertsChanged;

  const _CareerCard({
    required this.careerField,
    required this.weeklySkillHours,
    required this.certsPerYear,
    required this.onFieldChanged,
    required this.onSkillChanged,
    required this.onCertsChanged,
  });

  List<String> _getFields(AppLocalizations l10n) => [
        l10n.techField,
        l10n.healthField,
        l10n.financeField,
        l10n.artsField,
        l10n.eduField,
        l10n.otherField
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fields = _getFields(l10n);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.careerSkills, style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppConstants.spacingM),
          // Field chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: fields.map((field) {
              final isSelected = field == careerField;
              return GestureDetector(
                onTap: () => onFieldChanged(field),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : AppColors.surfaceElevated,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusFull),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryLight.withValues(alpha: 0.6)
                          : AppColors.border.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    field,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected
                          ? AppColors.primaryLight
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppConstants.spacingM),
          // Sliders
          _LabeledSlider(
            label: l10n.weeklySkillDev,
            value: weeklySkillHours,
            displayText: AppFormatters.hours(weeklySkillHours),
            min: 0,
            max: 40,
            divisions: 40,
            onChanged: onSkillChanged,
            accentColor: AppColors.accentCyan,
          ),
          const SizedBox(height: AppConstants.spacingS),
          _LabeledSlider(
            label: l10n.certsPerYearLabel,
            value: certsPerYear.toDouble(),
            displayText: '$certsPerYear',
            min: 0,
            max: 5,
            divisions: 5,
            onChanged: (v) => onCertsChanged(v.toInt()),
            accentColor: AppColors.primaryLight,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SocialCard extends StatelessWidget {
  final double socialMediaHours;
  final double familyHours;
  final double networkingHours;
  final ValueChanged<double> onSocialMediaChanged;
  final ValueChanged<double> onFamilyChanged;
  final ValueChanged<double> onNetworkingChanged;

  const _SocialCard({
    required this.socialMediaHours,
    required this.familyHours,
    required this.networkingHours,
    required this.onSocialMediaChanged,
    required this.onFamilyChanged,
    required this.onNetworkingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.socialNetworking, style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppConstants.spacingM),
          _LabeledSlider(
            label: l10n.socialMedia,
            value: socialMediaHours,
            displayText: AppFormatters.hours(socialMediaHours),
            min: 0,
            max: 10,
            divisions: 20,
            onChanged: onSocialMediaChanged,
            accentColor: AppColors.accentRed,
            suffix: l10n.dayUnit,
          ),
          const SizedBox(height: AppConstants.spacingS),
          _LabeledSlider(
            label: l10n.familyFriends,
            value: familyHours,
            displayText: AppFormatters.hours(familyHours),
            min: 0,
            max: 40,
            divisions: 40,
            onChanged: onFamilyChanged,
            accentColor: AppColors.accentAmber,
            suffix: l10n.weekUnit,
          ),
          const SizedBox(height: AppConstants.spacingS),
          _LabeledSlider(
            label: l10n.networking,
            value: networkingHours,
            displayText: AppFormatters.hours(networkingHours),
            min: 0,
            max: 20,
            divisions: 20,
            onChanged: onNetworkingChanged,
            accentColor: AppColors.primaryLight,
            suffix: l10n.weekUnit,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Reusable compact labeled slider
class _LabeledSlider extends StatelessWidget {
  final String label;
  final double value;
  final String displayText;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final Color accentColor;
  final String? suffix;

  const _LabeledSlider({
    required this.label,
    required this.value,
    required this.displayText,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    required this.accentColor,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.labelMedium),
            Row(
              children: [
                Text(
                  displayText,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: accentColor,
                    fontVariations: const [FontVariation('wght', 700)],
                  ),
                ),
                if (suffix != null)
                  Text(
                    suffix!,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 2),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: accentColor,
            inactiveTrackColor: AppColors.border.withValues(alpha: 0.5),
            thumbColor: accentColor,
            overlayColor: accentColor.withValues(alpha: 0.1),
            trackHeight: 2,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _BottomActionBar extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onPressed;

  const _BottomActionBar({
    required this.isSubmitting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background.withValues(alpha: 0),
            AppColors.background.withValues(alpha: 0.95),
            AppColors.background,
          ],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppConstants.spacingM,
        AppConstants.spacingL,
        AppConstants.spacingM,
        MediaQuery.of(context).padding.bottom + AppConstants.spacingM,
      ),
      child: Row(
        children: [
          Expanded(
            child: PrimaryButton(
              label: l10n.simulateMyFuture,
              icon: Icons.auto_awesome_rounded,
              isLoading: isSubmitting,
              onPressed: onPressed,
            ),
          ),
        ],
      ),
    );
  }
}
