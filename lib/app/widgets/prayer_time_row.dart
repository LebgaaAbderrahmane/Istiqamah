import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../l10n/locale_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

class PrayerTimeRow extends StatelessWidget {
  final Map<String, String> times;

  const PrayerTimeRow({super.key, required this.times});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final prayerOrder = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final nameMap = {
      'Fajr': AppStrings.fajr.tr,
      'Sunrise': AppStrings.sunrise.tr,
      'Dhuhr': AppStrings.dhuhr.tr,
      'Asr': AppStrings.asr.tr,
      'Maghrib': AppStrings.maghrib.tr,
      'Isha': AppStrings.isha.tr,
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: colors.accent.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: prayerOrder.map((name) {
          final time = times[name];
          final isSunrise = name == 'Sunrise';
          return Expanded(
            child: _PrayerTimeItem(
              name: nameMap[name] ?? name,
              time: time ?? '--:--',
              isMuted: isSunrise,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PrayerTimeItem extends StatelessWidget {
  final String name;
  final String time;
  final bool isMuted;

  const _PrayerTimeItem({
    required this.name,
    required this.time,
    this.isMuted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelSmall.copyWith(
            color: isMuted ? colors.textHint : colors.accent,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          time.substring(0, 5),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: isMuted ? colors.textHint : colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
