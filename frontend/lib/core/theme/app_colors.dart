import 'package:flutter/material.dart';

class AppColors {
  // Primary - Deep Teal / Emerald
  static const Color primary = Color(0xFF0D7377);
  static const Color primaryLight = Color(0xFF14A3A8);
  static const Color primaryDark = Color(0xFF094F52);
  static const Color primaryContainer = Color(0xFFB2DFDB);

  // Secondary - Warm Amber
  static const Color secondary = Color(0xFFF2A922);
  static const Color secondaryLight = Color(0xFFFFCC02);
  static const Color secondaryDark = Color(0xFFC78700);

  // Neutral
  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F2F5);
  static const Color onSurface = Color(0xFF1A1C1E);
  static const Color onSurfaceVariant = Color(0xFF6B7280);
  static const Color outline = Color(0xFFE2E5E9);
  static const Color divider = Color(0xFFEEF0F3);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Dark theme
  static const Color darkBackground = Color(0xFF111318);
  static const Color darkSurface = Color(0xFF1A1C22);
  static const Color darkSurfaceVariant = Color(0xFF23262E);
  static const Color darkOnSurface = Color(0xFFE4E6EA);
  static const Color darkOutline = Color(0xFF2E3138);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF0D7377), Color(0xFF14A3A8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF2A922), Color(0xFFFFCC02)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
