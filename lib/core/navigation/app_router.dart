import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/simulation/presentation/screens/splash_screen.dart';
import '../../features/simulation/presentation/screens/input_screen.dart';
import '../../features/simulation/presentation/screens/results_screen.dart';
import '../../features/simulation/presentation/screens/comparison_screen.dart';
import '../../features/simulation/presentation/screens/shell_screen.dart';

/// All named route paths for the Life Simulator app.
abstract class AppRoutes {
  static const String splash = '/';
  static const String input = '/simulation';
  static const String results = '/results';
  static const String comparison = '/compare';
}

/// The application [GoRouter] instance.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: false,
  routes: [
    // ── Splash / Landing ────────────────────────────────────────
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      pageBuilder: (context, state) => _buildPage(
        state: state,
        child: const SplashScreen(),
      ),
    ),

    // ── Main Shell (with bottom nav) ────────────────────────────
    ShellRoute(
      builder: (context, state, child) => ShellScreen(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.input,
          name: 'simulation',
          pageBuilder: (context, state) => _buildPage(
            state: state,
            child: const InputScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.results,
          name: 'results',
          pageBuilder: (context, state) => _buildPage(
            state: state,
            child: const ResultsScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.comparison,
          name: 'comparison',
          pageBuilder: (context, state) => _buildPage(
            state: state,
            child: const ComparisonScreen(),
          ),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    backgroundColor: const Color(0xFF0D0A1E),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 64),
          const SizedBox(height: 16),
          Text(
            'Page not found',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.splash),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);

/// Creates a custom page transition with a fade + slide effect.
CustomTransitionPage<void> _buildPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        ),
      );
    },
  );
}
