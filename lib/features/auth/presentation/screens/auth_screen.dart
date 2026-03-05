import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/localization/auth_provider.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../simulation/presentation/widgets/shared_widgets.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  late final AnimationController _modeAnim;

  @override
  void initState() {
    super.initState();
    _modeAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _modeAnim.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset();
    });
    if (_isLogin) {
      _modeAnim.reverse();
    } else {
      _modeAnim.forward();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (_isLogin) {
      await ref.read(authProvider.notifier).login(email, password);
    } else {
      final name = _nameController.text.trim();
      await ref.read(authProvider.notifier).register(name, email, password);
    }

    if (mounted && ref.read(authProvider).isAuthenticated) {
      context.go(AppRoutes.input);
    }
  }

  Future<void> _googleSignIn() async {
    await ref.read(authProvider.notifier).googleLogin();
    if (mounted && ref.read(authProvider).isAuthenticated) {
      context.go(AppRoutes.input);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);

    // Show error snackbar if present
    ref.listen<AuthState>(authProvider, (_, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.accentRed,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Background orbs ────────────────────────────────────
          Positioned(
            top: -100,
            right: -50,
            child: _GlowOrb(
                color: AppColors.primary.withValues(alpha: 0.15), size: 300),
          ),
          Positioned(
            bottom: -80,
            left: -40,
            child: _GlowOrb(
                color: AppColors.accentCyan.withValues(alpha: 0.1), size: 250),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),

                    // ── Logo ───────────────────────────────────────
                    const _AuthLogo().animate().fadeIn(duration: 800.ms).scale(
                        begin: const Offset(0.8, 0.8),
                        curve: Curves.easeOutBack),

                    const SizedBox(height: 28),

                    // ── Title ─────────────────────────────────────
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _isLogin ? l10n.loginTitle : l10n.signupTitle,
                        key: ValueKey(_isLogin ? 'login' : 'signup'),
                        style:
                            AppTextStyles.headlineLarge.copyWith(height: 1.1),
                        textAlign: TextAlign.center,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                    const SizedBox(height: 8),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _isLogin ? l10n.loginSubtitle : l10n.signupSubtitle,
                        key: ValueKey(_isLogin ? 'lsub' : 'rsub'),
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textMuted),
                        textAlign: TextAlign.center,
                      ),
                    ).animate().fadeIn(delay: 350.ms),

                    const SizedBox(height: 32),

                    // ── Form Card ──────────────────────────────────
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Full Name — signup only
                            AnimatedSize(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOut,
                              child: _isLogin
                                  ? const SizedBox.shrink()
                                  : Column(
                                      children: [
                                        _AuthField(
                                          controller: _nameController,
                                          label: l10n.fullNameLabel,
                                          hint: l10n.fullNameHint,
                                          icon: Icons.badge_outlined,
                                          validator: (v) {
                                            if (v == null || v.trim().isEmpty) {
                                              return l10n.authErrorEmpty;
                                            }
                                            if (v.trim().length < 2) {
                                              return l10n.authErrorShortName;
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 18),
                                      ],
                                    ),
                            ),

                            // Email
                            _AuthField(
                              controller: _emailController,
                              label: l10n.emailLabel,
                              hint: l10n.emailHint,
                              icon: Icons.alternate_email_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return l10n.authErrorEmpty;
                                }
                                if (!v.contains('@') || !v.contains('.')) {
                                  return l10n.authErrorInvalidEmail;
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 18),

                            // Password
                            _AuthField(
                              controller: _passwordController,
                              label: l10n.passwordLabel,
                              hint: l10n.passwordHint,
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textMuted,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return l10n.authErrorEmpty;
                                }
                                if (v.length < 6) {
                                  return l10n.authErrorShortPassword;
                                }
                                return null;
                              },
                            ),

                            // Confirm Password — signup only
                            AnimatedSize(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOut,
                              child: _isLogin
                                  ? const SizedBox.shrink()
                                  : Column(
                                      children: [
                                        const SizedBox(height: 18),
                                        _AuthField(
                                          controller: _confirmController,
                                          label: l10n.confirmPasswordLabel,
                                          hint: l10n.passwordHint,
                                          icon: Icons.lock_reset_rounded,
                                          obscureText: _obscureConfirm,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscureConfirm
                                                  ? Icons
                                                      .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              color: AppColors.textMuted,
                                              size: 20,
                                            ),
                                            onPressed: () => setState(() =>
                                                _obscureConfirm =
                                                    !_obscureConfirm),
                                          ),
                                          validator: (v) {
                                            if (v == null || v.isEmpty) {
                                              return l10n.authErrorEmpty;
                                            }
                                            if (v != _passwordController.text) {
                                              return l10n
                                                  .authErrorPasswordMismatch;
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                            ),

                            // Forgot password — login only
                            if (_isLogin) ...[
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    l10n.forgotPassword,
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.primaryLight,
                                    ),
                                  ),
                                ),
                              ),
                            ] else
                              const SizedBox(height: 24),

                            const SizedBox(height: 4),

                            PrimaryButton(
                              label: _isLogin
                                  ? l10n.loginButton
                                  : l10n.signupButton,
                              onPressed: _submit,
                              isLoading: authState.isLoading,
                            ),

                            // ── OR Divider ─────────────────────────────
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color:
                                        AppColors.border.withValues(alpha: 0.5),
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Text(
                                    'OR',
                                    style: AppTextStyles.overline.copyWith(
                                      color: AppColors.textMuted,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color:
                                        AppColors.border.withValues(alpha: 0.5),
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // ── Google Button ──────────────────────────
                            _GoogleSignInButton(
                              onPressed:
                                  authState.isLoading ? null : _googleSignIn,
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 500.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 28),

                    // ── Mode Toggle ────────────────────────────────
                    TextButton(
                      onPressed: _toggleMode,
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: _isLogin
                                  ? l10n.dontHaveAccountPrefix
                                  : l10n.alreadyHaveAccountPrefix,
                            ),
                            TextSpan(
                              text:
                                  _isLogin ? l10n.signUpLink : l10n.signInLink,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 700.ms),

                    const SizedBox(height: 16),
                  ],
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
// _AuthField
// ─────────────────────────────────────────────────────────────────────────────

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const _AuthField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.overline.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: AppColors.textMuted.withValues(alpha: 0.6)),
            prefixIcon: Icon(icon,
                color: AppColors.primary.withValues(alpha: 0.6), size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.03),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: AppColors.border.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.accentRed, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.accentRed, width: 1.5),
            ),
            errorStyle:
                const TextStyle(color: AppColors.accentRed, fontSize: 11),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AuthLogo
// ─────────────────────────────────────────────────────────────────────────────

class _AuthLogo extends StatelessWidget {
  const _AuthLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child:
          const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 40),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _GlowOrb
// ─────────────────────────────────────────────────────────────────────────────

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color, blurRadius: 100, spreadRadius: 20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _GoogleSignInButton
// ─────────────────────────────────────────────────────────────────────────────

class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const _GoogleSignInButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF3C4043),
          side: const BorderSide(color: Color(0xFFDADCE0), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google logo — painted with four official colors
            SizedBox(
              width: 20,
              height: 20,
              child: CustomPaint(painter: _GoogleLogoPainter()),
            ),
            const SizedBox(width: 12),
            const Text(
              'Continue with Google',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3C4043),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints the Google 'G' logo using the four official brand colours.
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Clipping circle
    canvas.clipPath(
        Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r)));

    // White background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.white);

    // Blue arc (top-right)
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), -1.05,
        1.55, true, Paint()..color = const Color(0xFF4285F4));

    // Red arc (top-left)
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), -2.70,
        1.65, true, Paint()..color = const Color(0xFFEA4335));

    // Yellow arc (bottom-left)
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), 2.00,
        1.22, true, Paint()..color = const Color(0xFFFBBC05));

    // Green arc (bottom-right)
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), -0.52,
        1.57, true, Paint()..color = const Color(0xFF34A853));

    // Inner white circle (cutout)
    canvas.drawCircle(Offset(cx, cy), r * 0.60, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
