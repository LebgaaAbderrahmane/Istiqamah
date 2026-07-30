import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'app/controllers/theme_controller.dart';
import 'app/controllers/settings_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/services/notification_service.dart';
import 'app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  Get.put(ThemeController());
  Get.put(SettingsController());
  runApp(const IstiqamahApp());
}

class IstiqamahApp extends StatelessWidget {
  const IstiqamahApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();
    return Obx(
      () => ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        builder: (context, child) => GetMaterialApp(
          title: 'Istiqamah',
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.today,
          getPages: AppPages.pages,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: tc.themeMode.value,
          defaultTransition: Transition.fadeIn,
        ),
      ),
    );
  }
}
