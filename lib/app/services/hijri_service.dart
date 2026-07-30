import 'package:hijri/hijri_calendar.dart';

class HijriService {
  String formatHijri(DateTime date) {
    try {
      final hijri = HijriCalendar.fromDate(date);
      return '${hijri.longMonthName} ${hijri.hDay}, ${hijri.hYear} AH';
    } catch (e) {
      return '';
    }
  }

  String formatHijriShort(DateTime date) {
    try {
      final hijri = HijriCalendar.fromDate(date);
      return '${hijri.longMonthName} ${hijri.hYear}';
    } catch (e) {
      return '';
    }
  }

  int? getHijriMonth(DateTime date) {
    try {
      final hijri = HijriCalendar.fromDate(date);
      return hijri.hMonth;
    } catch (e) {
      return null;
    }
  }

  bool isRamadan(DateTime date) {
    final month = getHijriMonth(date);
    return month == 9;
  }
}
