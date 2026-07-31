import 'package:get/get.dart';
import '../controllers/calendar_controller.dart';
import '../controllers/habit_controller.dart';
import '../controllers/main_controller.dart';
import '../controllers/prayer_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MainController>()) {
      Get.put<MainController>(MainController());
    }
    if (!Get.isRegistered<HabitController>()) {
      Get.put<HabitController>(HabitController());
    }
    if (!Get.isRegistered<PrayerController>()) {
      Get.put<PrayerController>(PrayerController());
    }
    if (!Get.isRegistered<CalendarController>()) {
      Get.put<CalendarController>(CalendarController());
    }
  }
}
