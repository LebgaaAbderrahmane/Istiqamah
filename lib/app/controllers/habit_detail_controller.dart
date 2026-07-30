import 'package:get/get.dart';
import '../data/models/habit_log_model.dart';
import '../data/models/habit_model.dart';
import '../data/repositories/habit_repository.dart';
import '../logic/streak_calculator.dart';
import '../logic/heatmap_aggregator.dart';

class HabitDetailController extends GetxController {
  final _repo = HabitRepository();

  final habit = Rx<HabitModel?>(null);
  final logs = <HabitLogModel>[].obs;
  final streak = Rx<StreakInfo?>(null);
  final monthCompletions = <DayCompletion>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final habitId = Get.arguments as String?;
    if (habitId != null) loadHabit(habitId);
  }

  Future<void> loadHabit(String habitId) async {
    isLoading.value = true;
    try {
      final h = await _repo.getHabitById(habitId);
      habit.value = h;
      if (h == null) return;

      final allLogs = await _repo.getLogsForHabit(habitId);
      logs.value = allLogs;

      streak.value = StreakCalculator.calculate(
        logs: allLogs,
        targetValue: h.targetValue,
        createdAt: h.createdAt,
        today: DateTime.now(),
      );

      final allHabits = await _repo.getActiveHabits();
      final now = DateTime.now();
      final start = DateTime(now.year, now.month - 11, 1);
      final end = DateTime(now.year, now.month + 1, 0);
      final logsByDate = await _repo.getAllLogsGroupedByDate(start, end);

      final allCompletions = <DayCompletion>[];
      for (var m = 0; m < 12; m++) {
        final monthDate = DateTime(now.year, now.month - 11 + m);
        final monthComps = HeatmapAggregator.aggregateMonth(
          year: monthDate.year,
          month: monthDate.month,
          habits: allHabits,
          logsByDate: logsByDate,
        );
        allCompletions.addAll(monthComps);
      }
      monthCompletions.value = allCompletions;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleLog(DateTime date) async {
    final h = habit.value;
    if (h == null) return;
    await _repo.toggleLog(h.id, date);
    await loadHabit(h.id);
  }
}
