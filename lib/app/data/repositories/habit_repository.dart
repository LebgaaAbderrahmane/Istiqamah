import 'package:uuid/uuid.dart';
import '../models/habit_log_model.dart';
import '../models/habit_model.dart';
import '../../services/database_service.dart';

class HabitRepository {
  final _db = DatabaseService.instance;
  final _uuid = const Uuid();

  Future<List<HabitModel>> getActiveHabits() => _db.getAllHabits();

  Future<List<HabitModel>> getAllHabits({bool includeArchived = false}) =>
      _db.getAllHabits(includeArchived: includeArchived);

  Future<HabitModel?> getHabitById(String id) => _db.getHabitById(id);

  Future<void> addHabit(HabitModel habit) => _db.insertHabit(habit);

  Future<void> updateHabit(HabitModel habit) => _db.updateHabit(habit);

  Future<void> reorderHabits(List<String> habitIds) async {
    final pairs = habitIds.asMap().entries.map((e) => {
      'id': e.value,
      'sortOrder': e.key,
    }).toList();
    await _db.updateHabitOrder(pairs);
  }

  Future<void> archiveHabit(String id) async {
    final habit = await _db.getHabitById(id);
    if (habit != null) {
      await _db.updateHabit(habit.copyWith(isArchived: true));
    }
  }

  Future<void> toggleLog(String habitId, DateTime date) async {
    final existing = await _db.getLog(habitId, date);
    if (existing != null) {
      await _db.upsertLog(existing.copyWith(
        value: existing.value == 0 ? 1 : 0,
        loggedAt: DateTime.now(),
      ));
    } else {
      await _db.upsertLog(HabitLogModel(
        id: _uuid.v4(),
        habitId: habitId,
        date: DateTime(date.year, date.month, date.day),
        value: 1,
        loggedAt: DateTime.now(),
      ));
    }
  }

  Future<void> updateLogValue(String habitId, DateTime date, int value) async {
    final existing = await _db.getLog(habitId, date);
    if (existing != null) {
      await _db.upsertLog(existing.copyWith(value: value, loggedAt: DateTime.now()));
    } else {
      await _db.upsertLog(HabitLogModel(
        id: _uuid.v4(),
        habitId: habitId,
        date: DateTime(date.year, date.month, date.day),
        value: value,
        loggedAt: DateTime.now(),
      ));
    }
  }

  Future<HabitLogModel?> getLog(String habitId, DateTime date) =>
      _db.getLog(habitId, date);

  Future<List<HabitLogModel>> getLogsForDate(DateTime date) =>
      _db.getLogsForDate(date);

  Future<List<HabitLogModel>> getLogsForHabit(String habitId) =>
      _db.getLogsForHabit(habitId);

  Future<Map<String, List<HabitLogModel>>> getAllLogsGroupedByDate(
    DateTime monthStart,
    DateTime monthEnd,
  ) =>
      _db.getAllLogsGroupedByDate(monthStart, monthEnd);

  Future<Map<String, int>> getRawatibForDate(DateTime date) =>
      _db.getRawatibForDate(date);

  Future<void> upsertRawatib(String prayer, DateTime date, String slot, int value) =>
      _db.upsertRawatib(prayer, date, slot, value);

  Future<int> getTotalXp() => _db.getTotalXp();

  Future<int> getXpForDate(DateTime date) => _db.getXpForDate(date);

  Future<void> deleteXpForDate(DateTime date) => _db.deleteXpForDate(date);

  Future<List<Map<String, dynamic>>> getXpLogs({int limit = 90}) =>
      _db.getXpLogs(limit: limit);

  Future<void> insertXpLog({
    required String id,
    required DateTime date,
    required int xp,
    required String category,
  }) =>
      _db.insertXpLog(id: id, date: date, xp: xp, category: category);
}
