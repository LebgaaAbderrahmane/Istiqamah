import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'app/controllers/locale_controller.dart';
import 'app/controllers/settings_controller.dart';
import 'app/controllers/stats_controller.dart';
import 'app/controllers/theme_controller.dart';
import 'app/l10n/app_translations.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/services/notification_service.dart';
import 'app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  Get.put(ThemeController());
  Get.put(LocaleController());
  Get.put(SettingsController());
  Get.put(StatsController());
  runApp(const IstiqamahApp());
}

class IstiqamahApp extends StatelessWidget {
  const IstiqamahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, child) {
        final tc = Get.find<ThemeController>();
        final lc = Get.find<LocaleController>();
        return Obx(
          () => GetMaterialApp(
            title: 'Istiqamah',
            debugShowCheckedModeBanner: false,
            translations: AppTranslations(),
            locale: lc.locale.value,
            fallbackLocale: const Locale('en', 'US'),
            initialRoute: AppRoutes.home,
            getPages: AppPages.pages,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: tc.themeMode.value,
            defaultTransition: Transition.fadeIn,
          ),
        );
      },
    );
  }
}
