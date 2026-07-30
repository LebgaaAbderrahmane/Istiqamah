import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  final calendarPreference = 'gregorian'.obs;
  final isNotificationsEnabled = true.obs;
  final ramadanModeOverride = Rx<bool?>(null);
  final cityName = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    calendarPreference.value = prefs.getString('calendarPreference') ?? 'gregorian';
    isNotificationsEnabled.value = prefs.getBool('notificationsEnabled') ?? true;
    final ramadan = prefs.getBool('ramadanModeOverride');
    ramadanModeOverride.value = ramadan;
    cityName.value = prefs.getString('cityName');
  }

  Future<void> setCalendarPreference(String value) async {
    calendarPreference.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('calendarPreference', value);
  }

  Future<void> toggleNotifications() async {
    isNotificationsEnabled.value = !isNotificationsEnabled.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', isNotificationsEnabled.value);
  }

  Future<void> setRamadanOverride(bool? value) async {
    ramadanModeOverride.value = value;
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove('ramadanModeOverride');
    } else {
      await prefs.setBool('ramadanModeOverride', value);
    }
  }

  Future<void> setCityName(String name) async {
    cityName.value = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cityName', name);
  }
}
