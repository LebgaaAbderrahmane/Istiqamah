import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/habit_controller.dart';
import '../controllers/rawatib_controller.dart';
import '../data/models/habit_model.dart';
import '../l10n/locale_strings.dart';
import '../logic/rawatib_config.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class PrayerCard extends StatelessWidget {
  final HabitModel habit;

  const PrayerCard({super.key, required this.habit});

  void _togglePrayer(
    HabitController controller,
    RawatibController rawController,
    bool isCompleted,
  ) {
    controller.toggleHabit(habit.id);
    if (isCompleted) {
      rawController.resetRawatibForPrayer(habit.name.toLowerCase());
    }
  }

  String _localizedName() {
    switch (habit.name.toLowerCase()) {
      case 'fajr':
        return AppStrings.fajr.tr;
      case 'dhuhr':
        return AppStrings.dhuhr.tr;
      case 'asr':
        return AppStrings.asr.tr;
      case 'maghrib':
        return AppStrings.maghrib.tr;
      case 'isha':
        return AppStrings.isha.tr;
      default:
        return habit.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HabitController>();
    final rawController = Get.find<RawatibController>();
    final prayerKey = habit.name.toLowerCase();
    final colors = context.appColors;
    final raws = RawatibConfig.rawatibFor(prayerKey);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 4,
      ),
      clipBehavior: Clip.antiAlias,
      child: Obx(() {
        final isCompleted = controller.isHabitCompletedToday(habit.id);
        return Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  alignment: AlignmentDirectional.bottomEnd,
                  child: Icon(
                    Icons.mosque_rounded,
                    size: 90,
                    color: colors.accent.withValues(alpha: 0.04),
                  ),
                ),
              ),
            ),
            if (isCompleted)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: colors.accent.withValues(alpha: 0.06),
                  ),
                ),
              ),
            InkWell(
              onTap: () =>
                  _togglePrayer(controller, rawController, isCompleted),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _TrailingCheck(
                          onToggle: () => _togglePrayer(
                            controller,
                            rawController,
                            isCompleted,
                          ),
                          isCompleted: isCompleted,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _localizedName(),
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: isCompleted
                                      ? colors.textHint
                                      : colors.textPrimary,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              Text(
                                AppStrings.obligatoryPrayer.tr,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: colors.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (raws.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _RawatibTiles(
                        prayer: prayerKey,
                        raws: raws,
                        rawController: rawController,
                        colors: colors,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _TrailingCheck extends StatelessWidget {
  final VoidCallback onToggle;
  final bool isCompleted;

  const _TrailingCheck({required this.onToggle, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          key: ValueKey(isCompleted),
          color: isCompleted ? colors.accent : colors.border,
          size: 28,
        ),
      ),
    );
  }
}

class _RawatibTiles extends StatelessWidget {
  final String prayer;
  final List<RawatibInfo> raws;
  final RawatibController rawController;
  final AppColors colors;

  const _RawatibTiles({
    required this.prayer,
    required this.raws,
    required this.rawController,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final chips = raws.map((info) {
        return _RawatibChip(
          label: RawatibConfig.slotLabel(info.slot, prayer),
          done: rawController.isDone(prayer, info.slot),
          onToggle: () => rawController.toggleRawatib(prayer, info.slot),
          colors: colors,
        );
      }).toList();
      return Row(
        children: [
          for (var i = 0; i < chips.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.xs),
            Expanded(child: chips[i]),
          ],
        ],
      );
    });
  }
}

class _RawatibChip extends StatelessWidget {
  final String label;
  final bool done;
  final VoidCallback onToggle;
  final AppColors colors;

  const _RawatibChip({
    required this.label,
    required this.done,
    required this.onToggle,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: done
              ? colors.gold.withValues(alpha: 0.15)
              : colors.border.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: done ? colors.gold : colors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSmall.copyWith(
                  color: done ? colors.gold : colors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              done ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16,
              color: done ? colors.gold : colors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}
