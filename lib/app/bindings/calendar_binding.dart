import 'package:get/get.dart';
import '../controllers/calendar_controller.dart';

class CalendarBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CalendarController>()) {
      Get.put<CalendarController>(CalendarController());
    }
  }
}
