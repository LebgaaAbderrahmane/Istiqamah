import 'package:intl/intl.dart';
import '../services/hijri_service.dart';

class AppDateUtils {
  static final _hijriService = HijriService();

  static String formatGregorian(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String formatGregorianFull(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  static String formatHijri(DateTime date) {
    return _hijriService.formatHijri(date);
  }

  static String formatHijriMonthYear(DateTime date) {
    return _hijriService.formatHijriShort(date);
  }

  static String formatBothDates(DateTime date) {
    final g = formatGregorian(date);
    final h = formatHijri(date);
    return '$g  ·  $h';
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
