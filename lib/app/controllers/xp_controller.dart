import 'package:get/get.dart';
import 'habit_controller.dart';
import 'rawatib_controller.dart';
import '../data/repositories/habit_repository.dart';
import '../logic/rawatib_config.dart';
import '../logic/xp_calculator.dart';
import '../utils/date_utils.dart';

class XpController extends GetxController {
  final _repo = HabitRepository();

  final totalXp = 0.obs;
  final todayXpValue = 0.obs;
  final level = 1.obs;
  final levelProgress = 0.0.obs;
  final xpLogs = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    recompute();
    final raw = Get.find<RawatibController>();
    raw.todayState.listen((_) => recompute());
  }

  Future<void> recompute() async {
    final today = AppDateUtils.dateOnly(DateTime.now());
    final habits = Get.find<HabitController>().habits;
    final logs = Get.find<HabitController>().todayLogs;

    var completedCount = 0;
    var prayersCompleted = 0;
    for (final habit in habits) {
      final log = logs[habit.id];
      final met = log != null && log.value >= habit.targetValue;
      if (met) completedCount++;
      if (met && RawatibConfig.isPrayer(habit.name)) prayersCompleted++;
    }

    final rawatibDone = Get.find<RawatibController>().rawatibDoneCount();

    final todayXp = XpCalculator.todayXp(
      completedCount: completedCount,
      prayersCompleted: prayersCompleted,
      rawatibDone: rawatibDone,
    );

    await _repo.deleteXpForDate(today);
    if (todayXp > 0) {
      await _repo.insertXpLog(
        id: '${today.toIso8601String()}_xp',
        date: today,
        xp: todayXp,
        category: 'daily',
      );
    }

    todayXpValue.value = todayXp;
    await _loadTotal();
    await _loadHistory();
  }

  Future<void> _loadTotal() async {
    final total = await _repo.getTotalXp();
    totalXp.value = total;
    final lvl = XpCalculator.levelForTotal(total);
    level.value = lvl;
    levelProgress.value = XpCalculator.levelProgress(total, lvl);
  }

  Future<void> _loadHistory() async {
    xpLogs.value = await _repo.getXpLogs();
  }
}