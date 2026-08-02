import 'package:flutter_test/flutter_test.dart';
import 'package:istiqamah/app/logic/rawatib_config.dart';
import 'package:istiqamah/app/logic/xp_calculator.dart';

void main() {
  group('XpCalculator', () {
    test('todayXp computes base from completed habits', () {
      final xp = XpCalculator.todayXp(
        completedCount: 3,
        prayersCompleted: 0,
        rawatibDone: 0,
      );
      expect(xp, 30);
    });

    test('todayXp adds rawaatib bonus', () {
      final xp = XpCalculator.todayXp(
        completedCount: 1,
        prayersCompleted: 0,
        rawatibDone: 4,
      );
      expect(xp, 10 + 4 * XpCalculator.bonusPerRawatib);
    });

    test('todayXp gives full prayers bonus', () {
      final xp = XpCalculator.todayXp(
        completedCount: 5,
        prayersCompleted: 5,
        rawatibDone: 0,
      );
      expect(xp, 50 + XpCalculator.fullPrayersBonus);
    });

    test('todayXp is zero with no activity', () {
      final xp = XpCalculator.todayXp(
        completedCount: 0,
        prayersCompleted: 0,
        rawatibDone: 0,
      );
      expect(xp, 0);
    });

    test('levelForTotal returns 1 at zero', () {
      expect(XpCalculator.levelForTotal(0), 1);
    });

    test('level increases with threshold', () {
      expect(XpCalculator.levelForTotal(99), 1);
      expect(XpCalculator.levelForTotal(100), 2);
      expect(XpCalculator.levelForTotal(250), 3);
    });

    test('level progress is between 0 and 1', () {
      final p = XpCalculator.levelProgress(150, 2);
      expect(p, inInclusiveRange(0.0, 1.0));
      expect(p > 0.0, isTrue);
    });

    test('floorForLevel is monotonic', () {
      expect(XpCalculator.floorForLevel(2), lessThan(XpCalculator.floorForLevel(3)));
    });
  });

  group('RawatibConfig', () {
    test('asr has no rawaatib', () {
      expect(RawatibConfig.rawatibFor('asr'), isEmpty);
    });

    test('fajr has 2 before', () {
      final raws = RawatibConfig.rawatibFor('fajr');
      expect(raws.length, 1);
      expect(raws.first.slot, RawatibSlot.before);
      expect(raws.first.rakat, 2);
    });

    test('dhuhr has before(4) and after(2)', () {
      final raws = RawatibConfig.rawatibFor('dhuhr');
      expect(raws.length, 2);
      final before = raws.firstWhere((r) => r.slot == RawatibSlot.before);
      final after = raws.firstWhere((r) => r.slot == RawatibSlot.after);
      expect(before.rakat, 4);
      expect(after.rakat, 2);
    });

    test('maghrib has 2 after', () {
      final raws = RawatibConfig.rawatibFor('maghrib');
      expect(raws.length, 1);
      expect(raws.first.slot, RawatibSlot.after);
    });

    test('total muakkadah rawaatib rakat is 12', () {
      final total = RawatibConfig.prayerOrder.fold<int>(0, (sum, p) {
        return sum + RawatibConfig.rawatibFor(p).fold<int>(0, (s, r) => s + r.rakat);
      });
      expect(total, 12);
    });
  });
}