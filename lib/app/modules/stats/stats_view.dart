import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/stats_controller.dart';
import '../../controllers/xp_controller.dart';
import '../../l10n/locale_strings.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/date_utils.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/habit_icon.dart';

class StatsView extends GetView<StatsController> {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.stats.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.habits.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.insights,
            message: AppStrings.noStatsYet.tr,
            subtitle: AppStrings.noStatsSubtitle.tr,
          );
        }

        final colors = context.appColors;

        return RefreshIndicator(
          onRefresh: controller.loadStats,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              80,
            ),
            children: [
              _WeekHeader(controller: controller),
              const SizedBox(height: AppSpacing.md),
              _OverallProgressCard(
                rate: controller.overallRate,
                colors: colors,
              ),
              const SizedBox(height: AppSpacing.md),
              _XpPanel(),
              const SizedBox(height: AppSpacing.md),
              if (controller.bestHabit != null) ...[
                _BestWorstCard(
                  icon: Icons.star_rounded,
                  title: AppStrings.bestHabit.tr,
                  stat: controller.bestHabit!,
                  colors: colors,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              if (controller.worstHabit != null) ...[
                _BestWorstCard(
                  icon: Icons.trending_up,
                  title: AppStrings.focusArea.tr,
                  stat: controller.worstHabit!,
                  colors: colors,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              _SectionTitle(title: AppStrings.thisWeek.tr),
              const SizedBox(height: AppSpacing.sm),
              ...controller.habitStats.map((stat) => _HabitStatRow(
                    stat: stat,
                    colors: colors,
                  )),
            ],
          ),
        );
      }),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  final StatsController controller;

  const _WeekHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Text(
          '${AppDateUtils.formatGregorian(controller.weekStart.value)} - '
          '${AppDateUtils.formatGregorian(controller.weekEnd.value)}',
          style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.refresh, size: 20),
          onPressed: controller.loadStats,
          tooltip: AppStrings.refresh.tr,
        ),
      ],
    );
  }
}

class _OverallProgressCard extends StatelessWidget {
  final double rate;
  final AppColors colors;

  const _OverallProgressCard({required this.rate, required this.colors});

  @override
  Widget build(BuildContext context) {
    final percentage = (rate * 100).round();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.accent, colors.accentDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.weeklyCompletion.tr,
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: rate,
                      strokeWidth: 7,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  AppStrings.lastSevenDays.tr,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BestWorstCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final HabitWeekStat stat;
  final AppColors colors;

  const _BestWorstCard({
    required this.icon,
    required this.title,
    required this.stat,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (stat.rate * 100).round();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.gold, size: 28),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stat.habit.name,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$percentage%',
            style: AppTextStyles.streakNumber.copyWith(
              color: colors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: context.appColors.textPrimary,
      ),
    );
  }
}

class _HabitStatRow extends StatelessWidget {
  final HabitWeekStat stat;
  final AppColors colors;

  const _HabitStatRow({required this.stat, required this.colors});

  @override
  Widget build(BuildContext context) {
    final percentage = (stat.rate * 100).round();
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              habitIconData(stat.habit.icon),
              size: 18,
              color: colors.accent,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.habit.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: stat.rate,
                    minHeight: 6,
                    backgroundColor: colors.border.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 42,
            child: Text(
              '$percentage%',
              textAlign: TextAlign.end,
              style: AppTextStyles.labelMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _XpPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final xp = Get.find<XpController>();
    final colors = context.appColors;
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_graph_rounded, color: colors.accent, size: 24),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  AppStrings.xp.tr,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${AppStrings.level.tr} ${xp.level.value}',
                  style: AppTextStyles.labelLarge.copyWith(color: colors.accent),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _XpStat(label: AppStrings.totalXp.tr, value: '${xp.totalXp.value}'),
                Container(width: 1, height: 36, color: colors.border),
                _XpStat(label: AppStrings.todayXp.tr, value: '${xp.todayXpValue.value}'),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: xp.levelProgress.value,
                minHeight: 8,
                backgroundColor: colors.border.withValues(alpha: 0.4),
                valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
              ),
            ),
            if (xp.xpLogs.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                AppStrings.xpHistory.tr,
                style: AppTextStyles.labelLarge.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              ...xp.xpLogs.take(7).map((log) => _XpHistoryRow(log: log)),
            ],
          ],
        ),
      );
    });
  }
}

class _XpStat extends StatelessWidget {
  final String label;
  final String value;

  const _XpStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.streakNumber.copyWith(color: colors.accent),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}

class _XpHistoryRow extends StatelessWidget {
  final Map<String, dynamic> log;

  const _XpHistoryRow({required this.log});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final date = DateTime.tryParse(log['date'] as String? ?? '');
    final xpValue = (log['xp'] as num?)?.toInt() ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              date != null
                  ? AppDateUtils.formatGregorian(date)
                  : '—',
              style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
            ),
          ),
          Text(
            '+$xpValue ${AppStrings.xp.tr}',
            style: AppTextStyles.labelMedium.copyWith(
              color: colors.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
