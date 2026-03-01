import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GlassCard — redesigned with frosted blur, refined borders, and layered depth
// ─────────────────────────────────────────────────────────────────────────────

class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final LinearGradient? gradient;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool enableHover;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.radius = AppConstants.radiusXL,
    this.gradient,
    this.borderColor,
    this.onTap,
    this.enableHover = false,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.982).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget card = AnimatedBuilder(
      animation: _scaleAnim,
      builder: (_, child) => Transform.scale(
        scale: _scaleAnim.value,
        child: child,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: widget.gradient ??
              const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1630), Color(0xFF110D22)],
                stops: [0.0, 1.0],
              ),
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(
            color: widget.borderColor ?? const Color(0xFF2A2445),
            width: 0.75,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: AppColors.primary.withOpacity(0.04),
              blurRadius: 40,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius),
          child: Stack(
            children: [
              // Subtle inner highlight at top edge
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 0.75,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(0.07),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: widget.padding ??
                    const EdgeInsets.all(AppConstants.spacingM),
                child: widget.child,
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.onTap != null) {
      card = GestureDetector(
        onTapDown: (_) => _pressController.forward(),
        onTapUp: (_) {
          _pressController.reverse();
          widget.onTap?.call();
        },
        onTapCancel: () => _pressController.reverse(),
        child: card,
      );
    }

    return card;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MetricCard — elevated with animated reveal, gradient orb, and score ring
// ─────────────────────────────────────────────────────────────────────────────

class MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String sublabel;
  final String value;
  final double progressValue;
  final Color progressColor;
  final int delayMs;

  const MetricCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.sublabel,
    required this.value,
    required this.progressValue,
    required this.progressColor,
    this.delayMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _IconBadge(icon: icon, color: iconColor),
              const SizedBox(width: AppConstants.spacingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: AppTextStyles.overline.copyWith(
                        letterSpacing: 1.8,
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Arc score ring replaces large ghost icon
              _ScoreRing(
                value: progressValue,
                color: progressColor,
                size: 36,
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacingM),

          // Value
          Text(
            value,
            style: AppTextStyles.headlineLarge.copyWith(
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            sublabel,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),

          const SizedBox(height: AppConstants.spacingM),

          // Progress bar
          _AnimatedProgressBar(
            value: progressValue,
            color: progressColor,
          ),

          const SizedBox(height: 8),

          // Percentage label below bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0%',
                style: AppTextStyles.overline.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 9,
                ),
              ),
              Text(
                '${(progressValue * 100).toInt()}%',
                style: AppTextStyles.overline.copyWith(
                  color: progressColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '100%',
                style: AppTextStyles.overline.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: delayMs))
        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
        .slideY(begin: 0.12, end: 0, duration: 600.ms, curve: Curves.easeOut);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _IconBadge — redesigned with glow shadow and softer radius
// ─────────────────────────────────────────────────────────────────────────────

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _IconBadge({
    required this.icon,
    required this.color,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 0.75,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: size * 0.46),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ScoreRing — circular arc progress indicator (replaces ghost icon)
// ─────────────────────────────────────────────────────────────────────────────

class _ScoreRing extends StatefulWidget {
  final double value;
  final Color color;
  final double size;

  const _ScoreRing({
    required this.value,
    required this.color,
    required this.size,
  });

  @override
  State<_ScoreRing> createState() => _ScoreRingState();
}

class _ScoreRingState extends State<_ScoreRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _anim = Tween(begin: 0.0, end: widget.value.clamp(0.0, 1.0)).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_ScoreRing old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _anim = Tween(
        begin: _anim.value,
        end: widget.value.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _RingPainter(
          value: _anim.value,
          color: widget.color,
          trackColor: widget.color.withOpacity(0.1),
        ),
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Center(
            child: Text(
              '${(_anim.value * 100).toInt()}',
              style: TextStyle(
                fontSize: 9,
                color: widget.color,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color color;
  final Color trackColor;

  const _RingPainter({
    required this.value,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    const startAngle = -math.pi / 2;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Arc
    if (value > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        2 * math.pi * value,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// _AnimatedProgressBar — segmented with glow and gradient fill
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedProgressBar extends StatefulWidget {
  final double value;
  final Color color;
  final double height;

  const _AnimatedProgressBar({
    required this.value,
    required this.color,
    this.height = 4,
  });

  @override
  State<_AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<_AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.animationSlow,
    );
    _animation = Tween<double>(begin: 0, end: widget.value.clamp(0, 1))
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedProgressBar old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.value.clamp(0, 1),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.border.withOpacity(0.5),
            borderRadius: BorderRadius.circular(widget.height),
          ),
          clipBehavior: Clip.hardEdge,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _animation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.color.withOpacity(0.7),
                    widget.color,
                  ],
                ),
                borderRadius: BorderRadius.circular(widget.height),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 0,
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
// AnimatedCounter — shimmer pulse on value change
// ─────────────────────────────────────────────────────────────────────────────

class AnimatedCounter extends StatefulWidget {
  final double value;
  final String Function(double) formatter;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    required this.formatter,
    this.style,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerCtrl;
  double _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void didUpdateWidget(AnimatedCounter old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _previousValue = old.value;
      _shimmerCtrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: _previousValue, end: widget.value),
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      builder: (_, val, __) {
        return AnimatedBuilder(
          animation: _shimmerCtrl,
          builder: (_, child) {
            // subtle brightness pulse on change
            final brightness = 1.0 +
                (_shimmerCtrl.value * (1 - _shimmerCtrl.value) * 4 * 0.08);
            return ColorFiltered(
              colorFilter: ColorFilter.matrix([
                brightness,
                0,
                0,
                0,
                0,
                0,
                brightness,
                0,
                0,
                0,
                0,
                0,
                brightness,
                0,
                0,
                0,
                0,
                0,
                1,
                0,
              ]),
              child: child,
            );
          },
          child: Text(
            widget.formatter(val),
            style: widget.style ?? AppTextStyles.moneyLarge,
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GainBadge — redesigned with icon and directional arrow
// ─────────────────────────────────────────────────────────────────────────────

class GainBadge extends StatelessWidget {
  final String text;
  final bool isPositive;

  const GainBadge({super.key, required this.text, this.isPositive = true});

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? AppColors.accentGreen : AppColors.accentRed;
    final icon =
        isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        border: Border.all(color: color.withOpacity(0.25), width: 0.75),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PrimaryButton — redesigned with shimmer sweep, haptic-ready, and glow pulse
// ─────────────────────────────────────────────────────────────────────────────

class PrimaryButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final LinearGradient? gradient;

  const PrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.gradient,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerCtrl;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        if (!widget.isLoading) widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: AnimatedContainer(
          duration: AppConstants.animationFast,
          height: 58,
          decoration: BoxDecoration(
            gradient: isDisabled
                ? const LinearGradient(
                    colors: [Color(0xFF2D2550), Color(0xFF1E1A38)],
                  )
                : (widget.gradient ?? AppColors.primaryGradient),
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            boxShadow: isDisabled
                ? []
                : [
                    BoxShadow(
                      color:
                          AppColors.primary.withOpacity(_pressed ? 0.2 : 0.45),
                      blurRadius: _pressed ? 12 : 24,
                      offset: const Offset(0, 6),
                      spreadRadius: _pressed ? 0 : 2,
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            child: Stack(
              children: [
                // Shimmer sweep on idle state
                if (!isDisabled)
                  AnimatedBuilder(
                    animation: _shimmerCtrl,
                    builder: (_, __) {
                      return Positioned.fill(
                        child: Transform.translate(
                          offset: Offset(
                            (_shimmerCtrl.value * 2 - 0.5) * 400,
                            0,
                          ),
                          child: Container(
                            width: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0),
                                  Colors.white.withOpacity(0.08),
                                  Colors.white.withOpacity(0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                // Button content
                Center(
                  child: widget.isLoading
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Simulating…',
                              style: AppTextStyles.labelLarge.copyWith(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(widget.icon, color: Colors.white, size: 19),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              widget.label,
                              style: AppTextStyles.labelLarge.copyWith(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SectionHeader — redesigned with accent line and optional badge
// ─────────────────────────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;
  final String? badge;
  final Color? accentColor;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.badge,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primaryLight;

    return Row(
      children: [
        // Vertical accent bar
        Container(
          width: 3,
          height: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color, color.withOpacity(0.3)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(title, style: AppTextStyles.headlineSmall),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: color.withOpacity(0.25), width: 0.5),
            ),
            child: Text(
              badge!,
              style: AppTextStyles.overline.copyWith(
                color: color,
                fontSize: 9,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
        const Spacer(),
        if (action != null) action!,
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SkeletonLoader — shimmer placeholder for async content
// ─────────────────────────────────────────────────────────────────────────────

class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.5 + _ctrl.value * 3.5, 0),
              end: Alignment(-0.5 + _ctrl.value * 3.5, 0),
              colors: const [
                Color(0xFF1A1630),
                Color(0xFF2A2250),
                Color(0xFF1A1630),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// StatusChip — versatile inline status indicator
// ─────────────────────────────────────────────────────────────────────────────

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool showDot;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.25), width: 0.75),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot && icon == null) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[
            Icon(icon, color: color, size: 11),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DividerLine — consistent styled divider
// ─────────────────────────────────────────────────────────────────────────────

class DividerLine extends StatelessWidget {
  final double opacity;
  const DividerLine({super.key, this.opacity = 1.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      margin: const EdgeInsets.symmetric(vertical: AppConstants.spacingS),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.border.withOpacity(opacity),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DataRow — key/value pair used in summary cards
// ─────────────────────────────────────────────────────────────────────────────

class DataRowItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;

  const DataRowItem({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.textMuted, size: 14),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.labelMedium.copyWith(
              color: valueColor ?? AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
