import 'package:get/get.dart';
import '../l10n/locale_strings.dart';

enum RawatibSlot { before, after }

class RawatibInfo {
  final RawatibSlot slot;
  final int rakat;

  const RawatibInfo({required this.slot, required this.rakat});

  String get keyId => slot == RawatibSlot.before ? 'before' : 'after';
}

class RawatibConfig {
  static const Map<String, List<RawatibInfo>> _map = {
    'fajr': [RawatibInfo(slot: RawatibSlot.before, rakat: 2)],
    'dhuhr': [
      RawatibInfo(slot: RawatibSlot.before, rakat: 4),
      RawatibInfo(slot: RawatibSlot.after, rakat: 2),
    ],
    'asr': [],
    'maghrib': [RawatibInfo(slot: RawatibSlot.after, rakat: 2)],
    'isha': [RawatibInfo(slot: RawatibSlot.after, rakat: 2)],
  };

  static const List<String> prayerOrder = [
    'fajr',
    'dhuhr',
    'asr',
    'maghrib',
    'isha',
  ];

  static List<RawatibInfo> rawatibFor(String prayerName) {
    return _map[prayerName.toLowerCase()] ?? const [];
  }

  static bool isPrayer(String habitName) => _map.containsKey(habitName.toLowerCase());

  static String slotLabel(RawatibSlot slot, String prayerName) {
    final count = rakatFor(prayerName, slot);
    final unit = count == 1 ? AppStrings.rakat.tr : AppStrings.rakats.tr;
    final prefix = slot == RawatibSlot.before
        ? AppStrings.rawBefore.tr
        : AppStrings.rawAfter.tr;
    return '$prefix · $count $unit';
  }

  static int rakatFor(String prayerName, RawatibSlot slot) {
    final list = rawatibFor(prayerName);
    for (final info in list) {
      if (info.slot == slot) return info.rakat;
    }
    return 0;
  }

  static int totalRawatibCount(String prayerName) => _map[prayerName.toLowerCase()]?.length ?? 0;
}