import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/app_localizations.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Force portrait orientation for optimal mobile experience.
  SystemChrome.setPreferredOrientations(const [
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
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const LifeSimulatorApp(),
    ),
  );
}

/// Root application widget.
class LifeSimulatorApp extends ConsumerWidget {
  const LifeSimulatorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      // ── App Identity ────────────────────────────────────────
      title: 'Life Simulator',
      debugShowCheckedModeBanner: false,

      // ── Localization ────────────────────────────────────────
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ── Theme ──────────────────────────────────────────────
      theme: locale.languageCode == 'ar' ? AppTheme.darkAr : AppTheme.dark,

      // ── Navigation ─────────────────────────────────────────
      routerConfig: appRouter,
    );
  }
}
