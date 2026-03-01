import 'package:flutter/material.dart';

/// Central color palette for the Life Simulator app.
/// Inspired by a deep dark purple aesthetic with vibrant accent tones.
abstract class AppColors {
  // ── Backgrounds ──────────────────────────────────────────────
  static const Color background = Color(0xFF0D0A1E);
  static const Color surface = Color(0xFF161229);
  static const Color surfaceElevated = Color(0xFF1E1836);
  static const Color cardBackground = Color(0xFF1A1530);

  // ── Brand / Accent ────────────────────────────────────────────
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFF9F67F5);
  static const Color primaryDark = Color(0xFF5B21B6);
  static const Color primaryGlow = Color(0x407C3AED);

  // ── Secondary Accents ─────────────────────────────────────────
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentRed = Color(0xFFEF4444);

  // ── Text ──────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0A8CC);
  static const Color textMuted = Color(0xFF6B6080);
  static const Color textAccent = Color(0xFF9F67F5);

  // ── Borders & Dividers ────────────────────────────────────────
  static const Color border = Color(0xFF2A2244);
  static const Color borderGlow = Color(0x557C3AED);

  // ── Chart Lines ───────────────────────────────────────────────
  static const Color chartPrimary = Color(0xFF7C3AED);
  static const Color chartSecondary = Color(0xFF06B6D4);
  static const Color chartFill = Color(0x337C3AED);

  // ── Gradients ─────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D0A1E), Color(0xFF0A0818)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1836), Color(0xFF161229)],
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
  );
}
