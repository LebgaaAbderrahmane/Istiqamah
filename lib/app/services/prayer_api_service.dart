import 'package:dio/dio.dart';

class PrayerApiService {
  final Dio _dio;

  PrayerApiService()
      : _dio = Dio(BaseOptions(
          baseUrl: 'https://api.aladhan.com/v1',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  Future<Map<String, String>?> fetchPrayerTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await _dio.get(
        '/timings/$dateStr',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'method': 2,
        },
      );

      final timings = response.data['data']['timings'] as Map<String, dynamic>;
      return {
        'Fajr': timings['Fajr'] as String,
        'Sunrise': timings['Sunrise'] as String,
        'Dhuhr': timings['Dhuhr'] as String,
        'Asr': timings['Asr'] as String,
        'Maghrib': timings['Maghrib'] as String,
        'Isha': timings['Isha'] as String,
      };
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, String>?> fetchPrayerTimesByCity({
    required String city,
    required DateTime date,
  }) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await _dio.get(
        '/timingsByCity/$dateStr',
        queryParameters: {
          'city': city,
          'country': '',
          'method': 2,
        },
      );

      final timings = response.data['data']['timings'] as Map<String, dynamic>;
      return {
        'Fajr': timings['Fajr'] as String,
        'Sunrise': timings['Sunrise'] as String,
        'Dhuhr': timings['Dhuhr'] as String,
        'Asr': timings['Asr'] as String,
        'Maghrib': timings['Maghrib'] as String,
        'Isha': timings['Isha'] as String,
      };
    } catch (e) {
      return null;
    }
  }
}
