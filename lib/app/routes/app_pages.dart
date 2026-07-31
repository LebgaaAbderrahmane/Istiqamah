import 'package:get/get.dart';
import 'app_routes.dart';
import '../bindings/habit_detail_binding.dart';
import '../bindings/main_binding.dart';
import '../bindings/settings_binding.dart';
import '../modules/habit_detail/habit_detail_view.dart';
import '../modules/main/main_view.dart';
import '../modules/settings/settings_view.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.home,
      page: () => const MainView(),
      binding: MainBinding(),
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
