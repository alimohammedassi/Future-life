import 'dart:math' as math;
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

// ─────────────────────────────────────────────────────────────────────────────
// InputScreen
// ─────────────────────────────────────────────────────────────────────────────

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
  late final AnimationController _pulseCtrl;
  late final AnimationController _orb1Ctrl;
  late final AnimationController _orb2Ctrl;

  @override
  void initState() {
    super.initState();
    final input = ref.read(simulationInputProvider);
    _incomeController.text = input.monthlyIncome.toStringAsFixed(0);
    _pulseCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _orb1Ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 8))
          ..repeat(reverse: true);
    _orb2Ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 11))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _pulseCtrl.dispose();
    _orb1Ctrl.dispose();
    _orb2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _simulateFuture() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    final input = ref.read(simulationInputProvider);
    await ref
        .read(scenariosProvider.notifier)
        .runScenarioA(input, name: 'My Simulation');
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _AmbientOrbs(orb1: _orb1Ctrl, orb2: _orb2Ctrl, size: size),
          Form(
            key: _formKey,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  floating: true,
                  pinned: false,
                  snap: true,
                  automaticallyImplyLeading: false,
                  expandedHeight: 68,
                  flexibleSpace: _TopBar(
                    l10n: l10n,
                    onBack: () => context.go(AppRoutes.splash),
                    onReset: () {
                      ref.read(simulationInputProvider.notifier).reset();
                      _incomeController.text = SimulationInput.defaults()
                          .monthlyIncome
                          .toStringAsFixed(0);
                    },
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingM),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: AppConstants.spacingS),

                      // ── Hero: live 10-year wealth card
                      _LiveWealthCard(
                        savings10Y: preview10Y,
                        currency: input.currency,
                        pulseCtrl: _pulseCtrl,
                        monthlyIncome: input.monthlyIncome,
                        savingPercentage: input.savingPercentage,
                      ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.06),

                      const SizedBox(height: AppConstants.spacingM),

                      // ── Life-score radar
                      _ReadinessRadar(input: input)
                          .animate(delay: 80.ms)
                          .fadeIn()
                          .slideY(begin: 0.06),

                      const SizedBox(height: AppConstants.spacingXL),

                      // ── 01 FINANCES
                      _StepDivider(
                              icon: Icons.account_balance_wallet_outlined,
                              label: l10n.finances,
                              color: AppColors.primaryLight,
                              step: '01')
                          .animate(delay: 120.ms)
                          .fadeIn(),
                      const SizedBox(height: AppConstants.spacingM),
                      _IncomeCard(
                              controller: _incomeController,
                              currency: input.currency,
                              monthlyIncome: input.monthlyIncome,
                              onCurrencyChanged: (v) => ref
                                  .read(simulationInputProvider.notifier)
                                  .updateCurrency(v),
                              onChanged: (v) {
                                final p = double.tryParse(v) ?? 0;
                                ref
                                    .read(simulationInputProvider.notifier)
                                    .updateIncome(p);
                              },
                              l10n: l10n)
                          .animate(delay: 150.ms)
                          .fadeIn()
                          .slideY(begin: 0.08),
                      const SizedBox(height: AppConstants.spacingS),
                      _SavingCard(
                              value: input.savingPercentage,
                              monthlyIncome: input.monthlyIncome,
                              currency: input.currency,
                              onChanged: (v) => ref
                                  .read(simulationInputProvider.notifier)
                                  .updateSavingPercentage(v),
                              l10n: l10n)
                          .animate(delay: 180.ms)
                          .fadeIn()
                          .slideY(begin: 0.08),

                      const SizedBox(height: AppConstants.spacingXL),

                      // ── 02 HEALTH & GROWTH
                      _StepDivider(
                              icon: Icons.bolt_rounded,
                              label: l10n.healthGrowth,
                              color: AppColors.accentCyan,
                              step: '02')
                          .animate(delay: 220.ms)
                          .fadeIn(),
                      const SizedBox(height: AppConstants.spacingM),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: _StudyCard(
                                      value: input.dailyStudyHours,
                                      onChanged: (v) => ref
                                          .read(
                                              simulationInputProvider.notifier)
                                          .updateStudyHours(v),
                                      l10n: l10n)
                                  .animate(delay: 250.ms)
                                  .fadeIn()
                                  .slideY(begin: 0.08)),
                          const SizedBox(width: AppConstants.spacingS),
                          Expanded(
                              child: _WorkoutCard(
                                      value: input.workoutDaysPerWeek,
                                      onChanged: (v) => ref
                                          .read(
                                              simulationInputProvider.notifier)
                                          .updateWorkoutDays(v),
                                      l10n: l10n)
                                  .animate(delay: 280.ms)
                                  .fadeIn()
                                  .slideY(begin: 0.08)),
                        ],
                      ),

                      const SizedBox(height: AppConstants.spacingXL),

                      // ── 03 CAREER
                      _StepDivider(
                              icon: Icons.work_outline_rounded,
                              label: l10n.career,
                              color: const Color(0xFF7C6FEC),
                              step: '03')
                          .animate(delay: 320.ms)
                          .fadeIn(),
                      const SizedBox(height: AppConstants.spacingM),
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
                              l10n: l10n)
                          .animate(delay: 350.ms)
                          .fadeIn()
                          .slideY(begin: 0.08),

                      const SizedBox(height: AppConstants.spacingXL),

                      // ── 04 SOCIAL
                      _StepDivider(
                              icon: Icons.people_outline_rounded,
                              label: l10n.social,
                              color: AppColors.accentAmber,
                              step: '04')
                          .animate(delay: 390.ms)
                          .fadeIn(),
                      const SizedBox(height: AppConstants.spacingM),
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
                              l10n: l10n)
                          .animate(delay: 420.ms)
                          .fadeIn()
                          .slideY(begin: 0.08),

                      const SizedBox(height: 120),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomCTA(
                isSubmitting: _isSubmitting,
                onPressed: _simulateFuture,
                l10n: l10n),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ambient Orbs
// ─────────────────────────────────────────────────────────────────────────────

class _AmbientOrbs extends StatelessWidget {
  final AnimationController orb1, orb2;
  final Size size;
  const _AmbientOrbs(
      {required this.orb1, required this.orb2, required this.size});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: Listenable.merge([orb1, orb2]),
        builder: (_, __) => Stack(children: [
          Positioned(
            top: -40 + orb1.value * 30,
            right: -60 + orb1.value * 20,
            child: Container(
                width: size.width * 0.6,
                height: size.width * 0.6,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppColors.primary.withOpacity(0.09),
                      Colors.transparent
                    ]))),
          ),
          Positioned(
            bottom: 100 + orb2.value * 40,
            left: -80 + orb2.value * 20,
            child: Container(
                width: size.width * 0.55,
                height: size.width * 0.55,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppColors.accentCyan.withOpacity(0.05),
                      Colors.transparent
                    ]))),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top Bar
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onBack, onReset;
  const _TopBar(
      {required this.l10n, required this.onBack, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.88),
        border: Border(
            bottom: BorderSide(
                color: AppColors.border.withOpacity(0.3), width: 0.5)),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: AppConstants.spacingM,
        right: AppConstants.spacingM,
        bottom: 8,
      ),
      child: Row(children: [
        _NavBtn(
            onTap: onBack,
            child: const Icon(Icons.arrow_back_ios_rounded,
                color: AppColors.primaryLight, size: 16)),
        const SizedBox(width: AppConstants.spacingM),
        Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.inputTitle,
                  style: AppTextStyles.overline.copyWith(
                      color: AppColors.primaryLight,
                      letterSpacing: 2.5,
                      fontSize: 9)),
              Text(l10n.inputSubtitle, style: AppTextStyles.headlineSmall),
            ]),
        const Spacer(),
        _NavBtn(
            onTap: onReset,
            child: const Icon(Icons.refresh_rounded,
                color: AppColors.textMuted, size: 17)),
      ]),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _NavBtn({required this.onTap, required this.child});

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
              border: Border.all(color: AppColors.border, width: 0.5)),
          child: Center(child: child)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step Divider
// ─────────────────────────────────────────────────────────────────────────────

class _StepDivider extends StatelessWidget {
  final IconData icon;
  final String label, step;
  final Color color;
  const _StepDivider(
      {required this.icon,
      required this.label,
      required this.color,
      required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(step,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color.withOpacity(0.3),
              letterSpacing: 1,
              fontFeatures: const [FontFeature.tabularFigures()])),
      const SizedBox(width: 10),
      Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: color.withOpacity(0.2), width: 0.5)),
          child: Icon(icon, color: color, size: 13)),
      const SizedBox(width: 8),
      Text(label.toUpperCase(),
          style: AppTextStyles.overline.copyWith(
              color: color.withOpacity(0.85),
              letterSpacing: 2.5,
              fontSize: 10,
              fontWeight: FontWeight.w700)),
      const SizedBox(width: 12),
      Expanded(
          child: Container(
              height: 0.5,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [color.withOpacity(0.3), Colors.transparent])))),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Live Wealth Card
// ─────────────────────────────────────────────────────────────────────────────

class _LiveWealthCard extends StatelessWidget {
  final double savings10Y, monthlyIncome, savingPercentage;
  final String currency;
  final AnimationController pulseCtrl;

  const _LiveWealthCard(
      {required this.savings10Y,
      required this.currency,
      required this.pulseCtrl,
      required this.monthlyIncome,
      required this.savingPercentage});

  Color get _rateColor {
    if (savingPercentage < 0.1) return AppColors.accentRed;
    if (savingPercentage < 0.2) return AppColors.accentAmber;
    if (savingPercentage < 0.35) return AppColors.primaryLight;
    return AppColors.accentGreen;
  }

  @override
  Widget build(BuildContext context) {
    final monthlySaving = monthlyIncome * savingPercentage;
    final annualSaving = monthlySaving * 12;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1C1245), Color(0xFF0E0B28)]),
        border: Border.all(color: AppColors.borderGlow, width: 0.75),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 8))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        child: Stack(children: [
          Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              width: 140,
              child: CustomPaint(painter: _WealthChartPainter())),
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Live dot
              Row(children: [
                AnimatedBuilder(
                  animation: pulseCtrl,
                  builder: (_, __) => Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentGreen,
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.accentGreen
                                    .withOpacity(0.4 + pulseCtrl.value * 0.5),
                                blurRadius: 8)
                          ])),
                ),
                const SizedBox(width: 7),
                Text('LIVE · 10-YEAR FORECAST',
                    style: AppTextStyles.overline.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 9,
                        letterSpacing: 2)),
              ]),

              const SizedBox(height: 14),

              AnimatedCounter(
                value: savings10Y,
                formatter: (val) =>
                    AppFormatters.currency(val, currencyCode: currency),
                style: AppTextStyles.moneyLarge.copyWith(fontSize: 32),
              ),

              const SizedBox(height: 5),
              Row(children: [
                GainBadge(text: '+12% / yr', isPositive: true),
                const SizedBox(width: 8),
                Text('projected wealth',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textMuted, fontSize: 11)),
              ]),

              const SizedBox(height: AppConstants.spacingM),
              Container(height: 0.5, color: AppColors.border.withOpacity(0.4)),
              const SizedBox(height: AppConstants.spacingM),

              // 3 sub-stats
              Row(children: [
                Expanded(
                    child: _WealthStat(
                        label: 'Monthly Saving',
                        value: monthlySaving > 0
                            ? AppFormatters.currency(monthlySaving,
                                currencyCode: currency)
                            : '—',
                        color: AppColors.primaryLight)),
                Container(
                    width: 0.5,
                    height: 28,
                    color: AppColors.border.withOpacity(0.4),
                    margin: const EdgeInsets.symmetric(horizontal: 12)),
                Expanded(
                    child: _WealthStat(
                        label: 'Per Year',
                        value: annualSaving > 0
                            ? AppFormatters.currency(annualSaving,
                                currencyCode: currency)
                            : '—',
                        color: AppColors.accentCyan)),
                Container(
                    width: 0.5,
                    height: 28,
                    color: AppColors.border.withOpacity(0.4),
                    margin: const EdgeInsets.symmetric(horizontal: 12)),
                Expanded(
                    child: _WealthStat(
                        label: 'Rate',
                        value: '${(savingPercentage * 100).toInt()}%',
                        color: _rateColor)),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _WealthStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _WealthStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: AppTextStyles.overline.copyWith(
              color: AppColors.textMuted, fontSize: 9, letterSpacing: 0.5)),
      const SizedBox(height: 4),
      Text(value,
          style: AppTextStyles.labelMedium.copyWith(
              color: color, fontSize: 12, fontWeight: FontWeight.w700)),
    ]);
  }
}

class _WealthChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const pts = [0.1, 0.25, 0.18, 0.42, 0.38, 0.62, 0.52, 0.78, 0.68, 1.0];
    final path = Path();
    for (int i = 0; i < pts.length; i++) {
      final x = size.width * (i / (pts.length - 1));
      final y = size.height * (1 - pts[i] * 0.7);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final px = size.width * ((i - 1) / (pts.length - 1));
        final py = size.height * (1 - pts[i - 1] * 0.7);
        final cpX = (px + x) / 2;
        path.cubicTo(cpX, py, cpX, y, x, y);
      }
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.primaryLight.withOpacity(0.15)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryLight.withOpacity(0.08),
                Colors.transparent
              ]).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_WealthChartPainter _) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Readiness Radar
// ─────────────────────────────────────────────────────────────────────────────

class _ReadinessRadar extends StatelessWidget {
  final dynamic input;
  const _ReadinessRadar({required this.input});

  double get _fin => (input.savingPercentage / 0.5).clamp(0.0, 1.0) as double;
  double get _health =>
      (input.workoutDaysPerWeek / 7.0).clamp(0.0, 1.0) as double;
  double get _learn =>
      (input.dailyStudyHours / AppConstants.maxStudyHoursPerDay).clamp(0.0, 1.0)
          as double;
  double get _career =>
      ((input.weeklySkillHours / 20.0) * 0.6 + (input.certsPerYear / 5.0) * 0.4)
          .clamp(0.0, 1.0) as double;
  double get _social {
    final sm = (input.socialMediaHours as double).clamp(0.0, 10.0);
    return ((input.familyHours / 20.0) * 0.5 +
            (input.networkingHours / 10.0) * 0.3 +
            ((10 - sm) / 10) * 0.2)
        .clamp(0.0, 1.0);
  }

  double get _overall => (_fin + _health + _learn + _career + _social) / 5;

  @override
  Widget build(BuildContext context) {
    final scores = [_fin, _health, _learn, _career, _social];
    const labels = ['Finance', 'Health', 'Learning', 'Career', 'Social'];
    const colors = [
      AppColors.primaryLight,
      AppColors.accentGreen,
      AppColors.accentCyan,
      Color(0xFF7C6FEC),
      AppColors.accentAmber
    ];
    final overall = (_overall * 100).toInt();
    final overallColor = _overall > 0.6
        ? AppColors.accentGreen
        : _overall > 0.35
            ? AppColors.accentAmber
            : AppColors.accentRed;

    return GlassCard(
      child: Row(children: [
        SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(painter: _RadarPainter(scores: scores))),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('LIFE SCORE',
                style: AppTextStyles.overline.copyWith(
                    color: AppColors.textMuted, fontSize: 9, letterSpacing: 2)),
            const Spacer(),
            Text('$overall',
                style: AppTextStyles.headlineLarge
                    .copyWith(color: overallColor, fontSize: 28, height: 1)),
            Text('/100',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textMuted, fontSize: 12)),
          ]),
          const SizedBox(height: 10),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: List.generate(
                5,
                (i) => _ScorePill(
                    label: labels[i], value: scores[i], color: colors[i])),
          ),
        ])),
      ]),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _ScorePill(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: color.withOpacity(0.25), width: 0.5)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 4),
        Text('$label ${(value * 100).toInt()}%',
            style: TextStyle(
                fontSize: 9,
                color: color,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2)),
      ]),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final List<double> scores;
  const _RadarPainter({required this.scores});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    const maxR = 40.0, sides = 5;
    const startAngle = -math.pi / 2;

    for (int ring = 1; ring <= 4; ring++) {
      final r = maxR * ring / 4;
      final path = Path();
      for (int i = 0; i < sides; i++) {
        final a = startAngle + 2 * math.pi * i / sides;
        final pt = Offset(cx + r * math.cos(a), cy + r * math.sin(a));
        i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
      }
      path.close();
      canvas.drawPath(
          path,
          Paint()
            ..color = AppColors.border.withOpacity(0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.5);
    }
    for (int i = 0; i < sides; i++) {
      final a = startAngle + 2 * math.pi * i / sides;
      canvas.drawLine(
          Offset(cx, cy),
          Offset(cx + maxR * math.cos(a), cy + maxR * math.sin(a)),
          Paint()
            ..color = AppColors.border.withOpacity(0.2)
            ..strokeWidth = 0.5);
    }

    final dataPath = Path();
    for (int i = 0; i < sides; i++) {
      final a = startAngle + 2 * math.pi * i / sides;
      final r = maxR * scores[i].clamp(0.05, 1.0);
      final pt = Offset(cx + r * math.cos(a), cy + r * math.sin(a));
      i == 0 ? dataPath.moveTo(pt.dx, pt.dy) : dataPath.lineTo(pt.dx, pt.dy);
    }
    dataPath.close();
    canvas.drawPath(
        dataPath,
        Paint()
          ..shader = RadialGradient(colors: [
            AppColors.primaryLight.withOpacity(0.45),
            AppColors.primary.withOpacity(0.12)
          ]).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: maxR))
          ..style = PaintingStyle.fill);
    canvas.drawPath(
        dataPath,
        Paint()
          ..color = AppColors.primaryLight.withOpacity(0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2);
    for (int i = 0; i < sides; i++) {
      final a = startAngle + 2 * math.pi * i / sides;
      final r = maxR * scores[i].clamp(0.05, 1.0);
      canvas.drawCircle(Offset(cx + r * math.cos(a), cy + r * math.sin(a)), 2.5,
          Paint()..color = AppColors.primaryLight);
    }
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.scores.toString() != scores.toString();
}

// ─────────────────────────────────────────────────────────────────────────────
// Income Card
// ─────────────────────────────────────────────────────────────────────────────

class _IncomeCard extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged, onCurrencyChanged;
  final String currency;
  final double monthlyIncome;
  final AppLocalizations l10n;

  const _IncomeCard(
      {required this.controller,
      required this.onChanged,
      required this.currency,
      required this.monthlyIncome,
      required this.onCurrencyChanged,
      required this.l10n});

  String _sym(String c) =>
      const {
        'USD': '\$',
        'EGP': 'E£',
        'SAR': '﷼',
        'AED': 'د.إ',
        'KWD': 'د.ك',
        'QAR': 'ر.ق'
      }[c] ??
      c;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(l10n.monthlyIncome, style: AppTextStyles.headlineSmall),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                    color: AppColors.border.withOpacity(0.6), width: 0.5)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currency,
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
                  if (v != null) onCurrencyChanged(v);
                },
              ),
            ),
          ),
        ]),
        const SizedBox(height: AppConstants.spacingM),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.primaryLight, letterSpacing: 1.5, fontSize: 28),
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                borderSide: BorderSide(
                    color: AppColors.border.withOpacity(0.5), width: 0.5)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                borderSide: BorderSide(
                    color: AppColors.border.withOpacity(0.5), width: 0.5)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                borderSide: const BorderSide(
                    color: AppColors.primaryLight, width: 1.5)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                borderSide: const BorderSide(color: AppColors.accentRed)),
            filled: true,
            fillColor: AppColors.surfaceElevated,
            contentPadding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 8, top: 2),
              child: Text(_sym(currency),
                  style: AppTextStyles.headlineLarge
                      .copyWith(color: AppColors.textMuted, fontSize: 24)),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            hintText: '0',
            hintStyle: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.textMuted.withOpacity(0.3), fontSize: 28),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return l10n.incomeErrorEmpty;
            final p = double.tryParse(v);
            if (p == null || p <= 0) return l10n.incomeErrorInvalid;
            return null;
          },
          onChanged: onChanged,
        ),
        // Annual + Daily derived pills
        if (monthlyIncome > 0) ...[
          const SizedBox(height: AppConstants.spacingS),
          Row(children: [
            _Pill(
                text:
                    'Annual: ${AppFormatters.currency(monthlyIncome * 12, currencyCode: currency)}'),
            const SizedBox(width: 8),
            _Pill(
                text:
                    'Daily: ${AppFormatters.currency(monthlyIncome / 30, currencyCode: currency)}'),
          ]),
        ],
        const SizedBox(height: AppConstants.spacingS),
        Text(l10n.incomeHint,
            style:
                AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
      ]),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(100),
          border:
              Border.all(color: AppColors.border.withOpacity(0.5), width: 0.5)),
      child: Text(text,
          style: AppTextStyles.labelSmall
              .copyWith(color: AppColors.textMuted, fontSize: 10)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Saving Card
// ─────────────────────────────────────────────────────────────────────────────

class _SavingCard extends StatelessWidget {
  final double value, monthlyIncome;
  final String currency;
  final ValueChanged<double> onChanged;
  final AppLocalizations l10n;

  const _SavingCard(
      {required this.value,
      required this.monthlyIncome,
      required this.currency,
      required this.onChanged,
      required this.l10n});

  Color get _color {
    if (value < 0.1) return AppColors.accentRed;
    if (value < 0.15) return AppColors.accentAmber;
    if (value < 0.25) return AppColors.primaryLight;
    return AppColors.accentGreen;
  }

  String _rating(AppLocalizations l) {
    if (value < 0.1) return l.savingLow;
    if (value < 0.15) return l.savingModerate;
    if (value < 0.25) return l.savingGood;
    return l.savingExcellent;
  }

  @override
  Widget build(BuildContext context) {
    final saved = monthlyIncome * value;
    return GlassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(l10n.savingRate, style: AppTextStyles.headlineSmall),
                if (saved > 0) ...[
                  const SizedBox(height: 4),
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: 'Saving ',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textMuted)),
                    TextSpan(
                        text: AppFormatters.currency(saved,
                            currencyCode: currency),
                        style: AppTextStyles.bodySmall.copyWith(
                            color: _color, fontWeight: FontWeight.w700)),
                    TextSpan(
                        text: ' / month',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textMuted)),
                  ])),
                ],
              ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: _color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: _color.withOpacity(0.3), width: 0.5)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('${(value * 100).toInt()}%',
                  style: AppTextStyles.labelLarge.copyWith(color: _color)),
              const SizedBox(width: 5),
              Text('· ${_rating(l10n)}',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: _color.withOpacity(0.7))),
            ]),
          ),
        ]),
        const SizedBox(height: AppConstants.spacingM),
        _SavingZoneBar(value: value),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.transparent,
            inactiveTrackColor: Colors.transparent,
            thumbColor: _color,
            overlayColor: _color.withOpacity(0.15),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
              value: value,
              min: 0,
              max: AppConstants.maxSavingPercentage,
              divisions: 50,
              onChanged: onChanged),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('0%',
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textMuted)),
          Text('${(AppConstants.maxSavingPercentage * 100).toInt()}%',
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textMuted)),
        ]),
      ]),
    );
  }
}

class _SavingZoneBar extends StatelessWidget {
  final double value;
  const _SavingZoneBar({required this.value});

  Color _glow() {
    if (value < 0.1) return AppColors.accentRed;
    if (value < 0.2) return AppColors.accentAmber;
    if (value < 0.3) return AppColors.primaryLight;
    return AppColors.accentGreen;
  }

  List<Color> _grad() {
    if (value < 0.1)
      return [AppColors.accentRed.withOpacity(0.6), AppColors.accentRed];
    if (value < 0.2) return [AppColors.accentRed, AppColors.accentAmber];
    if (value < 0.3) return [AppColors.accentAmber, AppColors.primaryLight];
    return [AppColors.primaryLight, AppColors.accentGreen];
  }

  @override
  Widget build(BuildContext context) {
    final filled = (value / AppConstants.maxSavingPercentage).clamp(0.0, 1.0);
    return LayoutBuilder(
        builder: (_, c) => Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Row(children: [
                  Expanded(
                      flex: 2,
                      child: Container(
                          height: 8,
                          color: AppColors.accentRed.withOpacity(0.22))),
                  Expanded(
                      flex: 1,
                      child: Container(
                          height: 8,
                          color: AppColors.accentAmber.withOpacity(0.22))),
                  Expanded(
                      flex: 2,
                      child: Container(
                          height: 8,
                          color: AppColors.accentAmber.withOpacity(0.16))),
                  Expanded(
                      flex: 2,
                      child: Container(
                          height: 8,
                          color: AppColors.primaryLight.withOpacity(0.22))),
                  Expanded(
                      flex: 3,
                      child: Container(
                          height: 8,
                          color: AppColors.accentGreen.withOpacity(0.22))),
                ]),
              ),
              Container(
                  height: 8,
                  width: c.maxWidth * filled,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: _grad()),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                            color: _glow().withOpacity(0.4), blurRadius: 6)
                      ])),
            ]));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Study Card
// ─────────────────────────────────────────────────────────────────────────────

class _StudyCard extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final AppLocalizations l10n;
  const _StudyCard(
      {required this.value, required this.onChanged, required this.l10n});

  String get _impact {
    if (value < 0.5) return 'Minimal';
    if (value < 1.5) return 'Basic';
    if (value < 3) return 'Solid';
    if (value < 5) return 'Strong';
    return 'Elite';
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.menu_book_rounded,
              color: AppColors.accentCyan, size: 15),
          const SizedBox(width: 5),
          Text(l10n.study, style: AppTextStyles.labelMedium),
        ]),
        const SizedBox(height: 14),
        Center(
            child: Column(children: [
          RichText(
              text: TextSpan(children: [
            TextSpan(
                text: value.toStringAsFixed(1),
                style: AppTextStyles.displaySmall
                    .copyWith(color: AppColors.accentCyan, height: 1)),
            TextSpan(
                text: 'h',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.accentCyan.withOpacity(0.6))),
          ])),
          Text('/day',
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textMuted)),
        ])),
        const SizedBox(height: 10),
        Center(
            child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
              color: AppColors.accentCyan.withOpacity(0.08),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                  color: AppColors.accentCyan.withOpacity(0.2), width: 0.5)),
          child: Text(_impact,
              style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.accentCyan.withOpacity(0.85), fontSize: 10)),
        )),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _StepBtn(
              icon: Icons.remove_rounded,
              color: AppColors.accentCyan,
              onTap: value > 0
                  ? () => onChanged((value - 0.5).clamp(0, 10))
                  : null),
          const SizedBox(width: 24),
          _StepBtn(
              icon: Icons.add_rounded,
              color: AppColors.accentCyan,
              onTap: value < AppConstants.maxStudyHoursPerDay
                  ? () => onChanged((value + 0.5).clamp(0, 10))
                  : null),
        ]),
        const SizedBox(height: 8),
        Center(
            child: Text('${(value * 7).toStringAsFixed(0)}h / week',
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.textMuted, fontSize: 10))),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Workout Card
// ─────────────────────────────────────────────────────────────────────────────

class _WorkoutCard extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final AppLocalizations l10n;
  const _WorkoutCard(
      {required this.value, required this.onChanged, required this.l10n});

  Color get _c {
    if (value == 0) return AppColors.accentRed;
    if (value <= 2) return AppColors.accentAmber;
    if (value <= 4) return AppColors.primaryLight;
    return AppColors.accentGreen;
  }

  String get _tier {
    if (value == 0) return 'Inactive';
    if (value <= 2) return 'Light';
    if (value <= 4) return 'Active';
    if (value <= 6) return 'Athletic';
    return 'Elite';
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.fitness_center_rounded, color: _c, size: 15),
          const SizedBox(width: 5),
          Text(l10n.workout, style: AppTextStyles.labelMedium),
        ]),
        const SizedBox(height: 12),
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: List.generate(7, (i) {
            final day = i + 1;
            final active = day <= value;
            const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
            return GestureDetector(
              onTap: () => onChanged(day == value ? 0 : day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color:
                      active ? _c.withOpacity(0.18) : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                      color: active
                          ? _c.withOpacity(0.7)
                          : AppColors.border.withOpacity(0.4),
                      width: 0.75),
                ),
                child: Center(
                    child: Text(labels[i],
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight:
                                active ? FontWeight.w800 : FontWeight.w400,
                            color: active ? _c : AppColors.textMuted))),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('$value day${value != 1 ? 's' : ''}/wk',
              style: AppTextStyles.labelSmall.copyWith(
                  color: _c.withOpacity(0.85),
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
                color: _c.withOpacity(0.08),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: _c.withOpacity(0.2), width: 0.5)),
            child: Text(_tier,
                style: TextStyle(
                    fontSize: 9,
                    color: _c.withOpacity(0.85),
                    fontWeight: FontWeight.w600)),
          ),
        ]),
      ]),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  const _StepBtn({required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final on = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color:
              on ? color.withOpacity(0.12) : AppColors.border.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: on
                  ? color.withOpacity(0.35)
                  : AppColors.border.withOpacity(0.3),
              width: 0.5),
        ),
        child: Icon(icon, color: on ? color : AppColors.textMuted, size: 17),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Career Card
// ─────────────────────────────────────────────────────────────────────────────

class _FieldOpt {
  final String label;
  final IconData icon;
  final Color color;
  const _FieldOpt(this.label, this.icon, this.color);
}

class _CareerCard extends StatelessWidget {
  final String careerField;
  final double weeklySkillHours;
  final int certsPerYear;
  final ValueChanged<String> onFieldChanged;
  final ValueChanged<double> onSkillChanged;
  final ValueChanged<int> onCertsChanged;
  final AppLocalizations l10n;

  const _CareerCard(
      {required this.careerField,
      required this.weeklySkillHours,
      required this.certsPerYear,
      required this.onFieldChanged,
      required this.onSkillChanged,
      required this.onCertsChanged,
      required this.l10n});

  List<_FieldOpt> _fields(AppLocalizations l) => [
        _FieldOpt(l.techField, Icons.code_rounded, const Color(0xFF4DB8CC)),
        _FieldOpt(l.healthField, Icons.local_hospital_outlined,
            AppColors.accentGreen),
        _FieldOpt(l.financeField, Icons.candlestick_chart_outlined,
            AppColors.primaryLight),
        _FieldOpt(l.artsField, Icons.palette_outlined, const Color(0xFFE8607A)),
        _FieldOpt(l.eduField, Icons.school_outlined, AppColors.accentAmber),
        _FieldOpt(l.otherField, Icons.more_horiz_rounded, AppColors.textMuted),
      ];

  @override
  Widget build(BuildContext context) {
    final fields = _fields(l10n);
    return GlassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.careerSkills, style: AppTextStyles.headlineSmall),
        const SizedBox(height: AppConstants.spacingM),
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2.4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: fields.map((f) {
            final sel = f.label == careerField;
            return GestureDetector(
              onTap: () => onFieldChanged(f.label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: sel
                      ? f.color.withOpacity(0.15)
                      : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: sel
                          ? f.color.withOpacity(0.5)
                          : AppColors.border.withOpacity(0.4),
                      width: 0.75),
                ),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(f.icon,
                      color: sel ? f.color : AppColors.textMuted, size: 12),
                  const SizedBox(width: 4),
                  Flexible(
                      child: Text(f.label,
                          style: TextStyle(
                              fontSize: 10,
                              color: sel ? f.color : AppColors.textSecondary,
                              fontWeight:
                                  sel ? FontWeight.w700 : FontWeight.w400),
                          overflow: TextOverflow.ellipsis)),
                ]),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppConstants.spacingM),
        _SmartSlider(
          label: l10n.weeklySkillDev,
          value: weeklySkillHours,
          min: 0,
          max: 40,
          divisions: 40,
          onChanged: onSkillChanged,
          color: AppColors.accentCyan,
          valueText: (v) => '${v.toInt()}h/wk',
          contextText: (v) {
            if (v < 5) return 'Below avg';
            if (v < 15) return 'Average';
            if (v < 25) return 'Fast growth';
            return 'Top 5%';
          },
        ),
        const SizedBox(height: AppConstants.spacingS),
        _SmartSlider(
          label: l10n.certsPerYearLabel,
          value: certsPerYear.toDouble(),
          min: 0,
          max: 5,
          divisions: 5,
          onChanged: (v) => onCertsChanged(v.toInt()),
          color: AppColors.primaryLight,
          valueText: (v) => '${v.toInt()} cert${v != 1 ? 's' : ''}',
          contextText: (v) {
            if (v == 0) return 'None';
            if (v <= 2) return 'Steady';
            return 'Ambitious';
          },
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Social Card
// ─────────────────────────────────────────────────────────────────────────────

class _SocialCard extends StatelessWidget {
  final double socialMediaHours, familyHours, networkingHours;
  final ValueChanged<double> onSocialMediaChanged,
      onFamilyChanged,
      onNetworkingChanged;
  final AppLocalizations l10n;

  const _SocialCard(
      {required this.socialMediaHours,
      required this.familyHours,
      required this.networkingHours,
      required this.onSocialMediaChanged,
      required this.onFamilyChanged,
      required this.onNetworkingChanged,
      required this.l10n});

  @override
  Widget build(BuildContext context) {
    final total = (socialMediaHours * 7 + familyHours + networkingHours)
        .clamp(0.1, double.infinity);
    return GlassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(l10n.socialNetworking,
                  style: AppTextStyles.headlineSmall)),
          SizedBox(
              width: 48,
              height: 48,
              child: CustomPaint(
                  painter: _DonutPainter(
                values: [
                  (socialMediaHours * 7 / total).clamp(0.0, 1.0),
                  (familyHours / total).clamp(0.0, 1.0),
                  (networkingHours / total).clamp(0.0, 1.0)
                ],
                colors: [
                  AppColors.accentRed,
                  AppColors.accentAmber,
                  AppColors.primaryLight
                ],
              ))),
        ]),
        const SizedBox(height: AppConstants.spacingM),
        _SmartSlider(
          label: l10n.socialMedia,
          value: socialMediaHours,
          min: 0,
          max: 10,
          divisions: 20,
          onChanged: onSocialMediaChanged,
          color: AppColors.accentRed,
          valueText: (v) => '${v.toStringAsFixed(1)}h/day',
          contextText: (v) {
            if (v < 1) return 'Minimal';
            if (v < 3) return 'Moderate';
            if (v < 6) return 'High';
            return '⚠ Very high';
          },
          isWarning: socialMediaHours > 4,
        ),
        const SizedBox(height: AppConstants.spacingS),
        _SmartSlider(
          label: l10n.familyFriends,
          value: familyHours,
          min: 0,
          max: 40,
          divisions: 40,
          onChanged: onFamilyChanged,
          color: AppColors.accentAmber,
          valueText: (v) => '${v.toInt()}h/wk',
          contextText: (v) {
            if (v < 5) return 'Isolated';
            if (v < 15) return 'Balanced';
            return 'Very social';
          },
        ),
        const SizedBox(height: AppConstants.spacingS),
        _SmartSlider(
          label: l10n.networking,
          value: networkingHours,
          min: 0,
          max: 20,
          divisions: 20,
          onChanged: onNetworkingChanged,
          color: AppColors.primaryLight,
          valueText: (v) => '${v.toInt()}h/wk',
          contextText: (v) {
            if (v < 2) return 'Passive';
            if (v < 8) return 'Active';
            return 'Proactive';
          },
        ),
      ]),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  const _DonutPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 3;
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = AppColors.border.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5);
    double angle = -math.pi / 2;
    for (int i = 0; i < values.length; i++) {
      if (values[i] <= 0) continue;
      final sweep = 2 * math.pi * values[i];
      canvas.drawArc(
          Rect.fromCircle(center: c, radius: r),
          angle,
          sweep - 0.06,
          false,
          Paint()
            ..color = colors[i]
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5
            ..strokeCap = StrokeCap.round);
      angle += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter _) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// Smart Slider — with context chip
// ─────────────────────────────────────────────────────────────────────────────

class _SmartSlider extends StatelessWidget {
  final String label;
  final double value, min, max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final Color color;
  final String Function(double) valueText, contextText;
  final bool isWarning;

  const _SmartSlider(
      {required this.label,
      required this.value,
      required this.min,
      required this.max,
      required this.divisions,
      required this.onChanged,
      required this.color,
      required this.valueText,
      required this.contextText,
      this.isWarning = false});

  @override
  Widget build(BuildContext context) {
    final c = isWarning ? AppColors.accentRed : color;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: AppTextStyles.labelMedium),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
                color: c.withOpacity(0.08),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: c.withOpacity(0.2), width: 0.5)),
            child: Text(contextText(value),
                style: TextStyle(
                    fontSize: 9,
                    color: c.withOpacity(0.85),
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Text(valueText(value),
              style: AppTextStyles.labelMedium
                  .copyWith(color: c, fontWeight: FontWeight.w700)),
        ]),
      ]),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: c,
          inactiveTrackColor: AppColors.border.withOpacity(0.4),
          thumbColor: c,
          overlayColor: c.withOpacity(0.1),
          trackHeight: 2.5,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        ),
        child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom CTA
// ─────────────────────────────────────────────────────────────────────────────

class _BottomCTA extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onPressed;
  final AppLocalizations l10n;
  const _BottomCTA(
      {required this.isSubmitting,
      required this.onPressed,
      required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background.withOpacity(0),
              AppColors.background.withOpacity(0.92),
              AppColors.background
            ],
            stops: const [
              0.0,
              0.35,
              1.0
            ]),
      ),
      padding: EdgeInsets.fromLTRB(
          AppConstants.spacingM,
          AppConstants.spacingL,
          AppConstants.spacingM,
          MediaQuery.of(context).padding.bottom + AppConstants.spacingM),
      child: PrimaryButton(
          label: l10n.simulateMyFuture,
          icon: Icons.auto_awesome_rounded,
          isLoading: isSubmitting,
          onPressed: onPressed),
    );
  }
}
