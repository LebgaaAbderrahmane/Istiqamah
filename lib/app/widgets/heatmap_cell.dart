import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class HeatmapCell extends StatelessWidget {
  final int bucket;
  final bool isToday;
  final VoidCallback? onTap;

  const HeatmapCell({
    super.key,
    required this.bucket,
    this.isToday = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ramp = isDark ? AppColors.darkHeatmapRamp : AppColors.heatmapRamp;
    final color = ramp[bucket.clamp(0, ramp.length - 1)];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppSpacing.xxs),
          border: isToday
              ? Border.all(color: AppColors.gold, width: 2)
              : null,
        ),
      ),
    );
  }
}
