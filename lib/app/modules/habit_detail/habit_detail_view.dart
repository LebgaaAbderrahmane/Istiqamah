import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/habit_detail_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../utils/date_utils.dart';
import '../../widgets/heatmap_cell.dart';
import '../../widgets/empty_state_widget.dart';
import '../../logic/streak_calculator.dart';
import '../../data/models/habit_model.dart';

class HabitDetailView extends GetView<HabitDetailController> {
  const HabitDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.habit.value?.name ?? 'Habit Detail')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final habit = controller.habit.value;
        if (habit == null) {
          return const EmptyStateWidget(
            icon: Icons.error_outline,
            message: 'Habit not found.',
          );
        }
        final streak = controller.streak.value;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(habit, streak),
              const SizedBox(height: AppSpacing.lg),
              if (streak != null) _buildStreakSection(streak),
              const SizedBox(height: AppSpacing.lg),
              _buildMiniHeatmap(),
              const SizedBox(height: AppSpacing.lg),
              _buildHistorySection(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(HabitModel habit, StreakInfo? streak) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Icon(
              Icons.check_circle,
              size: 48,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(habit.name, style: AppTextStyles.headlineLarge),
          Text(
              habit.type == 'count' ? '${habit.targetValue} ${habit.unit ?? ''}' : 'Daily',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakSection(StreakInfo streak) {
    return Row(
      children: [
        Expanded(
          child: _buildStreakCard('Current Streak', streak.current),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStreakCard('Longest Streak', streak.longest),
        ),
      ],
    );
  }

  Widget _buildStreakCard(String label, int value) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: AppTextStyles.displayLarge.copyWith(color: AppColors.accent),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniHeatmap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('12-Month Overview', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Obx(() {
          if (controller.monthCompletions.isEmpty) {
            return const SizedBox(height: 100);
          }
          return Wrap(
            spacing: 2,
            runSpacing: 2,
            children: controller.monthCompletions.map((day) {
              return SizedBox(
                width: 12,
                height: 12,
                child: HeatmapCell(
                  bucket: day.bucket,
                  onTap: () {},
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Logs', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Obx(() {
          if (controller.logs.isEmpty) {
            return Text(
              'No logs yet. Start tracking today!',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
            );
          }
          final recent = controller.logs.reversed.take(14).toList();
          return Column(
            children: recent.map((log) {
              final habit = controller.habit.value;
              final meetsTarget = habit != null && log.value >= habit.targetValue;
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  meetsTarget ? Icons.check_circle : Icons.cancel_outlined,
                  color: meetsTarget ? AppColors.accent : AppColors.textHint,
                  size: 20,
                ),
                title: Text(
                  AppDateUtils.formatGregorian(log.date),
                  style: AppTextStyles.bodyMedium,
                ),
                trailing: Text(
                  '${log.value}',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accent),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}
