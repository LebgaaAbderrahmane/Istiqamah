import 'package:get/get.dart';
import '../controllers/habit_controller.dart';
import '../controllers/prayer_controller.dart';

class TodayBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HabitController>()) {
      Get.put<HabitController>(HabitController());
    }
    if (!Get.isRegistered<PrayerController>()) {
      Get.put<PrayerController>(PrayerController());
    }
  }
}
