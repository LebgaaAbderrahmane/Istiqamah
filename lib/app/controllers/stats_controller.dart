import 'package:get/get.dart';
import '../data/models/habit_log_model.dart';
import '../data/models/habit_model.dart';
import '../data/repositories/habit_repository.dart';
import '../utils/date_utils.dart';

class HabitWeekStat {
  final HabitModel habit;
  final int completedDays;
  final int eligibleDays;
  final double rate;

  HabitWeekStat({
    required this.habit,
    required this.completedDays,
    required this.eligibleDays,
  }) : rate = eligibleDays == 0 ? 0 : completedDays / eligibleDays;
}

class StatsController extends GetxController {
  final _repo = HabitRepository();

  final habits = <HabitModel>[].obs;
  final habitStats = <HabitWeekStat>[].obs;
  final weekStart = DateTime.now().obs;
  final weekEnd = DateTime.now().obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  Future<void> loadStats() async {
    isLoading.value = true;
    try {
      final end = AppDateUtils.dateOnly(DateTime.now());
      final start = end.subtract(const Duration(days: 6));
      weekStart.value = start;
      weekEnd.value = end;

      habits.value = await _repo.getActiveHabits();
      final logs = await _repo.getAllLogsGroupedByDate(start, end);

      final stats = <HabitWeekStat>[];
      for (final habit in habits) {
        final created = AppDateUtils.dateOnly(habit.createdAt);
        var eligible = 0;
        var completed = 0;
        for (var day = 0; day <= 6; day++) {
          final date = start.add(Duration(days: day));
          if (date.isBefore(created)) continue;
          eligible++;
          final dayLogs = logs[AppDateUtils.normalizeDate(date)] ?? [];
          final log = dayLogs.cast<HabitLogModel?>().firstWhere(
                (l) => l?.habitId == habit.id,
                orElse: () => null,
              );
          if (log != null && log.value >= habit.targetValue) {
            completed++;
          }
        }
        stats.add(HabitWeekStat(
          habit: habit,
          completedDays: completed,
          eligibleDays: eligible,
        ));
      }

      stats.sort((a, b) => b.rate.compareTo(a.rate));
      habitStats.assignAll(stats);
    } finally {
      isLoading.value = false;
    }
  }

  double get overallRate {
    final totalEligible = habitStats.fold<int>(
      0,
      (sum, s) => sum + s.eligibleDays,
    );
    final totalCompleted = habitStats.fold<int>(
      0,
      (sum, s) => sum + s.completedDays,
    );
    return totalEligible == 0 ? 0 : totalCompleted / totalEligible;
  }

  HabitWeekStat? get bestHabit => habitStats.firstOrNull;

  HabitWeekStat? get worstHabit =>
      habitStats.length < 2 ? null : habitStats.last;
}
