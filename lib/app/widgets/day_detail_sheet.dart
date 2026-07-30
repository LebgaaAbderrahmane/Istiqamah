import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/habit_log_model.dart';
import '../data/models/habit_model.dart';
import '../data/repositories/habit_repository.dart';
import '../logic/heatmap_aggregator.dart';
import '../l10n/locale_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../utils/date_utils.dart';
import '../utils/constants.dart';

class DayDetailSheet extends StatefulWidget {
  final DayCompletion day;

  const DayDetailSheet({super.key, required this.day});

  @override
  State<DayDetailSheet> createState() => _DayDetailSheetState();
}

class _DayDetailSheetState extends State<DayDetailSheet> {
  final _repo = HabitRepository();
  late Future<List<HabitModel>> _habitsFuture;
  Map<String, HabitLogModel> _logs = {};

  @override
  void initState() {
    super.initState();
    _habitsFuture = _repo.getActiveHabits();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final logs = await _repo.getLogsForDate(widget.day.date);
    if (mounted) {
      setState(() {
        _logs = {for (final l in logs) l.habitId: l};
      });
    }
  }

  bool get _canEdit {
    final diff = DateTime.now().difference(widget.day.date).inDays;
    return diff >= 0 && diff <= AppConstants.maxEditDaysBack;
  }

  Future<void> _toggleLog(HabitModel habit) async {
    final todayDate = AppDateUtils.dateOnly(widget.day.date);
    await _repo.toggleLog(habit.id, todayDate);
    await _loadLogs();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HabitModel>>(
      future: _habitsFuture,
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
                AppDateUtils.formatGregorianFull(widget.day.date),
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                AppDateUtils.formatHijri(widget.day.date),
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '${widget.day.completedCount} ${AppStrings.outOf.tr} ${widget.day.totalActiveHabits} ${AppStrings.habitsCompleted.tr}',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              if (_canEdit)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    '${AppStrings.tapToEdit.tr} (${AppStrings.dayWindow.tr})',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.gold),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              ...habits.map((habit) {
                final log = _logs[habit.id];
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
                  onTap: _canEdit && habit.type == 'boolean'
                      ? () => _toggleLog(habit)
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
