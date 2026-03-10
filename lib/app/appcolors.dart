import 'package:flutter/material.dart';

/// Central place for all colors used in the project.
/// Import this file to use consistent branding and UI colors.
abstract final class AppColors {
  AppColors._();

  // --- Brand ---
  /// Primary brand green (darker).
  static const Color brandGreen = Color(0xFF1E7F3E);

  /// Lighter brand green (e.g. gradient start, dark theme seed).
  static const Color brandGreenLight = Color(0xFF6DBE45);

  /// Content on green backgrounds (e.g. app bar text/icons).
  static const Color onGreen = Colors.white;

  /// Default app bar / splash gradient: light green → dark green.
  static const LinearGradient defaultGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [brandGreenLight, brandGreen],
  );

  // --- Surfaces ---
  /// Light theme scaffold background.
  static const Color scaffoldLight = Color(0xFFF8FAF9);

  /// Dark theme scaffold background.
  static const Color scaffoldDark = Color(0xFF0F1A14);

  /// Search field / filled input background (e.g. white on light theme).
  static const Color inputFill = Colors.white;

  // --- Overlays & effects ---
  /// Transparent (e.g. gradient start).
  static const Color transparent = Colors.transparent;

  /// Black with opacity (e.g. gradient overlay on photo tiles, shadows).
  static Color blackOpacity(double alpha) => Colors.black.withValues(alpha: alpha);

  /// White with opacity (e.g. glass border, tint).
  static Color whiteOpacity(double alpha) => Colors.white.withValues(alpha: alpha);

  // --- Semantic ---
  /// Like / heart active state.
  static const Color likeActive = Colors.red;

  /// Inactive heart outline (e.g. on white).
  static const Color likeInactive = Colors.white;

  // --- Glass / overlay tint ---
  /// Glass tint in light mode (white).
  static const Color glassTintLight = Colors.white;

  /// Glass tint in dark mode (black).
  static const Color glassTintDark = Colors.black;
}
