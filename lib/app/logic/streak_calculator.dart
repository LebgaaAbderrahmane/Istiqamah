import '../data/models/habit_log_model.dart';

class StreakInfo {
  final int current;
  final int longest;
  StreakInfo({required this.current, required this.longest});
}

class StreakCalculator {
  static StreakInfo calculate({
    required List<HabitLogModel> logs,
    required int targetValue,
    required DateTime createdAt,
    required DateTime today,
  }) {
    final current = _currentStreak(logs, targetValue, createdAt, today);
    final longest = _longestStreak(logs, targetValue, createdAt);
    return StreakInfo(current: current, longest: longest);
  }

  static int _currentStreak(
    List<HabitLogModel> logs,
    int targetValue,
    DateTime createdAt,
    DateTime today,
  ) {
    final todayDate = DateTime(today.year, today.month, today.day);
    final todayLog = _findLog(logs, todayDate);
    var date = todayDate;

    if (todayLog == null || !_meetsTarget(todayLog, targetValue)) {
      final yesterday = DateTime(date.year, date.month, date.day - 1);
      if (_isBeforeCreated(yesterday, createdAt)) return 0;
      date = yesterday;
    }

    var streak = 0;
    while (true) {
      if (_isBeforeCreated(date, createdAt)) break;
      final log = _findLog(logs, date);
      if (log != null && _meetsTarget(log, targetValue)) {
        streak++;
        date = DateTime(date.year, date.month, date.day - 1);
      } else {
        break;
      }
    }
    return streak;
  }

  static int _longestStreak(
    List<HabitLogModel> logs,
    int targetValue,
    DateTime createdAt,
  ) {
    final eligibleLogs = logs
        .where((log) =>
            !_isBeforeCreated(
                DateTime(log.date.year, log.date.month, log.date.day), createdAt))
        .toList();
    if (eligibleLogs.isEmpty) return 0;

    eligibleLogs.sort((a, b) => a.date.compareTo(b.date));

    var longest = 0;
    var running = 0;
    DateTime? previousDate;

    for (final log in eligibleLogs) {
      final logDate = DateTime(log.date.year, log.date.month, log.date.day);

      if (!_meetsTarget(log, targetValue)) {
        running = 0;
        previousDate = logDate;
        continue;
      }

      if (previousDate != null) {
        final diff = logDate.difference(previousDate).inDays;
        if (diff == 1) {
          running++;
        } else if (diff == 0) {
        } else {
          running = 1;
        }
      } else {
        running = 1;
      }

      if (running > longest) longest = running;
      previousDate = logDate;
    }

    return longest;
  }

  static bool _meetsTarget(HabitLogModel log, int targetValue) {
    return log.value >= targetValue;
  }

  static bool _isBeforeCreated(DateTime date, DateTime createdAt) {
    final createdDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
    return date.isBefore(createdDate);
  }

  static HabitLogModel? _findLog(List<HabitLogModel> logs, DateTime date) {
    for (final log in logs) {
      final logDate = DateTime(log.date.year, log.date.month, log.date.day);
      if (logDate == date) return log;
    }
    return null;
  }
}
