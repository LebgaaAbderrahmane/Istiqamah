import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../controllers/locale_controller.dart';
import '../../l10n/locale_strings.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final localeController = Get.find<LocaleController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.settings.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _buildSectionHeader(AppStrings.appearance.tr),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: Text(AppStrings.theme.tr),
                  trailing: Obx(() => SegmentedButton<ThemeMode>(
                        segments: [
                          ButtonSegment(value: ThemeMode.light, label: Text(AppStrings.lightMode.tr)),
                          ButtonSegment(value: ThemeMode.dark, label: Text(AppStrings.darkMode.tr)),
                          ButtonSegment(value: ThemeMode.system, label: Text(AppStrings.systemMode.tr)),
                        ],
                        selected: {themeController.themeMode.value},
                        onSelectionChanged: (set) {
                          themeController.setThemeMode(set.first);
                        },
                      )),
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(AppStrings.language.tr),
                  trailing: Obx(() => DropdownButton<Locale>(
                        value: localeController.locale.value,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                            value: Locale('en', 'US'),
                            child: Text('English'),
                          ),
                          DropdownMenuItem(
                            value: Locale('ar', 'AE'),
                            child: Text('العربية'),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) localeController.setLocale(v);
                        },
                      )),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSectionHeader(AppStrings.calendar.tr),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(AppStrings.calendarPref.tr),
                  trailing: Obx(() => DropdownButton<String>(
                        value: controller.calendarPreference.value,
                        underline: const SizedBox(),
                        items: [
                          DropdownMenuItem(value: 'gregorian', child: Text(AppStrings.gregorian.tr)),
                          DropdownMenuItem(value: 'hijri', child: Text(AppStrings.hijri.tr)),
                          DropdownMenuItem(value: 'both', child: Text(AppStrings.both.tr)),
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
          _buildSectionHeader(AppStrings.notifications.tr),
          Card(
            child: Column(
              children: [
                Obx(() => SwitchListTile(
                      title: Text(AppStrings.prayerNotifications.tr),
                      subtitle: Text(AppStrings.notificationSubtitle.tr),
                      value: controller.isNotificationsEnabled.value,
                      onChanged: (_) => controller.toggleNotifications(),
                    )),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSectionHeader(AppStrings.location.tr),
          Card(
            child: Column(
              children: [
                Obx(() => ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: Text(AppStrings.city.tr),
                      subtitle: Text(controller.cityName.value ?? AppStrings.notSet.tr),
                      trailing: const Icon(Icons.edit),
                      onTap: () => _showCityInput(),
                    )),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSectionHeader(AppStrings.ramadan.tr),
          Card(
            child: Column(
              children: [
                Obx(() => SwitchListTile(
                      title: Text(AppStrings.ramadanMode.tr),
                      subtitle: Text(AppStrings.ramadanSubtitle.tr),
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
            Text(AppStrings.setCity.tr, style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: ctrl,
              decoration: InputDecoration(
                labelText: AppStrings.cityName.tr,
                hintText: AppStrings.cityHint.tr,
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
                child: Text(AppStrings.save.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
