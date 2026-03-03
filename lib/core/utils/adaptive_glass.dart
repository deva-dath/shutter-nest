import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shutter_nest/config/theme/app_theme.dart';

/// Adaptive glass (glassmorphism) container that blurs content behind it
/// and applies a theme-aware tint. Use for nav bars, overlays, and cards.
/// Respects [GlassTheme.of](context) when set (e.g. in [MaterialApp.builder]).
class AdaptiveGlass extends StatelessWidget {
  const AdaptiveGlass({
    super.key,
    required this.child,
    this.borderRadius,
    this.border,
    this.blurSigma,
    this.lightTintOpacity,
    this.darkTintOpacity,
    this.elevation = 0.0,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final Border? border;
  /// When null, uses [GlassTheme.of](context) or [AppTheme.defaultGlass].
  final double? blurSigma;
  final double? lightTintOpacity;
  final double? darkTintOpacity;
  final double elevation;

  /// Predefined for a bottom nav bar: stronger blur, subtle tint.
  factory AdaptiveGlass.navBar({
    Key? key,
    required Widget child,
    BorderRadius? borderRadius,
  }) {
    return AdaptiveGlass(
      key: key,
      borderRadius: borderRadius ?? BorderRadius.zero,
      blurSigma: 12.0,
      lightTintOpacity: 0.28,
      darkTintOpacity: 0.22,
      elevation: 0,
      child: child,
    );
  }

  /// Predefined for cards and overlays: rounded, soft shadow.
  factory AdaptiveGlass.card({
    Key? key,
    required Widget child,
    BorderRadius? borderRadius,
    double? blurSigma,
  }) {
    return AdaptiveGlass(
      key: key,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      blurSigma: blurSigma ?? 8.0,
      lightTintOpacity: 0.2,
      darkTintOpacity: 0.18,
      elevation: 2.0,
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.15),
        width: 1,
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glassTheme = GlassTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sigma = blurSigma ?? glassTheme.blurSigma;
    final tintOpacity = isDark
        ? (darkTintOpacity ?? glassTheme.darkTintOpacity)
        : (lightTintOpacity ?? glassTheme.lightTintOpacity);
    final tintColor = isDark ? Colors.black : Colors.white;
    final radius = borderRadius ?? BorderRadius.zero;

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: Container(
          decoration: BoxDecoration(
            color: tintColor.withValues(alpha: tintOpacity),
            borderRadius: radius,
            border: border,
            boxShadow: elevation > 0
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.25 : 0.08,
                      ),
                      blurRadius: elevation * 4,
                      offset: Offset(0, elevation),
                    ),
                  ]
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
