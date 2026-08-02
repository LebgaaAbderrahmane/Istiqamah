import 'package:get/get.dart';
import '../data/repositories/habit_repository.dart';
import '../logic/rawatib_config.dart';
import '../utils/date_utils.dart';

class RawatibController extends GetxController {
  final _repo = HabitRepository();

  Map<String, int> _today = {};
  final todayState = Rx<Map<String, int>>({});

  DateTime get today => DateTime.now();

  @override
  void onInit() {
    super.onInit();
    refreshToday();
  }

  Future<void> refreshToday() async {
    _today = await _repo.getRawatibForDate(AppDateUtils.dateOnly(today));
    todayState.value = Map.of(_today);
  }

  String _key(String prayer, RawatibSlot slot) =>
      '${prayer.toLowerCase()}_${slot == RawatibSlot.before ? 'before' : 'after'}';

  bool isDone(String prayer, RawatibSlot slot) {
    return (todayState.value[_key(prayer, slot)] ?? 0) == 1;
  }

  int rawatibDoneCount() {
    var count = 0;
    for (final prayer in RawatibConfig.prayerOrder) {
      for (final info in RawatibConfig.rawatibFor(prayer)) {
        if (isDone(prayer, info.slot)) count++;
      }
    }
    return count;
  }

  Future<void> toggleRawatib(String prayer, RawatibSlot slot) async {
    final key = _key(prayer, slot);
    final next = isDone(prayer, slot) ? 0 : 1;
    await _repo.upsertRawatib(
      prayer.toLowerCase(),
      AppDateUtils.dateOnly(today),
      slot == RawatibSlot.before ? 'before' : 'after',
      next,
    );
    _today[key] = next;
    todayState.value = Map.of(_today);
    update();
  }

  Future<void> resetRawatibForPrayer(String prayer) async {
    final normalized = prayer.toLowerCase();
    final slotted = RawatibConfig.rawatibFor(normalized);
    final date = AppDateUtils.dateOnly(today);
    for (final info in slotted) {
      final slot = info.slot == RawatibSlot.before ? 'before' : 'after';
      await _repo.upsertRawatib(normalized, date, slot, 0);
      _today.remove(_key(normalized, info.slot));
    }
    todayState.value = Map.of(_today);
    update();
  }
}