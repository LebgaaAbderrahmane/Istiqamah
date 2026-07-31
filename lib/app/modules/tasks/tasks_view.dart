import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/habit_controller.dart';
import '../../data/models/habit_model.dart';
import '../../l10n/locale_strings.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/add_habit_sheet.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/habit_icon.dart';
import '../../widgets/streak_badge.dart';

class TasksView extends GetView<HabitController> {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.tasks.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.habits.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.checklist,
            message: AppStrings.yourJourneyStarts.tr,
            subtitle: AppStrings.addFirstHabit.tr,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            80,
          ),
          itemCount: controller.habits.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
          itemBuilder: (context, index) {
            final habit = controller.habits[index];
            return _HabitTile(habit: habit);
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: AddHabitSheet.show,
        backgroundColor: context.appColors.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(AppStrings.addHabit.tr),
      ),
    );
  }
}

class _HabitTile extends StatelessWidget {
  final HabitModel habit;

  const _HabitTile({required this.habit});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HabitController>();
    final streak = controller.getStreak(habit.id);
    final isCountType = habit.type == 'count' || habit.type == 'duration';
    final colors = context.appColors;
    final subtitle = isCountType
        ? '${AppStrings.dailyTarget.tr}: ${habit.targetValue} ${habit.unit ?? ''}'
        : AppStrings.checkbox.tr;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () => Get.toNamed(AppRoutes.habitDetail, arguments: habit.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  habitIconData(habit.icon),
                  size: 24,
                  color: colors.accent,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
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
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                color: context.appColors.surface,
                onSelected: (value) {
                  if (value == 'archive') _confirmArchive(controller);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'archive',
                    child: Row(
                      children: [
                        Icon(Icons.archive_outlined,
                            color: context.appColors.textSecondary, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Text(AppStrings.archive.tr),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmArchive(HabitController controller) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(AppStrings.archive.tr),
        content: Text(AppStrings.archiveConfirm.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(AppStrings.cancel.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(AppStrings.archive.tr),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      controller.archiveHabit(habit.id);
    }
  }
}
