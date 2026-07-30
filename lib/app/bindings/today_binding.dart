import 'package:get/get.dart';
import '../controllers/habit_controller.dart';
import '../controllers/prayer_controller.dart';

class TodayBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HabitController>(() => HabitController());
    Get.lazyPut<PrayerController>(() => PrayerController());
  }
}
