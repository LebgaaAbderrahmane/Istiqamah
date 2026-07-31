import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.accent,
    required this.accentLight,
    required this.accentDark,
    required this.gold,
    required this.goldLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.error,
    required this.success,
    required this.border,
    required this.heatmapRamp,
  });

  final Color background;
  final Color surface;
  final Color accent;
  final Color accentLight;
  final Color accentDark;
  final Color gold;
  final Color goldLight;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color error;
  final Color success;
  final Color border;
  final List<Color> heatmapRamp;

  static const AppColors light = AppColors(
    background: Color(0xFFFAF7F2),
    surface: Color(0xFFFFFFFF),
    accent: Color(0xFF0F6B5C),
    accentLight: Color(0xFF1A9A85),
    accentDark: Color(0xFF0A4F43),
    gold: Color(0xFFC9A24B),
    goldLight: Color(0xFFE0C37A),
    textPrimary: Color(0xFF1A1A2E),
    textSecondary: Color(0xFF6B7280),
    textHint: Color(0xFF9CA3AF),
    error: Color(0xFFE74C3C),
    success: Color(0xFF27AE60),
    border: Color(0xFFE5E7EB),
    heatmapRamp: [
      Color(0xFFF0F0E8),
      Color(0xFFB8D4CF),
      Color(0xFF7AB8AD),
      Color(0xFF3D9B8A),
      Color(0xFF0F6B5C),
    ],
  );

  static const AppColors dark = AppColors(
    background: Color(0xFF0D1B1E),
    surface: Color(0xFF1A2D32),
    accent: Color(0xFF26B89A),
    accentLight: Color(0xFF3DD4B6),
    accentDark: Color(0xFF0F6B5C),
    gold: Color(0xFFC9A24B),
    goldLight: Color(0xFFE0C37A),
    textPrimary: Color(0xFFE8E8E8),
    textSecondary: Color(0xFF9CA3AF),
    textHint: Color(0xFF9CA3AF),
    error: Color(0xFFE74C3C),
    success: Color(0xFF27AE60),
    border: Color(0xFF2D3F44),
    heatmapRamp: [
      Color(0xFF1A2D32),
      Color(0xFF1D4055),
      Color(0xFF206060),
      Color(0xFF23806B),
      Color(0xFF26B89A),
    ],
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? accent,
    Color? accentLight,
    Color? accentDark,
    Color? gold,
    Color? goldLight,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? error,
    Color? success,
    Color? border,
    List<Color>? heatmapRamp,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      accent: accent ?? this.accent,
      accentLight: accentLight ?? this.accentLight,
      accentDark: accentDark ?? this.accentDark,
      gold: gold ?? this.gold,
      goldLight: goldLight ?? this.goldLight,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      error: error ?? this.error,
      success: success ?? this.success,
      border: border ?? this.border,
      heatmapRamp: heatmapRamp ?? this.heatmapRamp,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentLight: Color.lerp(accentLight, other.accentLight, t)!,
      accentDark: Color.lerp(accentDark, other.accentDark, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      goldLight: Color.lerp(goldLight, other.goldLight, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      border: Color.lerp(border, other.border, t)!,
      heatmapRamp: List.generate(
        heatmapRamp.length,
        (i) => Color.lerp(heatmapRamp[i], other.heatmapRamp[i], t)!,
        growable: false,
      ),
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get appColors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;
}
