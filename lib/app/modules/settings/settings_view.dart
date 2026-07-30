import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _buildSectionHeader('Appearance'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Theme'),
                  trailing: Obx(() => SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                          ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                          ButtonSegment(
                              value: ThemeMode.system, label: Text('System')),
                        ],
                        selected: {themeController.themeMode.value},
                        onSelectionChanged: (set) {
                          themeController.setThemeMode(set.first);
                        },
                      )),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSectionHeader('Calendar'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Calendar preference'),
                  trailing: Obx(() => DropdownButton<String>(
                        value: controller.calendarPreference.value,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                              value: 'gregorian', child: Text('Gregorian')),
                          DropdownMenuItem(
                              value: 'hijri', child: Text('Hijri')),
                          DropdownMenuItem(
                              value: 'both', child: Text('Both')),
                        ],
                        onChanged: (v) {
                          if (v != null) controller.setCalendarPreference(v);
                        },
                      )),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSectionHeader('Notifications'),
          Card(
            child: Column(
              children: [
                Obx(() => SwitchListTile(
                      title: const Text('Prayer time notifications'),
                      subtitle: const Text('Get reminded before each prayer'),
                      value: controller.isNotificationsEnabled.value,
                      onChanged: (_) => controller.toggleNotifications(),
                    )),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSectionHeader('Location'),
          Card(
            child: Column(
              children: [
                Obx(() => ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: const Text('City'),
                      subtitle: Text(controller.cityName.value ?? 'Not set'),
                      trailing: const Icon(Icons.edit),
                      onTap: () => _showCityInput(),
                    )),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSectionHeader('Ramadan'),
          Card(
            child: Column(
              children: [
                Obx(() => SwitchListTile(
                      title: const Text('Ramadan mode'),
                      subtitle: const Text('Show fasting & taraweeh tracking'),
                      value: controller.ramadanModeOverride.value ?? false,
                      onChanged: (v) => controller.setRamadanOverride(v),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        title,
        style: AppTextStyles.labelLarge.copyWith(color: AppColors.accent),
      ),
    );
  }

  void _showCityInput() {
    final controller = this.controller;
    final ctrl = TextEditingController(text: controller.cityName.value ?? '');
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Text('Set City', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                labelText: 'City name',
                hintText: 'e.g. Mecca',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (ctrl.text.trim().isNotEmpty) {
                    controller.setCityName(ctrl.text.trim());
                  }
                  Get.back();
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
