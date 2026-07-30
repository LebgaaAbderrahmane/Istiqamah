import 'package:flutter_test/flutter_test.dart';
import 'package:istiqamah/app/data/models/habit_log_model.dart';
import 'package:istiqamah/app/logic/streak_calculator.dart';

void main() {
  final today = DateTime(2026, 7, 30);

  group('StreakCalculator', () {
    test('streak of 0 with no logs', () {
      final result = StreakCalculator.calculate(
        logs: [],
        targetValue: 1,
        createdAt: DateTime(2026, 7, 1),
        today: today,
      );
      expect(result.current, 0);
      expect(result.longest, 0);
    });

    test('current streak counts consecutive days ending yesterday', () {
      final logs = [
        _log(DateTime(2026, 7, 28), 1),
        _log(DateTime(2026, 7, 29), 1),
      ];
      final result = StreakCalculator.calculate(
        logs: logs,
        targetValue: 1,
        createdAt: DateTime(2026, 7, 1),
        today: today,
      );
      expect(result.current, 2);
    });

    test('current streak holds when today is not logged yet', () {
      final logs = [
        _log(DateTime(2026, 7, 28), 1),
        _log(DateTime(2026, 7, 29), 1),
      ];
      final result = StreakCalculator.calculate(
        logs: logs,
        targetValue: 1,
        createdAt: DateTime(2026, 7, 1),
        today: today,
      );
      expect(result.current, 2);
    });

    test('streak broken by missed day', () {
      final logs = [
        _log(DateTime(2026, 7, 27), 1),
        _log(DateTime(2026, 7, 28), 1),
        _log(DateTime(2026, 7, 30), 1),
      ];
      final result = StreakCalculator.calculate(
        logs: logs,
        targetValue: 1,
        createdAt: DateTime(2026, 7, 1),
        today: today,
      );
      expect(result.current, 1);
    });

    test('streak ignores days before habit createdAt', () {
      final logs = [
        _log(DateTime(2026, 7, 28), 1),
        _log(DateTime(2026, 7, 29), 1),
      ];
      final result = StreakCalculator.calculate(
        logs: logs,
        targetValue: 1,
        createdAt: DateTime(2026, 7, 29),
        today: today,
      );
      expect(result.current, 1);
    });

    test('longest streak correctly identifies past streak after break', () {
      final logs = [
        _log(DateTime(2026, 7, 1), 1),
        _log(DateTime(2026, 7, 2), 1),
        _log(DateTime(2026, 7, 3), 1),
        _log(DateTime(2026, 7, 4), 1),
        _log(DateTime(2026, 7, 5), 1),
        _log(DateTime(2026, 7, 10), 1),
        _log(DateTime(2026, 7, 11), 1),
        _log(DateTime(2026, 7, 12), 1),
      ];
      final result = StreakCalculator.calculate(
        logs: logs,
        targetValue: 1,
        createdAt: DateTime(2026, 7, 1),
        today: today,
      );
      expect(result.longest, 5);
    });

    test('longest streak with no consecutive days', () {
      final logs = [
        _log(DateTime(2026, 7, 1), 1),
        _log(DateTime(2026, 7, 3), 1),
        _log(DateTime(2026, 7, 5), 1),
      ];
      final result = StreakCalculator.calculate(
        logs: logs,
        targetValue: 1,
        createdAt: DateTime(2026, 7, 1),
        today: today,
      );
      expect(result.longest, 1);
    });

    test('count type habit meets target correctly', () {
      final logs = [
        _log(DateTime(2026, 7, 28), 30),
        _log(DateTime(2026, 7, 29), 33),
      ];
      final result = StreakCalculator.calculate(
        logs: logs,
        targetValue: 33,
        createdAt: DateTime(2026, 7, 1),
        today: today,
      );
      expect(result.current, 1);
      expect(result.longest, 1);
    });

    test('count type habit does not meet target', () {
      final logs = [
        _log(DateTime(2026, 7, 28), 30),
        _log(DateTime(2026, 7, 29), 20),
      ];
      final result = StreakCalculator.calculate(
        logs: logs,
        targetValue: 33,
        createdAt: DateTime(2026, 7, 1),
        today: today,
      );
      expect(result.current, 0);
      expect(result.longest, 0);
    });
  });
}

HabitLogModel _log(DateTime date, int value) {
  return HabitLogModel(
    id: 'test-${date.toIso8601String()}',
    habitId: 'habit-1',
    date: date,
    value: value,
    loggedAt: date,
  );
}
