import 'package:get/get.dart';
import 'app_routes.dart';
import '../bindings/today_binding.dart';
import '../bindings/calendar_binding.dart';
import '../bindings/habit_detail_binding.dart';
import '../bindings/settings_binding.dart';
import '../modules/today/today_view.dart';
import '../modules/calendar/calendar_view.dart';
import '../modules/habit_detail/habit_detail_view.dart';
import '../modules/settings/settings_view.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.today,
      page: () => const TodayView(),
      binding: TodayBinding(),
    ),
    GetPage(
      name: AppRoutes.calendar,
      page: () => const CalendarView(),
      binding: CalendarBinding(),
    ),
    GetPage(
      name: AppRoutes.habitDetail,
      page: () => const HabitDetailView(),
      binding: HabitDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
  ];
}
