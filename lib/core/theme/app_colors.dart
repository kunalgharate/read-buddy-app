import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary / Accent
  static const Color primary = Color(0xFF2CE07F);
  static const Color accent = primary;
  static const Color secondary = Color(0xFF1AAF5C);

  // Light Mode Backgrounds
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);

  // Dark Mode Backgrounds
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF2C2C2C);

  // Text - Light Mode
  static const Color textDark = Color(0xFF052E44);
  static const Color textPrimary = Color(0xFF1E2939);
  static const Color textSecondary = Color(0xFF5B6675);
  static const Color textHint = Color(0xFF8895A7);
  static const Color textSubtitle = Color(0xFF666666);
  static const Color textMuted = Color(0xFF999999);

  // Text - Dark Mode
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textMutedDark = Color(0xFFA0A0A0);

  // Brand / Deep navy
  static const Color navy = Color(0xFF042153);
  static const Color navyLight = Color(0xFF1A237E);

  // Border - Light Mode
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFEAEAEA);
  static const Color divider = Color(0xFFEEEEEE);

  // Border - Dark Mode
  static const Color borderDark = Color(0xFF3A3A3A);
  static const Color dividerDark = Color(0xFF333333);

  // Status
  static const Color error = Color(0xFFE53E3E);
  static const Color success = Color(0xFF4CAF50);

  // Format action colors
  static const Color formatRead = Color(0xFF0D9488);
  static const Color formatRequest = Color(0xFF4F46E5);
  static const Color formatListen = Color(0xFFD97706);
  static const Color formatWatch = Color(0xFF7C3AED);

  // Helper method to get theme-aware colors
  static Color scaffoldBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundDark
        : background;
  }

  static Color surfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? surfaceDark
        : surface;
  }

  static Color cardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? cardDark : surface;
  }

  static Color textPrimaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textPrimaryDark
        : textPrimary;
  }

  static Color textSecondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textSecondaryDark
        : textSecondary;
  }

  static Color textMutedColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textMutedDark
        : textMuted;
  }

  static Color borderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? borderDark
        : border;
  }

  static Color dividerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dividerDark
        : divider;
  }
}
