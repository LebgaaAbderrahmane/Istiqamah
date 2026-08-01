import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/habit_model.dart';
import '../../controllers/habit_controller.dart';
import '../../controllers/main_controller.dart';
import '../../controllers/prayer_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../l10n/locale_strings.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../utils/date_utils.dart';

import '../../routes/app_routes.dart';
import '../../widgets/add_habit_sheet.dart';
import '../../widgets/habit_row.dart';
import '../../widgets/prayer_time_row.dart';
import '../../widgets/empty_state_widget.dart';

class TodayView extends GetView<HabitController> {
  const TodayView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Text(AppStrings.appName.tr, style: AppTextStyles.titleLarge),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => Get.find<MainController>().changeTab(1),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Get.toNamed(AppRoutes.settings),
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

        return RefreshIndicator(
          onRefresh: () => controller.loadData(),
          child: ReorderableListView.builder(
            padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: 80),
            itemCount: controller.habits.length + 5,
            onReorderItem: (from, to) => controller.reorderHabits(from, to),
            buildDefaultDragHandles: false,
            itemBuilder: (context, index) {
              if (index == 0)
                return const _ProgressOverviewCard(
                  key: ValueKey('progress_overview'),
                );
              if (index == 1)
                return const _InspirationCard(key: ValueKey('inspiration'));
              if (index == 2)
                return const _PrayerTimesSection(key: ValueKey('prayer'));
              if (index == 3)
                return const _HeaderSection(key: ValueKey('header'));
              if (index == 4) return const Divider(key: ValueKey('divider'));
              final habit = controller.habits[index - 5];
              return _ReorderableHabitRow(
                key: ValueKey(habit.id),
                habit: habit,
                index: index,
              );
            },
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

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HabitController>();
    return Obx(() {
      final total = controller.habits.length;
      final completed = controller.habits
          .where((h) => controller.isHabitCompletedToday(h.id))
          .length;

      String message;
      if (completed == total && total > 0) {
        message = AppStrings.allCompleted.tr;
      } else if (completed > 0) {
        message = AppStrings.keepGoing.tr;
      } else {
        message = AppStrings.bismillah.tr;
      }

      final colors = context.appColors;

      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$completed ${AppStrings.outOf.tr} $total',
                style: AppTextStyles.labelLarge.copyWith(color: colors.accent),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _PrayerTimesSection extends StatelessWidget {
  const _PrayerTimesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final prayerController = Get.find<PrayerController>();
    return Obx(() {
      final times = prayerController.prayerTimes.value;
      if (times == null) return const SizedBox.shrink();
      return PrayerTimeRow(times: times);
    });
  }
}

class _ReorderableHabitRow extends StatelessWidget {
  final HabitModel habit;
  final int index;

  const _ReorderableHabitRow({
    super.key,
    required this.habit,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        HabitRow(habit: habit),
        Positioned(
          right: 8,
          top: 0,
          bottom: 0,
          child: ReorderableDragStartListener(
            index: index,
            child: Icon(
              Icons.drag_handle,
              color: context.appColors.textHint.withValues(alpha: 0.5),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressOverviewCard extends StatelessWidget {
  const _ProgressOverviewCard({super.key});

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

class _InspirationCard extends StatelessWidget {
  const _InspirationCard({super.key});

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
