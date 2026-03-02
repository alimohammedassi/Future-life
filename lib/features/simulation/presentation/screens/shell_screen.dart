import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/navigation/app_router.dart';

/// Shell screen that wraps all main routes with the GNav bottom navigation bar.
class ShellScreen extends ConsumerWidget {
  final Widget child;

  const ShellScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: const _GNavBar(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _GNavBar — google_nav_bar implementation with 4 tabs
// ─────────────────────────────────────────────────────────────────────────────

class _GNavBar extends StatelessWidget {
  const _GNavBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 0.75),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x50000000),
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: GNav(
            // ── Colours ─────────────────────────────────────────
            backgroundColor: AppColors.surface,
            color: AppColors.textMuted,
            activeColor: Colors.white,
            tabBackgroundColor: AppColors.primary.withValues(alpha: 0.18),
            // ── Pill shape ──────────────────────────────────────
            gap: 8,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            tabBorderRadius: 14,
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 350),
            // ── Icon + text sizing ───────────────────────────────
            iconSize: 22,
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            // ── Active tab ────────────────────────────────────────
            selectedIndex: currentIndex,
            onTabChange: (index) => _onTap(context, index),
            // ── Tabs ─────────────────────────────────────────────
            tabs: [
              GButton(
                icon: Icons.auto_graph_rounded,
                text: l10n.navSimulation,
                iconActiveColor: AppColors.primaryLight,
                textColor: Colors.white,
              ),
              GButton(
                icon: Icons.leaderboard_rounded,
                text: l10n.navInsights,
                iconActiveColor: AppColors.accentCyan,
                textColor: Colors.white,
              ),
              GButton(
                icon: Icons.compare_arrows_rounded,
                text: l10n.navCompare,
                iconActiveColor: AppColors.accentGreen,
                textColor: Colors.white,
              ),
              GButton(
                icon: Icons.timeline_rounded,
                text: l10n.navFuture,
                iconActiveColor: AppColors.accentAmber,
                textColor: Colors.white,
              ),
              GButton(
                icon: Icons.person_rounded,
                text: l10n.navProfile,
                iconActiveColor: AppColors.primaryLight,
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _indexFromLocation(String location) {
    if (location.startsWith(AppRoutes.results)) return 1;
    if (location.startsWith(AppRoutes.comparison)) return 2;
    if (location.startsWith(AppRoutes.future)) return 3;
    if (location.startsWith(AppRoutes.profile)) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.input);
        break;
      case 1:
        context.go(AppRoutes.results);
        break;
      case 2:
        context.go(AppRoutes.comparison);
        break;
      case 3:
        context.go(AppRoutes.future);
        break;
      case 4:
        context.go(AppRoutes.profile);
        break;
    }
  }
}
