import '../data/models/habit_log_model.dart';
import '../data/models/habit_model.dart';
import '../utils/date_utils.dart';

class DayCompletion {
  final DateTime date;
  final int completedCount;
  final int totalActiveHabits;
  final List<HabitLogModel> logs;

  DayCompletion({
    required this.date,
    required this.completedCount,
    required this.totalActiveHabits,
    required this.logs,
  });

  double get ratio =>
      totalActiveHabits > 0 ? completedCount / totalActiveHabits : 0;

  int get bucket {
    if (ratio == 0) return 0;
    if (ratio <= 0.25) return 1;
    if (ratio <= 0.5) return 2;
    if (ratio <= 0.75) return 3;
    return 4;
  }
}

class HeatmapAggregator {
  static List<DayCompletion> aggregateMonth({
    required int year,
    required int month,
    required List<HabitModel> habits,
    required Map<String, List<HabitLogModel>> logsByDate,
  }) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final activeHabits =
        habits.where((h) => !h.isArchived).toList();
    final completions = <DayCompletion>[];

    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final dateStr = AppDateUtils.normalizeDate(date);
      final dayLogs = logsByDate[dateStr] ?? [];

      var completed = 0;
      var totalActive = 0;

      for (final habit in activeHabits) {
        if (date.isBefore(AppDateUtils.dateOnly(habit.createdAt))) continue;
        totalActive++;
        final log = _findLog(dayLogs, habit.id);
        if (log != null && log.value >= habit.targetValue) {
          completed++;
        }
      }

      completions.add(DayCompletion(
        date: date,
        completedCount: completed,
        totalActiveHabits: totalActive,
        logs: dayLogs,
      ));
    }

    return completions;
  }

  static HabitLogModel? _findLog(List<HabitLogModel> logs, String habitId) {
    for (final log in logs) {
      if (log.habitId == habitId) return log;
    }
    return null;
  }
}
