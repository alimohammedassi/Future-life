import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/auth_storage.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final authenticated = await AuthStorage.isAuthenticated();
    if (!mounted) return;

    if (authenticated) {
      context.go(AppRoutes.input);
    } else {
      context.go(AppRoutes.splash);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Return empty black screen while immediately navigating
    return const Scaffold(
      backgroundColor: AppColors.background,
    );
  }
}
