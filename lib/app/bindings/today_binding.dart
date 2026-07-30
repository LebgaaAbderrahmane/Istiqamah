import 'package:get/get.dart';
import '../controllers/habit_controller.dart';

class TodayBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HabitController>(() => HabitController());
  }
}
