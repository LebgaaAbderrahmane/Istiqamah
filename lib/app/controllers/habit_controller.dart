import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../data/models/habit_log_model.dart';
import '../data/models/habit_model.dart';
import '../data/repositories/habit_repository.dart';
import '../logic/streak_calculator.dart';
import '../services/hijri_service.dart';
import '../utils/date_utils.dart';
import 'xp_controller.dart';

class HabitController extends GetxController {
  final _repo = HabitRepository();

  final habits = <HabitModel>[].obs;
  final todayLogs = <String, HabitLogModel?>{}.obs;
  final streaks = <String, StreakInfo>{}.obs;
  final isLoading = false.obs;

  DateTime get today => DateTime.now();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      await _handleRamadanMode();
      habits.value = await _repo.getActiveHabits();
      await _loadTodayLogs();
      await _computeStreaks();
      if (Get.isRegistered<XpController>()) {
        Get.find<XpController>().recompute();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleRamadanMode() async {
    final prefs = await SharedPreferences.getInstance();
    final override = prefs.getBool('ramadanModeOverride');
    final isRamadan = HijriService().isRamadan(today);

    final shouldShowRamadan = override ?? isRamadan;
    final allHabits = await _repo.getAllHabits(includeArchived: true);
    final existingRamadan = allHabits.where((h) => h.name == 'Fasting' || h.name == 'Taraweeh').toList();

    if (shouldShowRamadan) {
      for (final habit in existingRamadan) {
        if (habit.isArchived) {
          await _repo.updateHabit(habit.copyWith(isArchived: false));
        }
      }
      if (!existingRamadan.any((h) => h.name == 'Fasting')) {
        final maxOrder = allHabits.isEmpty ? 0 : allHabits.map((h) => h.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
        await _repo.addHabit(HabitModel(
          id: const Uuid().v4(),
          name: 'Fasting',
          icon: 'nightlight',
          type: 'boolean',
          targetValue: 1,
          isCustom: true,
          sortOrder: maxOrder,
          createdAt: today,
        ));
      }
      if (!existingRamadan.any((h) => h.name == 'Taraweeh')) {
        final maxOrder = allHabits.isEmpty ? 0 : allHabits.map((h) => h.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
        await _repo.addHabit(HabitModel(
          id: const Uuid().v4(),
          name: 'Taraweeh',
          icon: 'mosque',
          type: 'boolean',
          targetValue: 1,
          isCustom: true,
          sortOrder: maxOrder,
          createdAt: today,
        ));
      }
    } else {
      for (final habit in existingRamadan) {
        if (!habit.isArchived) {
          await _repo.updateHabit(habit.copyWith(isArchived: true));
        }
      }
    }
  }

  Future<void> _loadTodayLogs() async {
    final todayDate = AppDateUtils.dateOnly(today);
    final logs = await _repo.getLogsForDate(todayDate);
    final map = <String, HabitLogModel?>{};
    for (final habit in habits) {
      map[habit.id] = logs.where((l) => l.habitId == habit.id).firstOrNull;
    }
    todayLogs.assignAll(map);
  }

  Future<void> _computeStreaks() async {
    final streakMap = <String, StreakInfo>{};
    for (final habit in habits) {
      final allLogs = await _repo.getLogsForHabit(habit.id);
      streakMap[habit.id] = StreakCalculator.calculate(
        logs: allLogs,
        targetValue: habit.targetValue,
        createdAt: habit.createdAt,
        today: today,
      );
    }
    streaks.assignAll(streakMap);
  }

  Future<void> toggleHabit(String habitId) async {
    final todayDate = AppDateUtils.dateOnly(today);
    await _repo.toggleLog(habitId, todayDate);
    await _loadTodayLogs();
    await _computeStreaks();
    if (Get.isRegistered<XpController>()) {
      Get.find<XpController>().recompute();
    }
  }

  Future<void> updateCountHabit(String habitId, int value) async {
    final todayDate = AppDateUtils.dateOnly(today);
    await _repo.updateLogValue(habitId, todayDate, value);
    await _loadTodayLogs();
    await _computeStreaks();
    if (Get.isRegistered<XpController>()) {
      Get.find<XpController>().recompute();
    }
  }

  Future<void> addCustomHabit({
    required String name,
    required String icon,
    required String type,
    required int targetValue,
    String? unit,
  }) async {
    final habit = HabitModel(
      id: const Uuid().v4(),
      name: name,
      icon: icon,
      type: type,
      targetValue: targetValue,
      unit: unit,
      isCustom: true,
      sortOrder: habits.length,
      createdAt: today,
    );
    await _repo.addHabit(habit);
    await loadData();
  }

  Future<void> reorderHabits(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final updated = <HabitModel>[...habits];
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    habits.value = updated;
    await _repo.reorderHabits(updated.map((h) => h.id).toList());
  }

  Future<void> archiveHabit(String id) async {
    await _repo.archiveHabit(id);
    await loadData();
  }

  bool isHabitCompletedToday(String habitId) {
    final log = todayLogs[habitId];
    if (log == null) return false;
    final habit = habits.firstWhereOrNull((h) => h.id == habitId);
    if (habit == null) return false;
    return log.value >= habit.targetValue;
  }

  int getHabitLogValue(String habitId) {
    final log = todayLogs[habitId];
    return log?.value ?? 0;
  }

  StreakInfo? getStreak(String habitId) => streaks[habitId];
}
