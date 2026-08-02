import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/habit_controller.dart';
import '../l10n/locale_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AddHabitSheet {
  AddHabitSheet._();

  static Future<void> show() {
    return Get.bottomSheet(
      const _AddHabitSheetBody(),
      isScrollControlled: true,
      backgroundColor: Get.context!.appColors.surface,
    );
  }
}

class _AddHabitSheetBody extends StatelessWidget {
  const _AddHabitSheetBody();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HabitController>();
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController(text: '1');
    final selectedType = 'boolean'.obs;
    final selectedIcon = 'check_circle'.obs;

    return Container(
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
                  color: context.appColors.textHint.withValues(alpha: 0.3),
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
    );
  }
}
