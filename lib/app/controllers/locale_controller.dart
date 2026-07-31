import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends GetxController {
  final locale = Rx<Locale>(const Locale('en', 'US'));

  @override
  void onInit() {
    super.onInit();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('locale');
    if (saved != null) {
      locale.value = saved == 'ar'
          ? const Locale('ar', 'AE')
          : const Locale('en', 'US');
    } else {
      final device = Get.deviceLocale;
      if (device?.languageCode == 'ar') {
        locale.value = const Locale('ar', 'AE');
      } else {
        locale.value = const Locale('en', 'US');
      }
    }
  }

  Future<void> setLocale(Locale l) async {
    locale.value = l;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', l.languageCode);
    Get.updateLocale(l);
  }

  bool get isRtl => locale.value.languageCode == 'ar';
}
