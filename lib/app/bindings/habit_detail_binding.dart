import 'package:get/get.dart';
import '../controllers/habit_detail_controller.dart';

class HabitDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HabitDetailController>(() => HabitDetailController());
  }
}
