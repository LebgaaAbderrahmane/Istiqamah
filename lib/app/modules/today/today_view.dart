import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/habit_model.dart';
import '../../controllers/habit_controller.dart';
import '../../controllers/prayer_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../l10n/locale_strings.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../utils/date_utils.dart';

import '../../routes/app_routes.dart';
import '../../widgets/habit_row.dart';
import '../../widgets/prayer_time_row.dart';
import '../../widgets/empty_state_widget.dart';

class TodayView extends GetView<HabitController> {
  const TodayView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              final pref = settings.calendarPreference.value;
              final today = DateTime.now();
              final gregorian = AppDateUtils.formatGregorian(today);
              final hijri = AppDateUtils.formatHijri(today);
              return Text(
                pref == 'hijri' ? hijri : gregorian,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              );
            }),
            Text(
              AppStrings.appName.tr,
              style: AppTextStyles.titleLarge,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => Get.toNamed(AppRoutes.calendar),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Get.toNamed(AppRoutes.settings),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.habits.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.checklist,
            message: AppStrings.yourJourneyStarts.tr,
            subtitle: AppStrings.addFirstHabit.tr,
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadData(),
          child: ReorderableListView.builder(
            padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: 80),
            itemCount: controller.habits.length + 3,
            onReorderItem: (from, to) => controller.reorderHabits(from, to),
            buildDefaultDragHandles: false,
            itemBuilder: (context, index) {
              if (index == 0) return const _HeaderSection(key: ValueKey('header'));
              if (index == 1) return const _PrayerTimesSection(key: ValueKey('prayer'));
              if (index == 2) return const Divider(key: ValueKey('divider'));
              final habit = controller.habits[index - 3];
              return _ReorderableHabitRow(
                key: ValueKey(habit.id),
                habit: habit,
                index: index,
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitDialog(context),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(AppStrings.addHabit.tr),
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController(text: '1');
    final selectedType = 'boolean'.obs;
    final selectedIcon = 'check_circle'.obs;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textHint.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(AppStrings.addCustomHabit.tr, style: AppTextStyles.titleLarge),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: AppStrings.habitName.tr,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Obx(() => DropdownButtonFormField<String>(
                    initialValue: selectedType.value,
                    decoration: InputDecoration(labelText: AppStrings.type.tr),
                    items: [
                      DropdownMenuItem(value: 'boolean', child: Text(AppStrings.checkbox.tr)),
                      DropdownMenuItem(value: 'count', child: Text(AppStrings.count.tr)),
                    ],
                    onChanged: (v) {
                      if (v != null) selectedType.value = v;
                    },
                  )),
              const SizedBox(height: AppSpacing.sm),
              if (selectedType.value == 'count')
                TextField(
                  controller: targetCtrl,
                  decoration: InputDecoration(labelText: AppStrings.dailyTarget.tr),
                  keyboardType: TextInputType.number,
                ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) return;
                    controller.addCustomHabit(
                      name: nameCtrl.text.trim(),
                      icon: selectedIcon.value,
                      type: selectedType.value,
                      targetValue: int.tryParse(targetCtrl.text) ?? 1,
                    );
                    Get.back();
                  },
                  child: Text(AppStrings.save.tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HabitController>();
    final total = controller.habits.length;
    final completed =
        controller.habits.where((h) => controller.isHabitCompletedToday(h.id)).length;

    String message;
    if (completed == total && total > 0) {
      message = AppStrings.allCompleted.tr;
    } else if (completed > 0) {
      message = AppStrings.keepGoing.tr;
    } else {
      message = AppStrings.bismillah.tr;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$completed ${AppStrings.outOf.tr} $total',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerTimesSection extends StatelessWidget {
  const _PrayerTimesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final prayerController = Get.find<PrayerController>();
    return Obx(() {
      final times = prayerController.prayerTimes.value;
      if (times == null) return const SizedBox.shrink();
      return PrayerTimeRow(times: times);
    });
  }
}

class _ReorderableHabitRow extends StatelessWidget {
  final HabitModel habit;
  final int index;

  const _ReorderableHabitRow({
    super.key,
    required this.habit,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        HabitRow(habit: habit),
        Positioned(
          right: 8,
          top: 0,
          bottom: 0,
          child: ReorderableDragStartListener(
            index: index,
            child: Icon(
              Icons.drag_handle,
              color: AppColors.textHint.withValues(alpha: 0.5),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
