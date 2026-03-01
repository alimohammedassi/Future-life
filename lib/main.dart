import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation for optimal mobile experience.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar to blend with the dark background.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0D0A1E),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(
    // ProviderScope is the Riverpod root — must wrap the entire widget tree.
    const ProviderScope(
      child: LifeSimulatorApp(),
    ),
  );
}

/// Root application widget.
class LifeSimulatorApp extends StatelessWidget {
  const LifeSimulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // ── App Identity ────────────────────────────────────────
      title: 'Life Simulator',
      debugShowCheckedModeBanner: false,

      // ── Theme ──────────────────────────────────────────────
      theme: AppTheme.dark,

      // ── Navigation ─────────────────────────────────────────
      routerConfig: appRouter,
    );
  }
}
