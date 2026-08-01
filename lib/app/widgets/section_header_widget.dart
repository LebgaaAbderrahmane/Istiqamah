import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class SectionHeaderWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? counterText;

  const SectionHeaderWidget({
    super.key,
    required this.icon,
    required this.title,
    this.counterText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.accent),
          const SizedBox(width: AppSpacing.xs),
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const Spacer(),
          if (counterText != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                counterText!,
                style: AppTextStyles.labelSmall.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
