import 'package:flutter/material.dart';
import '../data/models/habit_model.dart';
import '../data/repositories/habit_repository.dart';
import '../logic/heatmap_aggregator.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../utils/date_utils.dart';

class DayDetailSheet extends StatelessWidget {
  final DayCompletion day;

  const DayDetailSheet({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HabitModel>>(
      future: HabitRepository().getActiveHabits(),
      builder: (context, snapshot) {
        final habits = snapshot.data ?? <HabitModel>[];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textHint.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                AppDateUtils.formatGregorianFull(day.date),
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '${day.completedCount} / ${day.totalActiveHabits} habits completed',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              ...habits.map((habit) {
                final log = day.logs.where((l) => l.habitId == habit.id).firstOrNull;
                final isCompleted = log != null && log.value >= habit.targetValue;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    isCompleted ? Icons.check_circle : Icons.cancel_outlined,
                    color: isCompleted ? AppColors.accent : AppColors.textHint,
                  ),
                  title: Text(
                    habit.name,
                    style: AppTextStyles.bodyLarge,
                  ),
                  trailing: habit.type != 'boolean' && log != null
                      ? Text(
                          '${log.value} ${habit.unit ?? ''}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.accent,
                          ),
                        )
                      : null,
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
