import 'package:flutter/material.dart';

/// Optional theme data for adaptive glass UI (blur and tint).
class GlassThemeData {
  const GlassThemeData({
    this.blurSigma = 10.0,
    this.lightTintOpacity = 0.25,
    this.darkTintOpacity = 0.2,
  });

  final double blurSigma;
  final double lightTintOpacity;
  final double darkTintOpacity;
}

class GlassTheme extends InheritedTheme {
  const GlassTheme({super.key, required this.data, required super.child});

  final GlassThemeData data;

  static GlassThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<GlassTheme>();
    return theme?.data ?? const GlassThemeData();
  }

  @override
  bool updateShouldNotify(GlassTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return GlassTheme(data: data, child: child);
  }
}

class AppTheme {
  static const _brandGreen = Color(0xFF1E7F3E);

  /// Default glass styling used by [AdaptiveGlass] when no theme is set.
  static const defaultGlass = GlassThemeData(
    blurSigma: 10.0,
    lightTintOpacity: 0.25,
    darkTintOpacity: 0.2,
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _brandGreen,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF8FAF9),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6DBE45),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF0F1A14),
  );
}
