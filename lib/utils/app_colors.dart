import 'package:flutter/material.dart';

/// Central color palette for the Attendance Predictor app.
/// Clean, minimal, premium — blue-indigo brand with semantic status colors.
class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF3157D5);
  static const Color primaryDark = Color(0xFF1D3FBF);
  static const Color primaryLight = Color(0xFFEEF2FF);

  static const Color secondary = Color(0xFF0E8A83);
  static const Color accent = Color(0xFF7664E8);

  // ── Status ─────────────────────────────────────────────────────────────
  static const Color safe = Color(0xFF10B981);
  static const Color safeBackground = Color(0xFFECFDF5);
  static const Color safeBorder = Color(0xFFA7F3D0);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBackground = Color(0xFFFFFBEB);
  static const Color warningBorder = Color(0xFFFDE68A);

  static const Color danger = Color(0xFFEF4444);
  static const Color dangerBackground = Color(0xFFFEF2F2);
  static const Color dangerBorder = Color(0xFFFECACA);

  // ── Surfaces ───────────────────────────────────────────────────────────
  static const Color scaffoldBackground = Color(0xFFF6F8FC);
  static const Color cardSurface = Colors.white;

  // ── Text ───────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  // ── Borders & dividers ─────────────────────────────────────────────────
  static const Color border = Color(0xFFE5E9F2);
  static const Color divider = Color(0xFFF1F5F9);
}
