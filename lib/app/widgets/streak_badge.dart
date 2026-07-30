import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

class StreakBadge extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final bool compact;

  const StreakBadge({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
        decoration: BoxDecoration(
          color: currentStreak > 0
              ? AppColors.accent.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentStreak > 0 ? '$currentStreak' : '0',
              style: AppTextStyles.labelLarge.copyWith(
                color: currentStreak > 0 ? AppColors.accent : AppColors.textHint,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              'days',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department, size: 16, color: AppColors.accent),
          const SizedBox(width: 4),
          Text(
            '$currentStreak / $longestStreak',
            style: AppTextStyles.labelLarge.copyWith(color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}
