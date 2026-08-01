import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/habit_controller.dart';
import '../data/models/habit_model.dart';
import '../l10n/locale_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class QuranHabitCard extends StatelessWidget {
  final HabitModel habit;

  const QuranHabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HabitController>();
    final colors = context.appColors;

    return Obx(() {
      final logValue = controller.getHabitLogValue(habit.id);
      final isCompleted = controller.isHabitCompletedToday(habit.id);
      final target = habit.targetValue > 0 ? habit.targetValue : 1;
      final progress = (logValue / target).clamp(0.0, 1.0);

      return Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? colors.accent
                : colors.accent.withValues(alpha: 0.25),
            width: isCompleted ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.accent.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs + 2),
                    decoration: BoxDecoration(
                      color: colors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: colors.accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          '$logValue / $target ${habit.unit ?? AppStrings.pages.tr}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isCompleted
                                ? colors.accent
                                : colors.textSecondary,
                            fontWeight: isCompleted
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.toggleHabit(habit.id),
                    icon: Icon(
                      isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isCompleted ? colors.accent : colors.border,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              // Linear Progress Indicator
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: colors.border.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Quick action buttons
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      controller.updateCountHabit(habit.id, logValue + 1);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      side: BorderSide(
                        color: colors.accent.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(
                      AppStrings.addPage.tr,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: colors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  OutlinedButton.icon(
                    onPressed: () {
                      controller.updateCountHabit(habit.id, logValue + 5);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      side: BorderSide(
                        color: colors.accent.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.library_add_outlined, size: 16),
                    label: Text(
                      AppStrings.addFivePages.tr,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: colors.accent,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (logValue > 0)
                    IconButton(
                      onPressed: () {
                        if (logValue > 0) {
                          controller.updateCountHabit(habit.id, logValue - 1);
                        }
                      },
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      color: colors.textHint,
                      tooltip: 'Minus 1',
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              // Future Expansion Badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.bookmark_outline_rounded,
                      size: 14,
                      color: colors.accent.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        AppStrings.comingSoon.tr,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
