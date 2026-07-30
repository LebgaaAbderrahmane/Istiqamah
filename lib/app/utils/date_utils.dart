import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatGregorian(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String formatGregorianFull(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  static String dayOfWeekAbbr(DateTime date) {
    return DateFormat('E').format(date);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String normalizeDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  static DateTime dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  static int daysBetween(DateTime from, DateTime to) {
    return to.difference(from).inDays;
  }
}
