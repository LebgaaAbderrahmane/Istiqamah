import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/habit_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../utils/date_utils.dart';
import '../../utils/constants.dart';
import '../../routes/app_routes.dart';
import '../../widgets/habit_row.dart';
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
            Text(
              AppDateUtils.formatGregorian(DateTime.now()),
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            Obx(() => Text(
                  settings.calendarPreference.value == 'hijri'
                      ? 'Hijri Date'
                      : AppConstants.appName,
                  style: AppTextStyles.titleLarge,
                )),
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
          return const EmptyStateWidget(
            icon: Icons.checklist,
            message: 'Your journey starts today.',
            subtitle: 'Add your first habit to begin tracking.',
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadData(),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: 80),
            itemCount: controller.habits.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildHeader();
              }
              final habit = controller.habits[index - 1];
              return HabitRow(habit: habit);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitDialog(context),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Habit'),
      ),
    );
  }

  Widget _buildHeader() {
    final total = controller.habits.length;
    final completed =
        controller.habits.where((h) => controller.isHabitCompletedToday(h.id)).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _getMessage(completed, total),
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
              '$completed / $total',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  String _getMessage(int completed, int total) {
    if (completed == total && total > 0) {
      return 'Masha\'Allah! All habits completed today.';
    }
    if (completed > 0) {
      return 'Keep going — every step counts.';
    }
    return 'Bismillah — let\'s begin today\'s journey.';
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
              Text('Add Custom Habit', style: AppTextStyles.titleLarge),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Habit name',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Obx(() => DropdownButtonFormField<String>(
                    initialValue: selectedType.value,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: const [
                      DropdownMenuItem(value: 'boolean', child: Text('Checkbox')),
                      DropdownMenuItem(value: 'count', child: Text('Count')),
                    ],
                    onChanged: (v) {
                      if (v != null) selectedType.value = v;
                    },
                  )),
              const SizedBox(height: AppSpacing.sm),
              if (selectedType.value == 'count')
                TextField(
                  controller: targetCtrl,
                  decoration: const InputDecoration(labelText: 'Daily target'),
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
                  child: const Text('Add Habit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
