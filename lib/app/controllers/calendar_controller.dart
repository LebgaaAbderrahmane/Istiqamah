import 'package:get/get.dart';
import '../data/models/habit_model.dart';
import '../data/repositories/habit_repository.dart';
import '../logic/heatmap_aggregator.dart';

class CalendarController extends GetxController {
  final _repo = HabitRepository();

  final currentMonth = DateTime.now().obs;
  final completions = <DayCompletion>[].obs;
  final selectedDay = Rx<DayCompletion?>(null);
  final habits = <HabitModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMonth();
  }

  Future<void> loadMonth() async {
    isLoading.value = true;
    try {
      habits.value = await _repo.getActiveHabits();
      final start = DateTime(currentMonth.value.year, currentMonth.value.month, 1);
      final end = DateTime(currentMonth.value.year, currentMonth.value.month + 1, 0);
      final logsByDate = await _repo.getAllLogsGroupedByDate(start, end);

      completions.value = HeatmapAggregator.aggregateMonth(
        year: currentMonth.value.year,
        month: currentMonth.value.month,
        habits: habits,
        logsByDate: logsByDate,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void nextMonth() {
    currentMonth.value = DateTime(
      currentMonth.value.year,
      currentMonth.value.month + 1,
    );
    loadMonth();
  }

  void prevMonth() {
    currentMonth.value = DateTime(
      currentMonth.value.year,
      currentMonth.value.month - 1,
    );
    loadMonth();
  }

  void selectDay(DayCompletion day) {
    selectedDay.value = day;
  }

  void clearSelection() {
    selectedDay.value = null;
  }
}
