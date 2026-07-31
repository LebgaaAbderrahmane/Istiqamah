import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/habit_detail_controller.dart';
import '../../l10n/locale_strings.dart';
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
        title: Obx(() => Text(controller.habit.value?.name ?? '')),
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
          return EmptyStateWidget(
            icon: Icons.error_outline,
            message: AppStrings.habitNotFound.tr,
          );
        }
        final streak = controller.streak.value;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, habit, streak),
              const SizedBox(height: AppSpacing.lg),
              if (streak != null) _buildStreakSection(context, streak),
              const SizedBox(height: AppSpacing.lg),
              _buildMiniHeatmap(),
              const SizedBox(height: AppSpacing.lg),
              _buildHistorySection(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context, HabitModel habit, StreakInfo? streak) {
    final colors = context.appColors;
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Icon(
              Icons.check_circle,
              size: 48,
              color: colors.accent,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(habit.name, style: AppTextStyles.headlineLarge),
          Text(
            habit.type == 'count' ? '${habit.targetValue} ${habit.unit ?? ''}' : AppStrings.checkbox.tr,
            style: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakSection(BuildContext context, StreakInfo streak) {
    return Row(
      children: [
        Expanded(
          child: _buildStreakCard(context, AppStrings.currentStreak.tr, streak.current),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStreakCard(context, AppStrings.longestStreak.tr, streak.longest),
        ),
      ],
    );
  }

  Widget _buildStreakCard(BuildContext context, String label, int value) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: AppTextStyles.displayLarge.copyWith(color: colors.accent),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniHeatmap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.monthOverview.tr, style: AppTextStyles.titleMedium),
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

  Widget _buildHistorySection(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.recentLogs.tr, style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Obx(() {
          if (controller.logs.isEmpty) {
            return Text(
              AppStrings.noLogsYet.tr,
              style: AppTextStyles.bodyMedium.copyWith(color: colors.textHint),
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
                  color: meetsTarget ? colors.accent : colors.textHint,
                  size: 20,
                ),
                title: Text(
                  AppDateUtils.formatGregorian(log.date),
                  style: AppTextStyles.bodyMedium,
                ),
                trailing: Text(
                  '${log.value}',
                  style: AppTextStyles.bodyMedium.copyWith(color: colors.accent),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}
