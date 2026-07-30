import 'package:get/get.dart';
import '../controllers/habit_detail_controller.dart';

class HabitDetailBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HabitDetailController>()) {
      Get.put<HabitDetailController>(HabitDetailController());
    }
  }
}
