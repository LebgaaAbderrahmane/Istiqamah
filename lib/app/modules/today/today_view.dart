import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/habit_model.dart';
import '../../controllers/habit_controller.dart';
import '../../controllers/prayer_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/xp_controller.dart';
import '../../l10n/locale_strings.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../utils/date_utils.dart';

import '../../routes/app_routes.dart';
import '../../widgets/add_habit_sheet.dart';
import '../../widgets/habit_row.dart';
import '../../widgets/prayer_card.dart';
import '../../widgets/prayer_time_row.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/quran_habit_card.dart';
import '../../widgets/section_header_widget.dart';

class TodayView extends GetView<HabitController> {
  const TodayView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.appName.tr, style: AppTextStyles.titleLarge),
              Obx(() {
                final pref = settings.calendarPreference.value;
                final today = DateTime.now();
                final gregorian = AppDateUtils.formatGregorian(today);
                final hijri = AppDateUtils.formatHijri(today);
                return Text(
                  pref == 'hijri' ? hijri : gregorian,
                  style: AppTextStyles.bodySmall,
                );
              }),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Get.toNamed(AppRoutes.settings),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.habits.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.checklist,
            message: AppStrings.yourJourneyStarts.tr,
            subtitle: AppStrings.addFirstHabit.tr,
          );
        }

        final prayerHabits = controller.habits.where((h) {
          final n = h.name.toLowerCase();
          return n == 'fajr' ||
              n == 'dhuhr' ||
              n == 'asr' ||
              n == 'maghrib' ||
              n == 'isha';
        }).toList();

        final quranHabits = controller.habits.where((h) {
          final n = h.name.toLowerCase();
          return n.contains('quran') || n.contains('قرآن');
        }).toList();

        final adhkarHabits = controller.habits.where((h) {
          final n = h.name.toLowerCase();
          return n.contains('dhikr') ||
              n.contains('sadaqah') ||
              n.contains('qiyam') ||
              n.contains('fasting') ||
              n.contains('taraweeh') ||
              n.contains('ذكر') ||
              n.contains('صدقة');
        }).toList();

        final otherHabits = controller.habits.where((h) {
          return !prayerHabits.contains(h) &&
              !quranHabits.contains(h) &&
              !adhkarHabits.contains(h);
        }).toList();

        int completedCount(List<HabitModel> list) {
          return list
              .where((h) => controller.isHabitCompletedToday(h.id))
              .length;
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.loadData();
            await Get.find<PrayerController>().refreshTimes();
          },
          child: ListView(
            padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: 80),
            children: [
              const _ProgressOverviewCard(),
              const _InspirationCard(),
              const _PrayerTimesSection(),

              if (prayerHabits.isNotEmpty) ...[
                SectionHeaderWidget(
                  icon: Icons.mosque_rounded,
                  title: AppStrings.prayersSectionTitle.tr,
                  counterText:
                      '${completedCount(prayerHabits)} / ${prayerHabits.length}',
                ),
                ...prayerHabits.map(
                  (h) => PrayerCard(key: ValueKey(h.id), habit: h),
                ),
              ],

              if (quranHabits.isNotEmpty) ...[
                SectionHeaderWidget(
                  icon: Icons.menu_book_rounded,
                  title: AppStrings.quranSectionTitle.tr,
                  counterText:
                      '${completedCount(quranHabits)} / ${quranHabits.length}',
                ),
                ...quranHabits.map(
                  (h) => QuranHabitCard(key: ValueKey(h.id), habit: h),
                ),
              ],

              if (adhkarHabits.isNotEmpty) ...[
                SectionHeaderWidget(
                  icon: Icons.stars_rounded,
                  title: AppStrings.adhkarSectionTitle.tr,
                  counterText:
                      '${completedCount(adhkarHabits)} / ${adhkarHabits.length}',
                ),
                ...adhkarHabits.map(
                  (h) => HabitRow(key: ValueKey(h.id), habit: h),
                ),
              ],

              if (otherHabits.isNotEmpty) ...[
                SectionHeaderWidget(
                  icon: Icons.extension_rounded,
                  title: AppStrings.otherHabitsSectionTitle.tr,
                  counterText:
                      '${completedCount(otherHabits)} / ${otherHabits.length}',
                ),
                ...otherHabits.map(
                  (h) => HabitRow(key: ValueKey(h.id), habit: h),
                ),
              ],
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'today_add_habit_fab',
        onPressed: AddHabitSheet.show,
        backgroundColor: context.appColors.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(AppStrings.addHabit.tr),
      ),
    );
  }
}

class _PrayerTimesSection extends StatelessWidget {
  const _PrayerTimesSection();

  @override
  Widget build(BuildContext context) {
    final prayerController = Get.find<PrayerController>();
    final colors = context.appColors;
    return Obx(() {
      final times = prayerController.prayerTimes.value;
      final status = prayerController.locationStatus.value;
      final error = prayerController.errorMessage.value;
      if (times == null) {
        if (prayerController.isLoading.value) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  AppStrings.loadingTimes.tr,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }
        if (status != null || error != null) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_off_outlined,
                  size: 16,
                  color: colors.gold,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    status ?? error!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      }
      return PrayerTimeRow(times: times);
    });
  }
}

class _ProgressOverviewCard extends StatelessWidget {
  const _ProgressOverviewCard();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HabitController>();
    final colors = context.appColors;

    return Obx(() {
      final total = controller.habits.length;
      if (total == 0) return const SizedBox.shrink();

      final completed = controller.habits
          .where((h) => controller.isHabitCompletedToday(h.id))
          .length;
      final progress = total > 0 ? (completed / total) : 0.0;
      final percentage = (progress * 100).toInt();

      int maxStreak = 0;
      for (final h in controller.habits) {
        final st = controller.getStreak(h.id);
        if (st != null && st.current > maxStreak) {
          maxStreak = st.current;
        }
      }

      return Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xs,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.accent, colors.accent.withValues(alpha: 0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.accent.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -15,
              top: -15,
              child: Icon(
                Icons.star_outline_rounded,
                size: 130,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                      Text(
                        '$percentage%',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.todayProgress.tr,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$completed / $total ${AppStrings.habitsCompleted.tr}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      if (maxStreak > 0) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔥 ', style: TextStyle(fontSize: 11)),
                              Text(
                                '$maxStreak ${AppStrings.days.tr} ${AppStrings.currentStreak.tr}',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      _XpChip(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _XpChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final xpController = Get.find<XpController>();
    final colors = context.appColors;
    return Obx(() {
      final level = xpController.level.value;
      final total = xpController.totalXp.value;
      final progress = xpController.levelProgress.value;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_graph_rounded, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              '${AppStrings.level.tr} $level',
              style: AppTextStyles.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(colors.goldLight),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$total ${AppStrings.xp.tr}',
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white.withValues(alpha: 0.95),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _InspirationCard extends StatelessWidget {
  const _InspirationCard();

  static const List<Map<String, String>> _inspirations = [
    {
      'arabic':
          'إِنَّ الَّذِينَ قَالُوا رَبُّنَا اللَّهُ ثُمَّ اسْتَقَامُوا تَتَنَزَّلُ عَلَيْهِمُ الْمَلَائِكَةُ',
      'english':
          'Indeed, those who say "Our Lord is Allah" and then remain steadfast - the angels will descend upon them.',
      'source': 'Fussilat 41:30',
    },
    {
      'arabic': 'أَحَبُّ الأَعْمَالِ إِلَى اللَّهِ أَدْوَمُهَا وَإِنْ قَلَّ',
      'english':
          'The most beloved deeds to Allah are those performed consistently, even if they are small.',
      'source': 'Sahih Al-Bukhari',
    },
    {
      'arabic': 'قُلْ آمَنْتُ بِاللَّهِ ثُمَّ اسْتَقِمْ',
      'english': 'Say: "I believe in Allah", and then remain steadfast.',
      'source': 'Sahih Muslim',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    final item = _inspirations[dayOfYear % _inspirations.length];

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.accent.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.format_quote_rounded,
                  color: colors.accent,
                  size: 16,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                AppStrings.dailyInspiration.tr,
                style: AppTextStyles.labelLarge.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.border.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item['source']!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              item['arabic']!,
              style: AppTextStyles.titleMedium.copyWith(
                color: colors.textPrimary,
                height: 1.6,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            item['english']!,
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.textSecondary,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
