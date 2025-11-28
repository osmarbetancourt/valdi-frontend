import 'package:flutter/material.dart';

/// App theme and color tokens for Mercedes Analytics Mobile.
///
/// Rationale / design notes (short):
/// - Primary accent: a deep teal-blue provides a modern, professional accent while
///   still remaining calm and readable on light backgrounds.
/// - Neutral greys: a range of muted greys is used for surfaces, dividers and text
///   to preserve a data-dense look without overwhelming contrast.
/// - Success/Warning/Error: small set of feedback colors used for state and badges.
///
/// These tokens are intentionally compact and safe for mobile screens — prefer
/// small elevation and rounded corners for cards to match the desktop dashboard style.

class AppColors {
  // accent
  static const Color primary = Color(0xFF006D77); // deep teal-blue (accent)
  static const Color onPrimary = Colors.white;

  // greys
  static const Color background = Color(0xFFFFFFFF); // true white background (matches desktop)
  static const Color surface = Colors.white; // card background
  static const Color divider = Color(0xFFE6E9EE);
  static const Color textPrimary = Color(0xFF111827); // near-black for primary text
  static const Color textSecondary = Color(0xFF6B7280); // muted

  // feedback
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
}

class DarkAppColors {
  static const Color primary = Color(0xFF2DD4BF); // lighter cyan accent for dark theme
  static const Color background = Color(0xFF0B1116); // near-black charcoal
  static const Color surface = Color(0xFF0E1720); // slightly lighter card
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color divider = Color(0x1FFFFFFF);
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.light),
  scaffoldBackgroundColor: AppColors.background,
  primaryColor: AppColors.primary,
  appBarTheme: const AppBarTheme(
    elevation: 1,
    backgroundColor: Colors.white,
    foregroundColor: AppColors.textPrimary,
    iconTheme: IconThemeData(color: AppColors.textPrimary),
    titleTextStyle: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
  ),
  // CardTheme was removed for compatibility with older SDK versions —
  // Decorations can be applied via Card widgets directly.
  dividerColor: AppColors.divider,
  textTheme: const TextTheme(
    titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
    bodyMedium: TextStyle(color: AppColors.textPrimary),
    bodySmall: TextStyle(color: AppColors.textSecondary),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: AppColors.primary),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: DarkAppColors.primary, brightness: Brightness.dark),
  scaffoldBackgroundColor: DarkAppColors.background,
  primaryColor: DarkAppColors.primary,
  appBarTheme: const AppBarTheme(elevation: 0, backgroundColor: Colors.transparent, foregroundColor: DarkAppColors.textPrimary),
  cardColor: DarkAppColors.surface,
  textTheme: const TextTheme(
    titleLarge: TextStyle(color: DarkAppColors.textPrimary, fontWeight: FontWeight.w700),
    bodyMedium: TextStyle(color: DarkAppColors.textPrimary),
    bodySmall: TextStyle(color: DarkAppColors.textSecondary),
  ),
  dividerColor: DarkAppColors.divider,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(backgroundColor: DarkAppColors.primary, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
  ),
);
