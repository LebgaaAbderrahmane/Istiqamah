import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/prayer_api_service.dart';
import '../services/notification_service.dart';

class PrayerController extends GetxController {
  final _api = PrayerApiService();
  final _notif = NotificationService.instance;

  final prayerTimes = Rx<Map<String, String>?>(null);
  final isLoading = false.obs;
  final locationStatus = Rx<String?>(null);
  final errorMessage = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadCached();
    _initLocation();
  }

  Future<void> _loadCached() async {
    final prefs = await SharedPreferences.getInstance();
    final fajr = prefs.getString('pt_Fajr');
    if (fajr != null) {
      prayerTimes.value = {
        'Fajr': fajr,
        'Sunrise': prefs.getString('pt_Sunrise') ?? '',
        'Dhuhr': prefs.getString('pt_Dhuhr') ?? '',
        'Asr': prefs.getString('pt_Asr') ?? '',
        'Maghrib': prefs.getString('pt_Maghrib') ?? '',
        'Isha': prefs.getString('pt_Isha') ?? '',
      };
    }
  }

  Future<void> _cacheTimes(Map<String, String> times) async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in times.entries) {
      await prefs.setString('pt_${entry.key}', entry.value);
    }
  }

  Future<void> _initLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final req = await Geolocator.requestPermission();
        if (req == LocationPermission.denied) {
          locationStatus.value = 'Location permission denied. Set city in settings.';
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        locationStatus.value = 'Location permanently denied. Set city in settings.';
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );

      await _fetchAndSchedule(position.latitude, position.longitude);
    } catch (e) {
      locationStatus.value = 'Could not get location. Set city in settings.';
    }
  }

  Future<void> fetchByCity(String city) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final times = await _api.fetchPrayerTimesByCity(
        city: city,
        date: DateTime.now(),
      );
      if (times != null) {
        prayerTimes.value = times;
        await _cacheTimes(times);
        await _notif.schedulePrayerNotifications(times);
      } else {
        errorMessage.value = 'Could not fetch prayer times for $city';
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchAndSchedule(double lat, double lng) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final times = await _api.fetchPrayerTimes(
        latitude: lat,
        longitude: lng,
        date: DateTime.now(),
      );
      if (times != null) {
        prayerTimes.value = times;
        await _cacheTimes(times);
        await _notif.schedulePrayerNotifications(times);
      } else {
        errorMessage.value = 'Could not fetch prayer times';
      }
    } finally {
      isLoading.value = false;
    }
  }
}
