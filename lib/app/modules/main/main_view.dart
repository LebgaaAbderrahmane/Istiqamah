import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/main_controller.dart';
import '../../l10n/locale_strings.dart';
import '../calendar/calendar_view.dart';
import '../stats/stats_view.dart';
import '../tasks/tasks_view.dart';
import '../today/today_view.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: const [
              TodayView(),
              CalendarView(),
              TasksView(),
              StatsView(),
            ],
          )),
      bottomNavigationBar: Obx(() => NavigationBar(
            selectedIndex: controller.currentIndex.value,
            onDestinationSelected: controller.changeTab,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.today_outlined),
                selectedIcon: const Icon(Icons.today),
                label: AppStrings.today.tr,
              ),
              NavigationDestination(
                icon: const Icon(Icons.calendar_month_outlined),
                selectedIcon: const Icon(Icons.calendar_month),
                label: AppStrings.calendar.tr,
              ),
              NavigationDestination(
                icon: const Icon(Icons.checklist_outlined),
                selectedIcon: const Icon(Icons.checklist),
                label: AppStrings.tasks.tr,
              ),
              NavigationDestination(
                icon: const Icon(Icons.insights_outlined),
                selectedIcon: const Icon(Icons.insights),
                label: AppStrings.stats.tr,
              ),
            ],
          )),
    );
  }
}
