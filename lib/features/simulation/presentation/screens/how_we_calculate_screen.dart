import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HowWeCalculateScreen
// ─────────────────────────────────────────────────────────────────────────────

class HowWeCalculateScreen extends StatelessWidget {
  const HowWeCalculateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Background glow blobs ─────────────────────────────────
          Positioned(
            top: -100,
            right: -60,
            child: _GlowBlob(
              color: AppColors.primary.withValues(alpha: 0.10),
              size: 300,
            ),
          ),
          Positioned(
            bottom: 80,
            left: -80,
            child: _GlowBlob(
              color: AppColors.accentCyan.withValues(alpha: 0.06),
              size: 260,
            ),
          ),

          // ── Main content ─────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── Custom AppBar ──────────────────────────────────
                _HwcAppBar(),

                // ── Scrollable body ───────────────────────────────
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: const [
                      _HeroHeader(),
                      SizedBox(height: 24),
                      _Section1Finance(),
                      SizedBox(height: 12),
                      _Section2Career(),
                      SizedBox(height: 12),
                      _Section3Risk(),
                      SizedBox(height: 12),
                      _Section4Score(),
                      SizedBox(height: 12),
                      _Section5Philosophy(),
                      SizedBox(height: 24),
                    ],
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
// _HwcAppBar
// ─────────────────────────────────────────────────────────────────────────────

class _HwcAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 0.75),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textMuted,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How We Calculate',
                  style: AppTextStyles.headlineMedium,
                ),
                Text(
                  'Model transparency & methodology',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
                width: 0.75,
              ),
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: AppColors.primaryLight,
              size: 20,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _HeroHeader
// ─────────────────────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary.withValues(alpha: 0.18),
          AppColors.accentCyan.withValues(alpha: 0.06),
        ],
      ),
      borderColor: AppColors.primary.withValues(alpha: 0.3),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transparent by Design',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Every metric in this app is derived from documented mathematical models. No black boxes.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      delayMs: 100,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 1 — Financial Projection
// ─────────────────────────────────────────────────────────────────────────────

class _Section1Finance extends StatelessWidget {
  const _Section1Finance();

  @override
  Widget build(BuildContext context) {
    return _ExpandableSection(
      icon: Icons.account_balance_wallet_rounded,
      iconColor: AppColors.primary,
      title: 'Financial Projection Model',
      subtitle: 'Compound growth · Inflation · Savings rate',
      delayMs: 150,
      children: [
        _BulletPoint(
          icon: Icons.functions_rounded,
          color: AppColors.primaryLight,
          title: 'Compound Growth Formula',
          body:
              'We apply compound interest to your current savings and projected income surplus over your selected time horizon.',
        ),
        const SizedBox(height: 12),
        _FormulaBox(
          formula: 'FV = PV × (1 + r)ⁿ',
          legend:
              'FV = Future Value   PV = Present Value\nr = Annual Growth Rate   n = Years',
        ),
        const SizedBox(height: 14),
        _BulletPoint(
          icon: Icons.show_chart_rounded,
          color: AppColors.accentCyan,
          title: 'Inflation Adjustment',
          body:
              'Real purchasing power is computed by discounting future values by a configurable annual inflation rate (default 3%).',
        ),
        const SizedBox(height: 12),
        _BulletPoint(
          icon: Icons.savings_rounded,
          color: AppColors.accentGreen,
          title: 'Savings Rate Impact',
          body:
              'Higher savings rates accelerate wealth accumulation exponentially. Each 5% increase in savings ratio can reduce your financial independence timeline by 2–4 years.',
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 2 — Career Growth
// ─────────────────────────────────────────────────────────────────────────────

class _Section2Career extends StatelessWidget {
  const _Section2Career();

  @override
  Widget build(BuildContext context) {
    return _ExpandableSection(
      icon: Icons.work_history_rounded,
      iconColor: const Color(0xFFF5A623),
      title: 'Career Growth Estimation',
      subtitle: 'Skill investment · Effort · Promotion probability',
      delayMs: 200,
      children: [
        _BulletPoint(
          icon: Icons.school_rounded,
          color: const Color(0xFFF5A623),
          title: 'Skill Investment Impact',
          body:
              'Each unit of time allocated to skill development increases your career score multiplier. Returns follow a logarithmic curve — early investment yields the highest gains.',
        ),
        const SizedBox(height: 12),
        _BulletPoint(
          icon: Icons.bolt_rounded,
          color: AppColors.primaryLight,
          title: 'Effort Multiplier',
          body:
              'Your work effort input (1–10) applies a linear multiplier to your base income growth rate, capped to avoid unrealistic projections.',
        ),
        const SizedBox(height: 12),
        _BulletPoint(
          icon: Icons.trending_up_rounded,
          color: AppColors.accentGreen,
          title: 'Promotion Probability',
          body:
              'Promotion likelihood scales with skill level and effort. The model uses a sigmoid function so no input guarantees 100% outcome.',
        ),
        const SizedBox(height: 12),
        _BulletPoint(
          icon: Icons.timeline_rounded,
          color: AppColors.accentCyan,
          title: 'Long-Term Growth Curve',
          body:
              'Career growth follows a 3-phase model: rapid growth (years 1–5), plateau (years 5–8), and seniority premium (years 8–10).',
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 3 — Risk Index
// ─────────────────────────────────────────────────────────────────────────────

class _Section3Risk extends StatelessWidget {
  const _Section3Risk();

  @override
  Widget build(BuildContext context) {
    return _ExpandableSection(
      icon: Icons.shield_outlined,
      iconColor: AppColors.accentRed,
      title: 'Risk Index Model',
      subtitle: 'Burnout · Financial collapse · Stagnation',
      delayMs: 250,
      children: [
        _BulletPoint(
          icon: Icons.local_fire_department_rounded,
          color: AppColors.accentRed,
          title: 'Burnout Risk',
          body:
              'Derived from work effort, health investment, and sleep/rest balance. High effort with low health inputs raises burnout probability significantly.',
        ),
        const SizedBox(height: 12),
        _BulletPoint(
          icon: Icons.money_off_rounded,
          color: const Color(0xFFF5A623),
          title: 'Financial Collapse Risk',
          body:
              'Triggered when projected expenses exceed income for 3+ consecutive periods. Emergency fund size modulates this risk down.',
        ),
        const SizedBox(height: 12),
        _BulletPoint(
          icon: Icons.battery_alert_rounded,
          color: AppColors.accentRed,
          title: 'Energy Depletion Factor',
          body:
              'A compound metric of physical health, sleep, and social interaction inputs. Low energy amplifies all other risk components.',
        ),
        const SizedBox(height: 12),
        _BulletPoint(
          icon: Icons.remove_circle_outline_rounded,
          color: const Color(0xFFF5A623),
          title: 'Career Stagnation Probability',
          body:
              'When skill growth flat-lines and no new learning is logged, stagnation score rises over time.',
        ),
        const SizedBox(height: 16),
        // Color-coded risk legend
        _RiskLegend(),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 4 — Life Stability Score
// ─────────────────────────────────────────────────────────────────────────────

class _Section4Score extends StatelessWidget {
  const _Section4Score();

  static const _weights = [
    _WeightData('Finance', 0.35, AppColors.primary),
    _WeightData('Career', 0.25, Color(0xFFF5A623)),
    _WeightData('Health', 0.20, AppColors.accentGreen),
    _WeightData('Energy', 0.10, AppColors.accentCyan),
    _WeightData('Risk', 0.10, AppColors.accentRed),
  ];

  @override
  Widget build(BuildContext context) {
    return _ExpandableSection(
      icon: Icons.star_rounded,
      iconColor: AppColors.accentAmber,
      title: 'Life Stability Score',
      subtitle: 'Weighted composite of all life modules',
      delayMs: 300,
      children: [
        Text(
          'The Life Stability Score is a weighted average across five domains. Each module is normalised to a 0–100 scale before combining.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        ..._weights.map((w) => _WeightRow(data: w)),
        const SizedBox(height: 16),
        _FormulaBox(
          formula: 'LSS = Σ (module_score × weight)',
          legend:
              'All module scores are normalised to 0–100\nbefore applying their respective weights.',
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 5 — Simulation Philosophy
// ─────────────────────────────────────────────────────────────────────────────

class _Section5Philosophy extends StatelessWidget {
  const _Section5Philosophy();

  @override
  Widget build(BuildContext context) {
    return _ExpandableSection(
      icon: Icons.lightbulb_rounded,
      iconColor: AppColors.accentCyan,
      title: 'Simulation Philosophy',
      subtitle: 'Assumptions, limitations & disclaimer',
      delayMs: 350,
      children: [
        _BulletPoint(
          icon: Icons.check_circle_outline_rounded,
          color: AppColors.accentGreen,
          title: 'What This System Does',
          body:
              'Models probabilistic life trajectories based on your inputs and documented behavioral & financial assumptions. It helps explore trade-offs, not predict outcomes.',
        ),
        const SizedBox(height: 12),
        _BulletPoint(
          icon: Icons.cancel_outlined,
          color: AppColors.accentRed,
          title: 'What This System Does NOT Do',
          body:
              'It does not account for black swan events, geopolitical disruption, health emergencies, or any factor outside the modelled domains.',
        ),
        const SizedBox(height: 16),
        // Disclaimer box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accentAmber.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.accentAmber.withValues(alpha: 0.25),
              width: 0.75,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.accentAmber,
                size: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'This system does not predict the future.\n\nIt models probabilistic projections based on current user inputs and behavioral assumptions. All outputs are illustrative and should not replace professional financial advice.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.accentAmber.withValues(alpha: 0.9),
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable: _ExpandableSection
// ─────────────────────────────────────────────────────────────────────────────

class _ExpandableSection extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final List<Widget> children;
  final int delayMs;

  const _ExpandableSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.children,
    this.delayMs = 0,
  });

  @override
  State<_ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<_ExpandableSection>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _rotateAnim;
  late final Animation<double> _heightAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _rotateAnim = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _heightAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      delayMs: widget.delayMs,
      child: Column(
        children: [
          // ── Header (always visible) ──────────────────────────
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: widget.iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.iconColor.withValues(alpha: 0.2),
                      width: 0.75,
                    ),
                  ),
                  child: Icon(widget.icon, color: widget.iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                RotationTransition(
                  turns: _rotateAnim,
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textMuted,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),

          // ── Expandable body ───────────────────────────────────
          SizeTransition(
            sizeFactor: _heightAnim,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Divider(
                  height: 1,
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                ...widget.children,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable: _SectionCard
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  final LinearGradient? gradient;
  final Color? borderColor;
  final int delayMs;

  const _SectionCard({
    required this.child,
    this.gradient,
    this.borderColor,
    this.delayMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: gradient ??
            const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1630), Color(0xFF110D22)],
            ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor ?? const Color(0xFF2A2445),
          width: 0.75,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    )
        .animate(delay: Duration(milliseconds: delayMs))
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.08, end: 0, duration: 500.ms, curve: Curves.easeOut);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable: _BulletPoint
// ─────────────────────────────────────────────────────────────────────────────

class _BulletPoint extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;

  const _BulletPoint({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: color, size: 15),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                body,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable: _FormulaBox
// ─────────────────────────────────────────────────────────────────────────────

class _FormulaBox extends StatelessWidget {
  final String formula;
  final String legend;

  const _FormulaBox({required this.formula, required this.legend});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 0.75,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Formula line
          ShaderMask(
            shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
            child: Text(
              formula,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Courier',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.4)),
          const SizedBox(height: 10),
          Text(
            legend,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
              height: 1.6,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _RiskLegend — color-coded risk scale
// ─────────────────────────────────────────────────────────────────────────────

class _RiskLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.75),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RISK SCALE',
            style: AppTextStyles.overline.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 2,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 10),
          _RiskLegendRow(
            color: AppColors.accentGreen,
            label: 'Stable',
            range: '0 – 30',
            description: 'Well-balanced inputs, low depletion risk.',
          ),
          const SizedBox(height: 8),
          _RiskLegendRow(
            color: AppColors.accentAmber,
            label: 'Moderate Risk',
            range: '31 – 65',
            description: 'Some imbalances. Monitor closely.',
          ),
          const SizedBox(height: 8),
          _RiskLegendRow(
            color: AppColors.accentRed,
            label: 'High Risk',
            range: '66 – 100',
            description: 'Critical imbalances. Intervention recommended.',
          ),
        ],
      ),
    );
  }
}

class _RiskLegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String range;
  final String description;

  const _RiskLegendRow({
    required this.color,
    required this.label,
    required this.range,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label ',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                TextSpan(
                  text: '($range)  ',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
                TextSpan(
                  text: description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _WeightData & _WeightRow — Life Stability Score breakdown
// ─────────────────────────────────────────────────────────────────────────────

class _WeightData {
  final String label;
  final double weight;
  final Color color;

  const _WeightData(this.label, this.weight, this.color);
}

class _WeightRow extends StatelessWidget {
  final _WeightData data;

  const _WeightRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(right: 10, top: 1),
            decoration: BoxDecoration(
              color: data.color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(
            width: 68,
            child: Text(
              data.label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '${(data.weight * 100).toInt()}%',
              style: AppTextStyles.bodySmall.copyWith(
                color: data.color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: _WeightBar(value: data.weight, color: data.color),
          ),
        ],
      ),
    );
  }
}

class _WeightBar extends StatelessWidget {
  final double value;
  final Color color;

  const _WeightBar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) {
        return Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.border.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(6),
          ),
          clipBehavior: Clip.hardEdge,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: v,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.7), color],
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _GlowBlob — background decoration
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
