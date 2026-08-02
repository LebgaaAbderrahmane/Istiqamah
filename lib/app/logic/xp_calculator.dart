class XpCalculator {
  static const int basePerHabit = 10;
  static const int bonusPerRawatib = 5;
  static const int fullPrayersBonus = 5;

  /// Calculates today's XP awarded.
  ///
  /// [completedCount] = number of habits meeting target today.
  /// [prayersCompleted] = number of the 5 prayers completed (0-5).
  /// [rawatibDone] = number of rawatib toggles completed today.
  static int todayXp({
    required int completedCount,
    required int prayersCompleted,
    required int rawatibDone,
  }) {
    var xp = completedCount * basePerHabit;
    xp += rawatibDone * bonusPerRawatib;
    if (prayersCompleted >= 5) {
      xp += fullPrayersBonus;
    }
    return xp;
  }

  /// Escalating cumulative XP thresholds; index i = XP required to reach level i+1.
  static final List<int> thresholds = _buildThresholds();

  static List<int> _buildThresholds() {
    final base = [0, 100, 250, 450, 700, 1000];
    final list = [...base];
    for (var i = 0; i < 200; i++) {
      list.add(list.last + 500);
    }
    return list;
  }

  static int levelForTotal(int totalXp) {
    var level = 1;
    for (final threshold in thresholds.skip(1)) {
      if (totalXp >= threshold) {
        level++;
      } else {
        break;
      }
    }
    return level;
  }

  /// Cumulative XP at the start of [level].
  static int floorForLevel(int level) {
    final idx = _clampIndex(level - 1);
    return thresholds[idx];
  }

  /// Cumulative XP required to reach the next level after [level].
  static int xpForNextLevel(int level) {
    final idx = _clampIndex(level);
    return thresholds[idx];
  }

  static int _clampIndex(int idx) {
    if (idx < 0) return 0;
    if (idx >= thresholds.length) return thresholds.length - 1;
    return idx;
  }

  /// Progress (0..1) through the current level.
  static double levelProgress(int totalXp, int level) {
    final floor = floorForLevel(level);
    final ceiling = xpForNextLevel(level);
    final span = ceiling - floor;
    if (span <= 0) return 1.0;
    return ((totalXp - floor) / span).clamp(0.0, 1.0);
  }
}