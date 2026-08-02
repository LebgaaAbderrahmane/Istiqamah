import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/habit_model.dart';
import '../controllers/habit_controller.dart';
import '../l10n/locale_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import 'streak_badge.dart';
import 'habit_icon.dart';

class HabitRow extends StatelessWidget {
  final HabitModel habit;

  const HabitRow({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HabitController>();
    return Obx(() {
      final isCompleted = controller.isHabitCompletedToday(habit.id);
      final logValue = controller.getHabitLogValue(habit.id);
      final streak = controller.getStreak(habit.id);
      final isCountType = habit.type == 'count' || habit.type == 'duration';
      final colors = context.appColors;

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          onTap: () {
            if (isCountType) {
              _showCountInput(context, controller);
            } else {
              controller.toggleHabit(habit.id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                _buildIcon(context, habit.icon, isCompleted),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isCompleted ? colors.textHint : null,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (isCountType && logValue > 0)
                        Text(
                          '$logValue / ${habit.targetValue} ${habit.unit ?? ''}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colors.accent,
                          ),
                        ),
                    ],
                  ),
                ),
                if (streak != null)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: StreakBadge(
                      currentStreak: streak.current,
                      longestStreak: streak.longest,
                      compact: true,
                    ),
                  ),
                _buildTrailing(context, habit, isCompleted, logValue),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildIcon(BuildContext context, String iconName, bool isCompleted) {
    final colors = context.appColors;
    final iconData = habitIconData(iconName);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: isCompleted
            ? colors.accent.withValues(alpha: 0.1)
            : colors.border.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Icon(
        iconData,
        size: 24,
        color: isCompleted ? colors.accent : colors.textHint,
      ),
    );
  }

  Widget _buildTrailing(
    BuildContext context,
    HabitModel habit,
    bool isCompleted,
    int logValue,
  ) {
    final colors = context.appColors;
    if (habit.type == 'boolean') {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          key: ValueKey(isCompleted),
          color: isCompleted ? colors.accent : colors.border,
          size: 28,
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        '$logValue',
        style: AppTextStyles.titleMedium.copyWith(color: colors.accent),
      ),
    );
  }

  void _showCountInput(BuildContext context, HabitController controller) {
    final value = controller.getHabitLogValue(habit.id).obs;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              habit.name,
              style: AppTextStyles.titleLarge,
            ),
            Text(
              '${AppStrings.dailyTarget.tr}: ${habit.targetValue} ${habit.unit ?? ''}',
              style: AppTextStyles.bodyMedium.copyWith(color: context.appColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        if (value.value > 0) value.value--;
                      },
                      iconSize: 36,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Text(
                        '${value.value}',
                        style: AppTextStyles.displayMedium,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => value.value++,
                      iconSize: 36,
                    ),
                  ],
                )),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.updateCountHabit(habit.id, value.value);
                  Get.back();
                },
                child: Text(AppStrings.save.tr),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: context.appColors.surface,
    );
  }
}
